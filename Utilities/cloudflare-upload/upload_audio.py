"""Upload a deck's prepared AAC audio to Cloudflare R2 and verify every object."""

from __future__ import annotations

import argparse
import hashlib
import re
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

import boto3
from botocore.config import Config
from botocore.exceptions import ClientError

ROOT = Path(__file__).resolve().parents[2]
ENV_FILE = ROOT / "Utilities" / "cloudflare.local.env"
OUTPUT_DIR = ROOT / "Utilities" / "tts" / "output"


def load_settings() -> dict[str, str]:
    values = {}
    for line in ENV_FILE.read_text(encoding="utf-8").splitlines():
        if "=" in line and not line.lstrip().startswith("#"):
            key, value = line.split("=", 1)
            values[key.strip()] = value.strip().strip('"\'')
    required = ("CLOUDFLARE_ACCOUNT_ID", "R2_BUCKET", "R2_ACCESS_KEY_ID", "R2_SECRET_ACCESS_KEY")
    missing = [key for key in required if not values.get(key)]
    if missing:
        raise ValueError(f"Missing settings: {', '.join(missing)}")
    return values


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def audio_files(directory: Path) -> list[tuple[Path, str]]:
    files = sorted(directory.glob("*/*.m4a"))
    if not files:
        raise ValueError(f"No M4A audio files found under {directory}")
    for path in files:
        if path.parent.name not in {"words", "sentences"} or not re.fullmatch(r"\d+\.m4a", path.name):
            raise ValueError(f"Unexpected audio path: {path.relative_to(directory)}")
    return [(path, sha256_file(path)) for path in files]


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--deck-id", required=True, help="Deck ID used as the R2 key prefix")
    parser.add_argument("--voice", default="af_heart", help="TTS voice directory")
    parser.add_argument("--audio-dir", type=Path, help="Directory containing words/ and sentences/; defaults to output/<deck-id>/<voice>")
    parser.add_argument("--execute", action="store_true", help="Upload missing or changed files; without it, only show a dry run")
    parser.add_argument("--workers", type=int, default=16)
    args = parser.parse_args()
    if not re.fullmatch(r"[a-z0-9_]+", args.deck_id):
        parser.error("--deck-id must contain only lowercase letters, digits, and underscores")
    if not re.fullmatch(r"[a-zA-Z0-9_]+", args.voice):
        parser.error("--voice must contain only letters, digits, and underscores")
    if not 1 <= args.workers <= 64:
        parser.error("--workers must be between 1 and 64")

    audio_dir = args.audio_dir or OUTPUT_DIR / args.deck_id / args.voice
    files = audio_files(audio_dir)
    settings = load_settings()
    endpoint = settings.get("R2_ENDPOINT") or f"https://{settings['CLOUDFLARE_ACCOUNT_ID']}.r2.cloudflarestorage.com"
    client = boto3.client(
        "s3",
        endpoint_url=endpoint,
        aws_access_key_id=settings["R2_ACCESS_KEY_ID"],
        aws_secret_access_key=settings["R2_SECRET_ACCESS_KEY"],
        region_name="auto",
        config=Config(max_pool_connections=args.workers, retries={"max_attempts": 8, "mode": "adaptive"}),
    )
    bucket = settings["R2_BUCKET"]
    targets = {
        f"{args.deck_id}/{path.relative_to(audio_dir).as_posix()}": (path, digest)
        for path, digest in files
    }
    print(f"Deck: {args.deck_id}; audio files: {len(files)}; bytes: {sum(path.stat().st_size for path, _ in files)}")
    print(f"R2 destination: s3://{bucket}/{args.deck_id}/")

    existing_keys = {
        item["Key"]
        for page in client.get_paginator("list_objects_v2").paginate(Bucket=bucket, Prefix=f"{args.deck_id}/")
        for item in page.get("Contents", [])
    }

    def inspect(key_and_file: tuple[str, tuple[Path, str]]) -> tuple[str, Path, str, bool]:
        key, (path, digest) = key_and_file
        if key not in existing_keys:
            return key, path, digest, False
        try:
            head = client.head_object(Bucket=bucket, Key=key)
        except ClientError as error:
            if error.response.get("ResponseMetadata", {}).get("HTTPStatusCode") == 404:
                return key, path, digest, False
            raise
        unchanged = head["ContentLength"] == path.stat().st_size and head.get("Metadata", {}).get("sha256") == digest
        return key, path, digest, unchanged

    existing = {}
    with ThreadPoolExecutor(max_workers=args.workers) as executor:
        for result in executor.map(inspect, targets.items()):
            existing[result[0]] = result
    pending = [item for item in existing.values() if not item[3]]
    print(f"Unchanged: {len(files) - len(pending)}; to upload: {len(pending)}")
    for key, path, _, unchanged in list(existing.values())[:5]:
        print(f"  {'unchanged' if unchanged else 'upload'} {path.name} -> {key}")
    if not args.execute:
        print("Dry run only. Pass --execute to upload and verify.")
        return

    def upload(item: tuple[str, Path, str, bool]) -> str:
        key, path, digest, unchanged = item
        if not unchanged:
            client.upload_file(
                str(path), bucket, key,
                ExtraArgs={"ContentType": "audio/mp4", "CacheControl": "public, max-age=31536000, immutable", "Metadata": {"sha256": digest}},
            )
        head = client.head_object(Bucket=bucket, Key=key)
        if head["ContentLength"] != path.stat().st_size or head.get("Metadata", {}).get("sha256") != digest:
            raise RuntimeError(f"Uploaded object verification failed: {key}")
        return key

    errors = []
    completed = 0
    with ThreadPoolExecutor(max_workers=args.workers) as executor:
        futures = {executor.submit(upload, item): item[0] for item in existing.values()}
        for future in as_completed(futures):
            try:
                future.result()
                completed += 1
                if completed % 500 == 0:
                    print(f"Verified: {completed}/{len(files)}", flush=True)
            except Exception as error:
                errors.append((futures[future], str(error)))
    if errors:
        for key, error in errors[:10]:
            print(f"ERROR {key}: {error}")
        raise RuntimeError(f"{len(errors)} objects failed; rerun after resolving the errors")
    final_keys = {
        item["Key"]
        for page in client.get_paginator("list_objects_v2").paginate(Bucket=bucket, Prefix=f"{args.deck_id}/")
        for item in page.get("Contents", [])
    }
    missing = set(targets) - final_keys
    if missing:
        raise RuntimeError(f"{len(missing)} uploaded objects are missing from the deck prefix")
    print(f"Upload complete: {completed} objects verified; {len(final_keys)} keys present under {args.deck_id}/")


if __name__ == "__main__":
    main()

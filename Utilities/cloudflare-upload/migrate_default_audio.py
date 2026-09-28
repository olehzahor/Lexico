"""Move legacy root audio keys into default/, verifying each copy before deletion."""

from __future__ import annotations

import argparse
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

import boto3
from botocore.config import Config

ENV_FILE = Path(__file__).resolve().parents[1] / "cloudflare.local.env"
PREFIXES = ("words/", "sentences/")


def load_settings() -> dict[str, str]:
    values = {}
    for line in ENV_FILE.read_text().splitlines():
        if "=" in line and not line.lstrip().startswith("#"):
            key, value = line.split("=", 1)
            values[key.strip()] = value.strip().strip('"\'')
    required = ("CLOUDFLARE_ACCOUNT_ID", "R2_BUCKET", "R2_ACCESS_KEY_ID", "R2_SECRET_ACCESS_KEY")
    missing = [key for key in required if not values.get(key)]
    if missing:
        raise ValueError(f"Missing settings: {', '.join(missing)}")
    return values


def list_objects(client, bucket: str, prefix: str) -> dict[str, dict]:
    return {
        item["Key"]: item
        for page in client.get_paginator("list_objects_v2").paginate(Bucket=bucket, Prefix=prefix)
        for item in page.get("Contents", [])
    }


def same_object(source: dict, target: dict) -> bool:
    return source["ContentLength"] == target["ContentLength"] and source["ETag"] == target["ETag"]


def migrate_one(client, bucket: str, source: dict, existing_targets: set[str]) -> str:
    key = source["Key"]
    target_key = "default/" + key
    source_head = client.head_object(Bucket=bucket, Key=key)
    if target_key not in existing_targets:
        client.copy_object(
            Bucket=bucket,
            Key=target_key,
            CopySource={"Bucket": bucket, "Key": key},
            CopySourceIfMatch=source_head["ETag"].strip('"'),
        )
    target_head = client.head_object(Bucket=bucket, Key=target_key)
    if not same_object(source_head, target_head):
        raise RuntimeError(f"Copied object differs: {key}")
    latest_source = client.head_object(Bucket=bucket, Key=key)
    if not same_object(source_head, latest_source):
        raise RuntimeError(f"Source changed during migration: {key}")
    client.delete_object(Bucket=bucket, Key=key)
    return target_key


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--execute", action="store_true", help="Copy, verify, and delete legacy keys")
    parser.add_argument("--workers", type=int, default=16)
    args = parser.parse_args()
    if not 1 <= args.workers <= 128:
        parser.error("--workers must be between 1 and 128")

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
    sources = [item for prefix in PREFIXES for item in list_objects(client, bucket, prefix).values()]
    targets = {key for prefix in PREFIXES for key in list_objects(client, bucket, "default/" + prefix)}
    print(f"Legacy objects: {len(sources)}; bytes: {sum(item['Size'] for item in sources)}")
    print(f"Existing default objects: {len(targets)}")
    for item in sources[:5]:
        print(f"  {item['Key']} -> default/{item['Key']}")
    if not args.execute:
        print("Dry run only. Pass --execute to migrate.")
        return

    completed = 0
    errors = []
    with ThreadPoolExecutor(max_workers=args.workers) as executor:
        futures = {executor.submit(migrate_one, client, bucket, item, targets): item["Key"] for item in sources}
        for future in as_completed(futures):
            try:
                future.result()
                completed += 1
                if completed % 500 == 0:
                    print(f"Moved and verified: {completed}/{len(sources)}", flush=True)
            except Exception as error:
                errors.append((futures[future], str(error)))
    if errors:
        for key, error in errors[:10]:
            print(f"ERROR {key}: {error}")
        raise RuntimeError(f"{len(errors)} objects failed; rerun after resolving the errors")

    remaining = sum(len(list_objects(client, bucket, prefix)) for prefix in PREFIXES)
    if remaining:
        raise RuntimeError(f"{remaining} legacy objects remain")
    final_targets = {key for prefix in PREFIXES for key in list_objects(client, bucket, "default/" + prefix)}
    expected = {"default/" + item["Key"] for item in sources}
    missing = expected - final_targets
    if missing:
        raise RuntimeError(f"{len(missing)} migrated objects missing from default/")
    print(f"Migration complete: {completed} moved; {remaining} legacy objects remain; {len(final_targets)} default objects present")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Generate English word and sentence speech for one bundled card set."""

from __future__ import annotations

import argparse
import json
import re
import shutil
import subprocess
import sys
import tempfile
import urllib.request
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
CARDS_DIR = ROOT / "Lexico" / "Resources" / "Cards"
OUTPUT_DIR = Path(__file__).resolve().parent / "output"
MODEL = "Kokoro-82M-v1.0-ONNX"
VOICE = "af_heart"
SAMPLE_RATE = 24_000
MODEL_DIR = Path(__file__).resolve().parent / "models"
MODEL_BASE_URL = "https://github.com/thewh1teagle/kokoro-onnx/releases/download/model-files-v1.1"
MODEL_FILES = ("kokoro-v1.0.onnx", "voices-v1.0.bin")


def load_set(path: Path) -> list[dict]:
    with path.open(encoding="utf-8") as handle:
        document = json.load(handle)
    words = document.get("words")
    if not isinstance(words, list):
        raise ValueError(f"{path.name}: expected a 'words' array")
    return words


def load_deck_id(path: Path) -> str:
    with path.open(encoding="utf-8") as handle:
        document = json.load(handle)
    deck_id = document.get("metadata", {}).get("deck", {}).get("id")
    if not isinstance(deck_id, str) or not re.fullmatch(r"[a-z0-9_]+", deck_id):
        raise ValueError(f"{path.name}: expected a valid metadata.deck.id")
    return deck_id


def discover_sets(cards_dir: Path = CARDS_DIR) -> list[tuple[Path, list[dict]]]:
    sets = []
    for path in sorted(cards_dir.glob("*.json")):
        try:
            sets.append((path, load_set(path)))
        except (OSError, ValueError, json.JSONDecodeError) as error:
            print(f"Skipping {path.name}: {error}", file=sys.stderr)
    return sets


def choose_set(sets: list[tuple[Path, list[dict]]]) -> tuple[Path, list[dict]]:
    if not sets:
        raise ValueError(f"No card sets found in {CARDS_DIR}")
    print("Available card sets:")
    for index, (path, words) in enumerate(sets, 1):
        sentences = sum(len(card.get("sentences", [])) for card in words)
        print(f"  {index}. {path.name} — {len(words)} words, {sentences} sentences")
    while True:
        answer = input("Choose a set number (Enter to cancel): ").strip()
        if not answer:
            raise KeyboardInterrupt
        if answer.isdigit() and 1 <= int(answer) <= len(sets):
            return sets[int(answer) - 1]
        print("Please enter a number from the list.")


def collect_items(words: list[dict]) -> list[dict]:
    items = []
    seen_keys = set()
    for card in words:
        card_id = card["id"]
        word = card["word"].strip()
        if not word:
            raise ValueError(f"Card {card_id} has an empty word")
        items.append({"kind": "words", "id": card_id, "card_id": card_id, "text": word})
        for sentence in card.get("sentences", []):
            english = [entry["text"].strip() for entry in sentence["sentences"] if entry.get("language") == "en"]
            if len(english) != 1 or not english[0]:
                raise ValueError(f"Sentence {sentence['id']} on card {card_id} needs one English text")
            items.append({"kind": "sentences", "id": sentence["id"], "card_id": card_id, "text": english[0]})
    for item in items:
        key = (item["kind"], item["id"])
        if key in seen_keys:
            raise ValueError(f"Duplicate {item['kind']} ID: {item['id']}")
        seen_keys.add(key)
    return items


def object_path(item: dict) -> Path:
    item_id = int(item["id"])
    filename = f"{item_id:03d}.m4a" if item_id < 100 else f"{item_id}.m4a"
    return Path(item["kind"]) / filename


def download_models() -> tuple[Path, Path]:
    MODEL_DIR.mkdir(parents=True, exist_ok=True)
    for filename in MODEL_FILES:
        target = MODEL_DIR / filename
        if target.is_file() and target.stat().st_size > 0:
            continue
        print(f"Downloading {filename}...", flush=True)
        temporary = target.with_suffix(target.suffix + ".part")
        try:
            urllib.request.urlretrieve(f"{MODEL_BASE_URL}/{filename}", temporary)
            temporary.replace(target)
        finally:
            temporary.unlink(missing_ok=True)
    return tuple(MODEL_DIR / name for name in MODEL_FILES)


def synthesize(model, text: str, voice: str, target: Path) -> None:
    import soundfile as sf

    samples, sample_rate = model.create(text, voice=voice, speed=1.0, lang="en-us")
    if len(samples) == 0:
        raise RuntimeError(f"The model produced no audio for {text!r}")
    if sample_rate != SAMPLE_RATE:
        raise RuntimeError(f"Unexpected sample rate: {sample_rate}")
    target.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as temp_dir:
        wav_path = Path(temp_dir) / "speech.wav"
        m4a_path = Path(temp_dir) / "speech.m4a"
        sf.write(wav_path, samples, SAMPLE_RATE, subtype="PCM_16")
        subprocess.run(
            ["ffmpeg", "-hide_banner", "-loglevel", "error", "-y", "-i", str(wav_path),
             "-map_metadata", "-1", "-vn", "-ac", "1", "-ar", str(SAMPLE_RATE),
             "-codec:a", "aac", "-b:a", "48k", "-movflags", "+faststart", str(m4a_path)],
            check=True,
        )
        shutil.move(m4a_path, target)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--set", dest="set_name", help="JSON filename; omit for an interactive menu")
    parser.add_argument("--limit", type=int, help="Generate only the first N cards for a listening sample")
    parser.add_argument("--voice", default=VOICE, help=f"Kokoro voice (default: {VOICE})")
    parser.add_argument("--dry-run", action="store_true", help="Show planned output without loading the model")
    args = parser.parse_args()
    if args.limit is not None and args.limit < 1:
        parser.error("--limit must be positive")
    if not re.fullmatch(r"[a-zA-Z0-9_]+", args.voice):
        parser.error("--voice must contain only letters, digits, and underscores")

    sets = discover_sets()
    if args.set_name:
        matches = [(path, words) for path, words in sets if path.name == args.set_name]
        if not matches:
            parser.error(f"Unknown card set: {args.set_name}")
        path, words = matches[0]
    else:
        path, words = choose_set(sets)

    selected_words = words[:args.limit] if args.limit else words
    items = collect_items(selected_words)
    deck_id = load_deck_id(path)
    destination = OUTPUT_DIR / deck_id / args.voice
    manifest_path = destination / "manifest.json"
    previous_manifest = {}
    if manifest_path.is_file():
        try:
            previous_manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError):
            previous_manifest = {}
    previous_items = {
        (item.get("kind"), item.get("id")): item
        for item in previous_manifest.get("items", [])
        if isinstance(item, dict)
    }
    manifest_matches = previous_manifest.get("model") == MODEL and previous_manifest.get("voice") == args.voice
    pending = []
    for item in items:
        target = destination / object_path(item)
        previous = previous_items.get((item["kind"], item["id"]), {})
        if (
            not target.is_file()
            or target.stat().st_size == 0
            or not manifest_matches
            or previous.get("text") != item["text"]
        ):
            pending.append(item)
    print(f"Selected {path.name}: {len(selected_words)} words, {len(items) - len(selected_words)} sentences")
    print(f"Output: {destination} | to generate: {len(pending)} | existing: {len(items) - len(pending)}")
    if args.dry_run:
        return 0
    if pending and not shutil.which("ffmpeg"):
        parser.error("ffmpeg is required to encode AAC in M4A files")
    if pending and not shutil.which("espeak-ng"):
        parser.error("espeak-ng is required for English pronunciation (macOS: brew install espeak-ng)")
    if pending:
        try:
            from kokoro_onnx import Kokoro
        except ImportError as error:
            parser.error(f"Install dependencies with python -m pip install -r requirements.txt ({error})")

        model_path, voices_path = download_models()
        model = Kokoro(str(model_path), str(voices_path))
        for index, item in enumerate(pending, 1):
            target = destination / object_path(item)
            spoken_text = item["text"] + "." if item["kind"] == "words" else item["text"]
            print(f"[{index}/{len(pending)}] {item['kind']} {item['id']}: {item['text']}", flush=True)
            synthesize(model, spoken_text, args.voice, target)

    manifest = {
        "card_set": path.name,
        "deck_id": deck_id,
        "model": MODEL,
        "voice": args.voice,
        "format": "AAC in M4A container, mono, 24 kHz, 48 kb/s",
        "items": [
            {**item, "file": str(object_path(item))}
            for item in items
        ],
    }
    destination.mkdir(parents=True, exist_ok=True)
    (destination / "manifest.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Done. Manifest: {destination / 'manifest.json'}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (KeyboardInterrupt, EOFError):
        print("\nCancelled.")
        raise SystemExit(130)
    except (KeyError, TypeError, ValueError) as error:
        print(f"Invalid card set: {error}", file=sys.stderr)
        raise SystemExit(1)

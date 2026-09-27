import json
import tempfile
import unittest
from pathlib import Path

from generate import collect_items, discover_sets, object_path


class GeneratorTests(unittest.TestCase):
    def test_discovers_card_sets_and_builds_english_items(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "sample_en.json"
            path.write_text(json.dumps({"words": [{
                "id": 7,
                "word": "bank",
                "sentences": [{"id": 701, "sentences": [
                    {"language": "en", "text": "She sat by the bank."},
                    {"language": "ru", "text": "Она сидела на берегу."},
                ]}],
            }]}))
            sets = discover_sets(Path(directory))
            self.assertEqual([entry[0].name for entry in sets], ["sample_en.json"])
            self.assertEqual(collect_items(sets[0][1]), [
                {"kind": "words", "id": 7, "card_id": 7, "text": "bank"},
                {"kind": "sentences", "id": 701, "card_id": 7, "text": "She sat by the bank."},
            ])

    def test_rejects_duplicate_ids_and_missing_english(self):
        cards = [{"id": 1, "word": "one", "sentences": [{"id": 101, "sentences": [
            {"language": "ru", "text": "один"},
        ]}]}]
        with self.assertRaisesRegex(ValueError, "needs one English text"):
            collect_items(cards)
        with self.assertRaisesRegex(ValueError, "Duplicate words ID"):
            collect_items([{"id": 1, "word": "one"}, {"id": 1, "word": "two"}])

    def test_output_key_changes_when_text_or_voice_changes(self):
        item = {"kind": "words", "id": 1, "text": "read"}
        first = object_path(item, "af_heart")
        self.assertEqual(first.parent, Path("words"))
        self.assertNotEqual(first, object_path({**item, "text": "readable"}, "af_heart"))
        self.assertNotEqual(first, object_path(item, "am_adam"))


if __name__ == "__main__":
    unittest.main()

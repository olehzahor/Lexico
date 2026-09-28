# Generate a card deck with Codex

Use Codex in the Lexico repository to turn an English word list into one complete deck JSON file. This is a file-writing task: Codex should keep working until the file exists and has been checked. The word list is supplied by the user as a UTF-8 `.txt` file, one word or phrase per line. The reference is `Lexico/Resources/Cards/example_cards_en.json`.

## Resume Alternative: Unsure Words on another computer

The handoff archive contains a small Lexico directory tree with this README, `AGENTS.md`, `unsure-words.txt`, the example deck, and all saved drafts in `work/unsure_words/`. Extract it into an **empty directory** and open that directory as the Codex workspace. The archive is sufficient to continue generation and to assemble the finished JSON; it does not contain the full app or an Xcode project. If a full Lexico checkout is available, copy the archived files into their matching paths there instead.

Current checkpoint: `work/unsure_words/manifest.json` lists 40 complete batches covering source lines **1–215** of 2514. They contain 286 cards and 2860 English–Russian sentence pairs. The next unprocessed source line is **216, `charity`**. The deck ID is `unsure_words`; its English name is `Alternative: Unsure Words` and its Russian name is `Альтернативная: незнакомые слова`. Drafts are first-pass work and still need linguistic review. The separate `work/test*` experiments are not part of this checkpoint.

From the extracted root, check the transfer before continuing:

```sh
python3 Utilities/card-deck-generation/work/unsure_words/verify_progress.py
```

Select the **Luna** model in Codex and use this request:

```text
Read AGENTS.md, Utilities/card-deck-generation/README.md,
Utilities/card-deck-generation/work/unsure_words/manifest.json,
Utilities/card-deck-generation/work/unsure_words/assemble.py, and
Lexico/Resources/Cards/example_cards_en.json.

Continue the Alternative: Unsure Words deck from unsure-words.txt. First run
verify_progress.py; use its reported next source line rather than assuming this
README is current. Keep the existing draft format and all README content rules,
including exactly 10 English sentences and 10 Russian translations per card.
Generate about five source entries per new batch, save each batch as the next
batch-NNNN.json in work/unsure_words/, and update manifest.json only after the
batch file has passed checks. Reuse suitable existing category keys where possible;
add any new key with en and ru names to CATEGORY_NAMES in assemble.py.
Continue autonomously through the source list, checking saved progress before
each resumed session. Do not assemble or present a partial deck as complete.
After all unique entries are covered, run assemble.py and the final checks below.
```

Each draft has `source_lines: [first, last]` and an `entries` array. Each card entry has `word`, `part_of_speech`, `level`, `category`, `translations` (Russian strings), and `examples` (ten `[English, Russian]` pairs). Use `source_entry` when the source spelling differs from the dictionary headword, as with `cans` → `can`. The manifest stores the same line range as `lines: "first-last"` and names the draft file. Do not renumber cards or sentences in drafts; `assemble.py` assigns IDs after all source entries are complete. Its output path is `Lexico/Resources/Cards/unsure_words_en.json` relative to the extracted root.

## Start a run

1. Put the source TXT somewhere Codex can read. Keep the original file unchanged.
2. Choose a stable deck ID (lowercase snake case), English and Russian deck names, and output filename `<deck_id>_en.json`. Existing IDs are `default` and `alt_cards`; do not reuse them for a new deck. `example_cards_en.json` is a small reference, not an app deck.
3. Open Codex at the repository root and send the request below, filling in all four placeholders. For a long list, let Codex write intermediate drafts under `Utilities/card-deck-generation/work/<deck_id>/` and continue in later turns if needed. Only the validated final JSON belongs in `Lexico/Resources/Cards/`.

```text
Read Utilities/card-deck-generation/README.md and Lexico/Resources/Cards/example_cards_en.json. Generate a complete English card deck from <SOURCE_TXT> and write it to Lexico/Resources/Cards/<DECK_ID>_en.json. Use deck ID <DECK_ID>, English name <ENGLISH_NAME>, and Russian name <RUSSIAN_NAME>.

Follow every rule in the README. Work through the entire input in its original order. You may save intermediate drafts and resume, but do not end with a plan, a sample, or a partial final file. Run the structural checks described in the README and review linguistic quality. Report the final path, counts, and any limitations. Do not build the app unless I ask.
```

## Deck content rules

- Read every nonempty line in order. Trim surrounding whitespace. Count all nonempty lines for `source_counts`; skip identical duplicate entries after their first appearance and report how many were skipped. If an entry is ambiguous or malformed, make a reasonable lexical interpretation and record any unresolved cases in the final report.
- Preserve the source word or phrase in `word` in dictionary form. For a word with several common parts of speech, create a separate card for each common use, placed consecutively. Do not invent rare uses to increase card count.
- `part_of_speech` is one of `n`, `v`, `adj`, `adv`, `pron`, `det`, `prep`, `conj`, `exclam`. Use a suitable CEFR `level` from `A1` through `C2`. Each card has `language: "en"`.
- Give each card short, accurate Russian translations for its specific part of speech. Every translation is `{"text": "...", "language": "ru"}`. Do not mix meanings from another part of speech.
- Design categories for the entire source list. Group by clear meaning or function, taking part of speech into account. Category keys use `card.category.<english_snake_case_slug>`. Every used key has nonempty natural `en` and `ru` names in the root `categories` object. Do not add unused categories, one generic category for everything, or needless singleton categories. The category map belongs to this deck JSON; do not modify the app's localization catalog.
- Give each card exactly ten distinct, natural English example sentences that use the word in that card's part of speech. Inflected forms are fine. Give an accurate Russian translation of each whole sentence. Every `SentenceSet` has `id` and `sentences` with exactly two entries, English first and Russian second. Avoid repetitive sentence templates and fabricated or awkward meanings.
- Card IDs are consecutive integers starting at 1 in input order, including adjacent cards for different parts of speech. For card ID `c`, sentence IDs are `c * 100 + 1` through `c * 100 + 10`. IDs are local to this deck.

## JSON shape and metadata

The root object has exactly `metadata`, `categories`, and `words`. Follow the reference file's card structure. `metadata` must include:

```json
{
  "deck": {
    "id": "<DECK_ID>",
    "language": "en",
    "names": {"en": "<ENGLISH_NAME>", "ru": "<RUSSIAN_NAME>"}
  },
  "source_files": ["<SOURCE_TXT_BASENAME>"],
  "source_counts": {"<SOURCE_TXT_BASENAME>": 0},
  "levels_included": ["A1"],
  "total_words": 0,
  "updated_at_utc": "2026-09-27T00:00:00Z",
  "schema_version": "2"
}
```

Replace the example counts, levels, and timestamp with real values. `source_counts` counts nonempty source lines before deduplication or part-of-speech expansion. `total_words` counts card objects. `levels_included` lists exactly the levels used. Set `updated_at_utc` to the actual creation time in ISO 8601 UTC. Do not copy source facts or card content from the example unless they are independently appropriate for the input.

## Complete large lists

A large deck may exceed one response or one context window. Generate in manageable batches and save each batch to disk under `Utilities/card-deck-generation/work/<deck_id>/`. Keep a manifest with the source line range, normalized input entries, generated cards, and completion status. Before resuming, read the manifest and existing drafts; continue at the next unprocessed entry. Do not assume a batch is complete because a previous response said it was. Assemble the final JSON only after every unique input entry has at least one card. Keep final card and sentence IDs assigned in the assembled input order.

Do not fill gaps with placeholder translations or sentences. If generation or review cannot be completed, say exactly what remains and leave the partial work in the work directory; do not present it as a finished deck.

## Validate before reporting completion

Use a script or short Python check against the source TXT and final JSON. At minimum verify:

1. The JSON parses; root keys and required card fields match the reference; deck ID, language, names, source filename, counts, timestamp, and schema version are present and consistent.
2. Every unique nonempty source entry appears in `words` in input order, with one or more consecutive cards; no unexpected word appears. All card IDs equal `1...total_words`.
3. Parts of speech and CEFR levels use the allowed values. `levels_included` is exactly the set used by the cards.
4. Every card has nonempty Russian translations, a defined category with nonempty `en` and `ru` names, and exactly ten sentence sets. There are no unused category keys.
5. Sentence IDs are unique and match `card ID * 100 + 1...10`. Each sentence set contains exactly one nonempty English sentence followed by one nonempty Russian sentence.
6. Sample cards across the file, especially ambiguous words and multiple parts of speech, to check meaning, grammatical use, naturalness, translations, and category choice. Structural checks cannot prove linguistic correctness; review and correct problems found.

Report the input nonempty line count, unique entry count, duplicate count, card count, category count, sentence count, output path, and verification results. If the user asks only for deck generation, do not run an Xcode build.

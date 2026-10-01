# Unsure deck part-of-speech review

The JSON ledger contains one record for every pair of `unsure_words` cards with the same spelling and different parts of speech. Each record includes both card IDs, parts of speech, Russian translations, a decision, and a short rationale.

- `PENDING`: not reviewed yet.
- `KEEP_BOTH`: meanings are distinct enough that neither card is ignored due to this pair.
- `IGNORE_ID`: the pair shares a meaning and the listed `ignored_id` is redundant. In groups with three or more related cards, multiple redundant IDs may be ignored while one canonical card remains available.

The bundled `metadata.deck.preignored_words` is kept in sync with reviewed `IGNORE_ID` decisions only. The ledger has 581 pair decisions in 20 batches (30 pairs per batch, with 11 in the last batch). All pairs are reviewed: 473 decisions identify a redundant card and 108 preserve both cards.

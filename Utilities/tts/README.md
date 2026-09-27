# Audio generation

Generate English audio for card words and example sentences from `Lexico/Resources/Cards/alt_cards_en.json`.

Initial model choice: [Kokoro-82M](https://github.com/hexgrad/kokoro), using one consistent English voice for both words and sentences. Its code and weights are Apache-2.0 licensed. Evaluate pronunciation on a small set before batch generation; single words, homographs, names, and abbreviations need listening checks.

Proposed output: one audio file per unique word and sentence ID, plus a manifest mapping card and sentence IDs to object keys, text, voice, model version, and file hash. Keep generated audio and downloaded model weights outside Git.

This directory is the home for the generator. The model and output format should be confirmed with a short listening sample before the full batch.

# English card audio

`generate.py` lists every JSON card set in `Lexico/Resources/Cards`, asks which one to use, then generates English speech for each word and example sentence with Kokoro-82M through ONNX Runtime (`af_heart`). It writes mono 24 kHz MP3 files at 96 kb/s and a `manifest.json` mapping IDs and text to files. Output and model files stay out of Git.

Use Python 3.12. On macOS, install the audio encoder and phonemizer first: `brew install ffmpeg espeak-ng`. From this directory:

```sh
python3.12 -m venv .venv
.venv/bin/python -m pip install -r requirements.txt
.venv/bin/python generate.py --dry-run
.venv/bin/python generate.py --limit 3
.venv/bin/python generate.py
```

The first real run downloads the ONNX model and voice data. `--limit 3` makes a short listening sample before generating thousands of clips. To choose without the menu, pass `--set cards_en.json` or `--set alt_cards_en.json`. Files go to `output/<set>/<voice>/words/` and `sentences/`; reruns skip clips whose text, voice, and model match an existing file. Changed text or voice gets a new filename and manifest reference.

Listen to the sample, especially short words, homographs, names, and abbreviations. The generator does not infer pronunciation from card context. [Kokoro model weights](https://github.com/hexgrad/kokoro) are Apache-2.0 licensed; the [ONNX runtime wrapper](https://github.com/thewh1teagle/kokoro-onnx) is MIT licensed.

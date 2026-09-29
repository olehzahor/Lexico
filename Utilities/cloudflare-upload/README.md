# Cloudflare R2 upload

`upload_audio.py` uploads generated M4A audio from `Utilities/tts/output/<deck_id>/<voice>/` to the same `<deck_id>/words/<id>.m4a` and `<deck_id>/sentences/<id>.m4a` layout the app requests. It reads credentials from `Utilities/cloudflare.local.env`, defaults to a dry run, skips objects with matching size and SHA-256 metadata, and verifies uploaded hashes and the final key list. It does not upload the local manifest.

Create an R2 API token in the Cloudflare dashboard with **Object Read & Write** permission scoped to the target bucket. Copy its Access Key ID and Secret Access Key into the ignored `Utilities/cloudflare.local.env`; see `Utilities/cloudflare.local.env.example`. Do not reuse the Wrangler OAuth token or put credentials in source files.

The Mower project at `/Users/user/StudioProjects/Mower` uses a Cloudflare Worker and D1 database. Its Wrangler account also has the existing `lexico-audio-storage` R2 bucket. The account ID and bucket name are already set in the ignored local file. The R2 Access Key ID and Secret Access Key still need to be created in the Cloudflare dashboard and copied there; the Mower Wrangler login is not an S3 credential.

## Move existing audio into the default deck

The app now requests `default/words/<id>.m4a` and `default/sentences/<id>.m4a` for the default deck, and the same layout under another deck ID for other decks. Move the legacy root prefixes once, after filling in `Utilities/cloudflare.local.env`:

```sh
python3 -m pip install -r Utilities/cloudflare-upload/requirements.txt
python3 Utilities/cloudflare-upload/migrate_default_audio.py
python3 Utilities/cloudflare-upload/migrate_default_audio.py --execute
```

The first invocation is a dry run. The execute mode copies each object to `default/`, compares size and ETag, confirms the source is unchanged, then deletes the original key. It verifies that the old prefixes are empty and the destinations exist. It can be rerun after an interruption. Existing destination keys are never overwritten.

## Upload a deck

Install the uploader dependency in the Python environment you will use, then run a dry run and execute the upload:

```sh
python3 -m pip install -r Utilities/cloudflare-upload/requirements.txt
python3 Utilities/cloudflare-upload/upload_audio.py --deck-id unsure_words
python3 Utilities/cloudflare-upload/upload_audio.py --deck-id unsure_words --execute
```

The uploader uses `Utilities/tts/output/<deck_id>/af_heart` by default. Pass `--audio-dir` to use another prepared audio directory. Uploads can be resumed safely; matching objects are skipped, and changed files at the same stable ID path are uploaded again.

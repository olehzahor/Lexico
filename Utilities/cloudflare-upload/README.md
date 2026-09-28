# Cloudflare R2 upload

This directory is the home for the audio upload utility. It will read `Utilities/cloudflare.local.env` and upload the generated audio and manifest to an R2 bucket. The utility should support a dry run, skip unchanged objects by hash, and verify object counts and sizes after upload.

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

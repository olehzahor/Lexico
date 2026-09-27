# Cloudflare R2 upload

This directory is the home for the audio upload utility. It will read `cloudflare.local.env` from the repository root and upload the generated audio and manifest to an R2 bucket. The utility should support a dry run, skip unchanged objects by hash, and verify object counts and sizes after upload.

Create an R2 API token in the Cloudflare dashboard with **Object Read & Write** permission scoped to the target bucket. Copy its Access Key ID and Secret Access Key into the ignored `cloudflare.local.env`; see `cloudflare.local.env.example`. Do not reuse the Wrangler OAuth token or put credentials in source files.

The Mower project at `/Users/user/StudioProjects/Mower` uses a Cloudflare Worker and D1 database. Its Wrangler account also has the existing `lexico-audio-storage` R2 bucket. The account ID and bucket name are already set in the ignored local file. The R2 Access Key ID and Secret Access Key still need to be created in the Cloudflare dashboard and copied there; the Mower Wrangler login is not an S3 credential.

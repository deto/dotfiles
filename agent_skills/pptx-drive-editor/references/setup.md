# One-time setup

Do these once per environment. After this, `drive_client(...)` works with no
key file and no per-run login.

## 1. GCP project

```bash
gcloud config set project PROJECT

# Drive API + the impersonation API (the second is the one people forget —
# impersonation fails cryptically without it).
gcloud services enable drive.googleapis.com iamcredentials.googleapis.com

# Deck SA. Do NOT create a key for it.
gcloud iam service-accounts create deck-sa --display-name="Deck editor"

# Let the BASE identity impersonate the deck SA.
#   - local dev: your user      -> member="user:you@domain.com"
#   - on a GCP runtime: the attached SA -> member="serviceAccount:runner-sa@..."
gcloud iam service-accounts add-iam-policy-binding \
  deck-sa@PROJECT.iam.gserviceaccount.com \
  --member="user:you@domain.com" \
  --role="roles/iam.serviceAccountTokenCreator"

# So the SA can be the ADC quota project for Drive (client-based API).
gcloud projects add-iam-policy-binding PROJECT \
  --member="serviceAccount:deck-sa@PROJECT.iam.gserviceaccount.com" \
  --role="roles/serviceusage.serviceUsageConsumer"
```

## 2. Google Drive

- Put the decks in a **Shared Drive** (or a folder within one).
- Share that Shared Drive / folder with `deck-sa@PROJECT.iam.gserviceaccount.com`
  as **Content Manager** (the level that allows overwriting files).
- A service-account email is *external* to your Workspace domain, so the share
  dialog will warn "external to <org>" — that's expected; the SA is your own
  infrastructure. If your org hard-blocks external sharing, an admin must allow
  it (or use domain-wide delegation instead).
- IAM roles do **not** grant Drive content access. This sharing step is what
  lets the SA see and edit the decks.

## 3. Base ADC on the machine

The helper impersonates *from* whatever base ADC exists. Provide one:

- **Local dev** — log in as yourself once (your user is the base identity that
  impersonates the deck SA):
  ```bash
  gcloud auth login                       # gcloud's own identity (separate store)
  gcloud auth application-default login   # base ADC the helper impersonates from
  gcloud auth application-default set-quota-project PROJECT
  ```
  Note: the base ADC here is your plain user — the deck-SA impersonation happens
  in code, so you are NOT passing `--impersonate-service-account` to this login.

- **GCP runtime** (Batch / GCE / Cloud Run / GKE) — attach a runner SA to the
  resource; the metadata server supplies the base ADC automatically. Give that
  runner SA `serviceAccountTokenCreator` on the deck SA (step 1).

- Confirm `GOOGLE_APPLICATION_CREDENTIALS` is **unset** — if set, it overrides
  the base ADC the helper expects.

## Dependencies

```bash
pip install google-api-python-client google-auth
pip install python-pptx   # only if you use insert_picture()
```

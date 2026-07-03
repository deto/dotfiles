---
name: pptx-drive-editor
description: >-
  Edit existing PowerPoint (.pptx) decks that live in a Google Shared Drive, in
  place, using in-code service-account impersonation (no key files, no clobbering
  the machine's default ADC) and raw-OOXML editing that preserves template
  formatting and keeps text/shapes editable. Use this whenever the user wants to
  programmatically read or edit Drive-hosted .pptx decks, build an agent or
  pipeline that updates slides, swap template placeholders, refresh figures, or
  do "no manual pasting" slide automation — especially if they mention Google
  Drive + slides/decks/presentations, Shared Drives, or ADC/impersonation auth
  for Drive. Trigger this even when the user doesn't say "skill", and even if
  they only describe the goal (e.g. "update the Q2 deck in our shared drive").
---

# PPTX Drive Editor

Edit `.pptx` decks stored in a Google **Shared Drive**, in place, without
downloading service-account keys and without disturbing the machine's default
credentials. Text and graphics stay editable because edits are made to the
underlying OOXML, not by flattening slides to images.

## Project defaults

| Setting | Value |
|---------|-------|
| Deck SA | `deck-agent-sa@cloud-cli-481516.iam.gserviceaccount.com` |
| GCP project | `cloud-cli-481516` |

Use these values in all `drive_client(...)` calls unless the user specifies otherwise.

## When this applies

- The deck is a real `.pptx` file in Drive (not a native Google Slides file).
  Native Slides would require a lossy convert; this skill is for `.pptx` blobs,
  which Drive stores and serves losslessly.
- You want a repeatable, agent-driven edit: swap placeholders, replace text,
  add a generated figure, or restructure slides.

## Setup (one-time)

Before any edit can run, the project, service account, and Shared Drive sharing
must be in place, and a base ADC identity must exist on the machine. Read
[references/setup.md](references/setup.md) and confirm those are done. The two
failure modes that look like bugs but are setup gaps: the `iamcredentials` API
not enabled (impersonation fails cryptically), and the deck SA not added to the
Shared Drive (files 404 even though they exist).

## Auth model

Authentication is **in code** — do not write a credential file. The helper
resolves whatever base ADC exists (the user's `application-default login`, or an
attached SA on a GCP runtime) and impersonates the deck SA to mint a short-lived,
Drive-scoped token:

```python
from scripts.deck_drive import drive_client
drive = drive_client("deck-sa@PROJECT.iam.gserviceaccount.com")
```

Keep two grants straight — they are independent and mixing them up is the most
common dead end:

- **IAM** `roles/iam.serviceAccountTokenCreator` on the deck SA → governs *who
  may act as* the SA (the base identity needs this).
- **Drive** membership of the Shared Drive / folder as **Content Manager** →
  governs *what content* the SA can read and overwrite. IAM roles grant none of
  this.

## Core workflow

The shape is always: **download → edit OOXML → overwrite the same file.**
Overwriting the same `fileId` (via `files.update`, not a new upload) is what
keeps links, sharing, and comments intact.

```python
from scripts.deck_drive import read_slides, edit_deck_in_place, download_pptx, drive_client

SA = "deck-sa@PROJECT.iam.gserviceaccount.com"
FILE_ID = "..."

# 1) Inspect first. A human-authored deck has no semantic IDs, so read the XML
#    and reason out which run holds the title, where the placeholder is, etc.
drive = drive_client(SA)
slides = read_slides(download_pptx(drive, FILE_ID))   # {part_name: xml}

# 2) Edit. edit_fn(part_name, xml) -> new_xml. Return xml unchanged to skip.
def edit_fn(name, xml):
    if name == "ppt/slides/slide1.xml":
        xml = xml.replace("{{title}}", "Q2 In-vivo Perturb-seq Results")
    return xml

# 3) Apply in place.
edit_deck_in_place(SA, FILE_ID, edit_fn)
```

For simple deterministic placeholder swaps, `replace_tokens(data, {...})` is a
shortcut over writing `edit_fn` by hand.

## Choosing an edit strategy

- **Text / structure → raw OOXML (default).** Faithful and agent-native: each
  slide is a separate XML file, so edit it with your normal string-replace
  tooling. Only the parts you touch are rewritten.
- **New pictures or charts → python-pptx** via `insert_picture(...)`. Inserting
  media in raw OOXML means hand-managing content-types, relationships, and shape
  geometry; python-pptx does that correctly. It rewrites more of the package, so
  reserve it for *adding* visuals, not for faithful text edits.
- **AI-generated images → Vertex AI Imagen.** Call Imagen, get PNG bytes back,
  pass them straight into `insert_picture`. Same SA impersonation — no separate
  auth. See [references/imagen.md](references/imagen.md) for setup, model
  choice, and all config parameters. Default to `imagen-4.0-generate-001`
  ($0.04/image); use `imagen-4.0-fast-generate-001` ($0.02/image) for drafts.

Your scientific figures (UMAPs, volcano plots, heatmaps) are inherently raster —
generate them (matplotlib/plotly) → PNG → `insert_picture` for fully automatic,
no-paste placement. "Editable" applies to the surrounding text, callouts, tables,
and native charts, not the dense figure itself.

## OOXML editing rules

When writing or replacing slide XML, follow these so edits don't corrupt the
package or look off:

- **One `<a:t>` run per token.** A `{{token}}` split across runs (a frequent
  autocorrect artifact) won't match a plain replace. If a swap silently no-ops,
  this is why. Author template tokens in a single motion, or merge runs in the
  XML before replacing.
- **Multi-item content → one `<a:p>` per item.** Never concatenate list items
  into a single paragraph string. Copy the original `<a:pPr>` onto each new
  paragraph to preserve spacing.
- **Default generated fonts → Arial and Inter.** When creating new editable
  slide text instead of preserving an existing placeholder's font, use Arial for
  body text, labels, callouts, and node text. Use Inter Bold for slide titles
  and major section headers. Avoid Aptos unless the source deck already uses it
  and local/Drive preview font checks confirm it renders consistently.
- **Bold headers/labels** with `b="1"` on `<a:rPr>` (titles, section headers,
  inline labels like "Status:").
- **Disable auto-fit on generated text boxes.** PowerPoint's `<a:spAutoFit/>`
  can render differently in LibreOffice, Drive previews, and PowerPoint,
  shifting visible text origins and changing line wraps even when the shape
  coordinates are correct. For generated text boxes and text-bearing shapes,
  remove `<a:spAutoFit/>` / `<a:normAutofit/>`, append `<a:noAutofit/>`, and set
  explicit margins, box sizes, font sizes, and paragraph alignment.
- **Smart quotes as XML entities** in new text: `&#x201C; &#x201D; &#x2018;
  &#x2019;`. Escape `&`, `<`, `>` in any inserted value (`replace_tokens` does
  this for you).
- **Preserve leading/trailing spaces** with `xml:space="preserve"` on `<a:t>`.
- If you parse XML programmatically, use `defusedxml.minidom` — `xml.etree`
  mangles the namespaces.

## Critical Drive gotchas

- **`supportsAllDrives=True` on every call.** The helper sets it; if you add raw
  Drive calls, Shared Drive items 404 without it.
- **Overwrite, don't re-upload.** `files.update(fileId=...)` preserves identity;
  a fresh `files.create` makes a new file and breaks every existing link.
- **Service accounts have no My Drive storage quota.** Creating new preview
  files with the deck SA only works in a Shared Drive folder or another folder
  whose storage is not owned by the service account. For thumbnail previews, use
  the configured `.agent_tmp` folder ID below.

## Rendering slide previews

Drive exposes `thumbnailLink` for a PPTX file, but for multi-slide `.pptx` files
that is a **file-level** preview, usually the cover slide. To preview a specific
slide without converting the source deck to native Google Slides, create a
temporary one-slide `.pptx` that contains only the target slide, upload that
temporary deck to Drive, wait for Drive to generate its file thumbnail, and
download the thumbnail PNG locally.

Use the reusable helper:

```bash
python /home/deto/.agent-skills/pptx-drive-editor/scripts/drive_slide_preview.py \
  --file-id "DRIVE_PPTX_FILE_ID" \
  --slide-number 5 \
  --out-dir tmp
```

Defaults:

| Setting | Value |
|---------|-------|
| Preview folder | `.agent_tmp` |
| Preview folder ID | `1mVFIlE59dnMM0BGyvxfp-abUOA760_ko` |
| Thumbnail request size | `1600` |
| Auth | same deck SA impersonation as `drive_client(...)` |

The script writes two local artifacts:

- A one-slide PPTX copy, useful for debugging the exact uploaded source.
- A `*_thumbnail.png` downloaded from Drive after thumbnail generation.

The script also prints the temporary Drive file ID and `webViewLink`. Use
`--delete-drive-file` to trash the temporary Drive file after the thumbnail is
downloaded; otherwise leave it in `.agent_tmp` for manual inspection. If upload
fails with a service-account storage-quota error, the target preview folder is
not backed by usable shared storage for the service account.

## Local LibreOffice previews

For faster iteration, render the downloaded PPTX locally with LibreOffice:

```bash
soffice --headless --convert-to pdf --outdir tmp input.pptx
pdftoppm -png -r 144 tmp/input.pdf tmp/slide
```

On Ubuntu/WSL, install the renderer and rasterizer if they are missing:

```bash
sudo apt-get update
sudo apt-get install -y \
  libreoffice \
  poppler-utils \
  fontconfig \
  fonts-dejavu \
  fonts-liberation \
  fonts-noto-core \
  fonts-noto-color-emoji
```

Verify the tools:

```bash
which libreoffice soffice pdftoppm pdfinfo
soffice --headless --version
```

Font fidelity matters. LibreOffice will substitute missing fonts, which can move
line breaks and alter text sizing. Check the fonts used by the deck:

```bash
fc-match Arial
fc-match Inter
fc-match "Helvetica Neue"
fc-match Aptos
```

If the deck uses Windows or brand fonts, install them into WSL and refresh the
font cache:

```bash
mkdir -p ~/.local/share/fonts
cp /mnt/c/Windows/Fonts/arial*.ttf ~/.local/share/fonts/
fc-cache -f -v
```

Install non-Windows fonts such as Inter from their official source or package,
then verify with `fc-match`. If `fc-match` returns `DejaVu Sans` or
`Liberation Sans` for a deck font, local renders are using a fallback.

A typical local preview flow is:

```bash
mkdir -p tmp/local_preview
python - <<'PY'
import sys
from pathlib import Path
sys.path.insert(0, "/home/deto/.agent-skills/pptx-drive-editor/scripts")
from deck_drive import download_pptx, drive_client

drive = drive_client("deck-agent-sa@cloud-cli-481516.iam.gserviceaccount.com")
Path("tmp/local_preview/deck.pptx").write_bytes(download_pptx(drive, "DRIVE_FILE_ID"))
PY
soffice --headless --convert-to pdf --outdir tmp/local_preview tmp/local_preview/deck.pptx
pdftoppm -png -r 144 tmp/local_preview/deck.pdf tmp/local_preview/slide
```

`pdftoppm` writes `slide-1.png`, `slide-2.png`, etc. At 144 DPI, a 16:9
PowerPoint deck usually renders near `1440x810`; LibreOffice may produce a
fractional PDF page height that rasterizes to `1440x811`, so crop or pad to
exact 16:9 if downstream tooling needs fixed dimensions.

Use local LibreOffice previews for fast iteration and Drive thumbnails for final
fidelity checks. In one observed deck, local rendering took about 7.6 seconds
for a 5-slide PPTX (`PPTX -> PDF` 6.5s, `PDF -> PNG` 1.1s), while the Drive
single-slide thumbnail workflow took about 27 seconds for one slide.

## Verify before trusting the loop

Run a **no-op round trip** first: download the deck, repack with no edits, and
`upload_pptx_in_place`. Confirm it succeeds and the `fileId` is unchanged — that
proves auth, Shared Drive access, and in-place overwrite end to end. Then make a
single-token edit and confirm it in the Drive UI before pointing the agent at
real work.

## Helper reference (`scripts/deck_drive.py`)

| Function | Purpose |
|----------|---------|
| `drive_client(sa_email)` | Drive v3 client impersonating the deck SA |
| `download_pptx(drive, file_id)` | Bytes of the deck |
| `read_slides(data)` | `{slide_part: xml}` in deck order, for inspection |
| `edit_slides(data, edit_fn)` | Rewrite slide XML faithfully |
| `replace_tokens(data, mapping)` | Literal-token swap convenience |
| `insert_picture(data, idx, png, ...)` | Auto-place a figure (python-pptx) |
| `upload_pptx_in_place(drive, file_id, data)` | Overwrite same fileId |
| `edit_deck_in_place(sa, file_id, edit_fn)` | download → edit → overwrite |

## Script reference

| Script | Purpose |
|--------|---------|
| `scripts/drive_slide_preview.py` | Create a temporary one-slide PPTX in Drive and download its Drive-generated thumbnail PNG |

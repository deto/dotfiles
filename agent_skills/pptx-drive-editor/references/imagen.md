# Vertex AI Imagen — Image Generation

Generate images via Vertex AI and embed them in slides with `insert_picture`.
Uses the same SA impersonation as the Drive client — no separate auth setup.

## Prerequisites (one-time)

```bash
# Enable the Vertex AI API
gcloud services enable aiplatform.googleapis.com --project=PROJECT

# Grant the deck SA permission to call Vertex AI
gcloud projects add-iam-policy-binding PROJECT \
  --member="serviceAccount:deck-sa@PROJECT.iam.gserviceaccount.com" \
  --role="roles/aiplatform.user"
```

No terms-of-service dialog is required for Imagen 4.0 (this step was removed).

## SDK

Use `google-genai` (the new unified SDK, not the deprecated `google-cloud-aiplatform`
`vertexai.preview` path):

```bash
pip install google-genai
```

## Models

| Model | Cost | Notes |
|-------|------|-------|
| `imagen-4.0-generate-001` | **$0.04 / image** | Default — noticeably better quality, use this |
| `imagen-4.0-fast-generate-001` | $0.02 / image | Faster iteration / drafts |

## Minimal usage pattern

```python
import google.auth
from google.auth import impersonated_credentials
from google import genai
from google.genai import types

def imagen_client(sa_email: str, project: str, region: str = "us-central1"):
    source, _ = google.auth.default(
        scopes=["https://www.googleapis.com/auth/cloud-platform"]
    )
    creds = impersonated_credentials.Credentials(
        source_credentials=source,
        target_principal=sa_email,
        target_scopes=["https://www.googleapis.com/auth/cloud-platform"],
    )
    return genai.Client(vertexai=True, project=project,
                        location=region, credentials=creds)

def generate_image(
    client,
    prompt: str,
    model: str = "imagen-4.0-generate-001",   # $0.04/image
    aspect_ratio: str = "16:9",
) -> bytes:
    response = client.models.generate_images(
        model=model,
        prompt=prompt,
        config=types.GenerateImagesConfig(
            number_of_images=1,
            aspect_ratio=aspect_ratio,
            safety_filter_level="BLOCK_ONLY_HIGH",
            person_generation="ALLOW_ADULT",
            enhance_prompt=True,
        ),
    )
    return response.generated_images[0].image.image_bytes
```

Then pass the bytes straight to `insert_picture`:

```python
png = generate_image(client, "flat vector illustration of a neuron...")
data = insert_picture(data, slide_index=2, png=png, left=0.5, top=1.5,
                      width=12.0, height=5.5)
```

## Key config parameters

| Parameter | Type | Notes |
|-----------|------|-------|
| `aspect_ratio` | str | `"1:1"`, `"3:4"`, `"4:3"`, `"9:16"`, `"16:9"` — **no raw pixel dimensions**; use this to control shape |
| `image_size` | str | `"1K"` or `"2K"` — controls resolution of the largest dimension; `"2K"` for print/hi-res slides |
| `number_of_images` | int | 1–4; generate variants and pick the best |
| `negative_prompt` | str | What to suppress, e.g. `"photorealistic, blurry, text"` |
| `guidance_scale` | float | Higher → closer to prompt, may reduce quality; leave unset to use model default |
| `seed` | int | Pin for reproducible outputs; **incompatible with `add_watermark=True`** |
| `enhance_prompt` | bool | Lets the model rewrite/expand the prompt — generally helpful, set `False` to stay literal |
| `safety_filter_level` | enum | `BLOCK_LOW_AND_ABOVE` / `BLOCK_MEDIUM_AND_ABOVE` / `BLOCK_ONLY_HIGH` / `BLOCK_NONE` |
| `person_generation` | enum | `DONT_ALLOW` / `ALLOW_ADULT` / `ALLOW_ALL` |
| `output_mime_type` | str | `"image/png"` (default) or `"image/jpeg"` |
| `output_compression_quality` | int | JPEG only; 0–100 |
| `language` | enum | `"auto"`, `"en"`, `"zh"`, `"ja"`, `"ko"`, `"hi"`, `"pt"`, `"es"` |
| `add_watermark` | bool | Adds a SynthID watermark; incompatible with `seed` |
| `labels` | dict | Billing labels, e.g. `{"deck": "q2-review"}` |

## Image-conditioned generation (style reference & editing)

The SDK exposes `client.models.edit_image(...)` alongside `generate_images`.
This is how you use an input image as a style reference or for inpainting.

### Style transfer — "generate something in the style of this image"

```python
from google.genai import types

def generate_in_style(client, prompt: str, style_image_bytes: bytes,
                      model: str = "imagen-4.0-generate-001") -> bytes:
    style_ref = types.StyleReferenceImage(
        reference_id=1,
        reference_image=types.Image(image_bytes=style_image_bytes),
        config=types.StyleReferenceConfig(style_description="match this visual style"),
    )
    response = client.models.edit_image(
        model=model,
        prompt=prompt,
        reference_images=[style_ref],
        config=types.EditImageConfig(
            edit_mode="EDIT_MODE_STYLE",
            number_of_images=1,
            safety_filter_level="BLOCK_ONLY_HIGH",
        ),
    )
    return response.generated_images[0].image.image_bytes
```

### Other edit modes

| `EditMode` | What it does |
|------------|-------------|
| `EDIT_MODE_STYLE` | Apply the style of a reference image to a new generation |
| `EDIT_MODE_INPAINT_INSERTION` | Fill a masked region with new content |
| `EDIT_MODE_INPAINT_REMOVAL` | Erase a masked region and fill naturally |
| `EDIT_MODE_OUTPAINT` | Extend the image beyond its original borders |
| `EDIT_MODE_BGSWAP` | Replace the background while keeping the subject |
| `EDIT_MODE_PRODUCT_IMAGE` | Place a product on a new background |
| `EDIT_MODE_CONTROLLED_EDITING` | Fine-grained edits using a `ControlReferenceImage` |

For inpainting, supply a `MaskReferenceImage` alongside the `RawReferenceImage`.
`base_steps` in `EditImageConfig` trades quality for latency (higher = better quality).

## Prompting for diagram/illustration style

Imagen defaults toward photorealism. For slide-friendly output, steer the
style explicitly in the prompt:

```
"Flat vector cartoon illustration, clean lines, white background, bright
colours, scientific diagram style, no photorealism, no shadows"
```

Add `negative_prompt="photorealistic, photograph, blurry, noise"` for extra
control. For diagrams where text labels need to be readable, consider
generating the diagram in matplotlib and reserving Imagen for illustrative
/ decorative visuals — Imagen's text rendering is unreliable.

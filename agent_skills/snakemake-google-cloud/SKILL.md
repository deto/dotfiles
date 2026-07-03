---
name: snakemake-google-cloud
description: Use this private company skill when creating, reviewing, or modifying Snakemake workflows that run on Google Cloud Batch with Google Cloud Storage, especially workflows using the analysis-pipelines project, the company Snakemake profile defaults, GCS-backed outputs, Artifact Registry containers, or per-rule googlebatch resources.
---

# Snakemake Google Cloud

Use this skill for company Snakemake workflows that run with the `googlebatch` executor and `gcs` storage plugin. Prefer the defaults below unless the project gives a more specific profile.

## Environment

For `uv` projects, include these core dependencies in `pyproject.toml`:

```toml
[project]
requires-python = ">=3.12"
dependencies = [
    "snakemake>=9.22.0",
    "snakemake-storage-plugin-gcs>=1.1.4",
    "snakemake-executor-plugin-googlebatch>=0.5.1",
]

[tool.uv.sources]
snakemake-executor-plugin-googlebatch = { git = "https://github.com/deto/snakemake-executor-plugin-googlebatch", rev = "749f109" }
```

Keep the `deto` fork pin unless the user explicitly asks to move back to upstream PyPI or a newer fork revision. The lockfile observed in the source project resolved Snakemake to `9.23.1`, the forked `snakemake-executor-plugin-googlebatch` to version `0.5.1` from commit `749f1093606bea0801d3f53234a9ce14d797b6e2`, and `snakemake-storage-plugin-gcs` to `1.1.4`.

The executor plugin brings Google SDK dependencies such as `google-cloud-batch`, `google-cloud-logging`, and `google-cloud-storage`; the storage plugin brings `google-cloud-storage` and `google-crc32c`. Do not install these globally; use the project environment.

## Profile Defaults

Use a workflow profile such as `workflow/profiles/default/config.yaml`:

```yaml
executor: googlebatch
default-resources:
  mem_mb: 8000
  threads: 2

googlebatch-project: analysis-pipelines
googlebatch-service-account: snakemake-batch-executor@analysis-pipelines.iam.gserviceaccount.com
googlebatch-region: us-west1
googlebatch-machine-type: c2-standard-4
googlebatch-boot-disk-gb: 256
googlebatch-max-run-duration: 423000s
googlebatch-image-family: batch-cos-stable-official
googlebatch-container: snakemake/snakemake:v9.22.0

default-storage-provider: gcs
default-storage-prefix: gs://perturbai-pipeline-outputs
storage-gcs-project: analysis-pipelines

sdm: apptainer
rerun-trigger: mtime
jobs: 256
apptainer-args: "--contain --cleanenv"
```

Run from the directory containing `workflow/Snakefile` or `Snakefile`, typically:

```bash
uv run snakemake --profile workflow/profiles/default --cores all
```

For dry runs in restricted environments, local cache variables may be needed:

```bash
XDG_CACHE_HOME=.cache uv run snakemake --profile workflow/profiles/default -n
```

## Authentication

The launching machine needs Google application default credentials or equivalent service account access. If the workflow uses private Artifact Registry containers on Batch COS, set Docker credentials at top-level Snakefile parse time. This mirrors `workflows/singlecell_pipeline/workflow/Snakefile`: fetch a fresh OAuth token from the Batch VM metadata server and fall back to local ADCs when launching locally.

For Snakemake `container:` rules executed via Apptainer/Singularity, set both the generic Docker variables and the Apptainer/Singularity-specific variables. The outer Batch COS runnable can start successfully while the inner Apptainer pull of `docker://us-docker.pkg.dev/...` fails with `403 (Forbidden)` if these are missing.

```python
import os
import requests


def _get_ar_token():
    """Fetch a fresh AR token locally via ADCs or on Batch via metadata server."""
    try:
        resp = requests.get(
            "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token",
            headers={"Metadata-Flavor": "Google"},
            timeout=2,
        )
        resp.raise_for_status()
        return resp.json()["access_token"]
    except Exception:
        import google.auth
        import google.auth.transport.requests

        creds, _ = google.auth.default()
        creds.refresh(google.auth.transport.requests.Request())
        return creds.token


_token = _get_ar_token()
for _username_var in [
    "DOCKER_USERNAME",
    "APPTAINER_DOCKER_USERNAME",
    "SINGULARITY_DOCKER_USERNAME",
]:
    os.environ[_username_var] = "oauth2accesstoken"
for _password_var in [
    "DOCKER_PASSWORD",
    "APPTAINER_DOCKER_PASSWORD",
    "SINGULARITY_DOCKER_PASSWORD",
]:
    os.environ[_password_var] = _token
```

Use the profile's service account by default: `snakemake-batch-executor@analysis-pipelines.iam.gserviceaccount.com`. That service account needs permission to pull the private Artifact Registry image, and the launcher identity needs permission to submit Batch jobs as it.

## Storage Patterns

With `default-storage-provider: gcs` and `default-storage-prefix: gs://perturbai-pipeline-outputs`, relative workflow inputs and outputs are mapped to GCS under that prefix unless explicitly marked otherwise.

Use `storage.gcs(...)` for shared GCS resources that live outside the default output prefix or should be explicit:

```python
CELLRANGER = "gs://perturbai-pipeline-resources/software/cellranger/cellranger-10.0.0.tar.gz"

rule run_cellranger:
    input:
        cr_software=storage.gcs(CELLRANGER),
```

Use `local(...)` for files that must remain local to the launcher, such as registry/config files downloaded before job graph construction:

```python
rule update_registry:
    output:
        xlsx=local("workflow/Input/data_registry.xlsx")
```

When a cloud rule passes an output directory to a script, derive it from declared Snakemake outputs instead of hard-coding paths such as `Output/scvi`. With the GCS storage plugin, the remote job writes expected outputs under Snakemake's storage-local path (for example `.snakemake/storage/gcs/.../Output/scvi`) before uploading them to GCS. A hard-coded `Output/...` directory inside `/tmp/workdir` can make the analysis succeed but leave Snakemake unable to find and upload the declared outputs.

Good pattern:

```python
shell:
    """
    output_dir=$(dirname {output.latent})
    mkdir -p "$output_dir"
    python Scripts/run_scvi.py \
        --output-dir "$output_dir" \
        ...
    """
```

Also prefer passing explicit output file paths to scripts when practical; this avoids ambiguity between local working paths and storage-local paths.

The GCS plugin accepts `gs://bucket/path` and `gcs://bucket/path`. Required project default is `storage-gcs-project: analysis-pipelines`. Other settings to consider only when needed are `storage-gcs-max-requests-per-second`, `storage-gcs-stay-on-remote`, and `storage-gcs-retries`.

## Rule Requirements

Rules that run on Google Batch should normally specify:

- `container:` for the rule-specific analysis runtime.
- `threads:` matching tool parallelism and CPU allocation.
- `resources.googlebatch_memory` in MiB when the default is insufficient.
- `resources.googlebatch_cpu_milli = lambda wildcards, threads: threads * 1000` when CPU should track `threads`.
- `resources.googlebatch_machine_type` when the job requires a specific VM shape.
- `resources.googlebatch_boot_disk_gb` when the job stages large inputs, installs software, writes large intermediates, or runs Cell Ranger.

Examples from the source workflow:

```python
rule run_cellranger:
    container: "docker://us-docker.pkg.dev/analysis-pipelines/pipeline-modules/cellranger:d0cdbf4"
    threads: 96 if LARGE_INSTANCE else 32
    resources:
        googlebatch_memory=768000 if LARGE_INSTANCE else 256000,
        googlebatch_cpu_milli=lambda wildcards, threads: threads * 1000,
        googlebatch_machine_type="n2d-highmem-96" if LARGE_INSTANCE else "n2d-highmem-32",
        googlebatch_boot_disk_gb=10240 if LARGE_INSTANCE else 6144,
```

```python
rule run_preprocessing:
    container: "docker://us-docker.pkg.dev/analysis-pipelines/pipeline-modules/preprocessing:bdac37b"
    threads: 48 if LARGE_INSTANCE else 16
    resources:
        googlebatch_memory=384000 if LARGE_INSTANCE else 64000,
        googlebatch_cpu_milli=lambda wildcards, threads: threads * 1000,
        googlebatch_machine_type="n2d-highmem-48" if LARGE_INSTANCE else "n2d-standard-16",
        googlebatch_boot_disk_gb=1024,
```

For simpler jobs, Snakemake resources like `mem_mb` and `_cores` may be enough, but prefer explicit `googlebatch_*` resources when VM choice, boot disk size, or Batch CPU/memory allocation matters.

## GPU Rules

For GPU rules on Google Batch, set a Google Batch accelerator resource and use a compatible machine family. Examples:

```python
rule run_gpu_step:
    container: "docker://us-docker.pkg.dev/analysis-pipelines/pipeline-modules/analysis-gpu:2543fc7"
    threads: 8
    resources:
        mem_mb=56000,
        nvidia_gpu="nvidia-tesla-t4",
        googlebatch_memory=57344,
        googlebatch_cpu_milli=lambda wildcards, threads: threads * 1000,
        googlebatch_machine_type="n1-standard-16",
        googlebatch_boot_disk_gb=256,
```

Use `nvidia-tesla-t4` on `n1-*` machines for modest jobs when L4 capacity is scarce. Use `nvidia-l4` with `g2-*` machines when L4 capacity is available. If a zone is out of capacity, Google Batch may report a `CODE_GCE_ZONE_RESOURCE_POOL_EXHAUSTED` event for one zone; the job can still be allowed at the region level (`us-west1`) and Batch may try other zones if the request is not pinned too narrowly.

For Snakemake `container:` rules executed through Apptainer/Singularity, include NVIDIA binding:

```yaml
sdm: apptainer
apptainer-args: "--contain --cleanenv --nv"
```

Without `--nv`, the Batch VM may have a working GPU but the inner Apptainer container may not see `nvidia-smi` or CUDA devices. Add lightweight diagnostics to new GPU rules while validating:

```bash
command -v nvidia-smi || true
nvidia-smi || true
python - <<'PY'
import torch
print("torch_version=" + str(torch.__version__))
print("torch_cuda_available=" + str(torch.cuda.is_available()))
print("torch_cuda_device_count=" + str(torch.cuda.device_count()))
PY
```

The `googlebatch` executor plugin sets Batch `install_gpu_drivers = True` when a rule requests `nvidia_gpu`. Batch will install drivers and the NVIDIA container toolkit during VM startup if the image does not already have them. This adds startup time. In one observed T4 run, Batch installed driver `550.54.15` with CUDA `12.4`; `nvidia-smi` worked inside Apptainer with `--nv`, but a container with PyTorch `2.12.1+cu130` failed because the host driver was too old for CUDA 13.0. Match the GPU container's CUDA/PyTorch build to the driver Batch installs, or use a custom Batch boot image / plugin change that provides a sufficiently new driver and avoids redundant driver installation.

When debugging GPU jobs, consider setting:

```yaml
googlebatch-retry-count: 0
```

This keeps Batch from retrying a failed remote Snakemake wrapper and obscuring the primary error. A retry can auto-discover the workflow profile inside the remote container; if that profile says `executor: googlebatch` but the inner container only has local executors, the retry may fail with `invalid choice: 'googlebatch'`. Treat that as secondary noise unless it is the first failure.

## Googlebatch Options

The executor requires `googlebatch-project` and `googlebatch-region`; this skill defaults them to `analysis-pipelines` and `us-west1`.

Useful profile-level or per-rule Batch settings include:

- `googlebatch-container`: custom Batch COS container.
- `googlebatch-machine-type`: default or per-rule VM type.
- `googlebatch-image-family`: use `batch-cos-stable-official` for COS/container mode here.
- `googlebatch-service-account`: Batch VM service account.
- `googlebatch-memory`: memory in MiB.
- `googlebatch-cpu-milli`: CPU milli value, commonly `threads * 1000`.
- `googlebatch-boot-disk-gb`: boot disk size in GB; must be at least the provider minimum and often needs to be large for staged data.
- `googlebatch-max-run-duration`: duration string such as `3600s`; this profile uses `423000s`.
- `googlebatch-retry-count`, `googlebatch-labels`, `googlebatch-network`, and `googlebatch-subnetwork` only when a workflow needs them.

## Implementation Checklist

When adapting a workflow:

1. Add or update `snakemake`, `snakemake-storage-plugin-gcs`, and the fork-pinned `snakemake-executor-plugin-googlebatch` in the project environment.
2. Add `workflow/profiles/default/config.yaml` with the company defaults above unless a project profile already exists.
3. Make outputs relative paths when they should land under `gs://perturbai-pipeline-outputs`; use `storage.gcs(...)` for explicit external GCS inputs.
4. Add `container`, `threads`, and needed `googlebatch_*` resources to Batch rules.
5. Use `local(...)` for launcher-local config inputs and outputs.
6. Validate with at least `XDG_CACHE_HOME=.cache uv run snakemake --profile workflow/profiles/default -n`.

## Sources

This skill was distilled from the company single-cell pipeline files `workflow/profiles/default/config.yaml`, `workflow/Snakefile`, `workflow/modules/single_cell_preprocess.smk`, `workflow/modules/differential_expression.smk`, `pyproject.toml`, and `uv.lock`, plus:

- Snakemake Google Batch executor plugin docs: https://snakemake.github.io/snakemake-plugin-catalog/plugins/executor/googlebatch.html
- Snakemake GCS storage plugin docs: https://snakemake.github.io/snakemake-plugin-catalog/plugins/storage/gcs.html

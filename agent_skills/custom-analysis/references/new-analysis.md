# Starting a New Custom Analysis

Use this procedure only to initialize a new custom analysis directory. Inspect
the target first and preserve existing files; do not overwrite a partially
initialized analysis.

## Contents

- Organizational terms
- Name confirmation
- Python and Git initialization
- Workflow skeleton
- Analysis journal
- Sync helper
- Validation

## Organizational Terms

- Treat a **Project** as the top-level organizational item.
- Treat an **Experiment** as the organization for data within a Project.
- Treat an **Analysis** as the organization for custom analyses performed on
  processed Experiment data within a Project.
- Do not call a custom Analysis a Project or an Experiment.

## Confirm Names Before Initialization

Derive candidate names from the requested location when possible, but before
creating files, directories, environments, or repositories, explicitly show
the user both values:

```text
Project: <project-name>
Analysis: <analysis-name>
```

Ask the user to confirm or correct them and wait for confirmation. Do not begin
initialization until both names are confirmed.

For an analysis directory at `<project>/<analysis>`:

- `PROJECT` is the confirmed top-level Project name.
- `ANALYSIS` is the confirmed Analysis name.
- Sync to `gs://perturbai-custom-analysis/$PROJECT/$ANALYSIS`.

For example, `/analysis/3_glp1_screen/20260814_PertEffects` maps to
`gs://perturbai-custom-analysis/3_glp1_screen/20260814_PertEffects` only after
the user confirms `3_glp1_screen` and `20260814_PertEffects`.

## Python and Git Initialization

From the confirmed Analysis directory, run:

```bash
git init
uv init --no-workspace --bare --python 3.13
uv python pin 3.13
uv venv
uv add \
  "pandas<3" openpyxl scanpy \
  ipython \
  snakemake \
  python-lsp-server python-lsp-ruff
```

Use `uv run` for agent commands; sourcing `.venv/bin/activate` is unnecessary.
Add the following without duplicating existing TOML tables:

```toml
[tool.ruff]
builtins = ["snakemake"]

[tool.pyright]
typeCheckingMode = "off"
```

Create a `.gitignore` that excludes at least `.venv/`, `.snakemake/`, Python
and tool caches, and generated `Input/`, `Temp/`, and `Output/` contents.

## Workflow Skeleton

Create `Input/`, `Output/`, and `Scripts/`. Put this in the top-level
`Snakefile` and create an initially empty `Scripts/Snakefile`:

```python
include: "Scripts/Snakefile"
```

## Analysis Journal

Initialize the Quartz 5/Obsidian-compatible analysis journal described in
`references/journal-setup.md`. The journal is required for every newly
initialized analysis; create it as part of the initial scaffold rather than
waiting for the first result. This requirement includes the `Journal/` tree,
root `journal` serving wrapper, project-specific landing page, automatic
analysis archive, and generated-state ignores.

Do not invent findings for the initial journal. Limit the landing page to known
project context, the journal's purpose, and the convention that `Output/`
contains computational artifacts while the journal explains them.

## Sync Helper

Create an executable root-level Bash script named `sync`:

```bash
#!/usr/bin/env bash

PROJECT=<confirmed-project-name>
ANALYSIS=<confirmed-analysis-name>

EXCLUDES=(
  ".*\\.venv/.*"
  ".*\\.snakemake/.*"
  ".*\\.cache/.*"
  ".*\\.uv-cache/.*"
  ".*\\.matplotlib/.*"
  "renv/.*"
  "Temp/.*"
  ".*__pycache__/.*"
)

IFS='|'
JOINED_EXCLUDES="${EXCLUDES[*]}"
unset IFS

gcloud storage rsync . \
  "gs://perturbai-custom-analysis/$PROJECT/$ANALYSIS" \
  --recursive \
  --exclude="$JOINED_EXCLUDES" \
  "$@"
```

Run `chmod 775 sync`. Do not sync unless the user asks to upload files.

## Validation

Run `bash -n sync`, `bash -n journal`, `uv lock --check`, the standard
dependency imports, `uv run snakemake -n`, the journal build and link checks
from `references/journal-setup.md`, and `git status --short --branch`. Report
environmental limitations instead of claiming blocked validation succeeded.

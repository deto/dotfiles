---
name: custom-analysis
description: "Initialize and structure arbitrary bioinformatics analyses as reproducible, traceable Snakemake-backed analyses using the local custom-analysis repository conventions. Use when Agent is asked to bootstrap a new analysis directory or add, modify, review, or organize project-specific analyses, plots, tables, AnnData/single-cell workflows, R/renv package management, or other bioinformatics outputs in repositories that follow this pattern: lightweight top-level Snakefile, rules under Scripts/, Python analysis code under Scripts/ or Scripts/modules/, uv-managed Python dependencies, optional renv-managed R dependencies, Temp/ for working data, Output/ for durable results, and optional gcloud sync. For Google Cloud Batch execution details, combine with the snakemake-google-cloud skill instead of duplicating those details here."
---

# Custom Analysis

## Routed References

- When asked to initialize or bootstrap a new custom analysis, read
  [references/new-analysis.md](references/new-analysis.md) and
  [references/journal-setup.md](references/journal-setup.md) before making
  changes. Every new analysis must initialize an analysis journal.
- When an analysis repository already contains `Journal/`, read
  [references/journal-updates.md](references/journal-updates.md) before doing
  analysis work and treat the required journal update as part of completion.
- If an existing analysis has no `Journal/`, ignore all journal directives and
  do not initialize one unless the user explicitly asks to add a journal. This
  legacy-analysis exception does not apply when initializing a new analysis.

## Core Workflow

When adding or changing a durable analysis, make the result rerunnable through Snakemake:

1. Read repository docs first, especially `README.md`, `AGENTS.md`, the top-level `Snakefile`, and the relevant `Scripts/Snakefile` or `Scripts/modules/*/Snakefile`.
2. Add or update a Snakemake rule for every durable output.
3. Put non-trivial analysis logic in a Python source file under `Scripts/` or a domain module under `Scripts/modules/<analysis>/`.
4. Declare explicit inputs, outputs, params, logs, threads, and resources in the rule.
5. Route durable user-facing tables, plots, and model artifacts under the owning module's `Output/<module_name>/` root, nesting distinct analyses beneath it when useful.
6. Route temporary, smoke-test, cache, or intermediate working files to `Temp/<analysis_name>/`.
7. If the repository has `Journal/`, create or update its journal entry when
   required by the journal reference.
8. Run at least a Snakemake dry run for the target before handoff, and report the exact command and result.

Avoid one-off commands that create undocumented outputs. If an artifact is worth keeping, make Snakemake produce it.

## Interactive Notebook-Style Python Scripts

When the user explicitly asks for a "notebook-style script," treat it as an
interactive exception to the Snakemake workflow requirements:

- Create a `.py` file under `Notebooks/`, not an `.ipynb` file or a workflow
  script under `Scripts/`.
- Start every logical cell with a line in the form `# %% Short section name`.
- Put editable paths and analysis/plot parameters in the first configuration
  cell.
- Do not use `argparse`, CLI arguments, or environment variables for ordinary
  interactive settings.
- Write the cells so they can run sequentially from top to bottom or one at a
  time in a compatible editor.
- Do not add a Snakemake rule, workflow log, or durable companion outputs unless
  the user separately asks to operationalize the exploration.
- Default optional preview files to `Notebooks/` or `Temp/`, not curated
  `Output/`.
- Continue to use the project environment and documented metadata semantics.

If the user later asks to retain or productionize the result, move the analysis
logic under `Scripts/`, add the Snakemake rule and log, and route requested
durable outputs to `Output/`.

## Output Minimization

Treat `Output/` as a curated directory for results the user is likely to open or consume downstream. Unless the user explicitly requests additional artifacts, produce only the primary plots or tables requested, outputs required by a downstream rule, and the workflow log. The Snakemake rule, analysis script, declared inputs and parameters, and log are sufficient provenance by default.

Do not create plot manifests, audit tables, source-data exports, filter summaries, redundant reformatted tables, or similar companion files solely for traceability. Put concise diagnostic counts and filtering summaries in the log when they do not need to be consumed programmatically. Add a durable companion file only when it is itself a requested result or has a concrete downstream consumer.

Some existing or neighboring analyses may predate this convention and produce many companion files. Treat those as legacy examples, not as a style to imitate. Prefer this output-minimization instruction over matching the artifact pattern of older analyses. Do not remove legacy outputs unless the user explicitly asks for that cleanup.

## Repository Layout

Use this structure by default:

```text
Snakefile                         # lightweight entrypoint; includes Scripts/Snakefile
Scripts/Snakefile                 # central workflow composition and smaller local rules
Scripts/modules/<analysis>/       # preferred home for cohesive analysis modules
Scripts/modules/<analysis>/Snakefile
Scripts/modules/<analysis>/*.py
Scripts/*.py                      # acceptable for narrow cross-cutting or legacy analyses
Input/                            # durable local reference inputs
Temp/                             # generated working files and downloaded preprocessing
Output/                           # final or user-facing analysis outputs
Journal/                          # Quartz/Obsidian analysis journal in new analyses
journal                           # local Journal serving wrapper in new analyses
profiles/                         # Snakemake profiles
CloudWorkflows/                   # separate cloud/workflow transfer utilities
sync                              # gcloud storage rsync helper for custom-analysis mirroring
pyproject.toml, uv.lock           # Python dependency contract
```

Keep the top-level `Snakefile` lightweight. Prefer adding new modules to `Scripts/Snakefile` with:

```python
module my_analysis:
    snakefile: 'modules/my_analysis/Snakefile'

use rule * from my_analysis
```

Prefer mirroring Snakemake module ownership under `Output/`. For example,
rules from `Scripts/modules/qc/` should write beneath `Output/qc/`, with
distinct analyses nested further, such as `Output/qc/filter_thresholds/`.
Avoid separate top-level prefixed directories such as
`Output/qc_filter_thresholds/` when they belong to the same module.

For small or exploratory-but-retained analyses, adding a rule directly to `Scripts/Snakefile` is acceptable if it stays readable.

## Snakemake Rules

Follow existing rule style:

```python
rule my_analysis:
    localrule: True
    input:
        h5ads=H5ADS,
        script=local('Scripts/modules/my_analysis/run_my_analysis.py'),
    output:
        summary='Output/my_analysis/my_analysis_summary.csv',
        plot='Output/my_analysis/my_analysis_plot.png',
    params:
        output_dir='Output/my_analysis',
        random_seed=20260702,
    threads: 4
    resources:
        mem_mb=32000,
    log:
        'Output/my_analysis/my_analysis.log'
    shell:
        """
        uv run python {input.script} \
            --input {input.h5ads} \
            --output-dir {params.output_dir} \
            --random-seed {params.random_seed} \
            > {log} 2>&1
        """
```

Use named outputs for all files a downstream rule or user may need. Include the script and local helper modules as `local(...)` inputs for local rules. For production Google Batch rules, defer to the `snakemake-google-cloud` skill for deployment-specific script handling.

## Python Code

Use `uv` and the project `.venv`; do not install dependencies globally. Add dependency changes to `pyproject.toml` and `uv.lock`.

Prefer scripts with a CLI:

- `argparse` for inputs, outputs, thresholds, seeds, and grouping variables.
- `main()` guarded by `if __name__ == "__main__":`.
- Deterministic outputs: stable sorting, explicit random seeds, explicit category ordering where relevant.
- Structured IO with `scanpy`, `anndata`, `pandas`, `pyarrow`, or domain libraries instead of ad hoc parsing.
- Small reusable helper modules only when the same logic is shared by multiple analyses.

For AnnData/single-cell projects, read documented metadata before assuming column semantics. Preserve cell identifiers when writing per-cell tables.

## R Code and Packages

Use `renv` for project-specific R dependencies when an analysis uses R. Keep R dependency state in `renv.lock` and the project renv infrastructure; do not install analysis packages globally as the reproducibility mechanism.

When adding R packages for a project, install them only with `renv::install()` from the project root unless the user explicitly requests another installation path. Do not hydrate, copy, link, or otherwise import packages from a user/global/system library as a substitute for `renv::install()`; if `renv::install()` fails, stop and debug the failure with the user.

Initialize renv from the project root with a bare project library unless there is a clear reason to auto-discover existing R dependencies:

```bash
Rscript -e 'renv::init(bare = TRUE, restart = FALSE)'
```

Add R packages with `renv::install()` from the project root, then always run `renv::snapshot(prompt = FALSE)` after package additions, removals, or version changes so `renv.lock` records the updated dependency state:

```bash
Rscript -e 'renv::install(c("dplyr", "ggplot2")); renv::snapshot(prompt = FALSE)'
```

Use renv remote syntax for nonstandard sources when needed:

```r
renv::install("pkg@1.2.3")
renv::install("bioc::Biobase")
renv::install("owner/repo@commit-or-tag")
```

Restore the project R library from the lockfile with:

```bash
Rscript -e 'renv::restore(prompt = FALSE)'
```

For Snakemake rules that run R scripts, call R through the project root so `.Rprofile` activates renv, declare R scripts as rule inputs, and keep durable outputs under `Output/<analysis_name>/` like Python analyses. If package installation or restore needs network access, report that explicitly when validation cannot complete.

## Plots

Generate durable analysis plots through Snakemake. For explicitly requested
notebook-style scripts, follow the interactive exception above. Before handoff,
inspect rendered plots when feasible and iterate on cut-off labels, overlapping
text, misleading axes, missing legends, or plot limits that hide relevant data.

For PDF plot sets, consider writing a first-page PNG preview to validate plot appearance

## Validation

Run the narrowest useful validation:

```bash
uv run snakemake -n Output/my_analysis/my_output.csv
uv run snakemake --cores 1 Output/my_analysis/my_output.csv
```

For broad workflow checks, run:

```bash
uv run snakemake -n
```

If the project uses a profile that would send work to cloud by default, use the local convention documented in the repo, commonly:

```bash
uv run snakemake --workflow-profile none -n Output/my_analysis/my_output.csv
```

If required inputs, credentials, or cloud access are unavailable, say exactly which validation could not run.

## Sync Script

If a repository has a root `sync` script, treat it as the analysis-specific custom-analysis mirror helper. The pattern is:

- Define `PROJECT` and `ANALYSIS`.
- Exclude local environments, Snakemake state, caches, `Temp/`, and Python bytecode.
- Run `gcloud storage rsync . gs://perturbai-custom-analysis/$PROJECT/$ANALYSIS --recursive --exclude="$JOINED_EXCLUDES" "$@"`.

Use it to sync source files, workflow definitions, and selected durable outputs to GCS when requested. Do not assume cloud credentials are present. Do not use `sync` as a substitute for Snakemake provenance.

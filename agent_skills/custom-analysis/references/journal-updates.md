# Updating an Analysis Journal

Apply these instructions only when the analysis repository already contains
`Journal/`. If an existing analysis has no `Journal/`, ignore all journal
directives unless the user explicitly asks to add one.

Treat the journal as the durable, searchable record of questions, findings,
representative plots, exclusions, decisions, caveats, and provenance.
`Output/` remains the source of truth for generated artifacts; the journal
explains what those artifacts mean.

## When an Update Is Required

Create or update a journal entry whenever work produces a significant,
interpretable result. This is part of completion and does not require a
separate documentation request. Qualifying work includes:

- a new biological comparison, statistical model, or sensitivity analysis;
- a major QC, filtering, integration, clustering, or annotation result;
- a plot or table that answers a substantive project question;
- a useful negative result;
- a decision that changes retained samples or cells, interpretation, or
  downstream design;
- a revision that materially changes a recorded conclusion.

Do not add an entry for an unchanged rerun, formatting-only plot change, code
refactor, dependency maintenance, or minor implementation diagnostic. When new
work revisits an existing question, update the existing entry and preserve
important changes in interpretation instead of creating a near-duplicate.

## Author Entries

Store notes in `Journal/content/` as Markdown with YAML frontmatter. Use a
short, stable, lowercase filename such as `semaglutide-effect.md`; it defines
the canonical URL slug. The automatic archive discovers dated notes, so do not
maintain a duplicate entry list.

Use lowercase reusable tags and this frontmatter shape:

```yaml
---
title: Descriptive analysis title
date: YYYY-MM-DD
description: One-sentence statement of the principal finding
tags:
  - topic
  - method
status: complete
---
```

Avoid an alias that differs from the canonical filename only by capitalization;
Quartz lowercases slugs and can replace the canonical page with a self-redirect.
Use Obsidian wikilinks for journal-to-journal links:
`[[filename|descriptive label]]`.

Prefer concise sections: Question, Bottom line, Evidence, Interpretation and
caveats, Provenance, and Follow-up when applicable. Lead with the answer rather
than a command chronology. Record exact sample/cell counts, comparison
definitions, effect direction, uncertainty, exclusions, confounding, and
negative findings when relevant.

Base claims on completed outputs and logs, and inspect representative plots
before describing them. Provenance must name the workflow module, scripts,
primary outputs, and logs with paths relative to the project root. Do not copy
large machine-readable tables into Markdown.

## Link Curated Figures

Do not copy computational outputs into the journal. Create relative symlinks
under `Journal/content/_figures/<analysis>/` to the original files under
`Output/`. For a note directly under `Journal/content/`, use:

```markdown
![What the figure shows and why it matters.](_figures/<analysis>/<plot>.png)
```

Example from the project root:

```bash
mkdir -p Journal/content/_figures/semaglutide_effect
ln -s ../../../../Output/semaglutide_effect/effect_summary.png \
  Journal/content/_figures/semaglutide_effect/effect_summary.png
```

Git records the symlink, not the target plot. The corresponding `Output/` file
must be present when Quartz builds.

## Validate the Update

Before handing off significant analysis work:

1. Confirm every numerical journal statement against an output, log, or source
   table.
2. Inspect each journaled figure and add or update its relative symlink.
3. Run `find -L Journal/content/_figures -type l`; any output is a broken link.
4. Run `npm run quartz -- build` from `Journal/`.
5. Confirm canonical pages are content pages, not alias redirects.
6. Keep generated plots, `Journal/public/`, dependency directories, and analysis
   outputs untracked; only journal source/configuration and figure symlinks are
   versionable journal material.

Serve locally from the project root with `./journal 8080` when visual review is
useful. Do not run `quartz sync`; use the parent repository's Git workflow.

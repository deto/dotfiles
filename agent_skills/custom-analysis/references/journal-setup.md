# Initializing an Analysis Journal

Use this procedure only while initializing a new custom analysis or when the
user explicitly asks to add a journal to an existing analysis. Preserve any
existing files and stop rather than overlaying a partial `Journal/` tree.

## Scaffold Quartz

Create `Journal/` from the official Quartz 5 source distribution, not as a
nested Git repository. A safe pattern is to clone Quartz into a temporary
directory and export the tracked tree into the analysis repository:

```bash
QUARTZ_TMP=$(mktemp -d)
git clone --depth 1 https://github.com/quartz-community/quartz.git "$QUARTZ_TMP/quartz"
mkdir Journal
git -C "$QUARTZ_TMP/quartz" archive HEAD | tar -x -C Journal
rm -rf "$QUARTZ_TMP"
```

Confirm that `Journal/package.json` reports Quartz major version 5. If the
official default branch is no longer Quartz 5, resolve and check out the
official Quartz 5 branch or tag before exporting it. Do not retain
`Journal/.git`, configure a Quartz remote, or use `quartz sync`; the journal is
part of the parent analysis repository.

From `Journal/`, install locked dependencies and initialize fresh content with
the Obsidian template:

```bash
npm ci --cache .npm-cache
npm run quartz -- create \
  --template obsidian \
  --strategy new \
  --baseUrl localhost:8080
```

Quartz 5 requires Node.js 22 or newer and npm 10.9.2 or newer. Dependency and
plugin installation needs network access. Keep the generated lockfile.

## Configure the Journal

In `Journal/quartz.config.yaml`:

- set `configuration.pageTitle` to a concise project-specific journal title;
- keep `configuration.baseUrl: localhost:8080` for local development, noting
  that it must change before deployment;
- retain the Obsidian template's wikilinks, callouts, graph, backlinks, tags,
  Bases support, and local search;
- enable the description/frontmatter features used by journal entries;
- do not add deployment, comments, analytics, or hosting configuration unless
  requested.

Create `Journal/content/index.md` with YAML frontmatter containing a
project-specific `title`, one-sentence `description`, and the
`project-overview` tag. Explain the journal's scope and add these discovery
sections:

```markdown
## Browse analyses

The [[Analysis Archive.base|analysis archive]] provides a date-sorted, sortable
table of every journal entry.

## Recent analyses

![[Analysis Archive.base#Recent analyses]]
```

End the landing page with the working convention that generated artifacts stay
under project-level `Output/`; curated journal figures are relative symlinks to
those files.

Create `Journal/content/Analysis Archive.base`:

```yaml
filters:
  and:
    - file.ext == "md"
    - file.name != "index"
    - "!date.isEmpty()"
properties:
  date:
    displayName: Date
  title:
    displayName: Analysis
  description:
    displayName: Summary
  status:
    displayName: Status
  tags:
    displayName: Tags
views:
  - type: table
    name: Analysis archive
    order: [date, title, description, status, tags]
    sort:
      - property: date
        direction: DESC
      - property: title
        direction: ASC
  - type: list
    name: Recent analyses
    order: [file.name, date, description]
    sort:
      - property: date
        direction: DESC
      - property: title
        direction: ASC
    limit: 4
```

The Base makes dated entries discoverable automatically. Do not create a
second manually maintained list of entries.

## Add the Serving Wrapper

Create an executable root-level script named `journal`:

```bash
#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $(basename "$0") PORT" >&2
  echo "Serve the Quartz analysis journal on PORT (101-65535)." >&2
  echo "Live-reload WebSockets use PORT minus 100." >&2
}

if [[ $# -ne 1 ]]; then
  usage
  exit 2
fi

PORT="$1"
if [[ ! "$PORT" =~ ^[0-9]+$ ]] || (( PORT < 101 || PORT > 65535 )); then
  echo "Error: PORT must be an integer between 101 and 65535." >&2
  usage
  exit 2
fi

WS_PORT=$((PORT - 100))
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JOURNAL_DIR="$PROJECT_DIR/Journal"

if [[ ! -d "$JOURNAL_DIR/node_modules" ]]; then
  echo "Installing locked Quartz dependencies..."
  (cd "$JOURNAL_DIR" && npm ci --cache .npm-cache)
fi

cd "$JOURNAL_DIR"
exec npm run quartz -- build --serve --port "$PORT" --wsPort "$WS_PORT"
```

Run `chmod 775 journal`. Only the requested HTTP port needs forwarding when
automatic browser reloads are unnecessary.

## Ignore Generated State

Confirm `Journal/.gitignore` excludes at least `node_modules`, `.npm-cache/`,
`public`, `.obsidian`, `.quartz-cache`, and `.quartz/`. The project-level
`.gitignore` must continue to exclude generated `Input/`, `Temp/`, and
`Output/` contents. Do not ignore `Journal/content/` or its figure symlinks.

## Validate Initialization

Run:

```bash
node --version
npm --version
bash -n journal
cd Journal
npm run quartz -- build
cd ..
if [[ -d Journal/content/_figures ]]; then
  find -L Journal/content/_figures -type l
fi
git status --short --branch
```

A successful build writes ignored output to `Journal/public/`. Any output from
the broken-link check indicates a bad figure symlink. Confirm that the parent
repository sees ordinary Journal files, not an embedded repository or Gitlink,
and that generated site/dependency directories are untracked.

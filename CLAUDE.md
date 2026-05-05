# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Source for Spencer Hill's academic website, **live at https://spencerahill.github.io/**. The repo is the user-pages repo for the `spencerahill` GitHub account; pushes to `master` trigger a Quarto render + deploy via `.github/workflows/publish.yml`.

The site is built with [Quarto](https://quarto.org/) — `.qmd` files at the repo root, configured by `_quarto.yml`, output to `_site/` (gitignored).

**Legacy material is still present in the working tree** (`org/`, `public_html/`, `css/`, `themes/`, `Makefile`) — kept for archival reference but not part of the live build. The site previously lived at CCNY hosting (`shill.ccny.cuny.edu`), built from `org/*.org` via Emacs publish + FTP push; that stack is dead. Edit `.qmd` files for any content changes.

## Build and preview

```sh
quarto preview        # live-reload local preview
quarto render         # full build into _site/
```

Deployment is automatic via `.github/workflows/publish.yml` on pushes to `master`. A separate `link-check.yml` workflow runs lychee on PRs and weekly to flag broken URLs.

## Sensitive file — do not expose

`shill.ccny.cuny.edu_info.txt` contains **plaintext FTP and Plesk credentials** for the legacy CCNY-hosted site. It is gitignored (along with `Makefile`) but lives in the working tree. Never `cat`, paste, commit, or otherwise surface its contents. If you need to reference it conceptually, do so without quoting.

## Repository layout

- `index.qmd`, `group.qmd`, `opportunities.qmd`, `publications.qmd`, `teaching.qmd`, `resources.qmd` — top-level Quarto pages. `_quarto.yml` controls the navbar, theme, and resources copied into `_site/`.
- `teaching-interactive-demo.qmd` — unlinked-from-nav placeholder showing how Observable JS interactive demos work in Quarto. Reachable only by direct URL.
- `papers/` — paper PDFs. New papers drop a top-level PDF here (e.g. `hill-etal-science-2025-india.pdf`) plus an optional supplementary PDF.
- `cv/cv_spencer-hill.pdf` — copied (not symlinked) from `~/Dropbox/cv/`. Must be re-copied by hand whenever the canonical CV is updated; CI runners can't follow the absolute-path symlink.
- `images/` — site images, used by the live Quarto pages.
- `styles.scss` / `styles.css` — Tufte-inspired theme layered on the Cosmo base. `figure img` rules in `styles.css` are intentionally permissive about HTML-attribute heights — don't reintroduce `height: auto` here, that breaks `{height=Npx}` on `.qmd` images (see `group.qmd` photos).
- `org/`, `public_html/`, `css/`, `themes/`, `Makefile` — legacy stack, retained for archival reference. Not part of the live build (excluded from Quarto render via `project.render: ["*.qmd"]`).

## Common content edits

Quarto-only workflow now. To add a paper:
1. Drop the PDF into `papers/`.
2. Add an entry to the appropriate section of `publications.qmd` (numbered list, author formatting with `**Hill, SA**` for him, `[PDF](papers/...)` link, `[10.xxxx/...](https://doi.org/10.xxxx/...)` DOI link). **Year prefix must be backslash-escaped** as `\(YYYY\)` — Pandoc treats unescaped `(YYYY)` at the start of a list item as a nested fancy-list marker and the rendered numbering breaks.
3. Render locally with `quarto preview` or `quarto render` to verify the link works.
4. Commit and push to master — GitHub Actions deploys automatically.

Group / opportunities / teaching pages: edit the respective `.qmd` directly and follow the same render/commit/push flow.

## Permissions

`.claude/settings.local.json` (gitignored) allows direct master pushes (`Bash(git push:*)`) and read-only GitHub API calls (`gh api`, `gh run`, `gh pr view`) without prompting, so small site-maintenance commits don't require per-call confirmation. Commands that mutate shared state (`gh pr merge`, `gh repo rename/delete`, `gh release`) still prompt — keep those one-off and explicit.

## Writing style on this site

Site copy is Spencer's voice — first person, conversational, no marketing tone. Match the surrounding text's register when editing. The global em-dash and prose rules in `~/.claude/CLAUDE.md` apply to all edits here (slide text, captions, prose, commit messages).

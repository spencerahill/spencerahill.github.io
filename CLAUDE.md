# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Source for Spencer Hill's academic website. The site is mid-migration:

- **Legacy stack (currently live on master):** Emacs org-mode sources in `org/*.org` are published by Emacs into HTML files in `public_html/`, which were then pushed via FTP to CCNY hosting using the (gitignored) `Makefile`. CCNY IT policy now forces internal faculty sites under their CMS, so this stack is being retired.
- **New stack (in-progress on PR #9, branch `claude/migrate-academic-website-C6WkT`):** [Quarto](https://quarto.org/) project with `.qmd` files at the repo root, `_quarto.yml` config, and a GitHub Actions workflow that renders to `_site/` and deploys to GitHub Pages.

PR #9 adds Quarto files alongside (not in place of) the legacy `org/`, `public_html/`, `css/`, and `themes/` directories — the legacy material is retained for archival reference. Until the migration lands, edits to live content typically need to happen in **both** places (or, if the migration is approaching merge, only in the Quarto sources).

When in doubt about which stack to edit, check `gh pr view 9` and ask Spencer.

## Build and preview

**Quarto site (new):**
```sh
quarto preview        # live-reload local preview
quarto render         # full build into _site/
```
Deployment is automatic via `.github/workflows/publish.yml` on pushes to `master`.

**Legacy org-mode → HTML:** Spencer publishes by hand from Emacs (`C-c C-e P x` style, with project config in his personal `.emacs`). There is no Makefile target for the publish step itself — only for the (now-defunct) FTP push. Don't try to invoke this from Claude; ask Spencer to re-publish if HTML in `public_html/` looks stale relative to `org/`.

## Sensitive file — do not expose

`shill.ccny.cuny.edu_info.txt` contains **plaintext FTP and Plesk credentials** for the legacy CCNY-hosted site. It is gitignored (along with `Makefile`) but lives in the working tree. Never `cat`, paste, commit, or otherwise surface its contents. If you need to reference it conceptually, do so without quoting.

## Repository layout

- `org/` — legacy org-mode sources (`index.org`, `publications.org`, `group.org`, `opportunities.org`, `teaching-page.org`, `resources.org`, `about_me.org`, `macros.org`). `macros.org` defines the `SITETITLE` / `NAVBAR` / `PAGETITLE` / `LINK` / `COLOR` / `NEWLINE` macros used by every page; edit it carefully.
- `public_html/` — generated HTML from the legacy org publish. Treat as a build output even though it's checked in.
- `*.qmd` (PR #9 only) — Quarto pages. `_quarto.yml` controls the navbar, theme, and resources copied into `_site/`.
- `papers/` — paper PDFs. New papers usually drop a top-level PDF here (e.g. `hill-etal-science-2025-india.pdf`) plus an optional supplementary PDF; some older papers have their own subdirectory. Linked from `publications.org` via the `LINK` macro and (in Quarto) directly via markdown.
- `images/`, `css/`, `themes/` — assets used by the legacy site. The Quarto site uses `images/` plus its own `styles.scss` / `styles.css`.
- `cv/` — symlink/copy area for the CV PDF (`cv_spencer-hill.pdf`); the canonical CV source lives in `~/Dropbox/cv` and is copied here.

## Common content edits

When Spencer asks to "add the paper" or "update publications," the change typically spans:
1. Drop the PDF into `papers/`.
2. Add an entry to the appropriate section of `org/publications.org` using existing entry style (numbered list, author formatting with `*Hill, SA*` for him, `LINK` macro for the PDF, `doi:` link).
3. Re-publish from Emacs to refresh `public_html/publications.html`.
4. If the Quarto migration has landed, mirror the entry in `publications.qmd`.

Group/opportunities/teaching pages follow the same pattern in their respective org files.

## Writing style on this site

Site copy is Spencer's voice — first person, conversational, no marketing tone. Match the surrounding text's register when editing. The global em-dash and prose rules in `~/.claude/CLAUDE.md` apply to all edits here (slide text, captions, prose, commit messages).

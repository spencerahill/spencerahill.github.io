# Source code for Spencer Hill's academic website

This repository houses the source for [my academic website](https://spencerahill.github.io/).

The site is built with [Quarto](https://quarto.org/) and deployed to GitHub
Pages via the workflow in `.github/workflows/publish.yml`.

## Local development

```sh
# Install Quarto: https://quarto.org/docs/get-started/
quarto preview        # live-reload preview at http://localhost:xxxx
quarto render         # full build into _site/
```

## Structure

- `index.qmd`, `group.qmd`, `opportunities.qmd`, `publications.qmd`,
  `teaching.qmd`, `resources.qmd`, `about.qmd` — top-level pages
- `blog/` — blog with listing page and dated posts under `blog/posts/`
- `images/`, `papers/` — static assets served as-is
- `styles.scss`, `styles.css` — Tufte-inspired theme layered on the Cosmo base
- `_quarto.yml` — site config, navigation, formats
- `org/`, `public_html/`, `css/style.css` — retained for archival reference;
  these are the legacy org-mode sources and their generated HTML

## Deploy

Pushes to `main` trigger a GitHub Actions build that publishes the rendered
`_site/` directory to GitHub Pages. Configure a custom domain by adding a
`CNAME` file at the repo root and updating `_quarto.yml` `site-url`.

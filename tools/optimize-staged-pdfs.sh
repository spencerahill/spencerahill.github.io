#!/usr/bin/env bash
#
# Shrink any PDF about to be committed, then re-stage it.
#
# Installed as the repository's pre-commit hook (see tools/install-hooks.sh),
# so that a paper dropped into papers/ is optimized before it ever reaches
# the published site.
#
# This runs optpdf in its default lossless mode, which never re-renders a
# page: the published PDF is pixel for pixel what the publisher produced and
# extracts the same text byte for byte, and optpdf checks both before writing
# anything. Measured over the 32 PDFs in papers/ on 2026-09-16, that takes
# the directory to 92.5% of its size with the text identical on all 32.
#
# Settings:
#   PDF_OPT_DPI=300   ALSO downsample images to this resolution, which does
#                     change how figures look. Off by default. Ghostscript
#                     alters the extracted text of about half of a typical
#                     paper collection, and optpdf keeps the original in
#                     every such case, so expect this to be refused often.
#   SKIP_PDF_OPT=1    skip this entirely for one commit
#
# This hook never blocks a commit. A missing optpdf, a missing Ghostscript or
# a failed conversion produces a message and the commit proceeds.

set -uo pipefail

[ "${SKIP_PDF_OPT:-0}" = "1" ] && exit 0

# Empty means optpdf's default, which is lossless.
dpi=${PDF_OPT_DPI:-}
optpdf_args=(-q)
[ -n "$dpi" ] && optpdf_args+=(-d "$dpi")

if ! command -v optpdf >/dev/null 2>&1; then
    echo "optimize-staged-pdfs: optpdf is not on PATH; leaving PDFs alone" >&2
    exit 0
fi

root=$(git rev-parse --show-toplevel) || exit 0

# Staged additions and modifications only; a deleted or renamed-away path has
# nothing to optimize.
staged=$(git diff --cached --name-only --diff-filter=AM -z | tr '\0' '\n' | grep -i '\.pdf$')
[ -n "$staged" ] || exit 0

total_before=0
total_after=0
touched=0

while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    abs="$root/$rel"
    [ -f "$abs" ] || continue

    # If the working tree copy differs from what is staged, optimizing the
    # working tree and re-adding it would sweep in a change the commit was
    # not meant to carry. Leave those alone and say so.
    if ! git diff --quiet -- "$rel"; then
        echo "optimize-staged-pdfs: $rel differs between the index and the working tree; skipping" >&2
        continue
    fi

    before=$(wc -c < "$abs" | tr -d ' ')
    if ! optpdf "${optpdf_args[@]}" "$abs"; then
        echo "optimize-staged-pdfs: optpdf declined $rel; committing it as is" >&2
        continue
    fi
    after=$(wc -c < "$abs" | tr -d ' ')

    if [ "$after" -lt "$before" ]; then
        git add -- "$rel"
        pct=$((after * 100 / before))
        printf 'optimize-staged-pdfs: %s %d -> %d bytes (%d%%)\n' "$rel" "$before" "$after" "$pct"
        total_before=$((total_before + before))
        total_after=$((total_after + after))
        touched=$((touched + 1))
    fi
done <<< "$staged"

if [ "$touched" -gt 0 ]; then
    printf 'optimize-staged-pdfs: %d file(s), %d bytes saved in total\n' \
        "$touched" "$((total_before - total_after))"
fi

exit 0

#!/usr/bin/env bash
#
# Shrink any PDF about to be committed, then re-stage it.
#
# Installed as the repository's pre-commit hook (see tools/install-hooks.sh),
# so that a paper dropped into papers/ is optimized before it ever reaches
# the published site. Measured over the 32 PDFs already in papers/, the
# default 300 dpi setting takes the directory from 72.3 MB to 62.6 MB while
# keeping figures at print resolution.
#
# optpdf keeps the original whenever Ghostscript's output is larger or has
# lost text, so a file this leaves alone is a file that could not be shrunk
# safely.
#
# Settings:
#   PDF_OPT_DPI=300   resolution to downsample images to; 0 disables
#                     downsampling and only restructures the file
#   SKIP_PDF_OPT=1    skip this entirely for one commit
#
# This hook never blocks a commit. A missing optpdf, a missing Ghostscript or
# a failed conversion produces a message and the commit proceeds.

set -uo pipefail

[ "${SKIP_PDF_OPT:-0}" = "1" ] && exit 0

dpi=${PDF_OPT_DPI:-300}

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
    if ! optpdf -q -d "$dpi" "$abs"; then
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

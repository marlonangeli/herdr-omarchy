#!/bin/sh
# Apply patches/herdr-browser.patch to Herdr's browser helper, once.
# Usage: apply-herdr-browser.sh [helper folder]
# With a folder argument the helper that is running is left alone.
patch_file=$(cd "$(dirname "$0")" && pwd)/herdr-browser.patch
dir=${1:-$HOME/.local/share/herdr-browser}

[ -f "$dir/helper.mjs" ] || { echo "no herdr-browser helper in $dir" >&2; exit 1; }
if patch -d "$dir" -p1 -R -f -s --dry-run <"$patch_file" >/dev/null 2>&1; then
  echo "herdr-browser patch already applied"
  exit 0
fi
if ! patch -d "$dir" -p1 -f -s --dry-run <"$patch_file" >/dev/null 2>&1; then
  echo "herdr-browser patch does not fit the helper in $dir: its version changed, nothing was changed" >&2
  exit 1
fi
patch -d "$dir" -p1 -f -s <"$patch_file" || exit 1
echo "herdr-browser patch applied"

[ -n "$1" ] && exit 0
if ! command -v node >/dev/null 2>&1; then
  echo "node is not on PATH: herdr-browser needs it, so the helper was not restarted" >&2
  exit 0
fi
if herdr-browser status >/dev/null 2>&1; then
  herdr-browser stop && herdr-browser start && echo "herdr-browser restarted"
fi

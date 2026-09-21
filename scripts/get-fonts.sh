#!/bin/bash
# Download XCharter, the free extension of Bitstream Charter used by the TU/e
# theme, from CTAN into a font folder.
#
#   scripts/get-fonts.sh                        # into tmp/fonts (check.sh uses it)
#   scripts/get-fonts.sh ~/.local/share/fonts   # install for your user (Linux)

set -eu
cd "$(dirname "$0")/.."
dest="${1:-tmp/fonts}"
mkdir -p tmp
work=$(mktemp -d tmp/fonts-download.XXXXXX)
trap 'rm -rf "$work"' EXIT

curl -fsSL -o "$work/xcharter.zip" https://mirrors.ctan.org/fonts/xcharter.zip
unzip -q "$work/xcharter.zip" -d "$work"
mkdir -p "$dest"
find "$work" -name 'XCharter-*.otf' -exec cp {} "$dest/" \;
echo "XCharter installed in $dest"

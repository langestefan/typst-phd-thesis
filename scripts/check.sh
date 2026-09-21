#!/bin/bash
# Compile every test thesis, the template and the example; fail on any error
# or warning. tests/features.typ holds `assert`s on numbering and page logic.
# PDFs and PNG previews land in tmp/ (gitignored) for visual inspection.
#
#   scripts/check.sh            # compile + previews
#   scripts/check.sh --no-png   # compile only

set -u
cd "$(dirname "$0")/.." || exit 1

# Override the compiler with TYPST=/path/to/typst (CI tests several versions).
TYPST="${TYPST:-typst}"
# Fonts fetched by scripts/get-fonts.sh (XCharter for the TU/e theme).
fonts=()
[ -d tmp/fonts ] && fonts=(--font-path tmp/fonts)
out=tmp/check
rm -rf "$out"; mkdir -p "$out"
pass=0
fail=0

# compile <src> <name-suffix> [extra typst args...]
compile() {
  local src="$1" suffix="$2" name
  shift 2
  name=$(basename "$(dirname "$src")")-$(basename "$src" .typ)$suffix
  local log="$out/$name.log"
  if "$TYPST" compile --root . "${fonts[@]}" "$@" "$src" "$out/$name.pdf" >"$log" 2>&1 && ! grep -qE '^(warning|error)' "$log"; then
    printf '  ok    %-24s %s pages\n' "$name" "$(pdfinfo "$out/$name.pdf" 2>/dev/null | awk '/^Pages/ {print $2}')"
    pass=$((pass + 1))
    if [ "$NO_PNG" = 0 ]; then
      pdftoppm -r 50 -png "$out/$name.pdf" "$out/$name"
    fi
  else
    printf '  FAIL  %s\n' "$name"; sed 's/^/        /' "$log"
    fail=$((fail + 1))
  fi
}

NO_PNG=0
[ "${1:-}" = "--no-png" ] && NO_PNG=1
for f in tests/tue.typ tests/plain.typ tests/features.typ template/main.typ \
  examples/tue/main.typ examples/plain/main.typ; do
  compile "$f" ""
done

echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ]

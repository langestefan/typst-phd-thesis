# CLAUDE.md

This file guides Claude Code (claude.ai/code) when working in this repository.

## What this is

`thesis-tue` is a Typst PhD thesis package (`@local/thesis-tue:0.1.0`, entrypoint `src/lib.typ`) with two themes, `tue-theme` and `plain-theme`. It has no `@preview` dependencies. It is installed by symlinking the repo to `~/.local/share/typst/packages/local/thesis-tue/0.1.0`. `template/` is what `typst init` copies. Sibling project with the same conventions: `../typst-beamer-tue`.

```bash
scripts/check.sh                          # compile tests, template and example; fail on any warning; PNGs in tmp/check/
TYPST=/path/to/typst scripts/check.sh     # same, with another compiler version
typstyle --check src tests template examples   # formatting, as enforced by CI
```

CI (`.github/workflows/`):
- `tests.yml` runs `check.sh` and a `typst init` smoke test on Typst 0.14.2 and on the latest release (`compiler` minimum in `typst.toml` is 0.14.0).
- `lint.yml` runs `typstyle` 0.15.1 (pinned) and `shellcheck`.

Keep the sources `typstyle`-clean. If you bump the pinned `typstyle`, reformat in the same change.

## Architecture

- `src/core.typ` holds the engine: `thesis(...)` (page geometry, typography, chapter openers, running headers, per-chapter numbering) and the matter switches `front-matter`, `main-matter`, `appendix`, `back-matter`.
- `thesis` writes its configuration (kind, palette, heading font, metadata) into the `thesis-config` state (`src/helpers.typ`). `src/front.typ` and `src/back.typ` read it back in `context`, so page functions take no metadata arguments.
- `kind` (`"tue"` or `"plain"`) selects the chapter-opener and title/committee-page layouts. `src/themes/*.typ` only choose kind, palette and fonts; a new theme should be another thin wrapper.
- Fixed wording lives in `_terms` (`helpers.typ`), per language. `term(key, lang)` is a plain function so its result can go into heading bodies (outline entries, PDF bookmarks); callers read `text.lang` in their own context.

## Gotchas

- `pagebreak(to:)` counts **physical** pages, and the pages it inserts still get the header and footer. `_clear-to` brackets each parity break with `<thesis-break-start>`/`<thesis-break-end>` markers, and `_bare-page` hides header and footer on pages between them. A start marker at the very top of a page (after a plain `pagebreak`) also marks that page as blank.
- Title, committee and colophon pages go through `_special-page`, which marks the page `<thesis-plain-page>` (no header or footer) and turns off draft line numbers.
- `main-matter` clears to an odd physical page *before* resetting the page counter, so logical and physical parity agree for the rest of the book.
- Figure and equation numbering functions read `counter(heading)` and `thesis-appendix`; the chapter show rule resets the figure (image, table, raw) and equation counters.
- The chapter supplement ("Chapter"/"Hoofdstuk", "Appendix"/"Bijlage") is set with a show-set rule on level-1 headings so `@ref`s pick it up; sections keep Typst's localised "Section".
- `publications` uses `cite(form: "full")` with APA by default: IEEE full citations start with the `[n]` label.
- Themes pass the document body through `..args` to `thesis(...)`; do not turn them into `thesis.with(...)`, or `#show: tue-theme.with(...)` returns a function instead of content.
- Typst on this machine cannot read or write `/tmp` (it has a private `/tmp`). Put scratch compiles under the repo's `tmp/`, which is gitignored.

## Verification

Run `scripts/check.sh`, then look at the PNGs in `tmp/check/`. `tests/features.typ` asserts the structural invariants (chapters on odd pages, roman/arabic page numbering, per-chapter and appendix numbering, Dutch supplements); a regression fails the compile.

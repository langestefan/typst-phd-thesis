# CLAUDE.md

This file guides Claude Code (claude.ai/code) when working in this repository.

## What this is

`thesis-tue` is a Typst PhD thesis package (`@local/thesis-tue:0.1.0`, entrypoint `src/lib.typ`) with two themes, `tue-theme` and `plain-theme`. Its one `@preview` dependency is `alexandria` 0.2.2, for the second (own-publications) bibliography. It is installed by symlinking the repo to `~/.local/share/typst/packages/local/thesis-tue/0.1.0`. `template/` is what `typst init` copies. Sibling project with the same conventions: `../typst-beamer-tue`.

```bash
scripts/get-fonts.sh                      # once: XCharter (TU/e theme font) into tmp/fonts
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
- `kind` (`"tue"` or `"plain"`) selects the chapter-opener, running-head and title/committee-page layouts. The TU/e look is modelled on a classic TU/e LaTeX thesis (Charter, `1 | Introduction`, bold heads with the page number behind a bar, no footer); keep it monochrome, `tue-red` only reaches `accent`/`highlight-box`. `src/themes/*.typ` only choose kind, palette and fonts; a new theme should be another thin wrapper.
- Fixed wording lives in `_terms` (`helpers.typ`), per language. `term(key, lang)` is a plain function so its result can go into heading bodies (outline entries, PDF bookmarks); callers read `text.lang` in their own context.

## Gotchas

- `pagebreak(to:)` counts **physical** pages, and the pages it inserts still get the header and footer. `_clear-to` brackets each parity break with `<thesis-break-start>`/`<thesis-break-end>` markers, and `_bare-page` hides header and footer on pages between them. A start marker at the very top of a page (after a plain `pagebreak`) also marks that page as blank.
- Title, committee and colophon pages go through `_special-page`, which marks the page `<thesis-plain-page>` (no header or footer) and turns off draft line numbers.
- `main-matter` clears to an odd physical page *before* resetting the page counter, so logical and physical parity agree for the rest of the book.
- Figure and equation numbering functions read `counter(heading)` and `thesis-appendix` at `here()`. Anything that displays a figure number elsewhere (the lists of figures) must call `_in-chapter(n, "1.1", loc:)` with the figure's location, or it gets the list's chapter. The chapter show rule resets the figure (image, table, raw) and equation counters.
- Typst warns once per unknown font family, even inside a fallback list, and `check.sh` fails on warnings. Keep the TU/e font list to XCharter plus a Typst-bundled fallback, and run `scripts/get-fonts.sh` before `check.sh`.
- The chapter supplement ("Chapter"/"Hoofdstuk", "Appendix"/"Bijlage") is set with a show-set rule on level-1 headings so `@ref`s pick it up; sections keep Typst's localised "Section".
- Own publications are a second bibliography via alexandria: `thesis` registers the `pub:` prefix (show rule) and loads `publications-bib` with `assets/ieee-publications.csl` (IEEE with `P` numbers, sorted by date; CC BY-SA, keep its header). `publications()` renders `get-bibliography` itself and must place a `label(prefix + key)` for every entry, or `@pub:key` citations fail with "label does not exist". The `.bib` contents come from the user's file (`read(...)` there), because `read` in the package resolves package-relative paths.
- Themes pass the document body through `..args` to `thesis(...)`; do not turn them into `thesis.with(...)`, or `#show: tue-theme.with(...)` returns a function instead of content.
- Typst on this machine cannot read or write `/tmp` (it has a private `/tmp`). Put scratch compiles under the repo's `tmp/`, which is gitignored.

## Verification

Run `scripts/check.sh`, then look at the PNGs in `tmp/check/`. `tests/features.typ` asserts the structural invariants (chapters on odd pages, roman/arabic page numbering, per-chapter and appendix numbering, Dutch supplements); a regression fails the compile.

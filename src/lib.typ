// thesis-tue — PhD thesis template: `tue-theme` and `plain-theme`.
//
//   #import "@local/thesis-tue:0.1.0": *
//   #show: tue-theme.with(title: [...], author: "...", defense: datetime(...))
//   #title-page()
//
// See README.md for the full document skeleton.

#import "helpers.typ": (
  accent, format-date-en, format-date-nl, highlight-box, thesis-config,
)
#import "core.typ": (
  appendix, back-matter, front-matter, main-matter, thesis, thesis-appendix,
)
#import "front.typ": (
  colophon, committee-page, contents, half-title, list-of-figures,
  list-of-tables, samenvatting, summary, title-page,
)
#import "back.typ": acknowledgements, curriculum-vitae, publications
#import "themes/plain.typ": plain-palette, plain-theme
#import "themes/tue.typ": (
  tue-grey, tue-ink, tue-logo, tue-palette, tue-red, tue-theme,
)

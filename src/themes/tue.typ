// ============================================================================
//  TU/e theme: the classic TU/e thesis look. Charter throughout, chapters as
//  "1 | Introduction", bold running heads with the page number behind a
//  thick bar, and the Dutch doctorate title and committee pages. The layout
//  is black and white; `tue-red` colours only `accent` and `highlight-box`.
// ============================================================================

#import "../core.typ": thesis

// ---- TU/e palette ------------------------------------------------------------
// `tue-red` is the exact TU/e Red taken from the official logo (#c72125).
#let tue-red = rgb("#c72125")
#let tue-ink = rgb("#0c0c0c")
#let tue-grey = rgb("#63666a")

#let tue-palette = (
  primary: tue-red,
  ink: tue-ink,
  muted: tue-grey,
  rule: tue-grey.lighten(50%),
  link: tue-ink,
)

// The TU/e logo in any colour. The SVG uses a single fill, so recolouring is
// a string replacement. `full: false` keeps only the "TU/e" letters.
#let tue-logo(color: tue-red, full: true, ..args) = {
  let svg = read("../../assets/tue-logo.svg").replace("#c72125", color.to-hex())
  if not full {
    svg = svg.replace(
      regex("width=\"[^\"]*\"\\s+height=\"[^\"]*\"\\s+viewBox=\"[^\"]*\""),
      "viewBox=\"8.5 8.5 85.5 34.3\"",
    )
  }
  image(bytes(svg), format: "svg", ..args)
}

/// The TU/e thesis. Takes every `thesis` option (see core.typ) and passes
/// the document body through `args`; `colors` overrides palette entries,
/// e.g. `(primary: blue)`. The font is XCharter (free Charter, on CTAN; see
/// scripts/get-fonts.sh); without it Typst warns once and uses Libertinus.
#let tue-theme(
  font: ("XCharter", "Libertinus Serif"),
  institution: [Eindhoven University of Technology],
  colors: (:),
  ..args,
) = thesis(
  kind: "tue",
  palette: tue-palette + colors,
  font: font,
  institution: institution,
  ..args,
)

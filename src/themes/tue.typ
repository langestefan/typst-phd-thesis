// ============================================================================
//  TU/e theme: Eindhoven University of Technology house colours, sans-serif
//  headings with red chapter numbers, and the Dutch doctorate title and
//  committee pages.
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
  link: tue-red,
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
/// the document body through `args`; `colors`
/// overrides palette entries, e.g. `(primary: blue)`.
#let tue-theme(
  heading-font: ("Noto Sans", "Liberation Sans", "DejaVu Sans"),
  institution: [Eindhoven University of Technology],
  colors: (:),
  ..args,
) = thesis(
  kind: "tue",
  palette: tue-palette + colors,
  heading-font: heading-font,
  institution: institution,
  ..args,
)

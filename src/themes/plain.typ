// ============================================================================
//  Plain theme: institution-neutral, serif throughout, slate accents and an
//  English title and committee page.
// ============================================================================

#import "../core.typ": thesis
#import "../helpers.typ": _default-palette

#let plain-palette = _default-palette

/// A neutral thesis. Takes every `thesis` option (see core.typ); `colors`
/// overrides palette entries.
#let plain-theme(colors: (:), ..args) = thesis(
  kind: "plain",
  palette: plain-palette + colors,
  ..args,
)

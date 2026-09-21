// ============================================================================
//  Shared state and small helpers. `thesis` (core.typ) writes the document's
//  configuration into `thesis-config` once; the front- and back-matter
//  functions read it back, so they need no arguments the author already gave.
// ============================================================================

// Fallback palette, used only when a helper runs outside a themed document.
// Every theme palette must define all of these keys.
#let _default-palette = (
  primary: rgb("#2f3e52"), // chapter numbers, heading accents
  ink: rgb("#111111"), // body text
  muted: rgb("#6b7280"), // running headers, captions labels, secondary text
  rule: rgb("#c8ccd2"), // header rule, table rules
  link: rgb("#2f3e52"), // URL links
)

// The document's configuration: theme kind, palette, heading font and the
// thesis metadata (title, author, defence, ...). Set by `thesis` at the start.
#let thesis-config = state("thesis-tue-config", (
  kind: "plain",
  palette: _default-palette,
  heading-font: "Libertinus Serif",
  info: (:),
))

// Fixed wording, per language: `term("contents", "nl")`. A plain function, not
// `context`, so the result can go into heading bodies (outline, PDF bookmarks);
// callers read the language from `text.lang` inside their own context.
#let _terms = (
  en: (
    chapter: "Chapter",
    appendix: "Appendix",
    contents: "Contents",
    figures: "List of Figures",
    tables: "List of Tables",
    bibliography: "Bibliography",
    summary: "Summary",
    acknowledgements: "Acknowledgements",
    cv: "Curriculum Vitae",
    publications: "List of Publications",
    draft: "Draft",
  ),
  nl: (
    chapter: "Hoofdstuk",
    appendix: "Bijlage",
    contents: "Inhoudsopgave",
    figures: "Lijst van figuren",
    tables: "Lijst van tabellen",
    bibliography: "Bibliografie",
    summary: "Samenvatting",
    acknowledgements: "Dankwoord",
    cv: "Curriculum vitae",
    publications: "Lijst van publicaties",
    draft: "Concept",
  ),
)

#let term(key, lang) = _terms.at(lang, default: _terms.en).at(key)

// ---- Dates ------------------------------------------------------------------
#let _months-nl = (
  "januari",
  "februari",
  "maart",
  "april",
  "mei",
  "juni",
  "juli",
  "augustus",
  "september",
  "oktober",
  "november",
  "december",
)
#let _weekdays-nl = (
  "maandag",
  "dinsdag",
  "woensdag",
  "donderdag",
  "vrijdag",
  "zaterdag",
  "zondag",
)

/// A date in Dutch, e.g. "dinsdag 1 juli 2025". `weekday: false` drops the
/// day name. With `time: true` the date must carry a time: "... om 16:00 uur".
#let format-date-nl(date, weekday: true, time: false) = {
  let s = (
    str(date.day())
      + " "
      + _months-nl.at(date.month() - 1)
      + " "
      + str(date.year())
  )
  if weekday { s = _weekdays-nl.at(date.weekday() - 1) + " " + s }
  if time { s += " om " + date.display("[hour]:[minute]") + " uur" }
  s
}

/// A date in English, e.g. "Tuesday 1 July 2025" (or "1 July 2025").
#let format-date-en(date, weekday: true, time: false) = {
  let s = date.display("[day padding:none] [month repr:long] [year]")
  if weekday { s = date.display("[weekday]") + " " + s }
  if time { s += " at " + date.display("[hour]:[minute]") }
  s
}

// ---- Content helpers ----------------------------------------------------------

/// Inline emphasis in the theme's primary colour.
#let accent(body) = context text(
  fill: thesis-config.get().palette.primary,
  weight: "bold",
  body,
)

/// A tinted callout box with a stripe in the theme's primary colour.
#let highlight-box(title: none, width: 100%, body) = context {
  let p = thesis-config.get().palette
  block(
    fill: p.primary.lighten(90%),
    inset: 8pt,
    width: width,
    stroke: (left: 2pt + p.primary),
    {
      if title != none {
        text(weight: "bold", fill: p.primary, title)
        linebreak()
      }
      body
    },
  )
}

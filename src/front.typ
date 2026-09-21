// ============================================================================
//  Front matter: half-title, colophon, title page, committee page, summary
//  and the tables of contents. Each page function reads the thesis metadata
//  from `thesis-config`; `kind` picks the TU/e (Dutch) or plain wording.
// ============================================================================

#import "helpers.typ": format-date-en, format-date-nl, term, thesis-config
#import "core.typ": _clear-to, _plain-page-marker

// A page with no header and no footer, on a recto ("odd") or verso ("even")
// page. The body fills the page, so `v(1fr)` inside it positions content.
#let _special-page(parity, body) = {
  _clear-to(parity)
  _plain-page-marker
  set par(first-line-indent: 0pt, justify: false)
  set par.line(numbering: none)
  block(width: 100%, height: 100%, breakable: false, body)
  pagebreak(weak: true)
}

// A visible stand-in for metadata the author has not filled in yet.
#let _missing(what) = text(fill: red)[[#what]]

// ---- Half-title --------------------------------------------------------------

/// A recto page with only the title and subtitle.
#let half-title() = context {
  let cfg = thesis-config.get()
  let i = cfg.info
  _special-page("odd", {
    v(25%)
    align(center, {
      text(font: cfg.heading-font, size: 1.9em, weight: "bold", i.title)
      if i.subtitle != none {
        v(0.8em)
        text(size: 1.2em, i.subtitle)
      }
    })
  })
}

// ---- Title page ----------------------------------------------------------------

#let _title-block(cfg) = {
  let i = cfg.info
  text(font: cfg.heading-font, size: 1.9em, weight: "bold", i.title)
  if i.subtitle != none {
    v(0.6em)
    text(size: 1.2em, i.subtitle)
  }
}

// The TU/e doctorate title page, in Dutch as the doctorate regulations
// require.
#let _title-page-tue(cfg) = {
  let i = cfg.info
  set text(lang: "nl")
  set align(center)
  v(6mm)
  _title-block(cfg)
  v(1fr)
  text(size: 1.1em, weight: "bold", tracking: 0.25em)[PROEFSCHRIFT]
  v(1.4em)
  block(width: 88%, {
    let rector = if i.rector == none { _missing("rector magnificus") } else {
      i.rector
    }
    let defense = if i.defense == none { _missing("datum en tijd") } else {
      format-date-nl(i.defense, time: true)
    }
    [ter verkrijging van de graad van doctor aan de Technische Universiteit
      Eindhoven, op gezag van de rector magnificus #rector, voor een commissie
      aangewezen door het College voor Promoties, in het openbaar te verdedigen
      op #defense]
  })
  v(1.4em)
  [door]
  v(1.4em)
  text(size: 1.2em, weight: "bold", i.full-name)
  v(1.4em)
  [geboren te #if i.birthplace == none { _missing("geboorteplaats") } else { i.birthplace }]
  v(1fr)
}

#let _title-page-plain(cfg) = {
  let i = cfg.info
  set align(center)
  v(6mm)
  _title-block(cfg)
  v(1fr)
  [A thesis submitted for the degree of]
  v(0.4em)
  text(size: 1.1em, weight: "bold", i.degree)
  if i.institution != none {
    v(0.4em)
    [at #i.institution]
  }
  v(2em)
  [by]
  v(0.8em)
  text(size: 1.2em, weight: "bold", i.full-name)
  v(1fr)
  if i.defense != none {
    [To be defended on #format-date-en(i.defense, time: true)]
  } else { format-date-en(i.date, weekday: false) }
  v(4mm)
}

/// The official title page, on a recto page. TU/e: the Dutch "proefschrift"
/// wording with rector, defence date and birthplace from the theme options.
#let title-page() = context {
  let cfg = thesis-config.get()
  _special-page("odd", if cfg.kind == "tue" { _title-page-tue(cfg) } else {
    _title-page-plain(cfg)
  })
}

// ---- Committee page ----------------------------------------------------------------

// Label/name rows: the label only on the first row of each group.
#let _rows(label, names) = {
  if type(names) != array { names = (names,) }
  names
    .enumerate()
    .map(((k, n)) => (if k == 0 { label } else { [] }, n))
    .flatten()
}

/// The promotion committee, on the verso of the title page. Each argument is
/// a name or an array of names, e.g. "prof.dr.ir. A. Jansen (TU Delft)".
/// `statement`: auto gives the TU/e research-integrity statement (tue theme)
/// or nothing (plain); pass content to replace it or none to drop it.
#let committee-page(
  chair: none,
  promotors: (),
  copromotors: (),
  members: (),
  advisors: (),
  statement: auto,
) = context {
  let cfg = thesis-config.get()
  let tue = cfg.kind == "tue"
  let many(x) = type(x) == array and x.len() > 1
  let empty(x) = x == none or x == ()

  let rows = ()
  if not empty(chair) {
    rows += _rows(if tue [voorzitter:] else [Chair:], chair)
  }
  let proms = if type(promotors) == array { promotors } else { (promotors,) }
  if proms.len() == 1 {
    rows += _rows(if tue [promotor:] else [Promotor:], proms)
  } else {
    for (k, pr) in proms.enumerate() {
      rows += if tue { ([#(k + 1)#super[e] promotor:], pr) } else {
        ([Promotor #(k + 1):], pr)
      }
    }
  }
  if not empty(copromotors) {
    let label = if tue {
      if many(copromotors) [copromotoren:] else [copromotor:]
    } else {
      if many(copromotors) [Copromotors:] else [Copromotor:]
    }
    rows += _rows(label, copromotors)
  }
  if not empty(members) {
    rows += _rows(if tue [leden:] else [Members:], members)
  }
  if not empty(advisors) {
    let label = if tue {
      if many(advisors) [adviseurs:] else [adviseur:]
    } else {
      if many(advisors) [Advisors:] else [Advisor:]
    }
    rows += _rows(label, advisors)
  }

  let stmt = if statement == auto {
    if tue [Het onderzoek of ontwerp dat in dit proefschrift wordt beschreven is
      uitgevoerd in overeenstemming met de TU/e Gedragscode
      Wetenschapsbeoefening.]
  } else { statement }

  _special-page("even", {
    set text(lang: "nl") if tue
    if tue [Dit proefschrift is goedgekeurd door de promotoren en de samenstelling
      van de promotiecommissie is als volgt:] else [The doctoral committee:]
    v(1.2em)
    grid(columns: (auto, 1fr), column-gutter: 1.2em, row-gutter: 0.65em, ..rows)
    v(1fr)
    if stmt != none { stmt }
  })
}

// ---- Colophon --------------------------------------------------------------------

/// The colophon, on the verso of the half-title: set at the foot of the page.
/// `catalogue`: auto gives the TU/e library line (tue theme). `copyright`:
/// auto gives "© <year> <author>". `note` adds free text above it all.
#let colophon(
  isbn: none,
  printed-by: none,
  cover: none,
  funding: none,
  catalogue: auto,
  copyright: auto,
  note: none,
) = context {
  let cfg = thesis-config.get()
  let i = cfg.info
  let cat = if catalogue == auto {
    if cfg.kind == "tue" [A catalogue record is available from the Eindhoven
      University of Technology Library.]
  } else { catalogue }
  let copy = if copyright == auto [
    © #i.date.year() #i.author. All rights reserved. No part of this
    publication may be reproduced, stored or transmitted in any form or by any
    means without prior written permission of the copyright owner.
  ] else { copyright }

  _special-page("even", {
    set text(size: 0.85em)
    set par(spacing: 1.1em)
    v(1fr)
    if note != none { par(note) }
    if funding != none { par(funding) }
    if cat != none { par(cat) }
    if isbn != none { par[ISBN: #isbn] }
    let credits = ()
    if cover != none { credits.push[Cover design: #cover] }
    if printed-by != none { credits.push[Printed by: #printed-by] }
    if credits.len() > 0 { par(credits.join(linebreak())) }
    if copy != none { par(copy) }
  })
}

// ---- Summary and contents ----------------------------------------------------------

/// An unnumbered chapter with a summary. `lang: "nl"` sets it in Dutch and
/// titles it "Samenvatting"; `title` overrides the heading.
#let summary(lang: auto, title: auto, body) = context {
  let l = if lang == auto { text.lang } else { lang }
  set text(lang: l)
  heading(level: 1, numbering: none, if title == auto {
    term("summary", l)
  } else { title })
  body
}

/// The Dutch summary.
#let samenvatting = summary.with(lang: "nl")

/// The table of contents: chapters in bold, down to `depth`.
#let contents(depth: 2, title: auto) = context {
  show outline.entry.where(level: 1): set block(above: 1.1em)
  show outline.entry.where(level: 1): set text(weight: "bold")
  show outline.entry.where(level: 1): set outline.entry(fill: none)
  outline(
    title: if title == auto { term("contents", text.lang) } else { title },
    depth: depth,
  )
}

/// The list of figures.
#let list-of-figures(title: auto) = context outline(
  title: if title == auto { term("figures", text.lang) } else { title },
  target: figure.where(kind: image),
)

/// The list of tables.
#let list-of-tables(title: auto) = context outline(
  title: if title == auto { term("tables", text.lang) } else { title },
  target: figure.where(kind: table),
)

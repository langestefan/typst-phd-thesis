// ============================================================================
//  Front matter: half-title, title page, committee page, colophon, summary
//  and the tables of contents. Each page function reads the thesis metadata
//  from `thesis-config`; `kind` picks the TU/e (Dutch) or plain wording.
// ============================================================================

#import "helpers.typ": format-date-en, format-date-nl, term, thesis-config
#import "core.typ": _clear-to, _in-chapter, _plain-page-marker, thesis-appendix

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

// The title and subtitle. On the title page (`semantic: true`) the title is
// Typst's `title` element, which tags it as the document title in the PDF;
// a document has exactly one, so the half-title sets plain text.
#let _title-block(cfg, size: 1.9em, semantic: false) = {
  let i = cfg.info
  if semantic {
    // `size` is relative to the body text, not to the title's own default
    // size, so resolve it here (the callers run in `context`).
    show title: set text(
      font: cfg.heading-font,
      size: size.abs + size.em * text.size,
      weight: "bold",
    )
    show title: set block(above: 0pt, below: 0.6em)
    title(i.title)
  } else {
    text(font: cfg.heading-font, size: size, weight: "bold", i.title)
  }
  if i.subtitle != none {
    v(0.6em)
    text(size: 1.2em, i.subtitle)
  }
}

// ---- Half-title --------------------------------------------------------------

/// A recto page with only the title and subtitle.
#let half-title() = context {
  let cfg = thesis-config.get()
  _special-page("odd", {
    v(25%)
    align(center, _title-block(cfg))
  })
}

// ---- Title page ----------------------------------------------------------------

// The TU/e doctorate title page, in Dutch as the doctorate regulations
// require. Plain serif throughout, as TU/e theses traditionally set it.
#let _title-page-tue(cfg) = {
  let i = cfg.info
  set text(lang: "nl")
  set align(center)
  v(4mm)
  _title-block(cfg, size: 1.6em, semantic: true)
  v(2fr)
  [PROEFSCHRIFT]
  v(1.6fr)
  block(width: 80%, {
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
  v(1.6fr)
  [door]
  v(0.9fr)
  text(size: 1.1em, i.full-name)
  v(0.7fr)
  [geboren te #if i.birthplace == none { _missing("geboorteplaats") } else {
      i.birthplace
    }]
  v(3fr)
}

#let _title-page-plain(cfg) = {
  let i = cfg.info
  set align(center)
  v(6mm)
  _title-block(cfg, semantic: true)
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

// A committee entry is a name, or a (name, affiliation) pair.
#let _person(x) = if type(x) == array { x } else { (x, none) }

// A group of committee members as an array of entries. A bare pair of names
// is two people; wrap a (name, affiliation) pair once more: `((n, a),)`.
#let _people(x) = if x == none { () } else if type(x) == array { x } else {
  (x,)
}

/// The promotion committee, on the verso of the title page. Each argument is
/// one person or an array of people; a person is a name, or a (name,
/// affiliation) array: `members: (([prof.dr. A. Jansen], [TU Delft]),
/// [dr. B. de Vries])`. Affiliations get a column of their own.
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
  // (label, people, label on every row?)
  let groups = if tue {
    (
      ([Voorzitter:], chair, true),
      ([Promotor:], promotors, true),
      ([Copromotor:], copromotors, true),
      ([Leden:], members, false),
      ([Adviseur(s):], advisors, false),
    )
  } else {
    (
      ([Chair:], chair, true),
      ([Promotor:], promotors, true),
      ([Copromotor:], copromotors, true),
      ([Members:], members, false),
      ([Advisors:], advisors, false),
    )
  }
  let rows = ()
  for (label, people, every) in groups {
    for (k, x) in _people(people).enumerate() {
      let (name, aff) = _person(x)
      rows += (
        if every or k == 0 { label } else { [] },
        name,
        if aff != none [(#aff)] else { [] },
      )
    }
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
    v(1.6em)
    grid(
      columns: (auto, auto, 1fr),
      column-gutter: 1.5em,
      row-gutter: 0.55em,
      ..rows,
    )
    v(1fr)
    if stmt != none { stmt }
  })
}

// ---- Colophon --------------------------------------------------------------------

/// The colophon, set at the foot of a verso page (after the committee page,
/// so a blank recto page sits between them). `catalogue`: auto gives the
/// TU/e library line (tue theme). `copyright`: auto gives "Copyright ©
/// <year> by <author>. All Rights Reserved." `note` adds free text on top.
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
    Copyright © #i.date.year() by #i.author. All Rights Reserved.
  ] else { copyright }

  _special-page("even", {
    set text(size: 0.9em)
    set par(spacing: 1.6em)
    v(1fr)
    if note != none { par(note) }
    if funding != none { par(funding) }
    if cat != none { par(cat) }
    if isbn != none { par[ISBN: #isbn] }
    let credits = ()
    if cover != none { credits.push[Cover design by #cover] }
    if printed-by != none { credits.push[Printed by #printed-by] }
    if credits.len() > 0 { par(credits.join(linebreak())) }
    if copy != none { par(copy) }
    v(1.5cm)
  })
}

// ---- Summary and contents ----------------------------------------------------------

/// An unnumbered chapter with a summary. `lang: "nl"` sets it in Dutch and
/// titles it "Samenvatting"; `title` overrides the heading. `show-title`
/// repeats the thesis title in bold above the text (default: tue theme).
#let summary(lang: auto, title: auto, show-title: auto, body) = context {
  let cfg = thesis-config.get()
  let l = if lang == auto { text.lang } else { lang }
  set text(lang: l)
  heading(level: 1, numbering: none, if title == auto {
    term("summary", l)
  } else { title })
  if (show-title == auto and cfg.kind == "tue") or show-title == true {
    block(below: 1.5em, par(
      first-line-indent: 0pt,
      justify: false,
      text(size: 1.2em, weight: "bold", cfg.info.title),
    ))
  }
  body
}

/// The Dutch summary.
#let samenvatting = summary.with(lang: "nl")

/// The table of contents: chapters in bold without leaders, down to `depth`.
#let contents(depth: 2, title: auto) = context {
  show outline.entry.where(level: 1): set block(above: 1.3em)
  show outline.entry.where(level: 1): set text(weight: "bold")
  show outline.entry.where(level: 1): set outline.entry(fill: none)
  outline(
    title: if title == auto { term("contents", text.lang) } else { title },
    depth: depth,
  )
}

// An outline of figures of one kind: "3.12  Caption ....... 45", numbers
// without the "Figure" supplement, and a gap wherever the chapter changes.
#let _figure-list(kind, title) = {
  let chapter(loc) = (
    thesis-appendix.at(loc),
    counter(heading).at(loc).first(),
  )
  show outline.entry: it => {
    let fig = it.element
    let loc = fig.location()
    let prev = query(figure.where(kind: kind).before(loc, inclusive: false))
    if prev.len() > 0 and chapter(prev.last().location()) != chapter(loc) {
      v(0.8em)
    }
    let number = _in-chapter(fig.counter.at(loc).first(), "1.1", loc: loc)
    link(loc, it.indented(number, it.inner(), gap: 1em))
  }
  outline(title: title, target: figure.where(kind: kind))
}

/// The list of figures.
#let list-of-figures(title: auto) = context _figure-list(
  image,
  if title == auto { term("figures", text.lang) } else { title },
)

/// The list of tables.
#let list-of-tables(title: auto) = context _figure-list(
  table,
  if title == auto { term("tables", text.lang) } else { title },
)

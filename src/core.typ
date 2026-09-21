// ============================================================================
//  The engine. `thesis` sets up a two-sided book: page geometry, typography,
//  chapter openers on recto pages, running headers, per-chapter numbering of
//  figures, tables and equations. `front-matter`, `main-matter`,
//  `back-matter` and `appendix` switch page and heading numbering.
//
//  Themes (themes/*.typ) only choose `kind`, a palette and fonts; `kind`
//  ("tue" or "plain") selects the chapter-opener and title-page layouts.
// ============================================================================

#import "@preview/alexandria:0.2.2": alexandria, load-bibliography
#import "helpers.typ": _default-palette, term, thesis-config

// True from `appendix` on: chapters and figures are numbered A, A.1, ...
#let thesis-appendix = state("thesis-tue-appendix", false)

// ---- Page breaks and blank pages ----------------------------------------------
// `pagebreak(to:)` counts physical pages, and the pages it inserts still get
// the page header and footer. Every parity break is therefore bracketed by
// two markers; a page between a pair is blank, and `_bare-page` suppresses
// its header and footer.

#let _clear-to(parity) = {
  [#metadata(none) <thesis-break-start>]
  pagebreak(to: parity, weak: true)
  [#metadata(none) <thesis-break-end>]
}

// A page marked with this gets no header and no footer (title pages etc.).
#let _plain-page-marker = [#metadata(none) <thesis-plain-page>]

// Call in context. Whether physical page `p` has no header and no footer.
#let _bare-page(p) = {
  let starts = query(<thesis-break-start>)
  let ends = query(<thesis-break-end>)
  // A start marker at the very top of a page (no higher than the end marker,
  // which always opens its page) means nothing precedes it: that page is
  // blank too. This happens after a `pagebreak` that ended the previous page.
  let blank = starts
    .zip(ends)
    .any(((s, e)) => {
      let (s, e) = (s.location().position(), e.location().position())
      (s.page < p or (s.page == p and s.y <= e.y)) and p < e.page
    })
  let plain = query(<thesis-plain-page>).any(m => m.location().page() == p)
  blank or plain
}

// ---- Numbering --------------------------------------------------------------

// Call in context. A figure or equation number within its chapter: "3.2"
// in the main matter, "A.2" in appendices, just "2" before the first
// chapter. `loc` is where to read the chapter; auto means here, which is
// right for the numbering itself but not for lists of figures.
#let _in-chapter(n, pattern, loc: auto) = {
  let at = if loc == auto { here() } else { loc }
  let ch = counter(heading).at(at).first()
  if ch == 0 { return numbering(pattern.replace("1.", ""), n) }
  let p = if thesis-appendix.at(at) { pattern.replace("1.", "A.") } else {
    pattern
  }
  numbering(p, ch, n)
}

// ---- Running headers ----------------------------------------------------------

// A heading as "3.2  Title", or just "Title" when it is unnumbered.
#let _mark(hd) = {
  if hd.numbering == none { return hd.body }
  let n = numbering(hd.numbering, ..counter(heading).at(hd.location()))
  [#n#h(1em)#hd.body]
}

// Call in context. The chapter running on page `p` and, on recto pages, the
// section to name there: the first one starting on the page, else the last
// one before it. None on pages without a running header.
#let _marks(p) = {
  let chapters = query(heading.where(level: 1))
  if chapters.any(h => h.location().page() == p) { return none }
  let before = chapters.filter(h => h.location().page() < p)
  if before.len() == 0 { return none }
  let chapter = before.last()
  let section = none
  if calc.odd(p) {
    let secs = query(heading.where(level: 2).after(chapter.location())).filter(
      s => s.location().page() <= p,
    )
    let here-secs = secs.filter(s => s.location().page() == p)
    if here-secs.len() > 0 { section = here-secs.first() } else if (
      secs.len() > 0
    ) { section = secs.last() }
  }
  (chapter: chapter, section: section)
}

// TU/e: the page number and a bold mark, split by a thick bar, over a rule.
// Numbered chapters show the chapter title on verso pages and the section
// on recto pages; unnumbered ones (Contents, Summary, ...) their title in
// capitals.
#let _header-tue(cfg, p, m) = {
  let ch = m.chapter
  let mark = if ch.numbering == none { upper(ch.body) } else if (
    calc.odd(p) and m.section != none
  ) { _mark(m.section) } else { ch.body }
  let num = counter(page).display()
  let bar = box(
    width: 2pt,
    height: 1em,
    fill: cfg.palette.ink,
    outset: (top: 2pt, bottom: 3pt),
  )
  set text(weight: "bold")
  block(
    width: 100%,
    stroke: (bottom: 0.5pt + cfg.palette.ink),
    inset: (bottom: 3pt),
    if calc.even(p) {
      grid(
        columns: (auto, auto, 1fr),
        column-gutter: 0.35em,
        num, bar, mark,
      )
    } else {
      grid(
        columns: (1fr, auto, auto),
        column-gutter: 0.35em,
        mark, bar, num,
      )
    },
  )
}

// Plain: a muted mark in the outer corner over a hairline; the page number
// goes in the footer.
#let _header-plain(cfg, p, m) = {
  let mark = if m.section != none { _mark(m.section) } else {
    _mark(m.chapter)
  }
  set text(size: 0.85em, fill: cfg.palette.muted)
  block(
    width: 100%,
    stroke: (bottom: 0.4pt + cfg.palette.rule),
    inset: (bottom: 3pt),
    align(if calc.even(p) { left } else { right }, mark),
  )
}

#let _header(cfg) = context {
  let p = here().page()
  if _bare-page(p) { return }
  let m = _marks(p)
  if m == none { return }
  set par(first-line-indent: 0pt, justify: false)
  if cfg.kind == "tue" { _header-tue(cfg, p, m) } else {
    _header-plain(cfg, p, m)
  }
}

// Plain: the page number in the outer corner. TU/e: nothing, the number is
// in the header (and chapter openers carry none). Draft mode adds a centred
// date stamp.
#let _footer(cfg, draft) = context {
  let p = here().page()
  if _bare-page(p) { return }
  set text(size: 0.85em)
  let num = if cfg.kind != "tue" { counter(page).display() }
  let stamp = if draft {
    text(fill: cfg.palette.muted, [#term("draft", text.lang) --- #(
        datetime.today().display()
      )])
  }
  if calc.even(p) {
    grid(
      columns: (1fr, auto, 1fr),
      align(left, num), stamp, [],
    )
  } else {
    grid(
      columns: (1fr, auto, 1fr),
      [], stamp, align(right, num),
    )
  }
}

// ---- Headings ------------------------------------------------------------------

#let _chapter-opener(it, cfg) = {
  let p = cfg.palette
  set par(first-line-indent: 0pt, justify: false)
  set text(font: cfg.heading-font)
  let number = if it.numbering != none {
    counter(heading).display(it.numbering)
  }
  if cfg.kind == "tue" {
    // "1 | Introduction", bold, a third of the way down the text block.
    block(width: 100%, above: 0pt, below: 3.5em, {
      v(2.2cm)
      set text(size: 2.2em, weight: "bold", fill: p.ink)
      if number != none {
        grid(
          columns: (auto, auto, 1fr),
          column-gutter: 0.45em,
          number,
          // Decorative: kept out of the tags, so screen readers skip it.
          pdf.artifact(text(weight: "regular", fill: p.muted.lighten(30%))[|]),
          it.body,
        )
      } else { it.body }
    })
  } else {
    block(width: 100%, above: 0pt, below: 3em, {
      v(1.5cm)
      if number != none {
        text(size: 1.3em, fill: p.muted, smallcaps[#it.supplement #number])
        v(0.6em)
      }
      text(size: 2.2em, fill: p.ink, it.body)
      v(0.3em)
      line(length: 100%, stroke: 0.5pt + p.rule)
    })
  }
}

// A numbered section heading: the number in its own column, so a long
// title wraps under the title rather than under the number.
#let _section(it) = {
  if it.numbering == none { return it }
  block(grid(
    columns: (auto, 1fr),
    column-gutter: 1em,
    counter(heading).display(it.numbering), it.body,
  ))
}

// A caption: centred when it fits on one line, otherwise with the
// "Figure 1.2:" label hanging to the left of the text.
#let _caption(it) = context {
  if it.numbering == none { return it }
  let lbl = [#it.supplement #it.counter.display(it.numbering)#it.separator]
  layout(size => {
    let one = [#lbl#it.body]
    if measure(one).width <= size.width { align(center, one) } else {
      align(left, grid(
        columns: (auto, 1fr),
        lbl, it.body,
      ))
    }
  })
}

// ---- The document ---------------------------------------------------------------

/// The thesis show rule. Themes wrap it; see themes/tue.typ.
#let thesis(
  // Metadata, read back by `title-page`, `committee-page`, `colophon`, ...
  title: [Thesis title],
  subtitle: none,
  author: "Author Name", // a string: it goes into the PDF metadata
  full-name: auto, // name on the title page (all given names); auto = author
  birthplace: none,
  defense: none, // datetime with a time of day
  rector: none,
  institution: none,
  degree: "Doctor of Philosophy",
  date: datetime.today(),
  keywords: (),
  // Own publications: a second bibliography, cited as @pub:key with labels
  // [P1], [P2], ... and listed by `publications()`. Pass the file contents
  // from your own document: `read("publications.bib")` (or an array).
  publications-bib: none,
  publications-prefix: "pub:",
  publications-style: auto, // auto: IEEE with P-numbers, sorted by date
  // Layout
  lang: "en",
  paper: (170mm, 240mm),
  margin: (inside: 24mm, outside: 20mm, top: 24mm, bottom: 24mm),
  font: "Libertinus Serif",
  heading-font: auto,
  math-font: "New Computer Modern Math",
  text-size: 10pt,
  justify: true,
  draft: false,
  kind: "plain",
  palette: _default-palette,
  body,
) = {
  let hfont = if heading-font == auto { font } else { heading-font }
  let cfg = (
    kind: kind,
    palette: _default-palette + palette,
    heading-font: hfont,
    info: (
      title: title,
      subtitle: subtitle,
      author: author,
      full-name: if full-name == auto { author } else { full-name },
      birthplace: birthplace,
      defense: defense,
      rector: rector,
      institution: institution,
      degree: degree,
      date: date,
    ),
    pub-prefix: if publications-bib != none { publications-prefix },
  )
  let pal = cfg.palette

  set document(title: title, author: author, keywords: keywords)
  set page(
    width: paper.at(0),
    height: paper.at(1),
    margin: margin,
    numbering: "i",
    header: _header(cfg),
    footer: _footer(cfg, draft),
    header-ascent: 40%,
    footer-descent: 40%,
  )
  set text(font: font, size: text-size, lang: lang, fill: pal.ink)
  set par(
    justify: justify,
    leading: 0.6em,
    spacing: 0.6em,
    first-line-indent: 1.2em,
  )
  show math.equation: set text(font: math-font)
  show raw: set text(size: 0.9em)
  show link: it => if type(it.dest) == str { text(fill: pal.link, it) } else {
    it
  }
  set par.line(numbering: n => text(size: 6pt, fill: pal.muted, str(n))) if (
    draft
  )

  // Headings. Level 1 is a chapter; its supplement makes @refs read
  // "Chapter 3". Sections keep Typst's localised "Section".
  set heading(numbering: none)
  show heading: set text(font: hfont)
  show heading: set par(justify: false)
  show heading.where(level: 1): set heading(supplement: term("chapter", lang))
  show heading.where(level: 1): it => {
    _clear-to("odd")
    for kind in (image, table, raw) {
      counter(figure.where(kind: kind)).update(0)
    }
    counter(math.equation).update(0)
    _chapter-opener(it, cfg)
  }
  let (size-2, size-3) = if kind == "tue" { (1.4em, 1.15em) } else {
    (1.25em, 1.05em)
  }
  show heading.where(level: 2): set text(size: size-2, weight: "bold")
  show heading.where(level: 2): set block(above: 2em, below: 1em)
  show heading.where(level: 3): set text(size: size-3, weight: "bold")
  show heading.where(level: 3): set block(above: 1.6em, below: 0.8em)
  show heading.where(level: 2): _section
  show heading.where(level: 3): _section
  show heading.where(level: 4): set text(
    size: 1em,
    weight: "bold",
    style: "italic",
  )
  show heading.where(level: 4): set block(above: 1.4em, below: 0.8em)

  // Figures, tables and equations are numbered per chapter: 3.1, A.2.
  set figure(numbering: n => _in-chapter(n, "1.1"))
  set math.equation(numbering: n => _in-chapter(n, "(1.1)"))
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.caption: set text(size: 0.9em)
  show figure.caption: set par(justify: false)
  show figure.caption: _caption
  set table(stroke: (_, y) => if y == 0 { (bottom: 0.6pt + pal.ink) })

  set outline(indent: auto)
  set bibliography(style: "ieee")

  // The own-publications bibliography, loaded up front so that @pub:key
  // citations resolve wherever `publications()` is placed.
  show: if publications-bib == none { it => it } else {
    alexandria(prefix: publications-prefix, read: none)
  }
  if publications-bib != none {
    let sources = if type(publications-bib) == array { publications-bib } else {
      (publications-bib,)
    }
    load-bibliography(
      sources.map(s => if type(s) == str { bytes(s) } else { s }),
      prefix: publications-prefix,
      full: true,
      style: if publications-style == auto {
        read("../assets/ieee-publications.csl", encoding: none)
      } else { publications-style },
    )
  }

  thesis-config.update(cfg)
  body
}

// ---- Matter switches ----------------------------------------------------------------

/// Front matter: roman page numbers, unnumbered chapters. `thesis` already
/// behaves like this, so this is only needed for clarity at the start.
#let front-matter(body) = {
  set page(numbering: "i")
  counter(page).update(1)
  set heading(numbering: none)
  body
}

/// Main matter: starts on a recto page numbered 1; chapters are numbered.
#let main-matter(body) = {
  _clear-to("odd")
  set page(numbering: "1")
  counter(page).update(1)
  set heading(numbering: "1.1")
  counter(heading).update(0)
  body
}

/// Appendices: chapters numbered A, B, ..., figures A.1. Use inside the main
/// matter, after the last chapter.
#let appendix(body) = context {
  show heading.where(level: 1): set heading(supplement: term(
    "appendix",
    text.lang,
  ))
  set heading(numbering: "A.1")
  counter(heading).update(0)
  thesis-appendix.update(true)
  body
}

/// Back matter: page numbers continue, chapters are unnumbered.
#let back-matter(body) = {
  set heading(numbering: none)
  thesis-appendix.update(false)
  body
}

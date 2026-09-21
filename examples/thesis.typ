// A short sample thesis about the template itself, shared by
// examples/tue/main.typ and examples/plain/main.typ. `kind` ("tue" or
// "plain") picks the theme and the institution-specific details: the plain
// version is a thesis at a fictional university, with no TU/e wording.
#import "/src/lib.typ": *

#let example-thesis(kind) = [
  #let tue = kind == "tue"
  #show: (if tue { tue-theme } else { plain-theme }).with(
    title: [Typesetting a Doctoral Thesis with Typst],
    subtitle: if tue [A template for Eindhoven University of Technology] else [
      A template for doctoral theses
    ],
    author: "Jane Doe",
    full-name: [Jane Maria Doe],
    birthplace: if tue [Eindhoven] else [Springfield],
    defense: datetime(
      year: 2026,
      month: 12,
      day: 8,
      hour: 16,
      minute: 0,
      second: 0,
    ),
    rector: if tue [prof.dr. S.K. Lenaerts],
    ..if not tue { (institution: [Example University]) },
    keywords: ("typst", "thesis"),
    publications-bib: read("publications.bib"),
  )

  #title-page()
  #committee-page(
    chair: [prof.dr.ir. A. Chair],
    promotors: ([prof.dr.ir. B. First],),
    copromotors: ([dr.ir. C. Co],),
    members: (
      ([prof.dr. D. Member], [University of Example]),
      [dr. E. Member],
    ),
  )
  #colophon(
    isbn: if tue { "978-90-386-0000-0" } else { "978-0-000-00000-0" },
    cover: [Jane Doe],
    printed-by: [Example Print],
  )
  #summary[
    This thesis shows the `thesis-tue` template#if not tue [ in its plain
      theme]. It sets a two-sided book in 170 × 240 mm with chapters on recto
    pages, running headers, per-chapter numbering and the front and back
    matter of a #if tue [TU/e] doctorate.
  ]
  #contents()
  #list-of-figures()

  #show: main-matter

  = Introduction <ch:intro>
  A thesis is a book, and Typst @typst typesets one quickly. This chapter shows
  the body text; @ch:layout shows the page layout. Your own papers
  @pub:doe2022early @pub:doe2024mid come from a second bibliography and are
  labelled P1, P2, ...

  == Chapters and sections
  Every level-one heading opens a chapter on a recto page. If the previous
  chapter ends on a recto page, a blank verso page follows, without header or
  page number. #lorem(120)

  == Numbering
  Figures, tables and equations are numbered per chapter, so @fig:page is the
  first figure of this chapter and @eq:area its first equation:
  #math.equation(
    block: true,
    alt: "A equals w times h equals 170 millimetres times 240 millimetres",
    $A = w h = 170 "mm" times 240 "mm".$,
  ) <eq:area>

  #figure(
    rect(width: 50%, height: 3.5cm, stroke: 0.6pt)[#align(
      center + horizon,
    )[page]],
    alt: "An outlined rectangle labelled page.",
    caption: [A page of 170 × 240 mm.],
  ) <fig:page>

  #lorem(200)

  = Page layout <ch:layout>
  == Margins
  The inner margin is wider than the outer margin, so the text block sits well
  clear of the binding. #lorem(150)

  #figure(
    table(
      columns: 2,
      table.header([Margin], [Width]),
      [Inside], [24 mm],
      [Outside], [20 mm],
      [Top], [24 mm],
      [Bottom], [24 mm],
    ),
    caption: [Default margins.],
  ) <tab:margins>

  == Running headers
  Verso pages show the chapter, recto pages the current section. #lorem(250)

  #show: back-matter
  #bibliography("refs.bib")
  #if tue {
    samenvatting[Dit proefschrift laat het `thesis-tue` sjabloon zien.]
  }
  #acknowledgements[#lorem(60)]
  #curriculum-vitae(born: datetime(year: 1990, month: 5, day: 17))[#lorem(50)]
  #publications()
]

// Structural checks. Every `assert` below fails the compile (and so
// scripts/check.sh) when the engine's numbering or page logic regresses.
// Also exercises draft mode, a Dutch document and missing metadata.
#import "/src/lib.typ": *
#import "demo-body.typ": demo-body

#show: tue-theme.with(
  title: [Features],
  author: "Jane Doe",
  publications-bib: read("publications.bib"),
  lang: "nl",
  draft: true,
)

// No rector, date or birthplace: the title page shows red placeholders.
#title-page()
#summary(lang: "en")[#lorem(50)] <front-summary>
#contents()

#demo-body

#context {
  // Chapters open on recto (odd physical) pages.
  for h in query(heading.where(level: 1)) {
    assert(
      calc.odd(h.location().page()),
      message: "chapter on verso: " + repr(h.body),
    )
  }
  // Front matter is numbered i, ii, ...; the main matter restarts at 1.
  assert.eq(locate(<front-summary>).page-numbering(), "i")
  assert.eq(counter(page).at(<ch:intro>), (1,))
  assert.eq(locate(<ch:intro>).page-numbering(), "1")
  // Figures are numbered per chapter; appendices use letters.
  assert.eq(counter(figure.where(kind: image)).at(<fig:grid>), (1,))
  assert.eq(counter(heading).at(<ch:method>).first(), 2)
  assert.eq(counter(figure.where(kind: image)).at(<fig:app>), (1,))
  assert(thesis-appendix.at(<fig:app>))
  assert.eq(counter(heading).at(<app:deriv>).first(), 1)
  // Own publications: every entry is listed (and so labelled), P-numbered.
  for k in ("doe2022early", "doe2024mid", "roe2025late") {
    assert.eq(query(label("pub:" + k)).len(), 1)
  }
  // A Dutch document gets Dutch chapter supplements.
  assert.eq(query(<ch:intro>).first().supplement, [Hoofdstuk])
}

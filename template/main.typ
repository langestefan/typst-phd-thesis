// A PhD thesis at Eindhoven University of Technology.
// Compile with `typst watch main.typ`. Replace every red [placeholder].
#import "@local/thesis-tue:0.1.0": *

#show: tue-theme.with(
  title: [Title of the Thesis],
  subtitle: [Subtitle],
  author: "Your Name", // a string: it goes into the PDF metadata
  full-name: [Your Full Given Names Surname], // as on your birth certificate
  birthplace: none, // e.g. [Eindhoven]
  defense: none, // datetime(year: 2027, month: 6, day: 1, hour: 16, minute: 0, second: 0)
  rector: none, // check the name with the doctorate office
  keywords: ("keyword",),
  // Your own papers: cite as @pub:key, labelled [P1], [P2], ...
  publications-bib: read("publications.bib"),
  // draft: true,  // date stamp in the footer and line numbers
)

// ---- Front matter: numbered i, ii, ... -------------------------------------
#title-page()
#committee-page(
  chair: [prof.dr.ir. A. Voorzitter],
  promotors: ([prof.dr.ir. B. Promotor],),
  copromotors: ([dr.ir. C. Copromotor],),
  // A member with an affiliation is a (name, affiliation) pair.
  members: (
    ([prof.dr. D. Lid], [University of Example]),
    [dr. E. Lid],
  ),
)
#colophon(
  isbn: none, // "978-90-386-xxxx-x", from the TU/e library
  cover: none,
  printed-by: none,
  funding: none, // [This work is part of the project ..., funded by ...]
)
#summary(include "chapters/summary.typ")
#contents()

// ---- Main matter: starts on a recto page numbered 1 --------------------------
#show: main-matter

#include "chapters/introduction.typ"
#include "chapters/conclusion.typ"

#show: appendix
#include "chapters/appendix.typ"

// ---- Back matter -------------------------------------------------------------
#show: back-matter

#bibliography("refs.bib")
#samenvatting(include "chapters/samenvatting.typ")
#acknowledgements[Thank you.]
#curriculum-vitae(born: none)[Write your curriculum vitae here.]
#publications(groups: (
  "Journal articles": ("doe2024mid", "roe2025late"),
  "Conference papers": ("doe2022early",),
))

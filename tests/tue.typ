// The TU/e theme with the full Dutch front matter.
#import "/src/lib.typ": *
#import "demo-body.typ": demo-body

#show: tue-theme.with(
  title: [Probabilistic Methods for Distribution Grids],
  subtitle: [A sample thesis],
  author: "Jane Doe",
  publications-bib: read("publications.bib"),
  full-name: [Jane Maria Doe],
  birthplace: [Eindhoven],
  defense: datetime(
    year: 2026,
    month: 12,
    day: 8,
    hour: 16,
    minute: 0,
    second: 0,
  ),
  rector: [prof.dr. S.K. Lenaerts],
)

#title-page()
#committee-page(
  chair: [prof.dr.ir. A. Chair],
  promotors: ([prof.dr.ir. B. First], [prof.dr. C. Second]),
  copromotors: [dr.ir. D. Co],
  members: (
    ([prof.dr. E. Member], [University of Example]),
    ([dr. F. Member], [Example Institute]),
    [prof.dr.ir. G. Member],
  ),
)
#colophon(
  isbn: "978-90-386-0000-0",
  printed-by: [Example Print],
  cover: [Jane Doe],
  funding: [This work was funded by an example grant.],
)
#summary[#lorem(100)]
#contents()
#list-of-figures()
#list-of-tables()

#demo-body

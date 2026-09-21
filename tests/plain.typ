// The plain theme with an English title and committee page.
#import "/src/lib.typ": *
#import "demo-body.typ": demo-body

#show: plain-theme.with(
  title: [Probabilistic Methods for Distribution Grids],
  subtitle: [A sample thesis],
  author: "Jane Doe",
  institution: [the University of Examples],
  defense: datetime(
    year: 2026,
    month: 12,
    day: 8,
    hour: 16,
    minute: 0,
    second: 0,
  ),
)

#title-page()
#committee-page(
  chair: [Prof. A. Chair],
  promotors: [Prof. B. First],
  members: ([Prof. E. Member], [Dr. F. Member]),
)
#contents()

#demo-body

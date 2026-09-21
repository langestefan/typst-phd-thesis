// Shared thesis body for the theme tests: two chapters, an appendix and the
// back matter. The including file sets up the theme and the front matter.

#import "/src/lib.typ": *

#let demo-body = [
  #show: main-matter

  = Introduction <ch:intro>
  #lorem(120)

  #lorem(90) Typst @typst is used throughout; see @ch:method and @fig:grid.
  Our own work @pub:doe2022early @pub:roe2025late gets P-labels.

  == Background
  #lorem(200)

  #figure(
    rect(width: 60%, height: 3cm),
    alt: "An empty rectangle.",
    caption: [A placeholder figure.],
  ) <fig:grid>

  == Research questions
  #lorem(260)

  #math.equation(
    block: true,
    alt: "P equals V times I times cosine phi",
    $P = V I cos phi$,
  ) <eq:power>

  #lorem(300)

  = Method <ch:method>
  #lorem(80) As shown in @eq:power and @tab:data, following @doe2024journal.

  #figure(
    table(
      columns: 3,
      table.header([Bus], [Voltage (pu)], [Power (kW)]),
      [1], [1.00], [0],
      [2], [0.98], [12.5],
    ),
    caption: [Sample data.],
  ) <tab:data>

  == Model
  #lorem(400)

  === Details
  #lorem(150)

  #figure(
    rect(width: 50%, height: 2cm),
    alt: "An empty rectangle.",
    caption: [Another figure, with a caption long enough to wrap onto a second line so that the label hangs to its left.],
  )

  #show: appendix
  = Derivations <app:deriv>
  #lorem(100)
  #figure(
    rect(width: 40%, height: 2cm),
    alt: "An empty rectangle.",
    caption: [An appendix figure.],
  ) <fig:app>
  #math.equation(block: true, alt: "x equals 1", $x = 1$)

  #show: back-matter
  #bibliography("refs.bib")
  #summary[#lorem(150)]
  #samenvatting[Dit is een korte Nederlandse samenvatting. #lorem(100)]
  #acknowledgements[#lorem(120)]
  #curriculum-vitae(born: datetime(year: 1990, month: 5, day: 17))[#lorem(80)]
  #publications(groups: (
    "Journal articles": ("doe2024mid", "roe2025late"),
    "Conference papers": ("doe2022early",),
  ))
]

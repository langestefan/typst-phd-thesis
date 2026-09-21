= Introduction <ch:introduction>

Each `=` heading starts a chapter on a recto page. Cite with @doe2024journal,
cite your own work with @pub:doe2022early, and refer to @ch:conclusion,
@fig:example or @eq:example.

== Motivation

// Give every image and equation a short description (`alt`) for screen
// readers; export with `--pdf-standard ua-1` and Typst reports any you miss.
// On an image, put `alt` on the image: `figure(image("plot.svg", alt: "..."))`.
#figure(
  rect(width: 70%, height: 3cm),
  alt: "An empty rectangle standing in for a figure.",
  caption: [A figure, numbered per chapter.],
) <fig:example>

#math.equation(
  block: true,
  alt: "E equals m c squared",
  $E = m c^2$,
) <eq:example>

== Outline

Chapter by chapter overview.

// ============================================================================
//  Back matter: acknowledgements, curriculum vitae and the list of
//  publications. Each is an unnumbered chapter; titles follow the document
//  language (English or Dutch) unless `title` is given.
// ============================================================================

#import "helpers.typ": format-date-en, format-date-nl, term, thesis-config

#let _chapter(key, title) = context heading(
  level: 1,
  numbering: none,
  if title == auto { term(key, text.lang) } else { title },
)

/// The acknowledgements ("Dankwoord" in a Dutch document).
#let acknowledgements(title: auto, body) = {
  _chapter("acknowledgements", title)
  body
}

/// The curriculum vitae. With `born` (a datetime) it opens with "<author>
/// was born on <date> in <birthplace>."; `birthplace` defaults to the one
/// given to the theme. `photo` (content, e.g. an image) sits to the right.
#let curriculum-vitae(
  born: none,
  birthplace: auto,
  photo: none,
  title: auto,
  body,
) = {
  _chapter("cv", title)
  context {
    let i = thesis-config.get().info
    let place = if birthplace == auto { i.birthplace } else { birthplace }
    let nl = text.lang == "nl"
    let intro = if born != none {
      let date = if nl { format-date-nl(born, weekday: false) } else {
        format-date-en(born, weekday: false)
      }
      let where = if place != none {
        if nl [ te #place] else [ in #place]
      }
      if nl [#i.full-name werd geboren op #date#where.] else [
        #i.full-name was born on #date#where.
      ]
    }
    if photo != none {
      grid(
        columns: (1fr, auto),
        column-gutter: 1.5em,
        {
          intro
          parbreak()
          body
        },
        photo,
      )
    } else {
      intro
      parbreak()
      body
    }
  }
}

/// The list of publications, as full citations numbered straight through.
/// `groups` is an array of bibliography keys, or a dictionary of group title
/// to keys, e.g. `("Journal articles": ("lange2024",), "Conference papers":
/// ("lange2023",))`. The works come from the thesis' own `#bibliography`,
/// so they are also listed there. `style` is the citation style of the
/// entries; it must not print a label (IEEE full citations start with "[n]").
#let publications(
  groups,
  title: auto,
  intro: none,
  style: "american-psychological-association",
) = {
  _chapter("publications", title)
  if intro != none {
    intro
    parbreak()
  }
  let groups = if type(groups) == dictionary { groups.pairs() } else {
    ((none, groups),)
  }
  let n = 1
  for (group, keys) in groups {
    if group != none {
      heading(level: 2, numbering: none, outlined: false, group)
    }
    enum(
      start: n,
      spacing: 0.9em,
      ..keys.map(k => cite(label(k), form: "full", style: style)),
    )
    n += keys.len()
  }
}

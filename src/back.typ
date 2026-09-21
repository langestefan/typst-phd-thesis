// ============================================================================
//  Back matter: acknowledgements, curriculum vitae and the list of
//  publications. Each is an unnumbered chapter; titles follow the document
//  language (English or Dutch) unless `title` is given.
// ============================================================================

#import "@preview/alexandria:0.2.2": get-bibliography, hayagriva
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

/// The list of own publications: every entry of the theme's
/// `publications-bib`, labelled [P1], [P2], ... as they are cited in the
/// text (@pub:key). `groups` splits the list under subheadings: a dictionary
/// of group title to keys (without the prefix), e.g. `("Journal articles":
/// ("doe2024",), "Conference papers": ("doe2023",))`. Entries in no group
/// follow at the end.
#let publications(groups: auto, title: auto, intro: none) = {
  _chapter("publications", title)
  if intro != none {
    intro
    parbreak()
  }
  context {
    let prefix = thesis-config.get().pub-prefix
    assert(
      prefix != none,
      message: "publications() lists the theme's `publications-bib`; pass it, e.g. `publications-bib: read(\"publications.bib\")`",
    )
    let bib = get-bibliography(prefix)
    let by-key = (:)
    for e in bib.references { by-key.insert(e.key, e) }

    // Label (for @pub:key links), [Pn] and the entry, with a hanging indent.
    let entries(list) = grid(
      columns: 2,
      column-gutter: 0.65em,
      row-gutter: 0.9em,
      ..for e in list {
        (
          {
            [#metadata(none)#label(prefix + e.key)]
            if e.first-field != none { hayagriva.render(e.first-field) }
          },
          hayagriva.render(e.content),
        )
      },
    )

    if groups == auto {
      entries(bib.references)
    } else {
      let done = ()
      for (group, keys) in groups.pairs() {
        for k in keys {
          assert(
            k in by-key,
            message: "publications(): no entry '" + k + "' in publications-bib",
          )
        }
        heading(level: 2, numbering: none, outlined: false, group)
        entries(keys.map(k => by-key.at(k)))
        done += keys
      }
      let rest = bib.references.filter(e => e.key not in done)
      if rest.len() > 0 {
        v(1em)
        entries(rest)
      }
    }
  }
}

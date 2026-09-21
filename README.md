# thesis-tue

[![Tests](https://github.com/langestefan/typst-phd-thesis/actions/workflows/tests.yml/badge.svg)](https://github.com/langestefan/typst-phd-thesis/actions/workflows/tests.yml)
[![Lint](https://github.com/langestefan/typst-phd-thesis/actions/workflows/lint.yml/badge.svg)](https://github.com/langestefan/typst-phd-thesis/actions/workflows/lint.yml)

A PhD thesis template for [Typst](https://typst.app): a two-sided book in the
170 × 240 mm format that Dutch printers use for theses.

| Theme         | Look                                                              |
| ------------- | ----------------------------------------------------------------- |
| `tue-theme`   | Classic TU/e thesis: Charter, `1 \| Introduction` chapters, bold running heads with the page number behind a bar, Dutch doctorate pages |
| `plain-theme` | Neutral: serif throughout, English title and committee pages      |

## Install

Run the command for your system. It downloads the package to the folder where Typst looks for local packages, so any document can import it with `#import "@local/thesis-tue:0.1.0": *`.

Linux:

```bash
git clone https://github.com/langestefan/typst-phd-thesis.git ~/.local/share/typst/packages/local/thesis-tue/0.1.0
```

Windows (PowerShell):

```powershell
git clone https://github.com/langestefan/typst-phd-thesis.git "$env:APPDATA\typst\packages\local\thesis-tue\0.1.0"
```

The TU/e theme is set in [XCharter](https://ctan.org/pkg/xcharter), the free extension of Bitstream Charter. Install it once (without it Typst warns and falls back to Libertinus Serif):

```bash
scripts/get-fonts.sh ~/.local/share/fonts     # Linux; on Windows install the .otf files from CTAN
```

To update, run `git pull` in that folder. Then start a thesis from the template:

```bash
typst init @local/thesis-tue:0.1.0 my-thesis
cd my-thesis && typst watch main.typ
```

## Usage

```typst
#import "@local/thesis-tue:0.1.0": *

#show: tue-theme.with(                   // or plain-theme
  title: [Title], subtitle: [Subtitle],
  author: "Jane Doe",                     // a string: it goes into the PDF metadata
  full-name: [Jane Maria Doe],            // on the title page
  birthplace: [Eindhoven],
  defense: datetime(year: 2027, month: 6, day: 1, hour: 16, minute: 0, second: 0),
  rector: [prof.dr. S.K. Lenaerts],       // check with the doctorate office
)

// Front matter, numbered i, ii, ...
#title-page()                       // recto
#committee-page(                    // its verso
  chair: [...], promotors: ([...],), copromotors: ([...],),
  members: (([prof.dr. A. Jansen], [TU Delft]), [dr. B. de Vries]),  // (name, affiliation) or name
)
#colophon(isbn: "978-90-386-xxxx-x", cover: [...], printed-by: [...])  // next verso
#summary[...]                       // repeats the thesis title in bold (tue)
#contents()

#show: main-matter      // recto page 1, numbered chapters
= Introduction          // a chapter, always on a recto page
== Background           // a section

#show: appendix         // chapters A, B, ...; figures A.1
= Derivations

#show: back-matter      // unnumbered chapters
#bibliography("refs.bib")
#samenvatting[...]
#acknowledgements[...]
#curriculum-vitae(born: datetime(year: 1995, month: 3, day: 1))[...]
#publications(("Journal articles": ("key1", "key2"), "Conference papers": ("key3",)))
```

Metadata that the title page needs but you have not given yet (rector, defence
date, birthplace) shows as a red `[placeholder]`.

### Layout

- Chapters open on recto pages. A blank verso page before a chapter has no header and no page number.
- Running headers: the chapter on verso pages, the current section on recto pages; unnumbered chapters (Contents, Summary, ...) in capitals. None on chapter openers. The TU/e theme puts the page number in the header, next to a thick bar, and has no footer; the plain theme numbers pages in the footer.
- Captions are centred when they fit on one line; longer ones hang after the "Figure 1.2:" label. Lists of figures and tables show the number only and leave a gap between chapters.
- Figures, tables and equations are numbered per chapter (`2.3`, `(2.3)`); appendices use letters (`A.1`). Table captions go above the table.
- Front matter is numbered `i, ii, ...`; the main matter restarts at 1 on a recto page.

### Theme options

Both themes accept these options, passed through to `thesis` in `src/core.typ`:

| Option          | Default                          | Meaning                                                   |
| --------------- | -------------------------------- | --------------------------------------------------------- |
| `title`, `subtitle` | `[Thesis title]`, `none`     | on the half-title and title page                          |
| `author`        | `"Author Name"`                  | a string; PDF metadata, colophon                          |
| `full-name`     | `auto` (= `author`)              | name on the title page and in the CV                      |
| `birthplace`    | `none`                           | title page (tue) and CV                                   |
| `defense`       | `none`                           | a `datetime` with a time of day                           |
| `rector`        | `none`                           | rector magnificus on the TU/e title page                  |
| `institution`   | TU/e (tue), `none` (plain)       | plain title page                                          |
| `degree`        | `"Doctor of Philosophy"`         | plain title page                                          |
| `date`          | today                            | copyright year; plain title page without `defense`        |
| `keywords`      | `()`                             | PDF metadata                                              |
| `lang`          | `"en"`                           | `"nl"` for a Dutch thesis: Dutch fixed terms and hyphenation |
| `paper`         | `(170mm, 240mm)`                 | page width and height                                     |
| `margin`        | inside 24, outside 20, top 24, bottom 24 mm | two-sided margins                              |
| `font`          | XCharter (tue), Libertinus Serif (plain) | body font                                         |
| `heading-font`  | `auto` (= `font`)                | chapter and section titles                                |
| `math-font`     | New Computer Modern Math         |                                                           |
| `text-size`     | `10pt`                           |                                                           |
| `justify`       | `true`                           |                                                           |
| `draft`         | `false`                          | date stamp in the footer and line numbers                 |
| `colors`        | `(:)`                            | overrides palette entries: `primary`, `ink`, `muted`, `rule`, `link` |

### Functions

| Function                                    | Purpose                                                  |
| ------------------------------------------- | -------------------------------------------------------- |
| `title-page()`                              | TU/e: the Dutch *proefschrift* page. Plain: English      |
| `committee-page(chair:, promotors:, copromotors:, members:, advisors:, statement:)` | verso of the title page; a person is a name or a (name, affiliation) pair. TU/e adds the *Gedragscode* statement |
| `colophon(isbn:, printed-by:, cover:, funding:, catalogue:, copyright:, note:)` | verso page, set at the foot |
| `half-title()`                              | optional recto page with the title only                  |
| `summary(lang:, title:, show-title:)[...]`, `samenvatting[...]` | unnumbered chapter, English or Dutch |
| `contents(depth:)`, `list-of-figures()`, `list-of-tables()` | outlines                                 |
| `front-matter`, `main-matter`, `appendix`, `back-matter` | `#show:` switches                           |
| `acknowledgements[...]`                     | unnumbered chapter ("Dankwoord" in Dutch)                |
| `curriculum-vitae(born:, birthplace:, photo:)[...]` | opens with "*Name* was born on *date* in *place*." |
| `publications(groups, style:)`              | full citations from the thesis bibliography, numbered straight through |
| `format-date-nl(date, weekday:, time:)`     | "dinsdag 8 december 2026 om 16:00 uur"                   |
| `accent[...]`, `highlight-box(title:)[...]` | emphasis in the theme colour                             |
| `tue-logo(color:, full:)`                   | the TU/e logo in any colour                              |

## Known limitations

- **One bibliography.** `publications` cites the works from the thesis bibliography, so they also appear there. Its default style is APA, because IEEE full citations start with the `[n]` label.
- **Check the TU/e wording.** The title and committee pages follow the TU/e doctorate regulations as of 2026. The doctorate office has the final say; `statement:` and the theme options let you adjust them.

## Example

`examples/example.typ` is a short thesis about the template itself.

```bash
typst compile --root . --font-path tmp/fonts examples/example.typ tue.pdf
typst compile --root . --input theme=plain examples/example.typ plain.pdf
```

## Development

```bash
scripts/check.sh          # compile tests/, template/ and examples/, fail on any warning, PNG previews in tmp/check/
scripts/check.sh --no-png
```

Requirements:
- Typst 0.14 or newer. CI tests 0.14.2 and the latest release.
- `pdfinfo` and `pdftoppm` (poppler) for `check.sh`.
- XCharter: `scripts/get-fonts.sh` puts it in `tmp/fonts`, which `check.sh` passes to Typst.

The TU/e logo in `assets/` is a trademark of Eindhoven University of Technology. The MIT licence covers the code, not the logo.

// Get these values from the YAML and make them typst variables because writing
// out shortcodes all the time is messy
#let header-left = [{{< meta pdf-header-left >}}]
#let header-right = [{{< meta pdf-header-right >}}]
#let footer-left = [{{< meta pdf-footer-left >}}]

// Footnotes should use the body font, but Typst somehow doesn't pick that up
// from _brand.yml, so we have to manually set it here :shrug:
#show footnote.entry: set text(font: "Atkinson Hyperlegible Next")

// Hanging indent for the references/bibliography list
#show <refs>: it => {
  set par(hanging-indent: 1em)
  set text(size: 0.9em)
  it
}

// H1
#show heading.where(level: 1): it => {
  block(
    width: 100%,
    above: 1.5em,
    below: 0.8em,
    stroke: (bottom: 1pt + luma(170)),
    inset: (bottom: 0.4em),
    it
  )
}

// H2
#show heading.where(level: 2): it => {
  set block(above: 1.5em, below: 0.8em)
  it
}

// H6 - headings in the course details section
#show heading.where(level: 6): it => {
  set text(size: 1.1em)
  set block(below: 0.8em)
  it
}

// Center tables in the .centered-table div
#let centered-table(body) = {
  align(center, body)
}

// Schedule rows. Each row is its own little grid so that page breaks can
// happen between rows
#let schedule-table(body) = {
  set text(size: 0.85em)
  set par(justify: false)
  // No bullets, since the fontawesome icons act as bullets (like on the
  // website), and indent wrapped lines so they line up with the text after
  // the 1.25em-wide icon
  // (par(hanging-indent:) doesn't reach tight list items, so pad the whole
  // item and pull the first line back out instead)
  set list(spacing: 0.5em, marker: [], indent: 0pt, body-indent: 0pt)
  show list.item: it => block(
    spacing: 0.5em,
    inset: (left: 1.25em),
    h(-1.25em) + it.body
  )
  body
}

#let schedule-row(header: false, date, topic, reading) = {
  set text(weight: "bold") if header
  // Keep the header row on the same page as the first real row
  block(
    sticky: header,
    width: 100%,
    above: 0pt,
    below: 0pt,
    inset: (y: 0.5em),
    stroke: (bottom: if header { 1pt + luma(120) } else { 0.5pt + luma(210) }),
    grid(
      columns: (5.5em, 1fr, 2fr),
      column-gutter: 1em,
      date, topic, reading
    )
  )
}

// 3-column course details section that matches what the website has
#let grid-col(body) = body

#let course-details(body) = {
  block(
    fill: luma(240),
    inset: 1em,
    above: 2em,
    below: 2em,
    width: 100%,
    {
      set text(size: 0.8em)
      set par(justify: false)
      // No bullets, since the fontawesome icons act as bullets (like on the website)
      set list(marker: [], indent: 0pt, body-indent: 0pt)
      // Get rid of empty elements
      let cols = body.children.filter(c => c != [ ] and c != [
])
      grid(
        columns: 3,
        gutter: 2em,
        ..cols
      )
    }
  )
}


// Restyle Quarto callout boxes since they're a little too spacy
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black, body_background_color: white) = {
  block(
    stroke: (
      left: 3pt + icon_color,
      top: 0.5pt + icon_color,
      right: 0.5pt + icon_color,
      bottom: 0.5pt + icon_color
    ),
    radius: 2pt,
    width: 100%,
    [
      #set text(size: 0.9em)
      #set par(leading: 0.65em)
      #block(
        fill: background_color,
        inset: 0.5em,
        width: 100%,
        below: 0pt,
        text(icon_color, weight: "bold")[#icon #title]
      )
      #block(
        fill: body_background_color,
        inset: 0.5em,
        width: 100%,
        body
      )
    ]
  )
}


// Restyle and reformat the title area
#let original-article = article

#let article(
  title: none,
  subtitle: none,
  font: none,
  heading-family: none,
  heading-weight: "bold",
  heading-color: black,
  ..args,
  doc
) = {
  let remaining = args.named()

  set align(left)

  let title-font = if heading-family != none { heading-family } else { font }

  // Title and logo side by side
  if title != none {
    grid(
      columns: (1fr, auto),
      column-gutter: 1em,
      align: (left, right),

      // Left column: title and subtitle
      block(inset: (bottom: 1.5em))[
        #block(
          below: 2em,
          text(font: title-font, weight: heading-weight, fill: heading-color, size: 2em)[#title]
        )
        #if subtitle != none {
          block(
            above: 0em,
            text(font: title-font, weight: "regular", size: 1.2em)[#subtitle]
          )
        }
      ],

      // Right column: logo
      align(horizon)[
        #image("files/favicon-512.png", width: 1in)
      ]
    )
  }

  original-article(
    title: none,
    subtitle: none,
    font: font,
    heading-family: heading-family,
    heading-weight: heading-weight,
    heading-color: heading-color,
    ..remaining,
    doc
  )
}

// Running header and footer in gray serif (have to manually grab these from
// _brand.yml)
#set page(
  header: context {
    if counter(page).get().first() > 1 {
      set text(font: "Charis SIL", size: 0.8em, fill: rgb("#515257"))
      grid(
        columns: (1fr, auto),
        align: (left, right),
        emph(header-left),
        emph(header-right)
      )
    }
  },
  footer: context [
    #set text(font: "Charis SIL", size: 0.8em, fill: rgb("#515257"))
    #grid(
      columns: (1fr, auto),
      align: (left, right),
      emph(footer-left),
      counter(page).display("1")
    )
  ]
)

// General global styling stuff
#show par: set par(justify: false)  // This has to come at the end of this file
#set text(hyphenate: false)

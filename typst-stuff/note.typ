// Add a note to the top margin of the first page, with text from the pdf-note
// YAML key.
//
// This has to get injected as part of include-before-body and not in
// include-in-header because otherwise this gets placed on an empty A4 page at
// the beginning of the document because of how it interacts with `#set page()`
//
// The pdf-note text gets inserted raw (not converted from markdown), so it
// has to be valid Typst markup. In particular, write URLs bare (Typst makes
// them links automatically), since <https://...> is Typst label syntax

// Use #today in pdf-note to get the date the PDF was compiled. (This has to be
// defined here, since the meta shortcode escapes the [ ]s in the format string)
// #let today = datetime.today().display("[year]-[month]-[day]")
#let today = datetime.today().display("[month repr:long] [day padding:none], [year]")

#let note-content =[*NOTE*#h(1em){{< meta pdf-note >}}]

#place(
  top + left,
  dy: -2cm,  // Move this thing into the top margin (which is 2.5cm)
  block(
    width: 100%,
    fill: rgb("#FFF4F5"),  // maroon-50 from _brand.yml
    stroke: 0.5pt + rgb("#8A1538"),  // maroon
    radius: 2pt,
    inset: 0.75em,
    {
      set text(size: 0.75em)
      set par(justify: false)
      note-content
    }
  )
)

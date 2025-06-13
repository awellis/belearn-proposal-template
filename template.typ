// Helper functions and styling for ILLUMINATE proposal

// Checkbox function for forms
#let checkbox(checked: false) = {
  if checked {
    box(width: 1em, height: 1em, stroke: 1pt + black)[#align(center)[✓]]
  } else {
    box(width: 1em, height: 1em, stroke: 1pt + black)[]
  }
}

// Gray box for highlighting content
#let graybox(content) = {
  block(
    fill: rgb("#f2f2f2"),
    stroke: 0.5pt + black,
    inset: 10pt,
    width: 100%,
    content
  )
}

// Styled table with consistent formatting
#let styled-table(..args) = {
  table(
    stroke: 0.5pt + black,
    inset: 8pt,
    ..args
  )
}

// Checkbox table for forms (no borders)
#let checkbox-table(..args) = {
  table(
    stroke: none,
    inset: 8pt,
    ..args
  )
}
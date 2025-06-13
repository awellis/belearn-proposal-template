// Some definitions presupposed by pandoc's typst output.
#let blockquote(body) = [
  #set text( size: 0.92em )
  #block(inset: (left: 1.5em, top: 0.2em, bottom: 0.2em))[#body]
]

#let horizontalrule = line(start: (25%,0%), end: (75%,0%))

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms: it => {
  it.children
    .map(child => [
      #strong[#child.term]
      #block(inset: (left: 1.5em, top: -0.4em))[#child.description]
      ])
    .join()
}

// Some quarto-specific definitions.

#show raw.where(block: true): set block(
    fill: luma(230),
    width: 100%,
    inset: 8pt,
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let d = (:)
  let fields = old_block.fields()
  fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.abs
  }
  return block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == str {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == content {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

// Subfloats
// This is a technique that we adapted from https://github.com/tingerrr/subpar/
#let quartosubfloatcounter = counter("quartosubfloatcounter")

#let quarto_super(
  kind: str,
  caption: none,
  label: none,
  supplement: str,
  position: none,
  subrefnumbering: "1a",
  subcapnumbering: "(a)",
  body,
) = {
  context {
    let figcounter = counter(figure.where(kind: kind))
    let n-super = figcounter.get().first() + 1
    set figure.caption(position: position)
    [#figure(
      kind: kind,
      supplement: supplement,
      caption: caption,
      {
        show figure.where(kind: kind): set figure(numbering: _ => numbering(subrefnumbering, n-super, quartosubfloatcounter.get().first() + 1))
        show figure.where(kind: kind): set figure.caption(position: position)

        show figure: it => {
          let num = numbering(subcapnumbering, n-super, quartosubfloatcounter.get().first() + 1)
          show figure.caption: it => {
            num.slice(2) // I don't understand why the numbering contains output that it really shouldn't, but this fixes it shrug?
            [ ]
            it.body
          }

          quartosubfloatcounter.step()
          it
          counter(figure.where(kind: it.kind)).update(n => n - 1)
        }

        quartosubfloatcounter.update(0)
        body
      }
    )#label]
  }
}

// callout rendering
// this is a figure show rule because callouts are crossreferenceable
#show figure: it => {
  if type(it.kind) != str {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let old_title = old_title_block.body.body.children.at(2)

  // TODO use custom separator if available
  let new_title = if empty(old_title) {
    [#kind #it.counter.display()]
  } else {
    [#kind #it.counter.display(): #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block, 
    block_with_new_content(
      old_title_block.body, 
      old_title_block.body.body.children.at(0) +
      old_title_block.body.body.children.at(1) +
      new_title))

  block_with_new_content(old_callout,
    block(below: 0pt, new_title_block) +
    old_callout.body.children.at(1))
}

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black, body_background_color: white) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color, 
        width: 100%, 
        inset: 8pt)[#text(icon_color, weight: 900)[#icon] #title]) +
      if(body != []){
        block(
          inset: 1pt, 
          width: 100%, 
          block(fill: body_background_color, width: 100%, inset: 8pt, body))
      }
    )
}



#let article(
  title: none,
  subtitle: none,
  authors: none,
  date: none,
  abstract: none,
  abstract-title: none,
  cols: 1,
  margin: (x: 1.25in, y: 1.25in),
  paper: "us-letter",
  lang: "en",
  region: "US",
  font: "libertinus serif",
  fontsize: 11pt,
  title-size: 1.5em,
  subtitle-size: 1.25em,
  heading-family: "libertinus serif",
  heading-weight: "bold",
  heading-style: "normal",
  heading-color: black,
  heading-line-height: 0.65em,
  sectionnumbering: none,
  pagenumbering: "1",
  toc: false,
  toc_title: none,
  toc_depth: none,
  toc_indent: 1.5em,
  doc,
) = {
  set page(
    paper: paper,
    margin: margin,
    numbering: pagenumbering,
  )
  set par(justify: true)
  set text(lang: lang,
           region: region,
           font: font,
           size: fontsize)
  set heading(numbering: sectionnumbering)
  if title != none {
    align(center)[#block(inset: 2em)[
      #set par(leading: heading-line-height)
      #if (heading-family != none or heading-weight != "bold" or heading-style != "normal"
           or heading-color != black or heading-decoration == "underline"
           or heading-background-color != none) {
        set text(font: heading-family, weight: heading-weight, style: heading-style, fill: heading-color)
        text(size: title-size)[#title]
        if subtitle != none {
          parbreak()
          text(size: subtitle-size)[#subtitle]
        }
      } else {
        text(weight: "bold", size: title-size)[#title]
        if subtitle != none {
          parbreak()
          text(weight: "bold", size: subtitle-size)[#subtitle]
        }
      }
    ]]
  }

  if authors != none {
    let count = authors.len()
    let ncols = calc.min(count, 3)
    grid(
      columns: (1fr,) * ncols,
      row-gutter: 1.5em,
      ..authors.map(author =>
          align(center)[
            #author.name \
            #author.affiliation \
            #author.email
          ]
      )
    )
  }

  if date != none {
    align(center)[#block(inset: 1em)[
      #date
    ]]
  }

  if abstract != none {
    block(inset: 2em)[
    #text(weight: "semibold")[#abstract-title] #h(1em) #abstract
    ]
  }

  if toc {
    let title = if toc_title == none {
      auto
    } else {
      toc_title
    }
    block(above: 0em, below: 2em)[
    #outline(
      title: toc_title,
      depth: toc_depth,
      indent: toc_indent
    );
    ]
  }

  if cols == 1 {
    doc
  } else {
    columns(cols, doc)
  }
}

#set table(
  inset: 6pt,
  stroke: none
)

#show: doc => article(
  title: [\[PROPOSAL TITLE\]],
  pagenumbering: "1",
  toc_title: [Table of contents],
  toc_depth: 3,
  cols: 1,
  doc,
)

// Import template with helper functions
#import "template.typ": *

// Add logo to top right corner
#place(
  top + right,
  dx: 0pt,
  dy: -50pt,
  image("assets/logo.png", width: 100pt)
)
= General Information
<general-information>
== \[PROJECT NAME\]
<project-name>
\[Brief project description - 2-3 sentences summarizing the project's main goal and approach\]

== Thematic Areas of the Project (Multiple options can be selected)
<thematic-areas-of-the-project-multiple-options-can-be-selected>
#checkbox-table(
  columns: (auto, auto, auto),
  align: (left, left, left),
  inset: 10pt,
  
  [#checkbox() Digital Skills],
  [#checkbox() Digital Tools],
  [#checkbox() Data Science in Education],
  
  [#checkbox() Digital Ethics],
  [#checkbox(checked: true) Artificial Intelligence],
  [],
)
== Participating Founding Universities
<participating-founding-universities>
#checkbox-table(
  columns: (auto, auto, auto, auto, auto),
  align: center,
  
  [#checkbox(checked: true) BFH],
  [#checkbox() EHB],
  [#checkbox() EPFL],
  [#checkbox() PHBern],
  [#checkbox() Uni Bern],
)
= Project Team
<project-team>
== Project Leader(s)
<project-leaders>
#styled-table(
  columns: (3.5cm, 3cm, 3cm, 4cm),
  fill: (_, y) => if y == 0 { rgb("#f2f2f2") } else { none },
  
  [*First and Last Name*], [*Position*], [*Institution*], [*Ø presence in the hub per week*],
  
  [[LEADER NAME]], [[POSITION]], [[INSTITUTION]], [[DAYS] days],
  [[LEADER NAME 2]], [[POSITION]], [[INSTITUTION]], [[DAYS] days],
)
== Project Collaborators / Further Persons Involved in the Project
<project-collaborators-further-persons-involved-in-the-project>
#styled-table(
  columns: (3.5cm, 3cm, 3cm, 4cm),
  fill: (_, y) => if y == 0 { rgb("#f2f2f2") } else { none },
  
  [*First and Last Name*], [*Position*], [*Institution*], [*Ø presence in the hub per week*],
  [[COLLABORATOR NAME]], [[POSITION]], [[INSTITUTION]], [[DAYS] day],
)
== Duration
<duration>
#styled-table(
  columns: (4cm, auto),
  [*Project Start:*], [[START DATE]],
  [*Project End:*], [[END DATE]],
)
= Outline of the research project
<outline-of-the-research-project>
== Abstract
<abstract>
\[Write a comprehensive abstract (250-300 words) that covers: - The problem your project addresses - Your approach/methodology - Expected outcomes and impact - Relevance to BeLEARN's mission\]

== Introduction
<introduction>
\[Provide background context explaining: - Current state of the field - Identified gaps or challenges - Why this project is needed now - How it connects to broader educational technology trends\]

== Objectives
<objectives>
\[List the main objectives of your project: - Primary objective (1 sentence) - Secondary objectives (bullet points) - Specific deliverables expected\]

== Research Questions / Research Issue
<research-questions-research-issue>
=== Core Research Questions
<core-research-questions>
#strong[RQ1: \[MAIN RESEARCH QUESTION\]:] \[Detailed description of your primary research question\]

#strong[RQ2: \[SECONDARY RESEARCH QUESTION\]:] \[Detailed description of your secondary research question\]

#strong[RQ3: \[ADDITIONAL RESEARCH QUESTION\]:] \[If applicable, add more research questions\]

#emph[Note: \[Indicate which research questions are primary focus for the project duration\]]

== Method / Approach
<method-approach>
\[Describe your methodology in detail: - Technical approach - Research methods - Data collection strategies - Analysis techniques - Validation methods\]

== Added Value of the Project
<added-value-of-the-project>
\[Explain the value proposition: - Scientific contribution - Practical benefits - Innovation aspects - Alignment with BeLEARN priorities\]

== Translation into Educational Practice
<translation-into-educational-practice>
\[Describe how your project will be implemented: - Pilot implementation plans - Target audience (students, educators, institutions) - Integration with existing systems - Feedback mechanisms - Scaling considerations\]

== Timeline and Deliverables per Milestone
<timeline-and-deliverables-per-milestone>
#styled-table(
  columns: (7cm, 4cm, 2cm),
  fill: (_, y) => if y == 1 or y == 4 or y == 7 { rgb("#f2f2f2") } else { none },
  align: (left, left, center),
  
  [*Milestone*], [*Deliverable*], [*Month*],
  
  // Year 1 header
  [*Year 1: [YEAR 1 THEME]*], [], [],
  
  [[MILESTONE 1]], [[DELIVERABLE 1]], [[MONTH]],
  [[MILESTONE 2]], [[DELIVERABLE 2]], [[MONTH]],
  
  // Year 2 header (if applicable)
  [*Year 2: [YEAR 2 THEME]*], [], [],
  
  [[MILESTONE 3]], [[DELIVERABLE 3]], [[MONTH]],
  [[MILESTONE 4]], [[DELIVERABLE 4]], [[MONTH]],
  
  // Year 3 header (if applicable)
  [*Year 3: [YEAR 3 THEME]*], [], [],
  
  [[MILESTONE 5]], [[DELIVERABLE 5]], [[MONTH]],
  [[MILESTONE 6]], [[DELIVERABLE 6]], [[MONTH]],
)
== Thesis
<thesis>
#styled-table(
  columns: (auto, 10cm),
  fill: (_, y) => if y == 0 { rgb("#f2f2f2") } else { none },
  align: (center, left),
  
  [*Type*], [*Description*],
  
  [*Research Article*], [*Subject area:* [SUBJECT AREA]#linebreak()
  *Potential topics:* [LIST POTENTIAL RESEARCH ARTICLE TOPICS]],
  
  [*Master's Thesis*], [*Subject area:* [SUBJECT AREA]#linebreak()
  *Potential topics:* [LIST POTENTIAL THESIS TOPICS]],
)
= Requested Funding
<requested-funding>
#emph[For multi-year projects, funding is guaranteed for the first year only. Funding for subsequent years depends on the achievement of annual milestones.]

== List of Costs
<list-of-costs>
#styled-table(
  columns: (3cm, 2.5cm, 2.5cm, 2.5cm, 2.5cm),
  fill: (_, y) => if y == 0 { rgb("#f2f2f2") } else { none },
  align: (left, right, right, right, right),
  
  [*Founding University*], [*Year 1 (CHF)*], [*Year 2 (CHF)*], [*Year 3 (CHF)*], [*Total (CHF)*],
  [[INSTITUTION 1]], [[AMOUNT]], [[AMOUNT]], [[AMOUNT]], [[TOTAL]],
  [[INSTITUTION 2]], [[AMOUNT]], [[AMOUNT]], [[AMOUNT]], [[TOTAL]],
)
== Staff Costs
<staff-costs>
#styled-table(
  columns: (5cm, 4cm, 3cm),
  fill: (_, y) => if y == 0 { rgb("#f2f2f2") } else { none },
  align: (left, center, right),
  
  [*Name and institution:*], [*Employment rate (%) funded by BeLEARN*], [*Costs in CHF*],
  [[NAME] ([INSTITUTION])#linebreak()#text(size: 0.9em)[(payed by [INSTITUTION])]], [[PERCENTAGE]%], [[AMOUNT]],
  [[NAME] ([INSTITUTION])], [[PERCENTAGE]%], [[AMOUNT]],
)
== Acquisitions (e.g., Laptop, VR Headsets, Licenses, etc.)
<acquisitions-e.g.-laptop-vr-headsets-licenses-etc.>
#styled-table(
  columns: (9cm, 3cm),
  fill: (_, y) => if y == 0 { rgb("#f2f2f2") } else { none },
  align: (left, right),
  
  [*Description (mentioning institution)*], [*Costs in CHF*],
  [[DESCRIPTION] ([INSTITUTION])], [[AMOUNT]],
  [[DESCRIPTION] ([INSTITUTION])], [[AMOUNT]],
)
== Consumables and Expenses
<consumables-and-expenses>
#styled-table(
  columns: (9cm, 3cm),
  fill: (_, y) => if y == 0 { rgb("#f2f2f2") } else { none },
  align: (left, right),
  
  [*Description (mentioning institution)*], [*Costs in CHF*],
  [[DESCRIPTION] ([INSTITUTION])], [[AMOUNT]],
  [[DESCRIPTION] ([INSTITUTION])], [[AMOUNT]],
)
#strong[Has this project been funded by BeLEARN before?]

#styled-table(
  columns: (6cm, 6cm),
  align: center,
  
  [*Yes*], [*No*],
  [#checkbox()], [#checkbox()],
)
#strong[Is this project (partially) financed by the BeLEARN Booster Fund?]

#styled-table(
  columns: (6cm, 6cm),
  align: center,
  
  [*Yes*], [*No*],
  [#checkbox()], [#checkbox()],
)
#strong[Is this project also (partially) financed by another funding institution?]

#styled-table(
  columns: (6cm, 6cm),
  align: center,
  
  [*Yes*], [*No*],
  [#checkbox()], [#checkbox()],
)
If so, from which funding institution and for what amount?

#styled-table(
  columns: (7cm, 4cm),
  
  [*Funding institution:*], [*Amount in CHF:*],
  [[INSTITUTION]], [[AMOUNT]],
)
== Total Project Costs
<total-project-costs>
#strong[Total Project Costs (including non-BeLEARN requested costs)];: \[TOTAL AMOUNT\] CHF

Please fill in one form per project and send it until #strong[\[DEADLINE\]] at the latest in electronic form to the following address: #link("mailto:info@belearn.swiss")[info\@belearn.swiss]

#pagebreak()


 

#set bibliography(style: "apa")


#bibliography("bibliography.bib")


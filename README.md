# BeLEARN Proposal Template

This template provides a structured format for BeLEARN funding applications based on the ILLUMINATE proposal format.

## Quick Start

1. **Copy this template directory** to create a new proposal
2. **Edit `main.qmd`** and replace all placeholder content marked with `[BRACKETS]`
3. **Update the bibliography** in `bibliography.bib` with your references
4. **Replace the logo** in `assets/logo.png` with your institution's logo
5. **Generate the PDF** using Quarto

## Files Included

- `main.qmd` - Main proposal document with placeholder content
- `main.typ` - Generated Typst document (auto-created from main.qmd during rendering)
- `template.typ` - Typst template for formatting (custom functions for tables, checkboxes)
- `bibliography.bib` - Template bibliography file
- `_quarto.yml` - Quarto configuration
- `assets/logo.png` - Placeholder logo (replace with your own)

## Building the Document

Ensure you have Quarto installed with Typst support, then run:

```bash
quarto render main.qmd
```

This will generate `main.pdf`.

## Template Placeholders

Replace all content marked with `[BRACKETS]`:

### Project Information
- `[PROPOSAL TITLE]` - Your proposal title
- `[PROJECT NAME]` - Short project name
- `[Brief project description]` - 2-3 sentence summary

### Team Information
- `[LEADER NAME]`, `[POSITION]`, `[INSTITUTION]`, `[DAYS]` - Project leader details
- `[COLLABORATOR NAME]` - Collaborator information

### Dates and Timeline
- `[START DATE]`, `[END DATE]` - Project duration
- `[YEAR X THEME]` - Yearly themes
- `[MILESTONE X]`, `[DELIVERABLE X]`, `[MONTH]` - Timeline details

### Budget Information
- `[INSTITUTION X]`, `[AMOUNT]`, `[TOTAL]` - Cost breakdowns
- `[PERCENTAGE]` - Employment percentages
- `[DESCRIPTION]` - Budget item descriptions

### Content Sections
- Research questions, methodology, objectives - Replace with your content
- Abstract, introduction, added value - Write your specific content

## Checkbox Tables

Use the provided checkbox functions for required selections:

```typst
// Checked checkbox
#checkbox(checked: true)

// Unchecked checkbox  
#checkbox()
```

## Custom Styling

The template includes:
- `#styled-table()` for formatted tables
- `#checkbox-table()` for checkbox selection tables
- Custom Typst formatting functions

## Tips

1. **Keep formatting consistent** - Use the provided table functions
2. **Check all placeholders** - Search for `[` to find remaining placeholders
3. **Validate dates** - Ensure timeline is realistic and consistent
4. **Budget accuracy** - Double-check all financial calculations
5. **Reference formatting** - Follow BibTeX format in bibliography.bib

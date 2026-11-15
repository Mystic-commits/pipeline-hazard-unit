# Phase I report and submission materials

- [IEEE project report PDF](ieee-report.pdf) — submission copy, typeset using the IEEEtran conference class.
- [Editable LaTeX source](ieee-report.tex) — includes the block diagram and numbered bibliography.
- [Video status and timed script](video.md) — target 4:30, all five member names, live prototype demonstration.

## Rebuild the report

Use an existing TeX Live/MiKTeX installation with IEEEtran, or Tectonic. From the repository root:

```sh
make report
```

Alternatively, from this directory run `pdflatex ieee-report.tex` twice, or upload the `.tex` file to Overleaf and select a compiler with IEEEtran installed. Standard packages used are `amsmath`, `graphicx`, `booktabs`, `tikz`, `hyperref`, and `url`.

The report uses the standard two-column IEEE conference layout, title and author block, abstract, index terms, Roman-numbered sections, and numbered references. It is a course project report, not an IEEE-published paper. No copyright notice, publication identifier or DOI is invented for the project.

Numerical results are taken from `docs/evidence/`. The report's individual-contribution section describes allocated workstreams. Existing Git history is not proof of five separate authors; preserve real contribution evidence as described in `CONTRIBUTING.md`.

# StateDiagramsSVG.jl

[![Documentation](https://img.shields.io/badge/docs-dev-blue.svg)](https://EvoArt.github.io/StateDiagramsSVG.jl/dev/)
[![CI](https://github.com/EvoArt/StateDiagramsSVG.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/EvoArt/StateDiagramsSVG.jl/actions/workflows/CI.yml)
[![Coverage](https://codecov.io/gh/EvoArt/StateDiagramsSVG.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/EvoArt/StateDiagramsSVG.jl)

Describe states and transitions in a short model specification. The package
places the cards and arrows, then renders the diagram as SVG, TikZ for LaTeX,
CeTZ for Typst, or a Makie figure. The core package has no dependencies.

```julia
using Pkg
Pkg.add(url = "https://github.com/EvoArt/StateDiagramsSVG.jl.git")
```

```julia
using StateDiagramsSVG

d = state_diagram(raw"""
    state D: Draft
    state R: Review
    state P: Published
    D -> R: submit | p_submit ~ $p_{\mathrm{submit}}$
    R -> P: approve | p_accept ~ $p_{\mathrm{accept}}$
    """; title = "Document workflow", width = 900)

save_svg("workflow.svg", d)
save_tikz("workflow.tex", d; standalone = true)
save_cetz("workflow.typ", d; standalone = true)
d
```

![Document workflow diagram](docs/src/assets/workflow.svg)

The text before ` ~ ` is used in SVG, CeTZ and Makie; the TeX after it is used
verbatim in TikZ. Compile a standalone `.tex` file with XeLaTeX for a PDF,
then run `pdftocairo -svg workflow.pdf workflow.svg` for a vector SVG with TeX text.
Only use trusted TeX input. Optional `entry:`, `note:`, and `section` statements
add annotations. Multiple sources can share a transition, as in
`D, R -> P: publish | p`.

Load `CairoMakie`, `GLMakie`, or another Makie backend to call
`makiefigure(d)` or draw into an existing axis with `makieplot!(axis, d)`.
See the [backend guide](https://EvoArt.github.io/StateDiagramsSVG.jl/dev/backends/)
and [API reference](https://EvoArt.github.io/StateDiagramsSVG.jl/dev/api/).

The coordinate drawing functions remain available for custom layouts.

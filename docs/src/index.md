# StateDiagramsSVG.jl

StateDiagramsSVG lays out a diagram from state and transition statements, then
renders SVG, TikZ, CeTZ, or a Makie figure. The core renderer has no dependencies.

Install the current release from GitHub:

```julia
using Pkg
Pkg.add(url = "https://github.com/EvoArt/StateDiagramsSVG.jl.git")
```

## First diagram

The following example is executed during the documentation build.

```@example workflow
using StateDiagramsSVG

d = state_diagram(raw"""
    state D: Draft
    state R: Review
    state P: Published
    D -> R: submit | p_submit ~ $p_{\mathrm{submit}}$
    R -> P: approve | p_accept ~ $p_{\mathrm{accept}}$
    """; title = "Document workflow", width = 900)

save_svg("workflow.svg", d)
nothing
```

![Document workflow](assets/workflow.svg)

Add an `entry:` or `note:` line for context. Use
`section NAME [wide]: text | detail` for an explanatory panel. A label can have
a TeX alternative after ` ~ `, which the TikZ backend uses verbatim. See
[Backends](@ref) for vector TeX output and Makie, and [API](@ref) for the
underlying drawing functions.

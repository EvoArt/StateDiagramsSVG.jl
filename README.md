# StateDiagramsSVG.jl

A small, dependency free Julia package for drawing labelled state diagrams as
publication quality SVG. It provides rounded cards, paths, centred arrows, and
text; the calling script controls the layout and colour scheme. All geometry
is vector and the output remains editable in a text or vector graphics editor.

```julia
using StateDiagramsSVG
d = Diagram(500, 160; title = "Two states")
state_card!(d, 30, 30, 140, 100, "S", "Susceptible";
            fill = "#eef7f9", accent = "#2879a0")
state_card!(d, 330, 30, 140, 100, "E", "Exposed";
            fill = "#f1f7f3", accent = "#427e68")
arrow!(d, 180, 80, 320, 80)
save_svg("states.svg", d)
```

The manuscript's figure recipe is in `code/src/05_state_space.jl` in the
Badger Grant Paper 1 repository.

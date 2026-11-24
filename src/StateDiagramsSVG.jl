module StateDiagramsSVG

export Diagram, rect!, circle!, path!, line!, text!, arrow!, state_card!
export svg, save_svg, tikz, save_tikz, cetz, save_cetz, makiefigure, makieplot!
export state_diagram

abstract type Primitive end
struct RectPrim <: Primitive
    x::Float64; y::Float64; w::Float64; h::Float64; radius::Float64
    fill::String; stroke::String; width::Float64
end
struct CirclePrim <: Primitive
    x::Float64; y::Float64; r::Float64
    fill::String; stroke::String; width::Float64
end
struct PathPrim <: Primitive
    commands::String; stroke::String; width::Float64; fill::String
    dash::Union{Nothing,String}
end
struct TextPrim <: Primitive
    x::Float64; y::Float64; content::String; size::Float64
    color::String; bold::Bool; anchor::Symbol; family::String
    latex::Union{Nothing,String}
end

"""
    Diagram

Canvas of drawing primitives, rendered by [`svg`](@ref), [`tikz`](@ref),
[`cetz`](@ref) or [`makiefigure`](@ref). Origin top left, y down.

Fields: `width`, `height`, `title`, `description` (SVG accessibility text).
"""
struct Diagram
    width::Int
    height::Int
    elements::Vector{String}
    primitives::Vector{Primitive}
    title::String
    description::String
end

"""
    Diagram(width, height; title="", description="") -> Diagram

Empty canvas of `width` × `height` units.
"""
Diagram(width::Integer, height::Integer; title = "", description = "") =
    Diagram(Int(width), Int(height), String[], Primitive[], title, description)

escape_xml(s) = replace(string(s), '&' => "&amp;", '<' => "&lt;", '>' => "&gt;",
                        '"' => "&quot;", '\'' => "&apos;")
attr(name, value) = " $name=\"$(escape_xml(value))\""
add!(d::Diagram, element) = (push!(d.elements, element); d)

"""
    rect!(d, x, y, w, h; radius=0, fill="white", stroke="none", width=1) -> d

Add a rectangle with top-left corner `(x, y)`. `radius` rounds corners; `width` is stroke width.
"""
function rect!(d::Diagram, x, y, w, h; radius = 0, fill = "white", stroke = "none", width = 1)
    push!(d.primitives, RectPrim(x, y, w, h, radius, fill, stroke, width))
    add!(d, "<rect$(attr("x", x))$(attr("y", y))$(attr("width", w))$(attr("height", h))" *
            "$(attr("rx", radius))$(attr("fill", fill))$(attr("stroke", stroke))" *
            "$(attr("stroke-width", width)) />")
end

"""
    circle!(d, x, y, r; fill="white", stroke="none", width=1) -> d

Add a circle centred at `(x, y)`.
"""
function circle!(d::Diagram, x, y, r; fill = "white", stroke = "none", width = 1)
    push!(d.primitives, CirclePrim(x, y, r, fill, stroke, width))
    add!(d, "<circle$(attr("cx", x))$(attr("cy", y))$(attr("r", r))" *
            "$(attr("fill", fill))$(attr("stroke", stroke))$(attr("stroke-width", width)) />")
end

"""
    path!(d, commands; stroke="#172630", width=2, fill="none", dash=nothing) -> d

Add a path from absolute SVG commands (`M L H V Q C Z`), e.g. `"M0 0 L10 10"`.
`dash` is an SVG dash array `"on off"`.
"""
function path!(d::Diagram, commands; stroke = "#172630", width = 2, fill = "none",
               dash = nothing)
    push!(d.primitives, PathPrim(commands, stroke, width, fill, dash))
    extra = isnothing(dash) ? "" : attr("stroke-dasharray", dash)
    add!(d, "<path$(attr("d", commands))$(attr("stroke", stroke))" *
            "$(attr("stroke-width", width))$(attr("fill", fill))$extra " *
            "stroke-linecap=\"round\" stroke-linejoin=\"round\" />")
end

"""
    line!(d, x1, y1, x2, y2; kwargs...) -> d

Add a line segment. Keywords as [`path!`](@ref).
"""
line!(d::Diagram, x1, y1, x2, y2; kwargs...) =
    path!(d, "M$x1 $y1 L$x2 $y2"; kwargs...)

"""
    text!(d, x, y, content; size=20, color="#172630", bold=false, anchor=:start,
          family="Arial, Helvetica, sans-serif", latex=nothing) -> d

Add text vertically centred on `y`. `anchor` is `:start`, `:middle` or `:end`.
`latex`, if given, replaces `content` in [`tikz`](@ref) output.
"""
function text!(d::Diagram, x, y, content; size = 20, color = "#172630", bold = false,
               anchor = :start, family = "Arial, Helvetica, sans-serif", latex = nothing)
    push!(d.primitives, TextPrim(x, y, content, size, color, bold, anchor, family, latex))
    alignment = anchor === :middle ? "middle" : anchor === :end ? "end" : "start"
    add!(d, "<text$(attr("x", x))$(attr("y", y))$(attr("font-size", size))" *
            "$(attr("fill", color))$(attr("font-weight", bold ? 700 : 400))" *
            "$(attr("text-anchor", alignment))$(attr("font-family", family))" *
            " dominant-baseline=\"middle\">$(escape_xml(content))</text>")
end

"""
    arrow!(d, x1, y1, x2, y2; color="#2879a0", width=4.5, head=13) -> d

Add a straight arrow from `(x1, y1)` to `(x2, y2)` with a filled head of length `head`.
Throws `ArgumentError` if the arrow is shorter than `head`.
"""
function arrow!(d::Diagram, x1, y1, x2, y2; color = "#2879a0", width = 4.5, head = 13)
    dx, dy = x2 - x1, y2 - y1
    len = hypot(dx, dy)
    len > head || throw(ArgumentError("arrow length must exceed head size"))
    ux, uy = dx / len, dy / len
    px, py = -uy, ux
    bx, by = x2 - head * ux, y2 - head * uy
    line!(d, x1, y1, bx + 0.35head * ux, by + 0.35head * uy;
          stroke = color, width)
    tip = "M$x2 $y2 L$(bx + 0.43head * px) $(by + 0.43head * py) " *
          "L$(bx - 0.43head * px) $(by - 0.43head * py) Z"
    path!(d, tip; stroke = color, width = 1, fill = color)
end

"""
    state_card!(d, x, y, w, h, code, name; fill, accent, ink="#172630") -> d

Add a rounded card with top-left `(x, y)` showing `code` (large, `accent`) above `name` (`ink`).
"""
function state_card!(d::Diagram, x, y, w, h, code, name; fill, accent,
                     ink = "#172630")
    rect!(d, x, y, w, h; radius = 15, fill, stroke = accent, width = 2.8)
    text!(d, x + 23, y + 39, code; size = 38, color = accent, bold = true)
    text!(d, x + 23, y + 82, name; size = 21, color = ink)
end

"""
    svg(d) -> String

Render `d` as a standalone SVG document.
"""
function svg(d::Diagram)
    io = IOBuffer()
        println(io, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>")
        println(io, "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"$(d.width)\" " *
                    "height=\"$(d.height)\" viewBox=\"0 0 $(d.width) $(d.height)\" " *
                    "role=\"img\" aria-labelledby=\"diagram-title diagram-description\">")
        println(io, "<title id=\"diagram-title\">$(escape_xml(d.title))</title>")
        println(io, "<desc id=\"diagram-description\">$(escape_xml(d.description))</desc>")
        println(io, "<rect width=\"100%\" height=\"100%\" fill=\"white\"/>")
        foreach(element -> println(io, element), d.elements)
        println(io, "</svg>")
    String(take!(io))
end

Base.show(io::IO, ::MIME"image/svg+xml", d::Diagram) = print(io, svg(d))

"""
    save_svg(filename, d) -> filename

Write [`svg(d)`](@ref svg) to `filename`, creating parent directories.
"""
function save_svg(filename, d::Diagram)
    mkpath(dirname(filename))
    write(filename, svg(d))
    filename
end

"""
    makiefigure(d; scale=1) -> (Figure, Axis)

Render `d` as a new Makie figure sized `scale` × canvas. Requires a loaded Makie backend.
"""
function makiefigure end
"""
    makieplot!(ax, d; linewidthscale=1, fontscale=1) -> ax

Draw `d` into an existing `Makie.Axis` (y negated). Requires a loaded Makie backend.
"""
function makieplot! end

include("geometry.jl")
include("tikz.jl")
include("cetz.jl")
include("highlevel.jl")

end

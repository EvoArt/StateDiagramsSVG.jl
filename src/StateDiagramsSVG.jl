module StateDiagramsSVG

export Diagram, rect!, circle!, path!, line!, text!, arrow!, state_card!, save_svg

"A small, dependency free canvas for publication diagrams in SVG. Coordinates start at the top left."
struct Diagram
    width::Int
    height::Int
    elements::Vector{String}
    title::String
    description::String
end

Diagram(width::Integer, height::Integer; title = "", description = "") =
    Diagram(Int(width), Int(height), String[], title, description)

escape_xml(s) = replace(string(s), '&' => "&amp;", '<' => "&lt;", '>' => "&gt;",
                        '"' => "&quot;", '\'' => "&apos;")
attr(name, value) = " $name=\"$(escape_xml(value))\""
add!(d::Diagram, element) = (push!(d.elements, element); d)

function rect!(d::Diagram, x, y, w, h; radius = 0, fill = "white", stroke = "none", width = 1)
    add!(d, "<rect$(attr("x", x))$(attr("y", y))$(attr("width", w))$(attr("height", h))" *
            "$(attr("rx", radius))$(attr("fill", fill))$(attr("stroke", stroke))" *
            "$(attr("stroke-width", width)) />")
end

function circle!(d::Diagram, x, y, r; fill = "white", stroke = "none", width = 1)
    add!(d, "<circle$(attr("cx", x))$(attr("cy", y))$(attr("r", r))" *
            "$(attr("fill", fill))$(attr("stroke", stroke))$(attr("stroke-width", width)) />")
end

function path!(d::Diagram, commands; stroke = "#172630", width = 2, fill = "none",
               dash = nothing)
    extra = isnothing(dash) ? "" : attr("stroke-dasharray", dash)
    add!(d, "<path$(attr("d", commands))$(attr("stroke", stroke))" *
            "$(attr("stroke-width", width))$(attr("fill", fill))$extra " *
            "stroke-linecap=\"round\" stroke-linejoin=\"round\" />")
end

line!(d::Diagram, x1, y1, x2, y2; kwargs...) =
    path!(d, "M$x1 $y1 L$x2 $y2"; kwargs...)

function text!(d::Diagram, x, y, content; size = 20, color = "#172630", bold = false,
               anchor = :start, family = "Arial, Helvetica, sans-serif")
    alignment = anchor === :middle ? "middle" : anchor === :end ? "end" : "start"
    add!(d, "<text$(attr("x", x))$(attr("y", y))$(attr("font-size", size))" *
            "$(attr("fill", color))$(attr("font-weight", bold ? 700 : 400))" *
            "$(attr("text-anchor", alignment))$(attr("font-family", family))" *
            " dominant-baseline=\"middle\">$(escape_xml(content))</text>")
end

"Draw a centred straight arrow between two points, with a compact filled head."
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

"Draw a two-line hidden-state card."
function state_card!(d::Diagram, x, y, w, h, code, name; fill, accent,
                     ink = "#172630")
    rect!(d, x, y, w, h; radius = 15, fill, stroke = accent, width = 2.8)
    text!(d, x + 23, y + 39, code; size = 38, color = accent, bold = true)
    text!(d, x + 23, y + 82, name; size = 21, color = ink)
end

function save_svg(filename, d::Diagram)
    mkpath(dirname(filename))
    open(filename, "w") do io
        println(io, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>")
        println(io, "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"$(d.width)\" " *
                    "height=\"$(d.height)\" viewBox=\"0 0 $(d.width) $(d.height)\" " *
                    "role=\"img\" aria-labelledby=\"diagram-title diagram-description\">")
        println(io, "<title id=\"diagram-title\">$(escape_xml(d.title))</title>")
        println(io, "<desc id=\"diagram-description\">$(escape_xml(d.description))</desc>")
        println(io, "<rect width=\"100%\" height=\"100%\" fill=\"white\"/>")
        foreach(element -> println(io, element), d.elements)
        println(io, "</svg>")
    end
    filename
end

end

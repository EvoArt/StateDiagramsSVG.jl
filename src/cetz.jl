_typstr(s::AbstractString) = "\"" * replace(s, '\\' => "\\\\", '"' => "\\\"",
                                         '\n' => "\\n") * "\""
_czxy(x, y, scale) = "($(_fmt(scale*x)), $(_fmt(-scale*y)))"
_czcolor(c) = c == "none" ? "none" : "rgb(\"#$( _hex(c) )\")"

function _czstyle(fill, stroke, width, scale; dash = nothing)
    f = _czcolor(fill)
    s = if stroke == "none" || width <= 0
        "none"
    else
        parts = ["paint: $(_czcolor(stroke))", "thickness: $(_fmt(scale*width))pt",
                 "cap: \"round\"", "join: \"round\""]
        if dash !== nothing
            bits = split(replace(dash, ',' => ' '))
            length(bits) == 2 || throw(ArgumentError("dash must contain on and off lengths"))
            push!(parts, "dash: ($(_fmt(scale*parse(Float64,bits[1])))pt, " *
                         "$(_fmt(scale*parse(Float64,bits[2])))pt)")
        end
        "(" * join(parts, ", ") * ")"
    end
    "fill: $f, stroke: $s"
end

function _cetz_primitive(io, p::RectPrim, scale)
    style = _czstyle(p.fill, p.stroke, p.width, scale)
    println(io, "  rect($(_czxy(p.x,p.y,scale)), $(_czxy(p.x+p.w,p.y+p.h,scale)), " *
                "$style, radius: $(_fmt(scale*p.radius)))")
end

function _cetz_primitive(io, p::CirclePrim, scale)
    style = _czstyle(p.fill, p.stroke, p.width, scale)
    println(io, "  circle($(_czxy(p.x,p.y,scale)), radius: $(_fmt(scale*p.r)), $style)")
end

function _cetz_primitive(io, p::PathPrim, scale)
    style = _czstyle(p.fill, p.stroke, p.width, scale; dash = p.dash)
    for (pts, closed) in _path_polylines(p.commands)
        length(pts) >= 2 || continue
        coords = join((_czxy(x, y, scale) for (x, y) in pts), ", ")
        println(io, "  line($coords, ", closed ? "close: true, " : "", "$style)")
    end
end

function _cetz_primitive(io, p::TextPrim, scale)
    anchor = p.anchor === :middle ? "base" : p.anchor === :end ? "base-east" : "base-west"
    weight = p.bold ? ", weight: \"bold\"" : ""
    baseline = p.y + 0.36p.size
    println(io, "  content($(_czxy(p.x,baseline,scale)), " *
                "text(size: $(_fmt(scale*p.size))pt, fill: $(_czcolor(p.color))$weight, " *
                "top-edge: \"cap-height\", bottom-edge: \"baseline\", $(_typstr(p.content))), " *
                "anchor: \"$anchor\", padding: 0)")
end

"""
    cetz(diagram; standalone=false, scale=1, version="0.4.2") -> String

Render a diagram as CeTZ code for Typst. Curves are sampled into short line
segments. The generated source imports CeTZ from Typst Universe.
"""
function cetz(d::Diagram; standalone::Bool = false, scale::Real = 1,
              version::AbstractString = "0.4.2")
    scale > 0 || throw(ArgumentError("scale must be positive"))
    io = IOBuffer()
    println(io, "#import \"@preview/cetz:$version\"")
    standalone && println(io, "#set page(width: auto, height: auto, margin: 0pt)")
    println(io, "#[")
    println(io, "#context cetz.canvas(length: 1pt, {")
    println(io, "  import cetz.draw: *")
    println(io, "  rect((0, 0), $(_czxy(d.width,d.height,scale)), " *
                "fill: rgb(\"#FFFFFF\"), stroke: none)")
    for p in d.primitives
        _cetz_primitive(io, p, scale)
    end
    println(io, "})")
    println(io, "]")
    String(take!(io))
end

"Write CeTZ/Typst source to `filename`. Pass `standalone=true` for a full document."
function save_cetz(filename, d::Diagram; kwargs...)
    mkpath(dirname(filename))
    write(filename, cetz(d; kwargs...))
    filename
end

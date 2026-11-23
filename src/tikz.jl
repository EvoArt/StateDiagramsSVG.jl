_colours(p::RectPrim) = (p.fill, p.stroke)
_colours(p::CirclePrim) = (p.fill, p.stroke)
_colours(p::PathPrim) = (p.fill, p.stroke)
_colours(p::TextPrim) = (p.color,)

function _colour_names(d::Diagram)
    names = Dict{String,String}()
    for p in d.primitives, color in _colours(p)
        color == "none" && continue
        hex = _hex(color)
        get!(names, hex) do
            "sd$(length(names) + 1)"
        end
    end
    names
end

_tkxy(x, y) = "($(_fmt(x)),$(_fmt(y)))"

function _tkstyle(fill, stroke, width, names; radius = 0, dash = nothing)
    opts = String[]
    fill == "none" || push!(opts, "fill=$(names[_hex(fill)])")
    if stroke != "none" && width > 0
        append!(opts, ("draw=$(names[_hex(stroke)])", "line width=$(_fmt(width))pt",
                       "line cap=round", "line join=round"))
        if dash !== nothing
            bits = split(replace(dash, ',' => ' '))
            length(bits) == 2 || throw(ArgumentError("dash must contain on and off lengths"))
            push!(opts, "dash pattern=on $(bits[1])pt off $(bits[2])pt")
        end
    end
    radius > 0 && push!(opts, "rounded corners=$(_fmt(radius))pt")
    isempty(opts) ? "draw=none" : join(opts, ", ")
end

function _texescape(s::AbstractString)
    io = IOBuffer()
    for ch in s
        if ch == '\\'
            print(io, "\\textbackslash{}")
        elseif ch in ('{', '}', '$', '&', '#', '%', '_')
            print(io, '\\', ch)
        elseif ch == '^'
            print(io, "\\textasciicircum{}")
        elseif ch == '~'
            print(io, "\\textasciitilde{}")
        else
            print(io, ch)
        end
    end
    String(take!(io))
end

function _tikz_primitive(io, p::RectPrim, names)
    style = _tkstyle(p.fill, p.stroke, p.width, names; radius = p.radius)
    println(io, "\\path[$style] $(_tkxy(p.x, p.y)) rectangle $(_tkxy(p.x+p.w, p.y+p.h));")
end

function _tikz_primitive(io, p::CirclePrim, names)
    style = _tkstyle(p.fill, p.stroke, p.width, names)
    println(io, "\\path[$style] $(_tkxy(p.x, p.y)) circle[radius=$(_fmt(p.r))pt];")
end

function _tikz_primitive(io, p::PathPrim, names)
    style = _tkstyle(p.fill, p.stroke, p.width, names; dash = p.dash)
    for (pts, closed) in _path_polylines(p.commands)
        isempty(pts) && continue
        body = join((_tkxy(x, y) for (x, y) in pts), " -- ")
        closed && (body *= " -- cycle")
        println(io, "\\path[$style] $body;")
    end
end

function _tikz_primitive(io, p::TextPrim, names)
    anchor = p.anchor === :middle ? "base" : p.anchor === :end ? "base east" : "base west"
    font = "\\fontsize{$(_fmt(p.size))}{$(_fmt(1.2p.size))}\\selectfont" *
           (p.bold ? "\\bfseries" : "")
    color = names[_hex(p.color)]
    println(io, "\\node[anchor=$anchor, inner sep=0pt, text=$color, font=$font] at " *
                "$(_tkxy(p.x, p.y + 0.36p.size)) {$(isnothing(p.latex) ? _texescape(p.content) : p.latex)};")
end

"""
    tikz(diagram; standalone=false, scale=1) -> String

Render the same diagram as a TikZ picture. Curves are sampled into short line
segments. Use XeLaTeX or LuaLaTeX for labels containing Unicode characters.
"""
function tikz(d::Diagram; standalone::Bool = false, scale::Real = 1)
    scale > 0 || throw(ArgumentError("scale must be positive"))
    names = _colour_names(d)
    io = IOBuffer()
    if standalone
        println(io, "\\documentclass[tikz,border=0pt]{standalone}")
        println(io, "\\usepackage{fontspec}")
        println(io, "\\begin{document}")
    end
    println(io, "\\begingroup")
    for (hex, name) in sort!(collect(names); by = last)
        println(io, "\\definecolor{$name}{HTML}{$hex}")
    end
    println(io, "\\begin{tikzpicture}[x=1pt,y=-1pt,scale=$(_fmt(scale)),transform shape]")
    println(io, "\\path[fill=white,draw=none] (0,0) rectangle $(_tkxy(d.width,d.height));")
    for p in d.primitives
        _tikz_primitive(io, p, names)
    end
    println(io, "\\end{tikzpicture}")
    println(io, "\\endgroup")
    standalone && println(io, "\\end{document}")
    String(take!(io))
end

"Write TikZ source to `filename`. Pass `standalone=true` for a full document."
function save_tikz(filename, d::Diagram; kwargs...)
    mkpath(dirname(filename))
    write(filename, tikz(d; kwargs...))
    filename
end

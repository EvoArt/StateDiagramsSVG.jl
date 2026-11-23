module StateDiagramsSVGMakieExt

import Makie
import StateDiagramsSVG
using StateDiagramsSVG: Diagram, Primitive, RectPrim, CirclePrim, PathPrim, TextPrim,
                        _path_polylines, _rect_points, _circle_points
import StateDiagramsSVG: makiefigure, makieplot!

_point(x, y) = Makie.Point2f(x, -y)
_points(pts) = [_point(x, y) for (x, y) in pts]

function _draw!(ax, p::RectPrim, lws, fs)
    pts = _points(_rect_points(p))
    if p.fill == "none"
        p.stroke == "none" || Makie.lines!(ax, [pts; first(pts)]; color = p.stroke,
                                           linewidth = p.width*lws, linecap = :round)
    else
        Makie.poly!(ax, pts; color = p.fill,
                    strokecolor = p.stroke == "none" ? :transparent : p.stroke,
                    strokewidth = p.stroke == "none" ? 0 : p.width*lws)
    end
end

function _draw!(ax, p::CirclePrim, lws, fs)
    pts = _points(_circle_points(p))
    if p.fill == "none"
        p.stroke == "none" || Makie.lines!(ax, [pts; first(pts)]; color = p.stroke,
                                           linewidth = p.width*lws, linecap = :round)
    else
        Makie.poly!(ax, pts; color = p.fill,
                    strokecolor = p.stroke == "none" ? :transparent : p.stroke,
                    strokewidth = p.stroke == "none" ? 0 : p.width*lws)
    end
end

function _draw!(ax, p::PathPrim, lws, fs)
    for (polyline, closed) in _path_polylines(p.commands)
        length(polyline) >= 2 || continue
        pts = _points(polyline)
        if p.fill != "none" && length(pts) >= 3
            Makie.poly!(ax, pts; color = p.fill,
                        strokecolor = p.stroke == "none" ? :transparent : p.stroke,
                        strokewidth = p.stroke == "none" ? 0 : p.width*lws)
        elseif p.stroke != "none"
            closed && push!(pts, first(pts))
            Makie.lines!(ax, pts; color = p.stroke, linewidth = p.width*lws,
                         linecap = :round, joinstyle = :round)
        end
    end
end

function _draw!(ax, p::TextPrim, lws, fs)
    align = p.anchor === :middle ? :center : p.anchor === :end ? :right : :left
    Makie.text!(ax, p.x, -p.y; text = p.content, color = p.color,
                fontsize = p.size*fs, font = p.bold ? :bold : :regular,
                align = (align, :center))
end

"Draw the recorded primitives into an existing Makie axis."
function makieplot!(ax::Makie.Axis, d::Diagram; linewidthscale::Real = 1,
                    fontscale::Real = 1)
    for p in d.primitives
        _draw!(ax, p, linewidthscale, fontscale)
    end
    ax
end

"Return a Makie figure and axis containing the same diagram as the SVG backend."
function makiefigure(d::Diagram; scale::Real = 1)
    scale > 0 || throw(ArgumentError("scale must be positive"))
    fig = Makie.Figure(size = (round(Int, d.width*scale), round(Int, d.height*scale)),
                       figure_padding = 0, backgroundcolor = :white)
    ax = Makie.Axis(fig[1, 1], limits = (0, d.width, -d.height, 0),
                    aspect = Makie.DataAspect(), backgroundcolor = :white)
    Makie.hidedecorations!(ax)
    Makie.hidespines!(ax)
    makieplot!(ax, d; linewidthscale = scale, fontscale = scale)
    (fig, ax)
end

end

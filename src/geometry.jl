# Shared geometry for the TikZ, CeTZ and Makie renderers. SVG keeps the
# original vector commands; other renderers sample quadratic/cubic curves.

const Point = NTuple{2,Float64}
const Polyline = Tuple{Vector{Point},Bool}

_fmt(x::Real) = string(round(Float64(x); digits = 4))

function _hex(color::AbstractString)
    c = lowercase(color)
    c == "white" && return "FFFFFF"
    c == "black" && return "000000"
    if occursin(r"^#[0-9a-f]{6}$", c)
        return uppercase(c[2:end])
    elseif occursin(r"^#[0-9a-f]{3}$", c)
        return uppercase(join(repeat(string(ch), 2) for ch in c[2:end]))
    end
    throw(ArgumentError("TikZ and CeTZ colours must be #RRGGBB, #RGB, white or black; got $color"))
end

function _path_polylines(commands::AbstractString)
    tokens = [m.match for m in eachmatch(r"[A-Za-z]|[-+]?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?", commands)]
    out = Polyline[]
    pts = Point[]
    i = 1
    cmd = '\0'
    x = y = 0.0
    start = (0.0, 0.0)
    function number()
        i <= length(tokens) || throw(ArgumentError("incomplete SVG path: $commands"))
        v = parse(Float64, tokens[i])
        i += 1
        v
    end
    while i <= length(tokens)
        tok = tokens[i]
        if length(tok) == 1 && isletter(tok[1])
            cmd = tok[1]
            i += 1
        end
        if cmd == 'M'
            isempty(pts) || push!(out, (pts, false))
            x, y = number(), number()
            pts = Point[(x, y)]
            start = (x, y)
            cmd = 'L'
        elseif cmd == 'L'
            x, y = number(), number()
            push!(pts, (x, y))
        elseif cmd == 'H'
            x = number()
            push!(pts, (x, y))
        elseif cmd == 'V'
            y = number()
            push!(pts, (x, y))
        elseif cmd == 'Q'
            cx, cy, ex, ey = number(), number(), number(), number()
            x0, y0 = x, y
            for k in 1:16
                t = k / 16
                push!(pts, ((1-t)^2*x0 + 2(1-t)*t*cx + t^2*ex,
                            (1-t)^2*y0 + 2(1-t)*t*cy + t^2*ey))
            end
            x, y = ex, ey
        elseif cmd == 'C'
            c1x, c1y, c2x, c2y, ex, ey = (number() for _ in 1:6)
            x0, y0 = x, y
            for k in 1:20
                t = k / 20
                push!(pts, ((1-t)^3*x0 + 3(1-t)^2*t*c1x + 3(1-t)*t^2*c2x + t^3*ex,
                            (1-t)^3*y0 + 3(1-t)^2*t*c1y + 3(1-t)*t^2*c2y + t^3*ey))
            end
            x, y = ex, ey
        elseif cmd == 'Z'
            isempty(pts) && throw(ArgumentError("close without a path"))
            push!(out, (pts, true))
            pts = Point[]
            x, y = start
            cmd = '\0'
        else
            throw(ArgumentError("unsupported SVG path command: $cmd"))
        end
    end
    isempty(pts) || push!(out, (pts, false))
    out
end

function _rect_points(p::RectPrim)
    x, y, w, h = p.x, p.y, p.w, p.h
    r = clamp(p.radius, 0, min(w, h) / 2)
    r == 0 && return Point[(x, y), (x+w, y), (x+w, y+h), (x, y+h)]
    pts = Point[]
    for (cx, cy, first) in ((x+w-r, y+r, -pi/2), (x+w-r, y+h-r, 0.0),
                            (x+r, y+h-r, pi/2), (x+r, y+r, pi))
        for a in range(first, first + pi/2; length = 9)
            push!(pts, (cx + r*cos(a), cy + r*sin(a)))
        end
    end
    pts
end

_circle_points(p::CirclePrim) = Point[(p.x + p.r*cos(2pi*k/64),
                                     p.y + p.r*sin(2pi*k/64)) for k in 0:63]

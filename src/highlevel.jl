raw"""
    state_diagram(source; title="State transition model", subtitle="", width=1200)

Lay out a state model from a small line-oriented language. Declare states with
`state A: Name`, transitions with `A -> B: event | probability`, and a shared
destination with `A, B -> C: event | probability`. Optional `entry:`, `note:`,
and `section NAME [wide]: heading | detail | detail` lines add context.

A label can have a TeX alternative after ` ~ `, for example
`s p_SE ~ $s p_{\mathrm{SE}}$`. SVG, CeTZ, and Makie use the first form;
TikZ uses the TeX form verbatim. Only use trusted TeX input.
"""
function state_diagram(source::AbstractString; title="State transition model",
                       subtitle="", width::Integer=1200)
    states = Pair{String,String}[]
    edges = NamedTuple[]
    sections = NamedTuple[]
    entry = ""
    note = ""
    for (number, raw) in enumerate(split(source, '\n'))
        line = strip(first(split(raw, '#'; limit=2)))
        isempty(line) && continue
        if startswith(line, "state ")
            m = match(r"^state\s+([A-Za-z][A-Za-z0-9_]*):\s*(.+)$", line)
            isnothing(m) && throw(ArgumentError("invalid state on line $number"))
            any(p -> p.first == m[1], states) && throw(ArgumentError("duplicate state $(m[1])"))
            push!(states, m[1] => m[2])
        elseif occursin("->", line)
            m = match(r"^([A-Za-z0-9_, ]+)\s*->\s*([A-Za-z][A-Za-z0-9_]*):\s*(.+)$", line)
            isnothing(m) && throw(ArgumentError("invalid transition on line $number"))
            parts = strip.(split(m[3], '|'))
            length(parts) == 2 || throw(ArgumentError("transition needs event | probability on line $number"))
            for from in strip.(split(m[1], ','))
                push!(edges, (from=from, to=m[2], event=parts[1], probability=parts[2]))
            end
        elseif startswith(line, "entry:")
            entry = strip(line[7:end])
        elseif startswith(line, "note:")
            note = strip(line[6:end])
        elseif startswith(line, "section ")
            m = match(r"^section\s+(.+?)(\s+\[wide\])?:\s*(.+)$", line)
            isnothing(m) && throw(ArgumentError("invalid section on line $number"))
            push!(sections, (title=m[1], wide=!isnothing(m[2]),
                             parts=strip.(split(m[3], '|'))))
        else
            throw(ArgumentError("unknown statement on line $number: $line"))
        end
    end
    isempty(states) && throw(ArgumentError("declare at least one state"))
    ids = Set(first.(states))
    for e in edges
        e.from in ids && e.to in ids || throw(ArgumentError("unknown state in $(e.from) -> $(e.to)"))
    end
    _render_state_model(states, edges, sections, entry, note, String(title),
                        String(subtitle), Int(width))
end

function _label(raw)
    parts = split(raw, " ~ "; limit=2)
    (strip(parts[1]), length(parts) == 2 ? strip(parts[2]) : nothing)
end

function _model_text!(d, x, y, raw; kwargs...)
    plain, latex = _label(raw)
    text!(d, x, y, plain; latex, kwargs...)
end

function _render_state_model(states, edges, sections, entry, note, title, subtitle, width)
    ink, muted, rule = "#172630", "#53636c", "#d5dee1"
    colours = ["#2879a0", "#427e68", "#356caa", "#ad652e", "#705a91"]
    fills = ["#eef7f9", "#f1f7f3", "#edf3fa", "#fbf7f2", "#f4f1f8"]
    # A multiply reached terminal state is drawn after the main chain.
    terminal = [p.first for p in states if !any(e -> e.from == p.first, edges)]
    shared = findfirst(id -> count(e -> e.to == id, edges) > 1 && id in terminal,
                       first.(states))
    sinkid = isnothing(shared) ? nothing : states[shared].first
    main = isnothing(sinkid) ? states : filter(p -> p.first != sinkid, states)
    n = length(main)
    n <= 5 || throw(ArgumentError("at most five main states fit on one row"))
    panelrows = count(s -> s.wide, sections) + cld(count(s -> !s.wide, sections), 2)
    height = 390 + 112 * panelrows + (isempty(sections) ? 0 : 20)
    d = Diagram(width, height; title, description="State transition diagram: " *
        join(["$(e.from) to $(e.to) by $(e.event)" for e in edges], "; "))
    text!(d, 70, 43, uppercase(title); size=28, bold=true, color=ink)
    isempty(subtitle) || text!(d, width-70, 43, subtitle; size=17, color=muted, anchor=:end)
    line!(d, 70, 76, width-70, 76; stroke=rule, width=2)
    if !isempty(entry)
        text!(d, 70, 110, "ENTRY"; size=16, color=colours[1], bold=true)
        _model_text!(d, 157, 110, entry; size=18, color=muted)
    end
    text!(d, 70, 153, "LATENT STATE"; size=16, color=muted, bold=true)
    isempty(note) || _model_text!(d, width-70, 153, note; size=16, color=muted, anchor=:end)
    left, right = 170.0, isnothing(sinkid) ? width-170.0 : width-390.0
    centres = n == 1 ? [(left+right)/2] : collect(range(left, right; length=n))
    positions = Dict{String,Tuple{Float64,Float64}}()
    for (i, p) in enumerate(main)
        x = centres[i]
        positions[p.first] = (x, 236.0)
        state_card!(d, x-100, 180, 200, 112, p.first, p.second;
                    fill=fills[mod1(i, length(fills))], accent=colours[mod1(i, length(colours))])
    end
    if !isnothing(sinkid)
        p = only(filter(p -> p.first == sinkid, states))
        x = width-125.0
        positions[sinkid] = (x, 236.0)
        state_card!(d, x-85, 180, 170, 112, p.first, p.second;
                    fill="#f1f2f1", accent="#656d70")
    end
    normal = filter(e -> e.to != sinkid, edges)
    for e in normal
        x1, y1 = positions[e.from]; x2, y2 = positions[e.to]
        x2 > x1 || throw(ArgumentError("transitions must follow state declaration order"))
        gap1 = x1+100; gap2 = x2-100
        gap2-gap1 > 30 || throw(ArgumentError("too many states for labelled transitions"))
        arrow!(d, gap1+8, y1, gap2-8, y2; color=colours[mod1(findfirst(==(e.from), first.(main)), length(colours))], width=5.2, head=13)
        mid = (gap1+gap2)/2
        _model_text!(d, mid, 205, e.event; size=17, color=ink, bold=true, anchor=:middle)
        _model_text!(d, mid, 269, e.probability; size=17, color=muted, anchor=:middle)
    end
    sinkedges = filter(e -> e.to == sinkid, edges)
    if !isempty(sinkedges)
        xs = sort([positions[e.from][1] for e in sinkedges])
        target = positions[sinkid][1]
        ybus = 347.0
        for x in xs
            line!(d, x, 292, x, ybus; stroke="#ad652e", width=3.8)
            circle!(d, x, ybus, 4.0; fill="#ad652e")
        end
        path!(d, "M$(first(xs)) $ybus H$target V312"; stroke="#ad652e", width=3.8)
        arrow!(d, target, 313, target, 299; color="#ad652e", width=3.8, head=8)
        names = unique(e.event for e in sinkedges)
        probs = unique(e.probability for e in sinkedges)
        summary = if length(names) == 1 && length(probs) == 1
            plain, latex = _label(only(probs))
            prefix = "$(only(names)) from any live state: "
            isnothing(latex) ? prefix * plain : prefix * plain * " ~ " * prefix * latex
        else
            join(["$(e.from): $(e.event) $(first(_label(e.probability)))" for e in sinkedges], "   ")
        end
        _model_text!(d, 300, 379, summary; size=18, color="#ad652e", bold=true)
    end
    x, y = 70.0, 414.0
    for (i, s) in enumerate(sections)
        w = s.wide ? width-140.0 : (width-158.0)/2
        if !s.wide && x+w > width-65
            x, y = 70.0, y+112
        elseif s.wide && x != 70
            x, y = 70.0, y+112
        end
        accent = colours[mod1(i, length(colours))]
        rect!(d, x, y, w, 96; radius=15, fill=fills[mod1(i, length(fills))], stroke=accent, width=1.7)
        text!(d, x+21, y+25, uppercase(s.title); size=17, color=accent, bold=true)
        if length(s.parts) == 1
            _model_text!(d, x+21, y+60, s.parts[1]; size=18, color=ink)
        elseif length(s.parts) == 2
            _model_text!(d, x+21, y+54, s.parts[1]; size=18, color=ink)
            _model_text!(d, x+21, y+78, s.parts[2]; size=16, color=muted)
        elseif length(s.parts) == 3 && s.wide
            _model_text!(d, x+21, y+54, s.parts[1]; size=17, color=ink)
            line!(d, x+w/2, y+45, x+w/2, y+85; stroke=rule, width=2)
            _model_text!(d, x+w/2+20, y+54, s.parts[2]; size=17, color=ink)
            _model_text!(d, x+21, y+79, s.parts[3]; size=15, color=muted)
        else
            throw(ArgumentError("section $(s.title) has too many parts"))
        end
        if s.wide
            x, y = 70.0, y+112
        else
            x += w+18
        end
    end
    d
end

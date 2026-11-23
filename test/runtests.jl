using Test
using StateDiagramsSVG
import CairoMakie

@testset "README example" begin
    source = read(joinpath(@__DIR__, "..", "README.md"), String)
    blocks = [m.captures[1] for m in eachmatch(r"```julia\s*\n(.*?)```"s, source)]
    examples = filter(block -> occursin("d = Diagram", block), blocks)
    @test length(examples) == 1
    mktempdir() do folder
        cd(folder) do
            diagram = Base.include_string(Main, only(examples), "README.md example")
            @test diagram isa Diagram
            @test isfile("workflow.svg")
            @test isfile("workflow.tex")
            @test isfile("workflow.typ")
            @test occursin("<svg", read("workflow.svg", String))
            @test occursin("\\begin{tikzpicture}", read("workflow.tex", String))
            @test occursin("cetz.canvas", read("workflow.typ", String))
        end
    end
end

@testset "Makie extension" begin
    d = Diagram(180, 100)
    rect!(d, 10, 10, 50, 40; radius = 8, fill = "#eef7f9", stroke = "#2879a0")
    arrow!(d, 65, 30, 110, 30)
    text!(d, 120, 30, "end")
    fig, ax = makiefigure(d)
    @test fig isa CairoMakie.Figure
    @test ax isa CairoMakie.Axis
    mktempdir() do folder
        filename = joinpath(folder, "makie.svg")
        CairoMakie.save(filename, fig)
        @test occursin("<svg", read(filename, String))
    end
end

@testset "shared geometry and escaping" begin
    d = Diagram(100, 80; title = "A & B")
    rect!(d, 4, 4, 25, 20; radius = 5, fill = "#abc", stroke = "black")
    circle!(d, 60, 20, 8; fill = "none", stroke = "#123456")
    path!(d, "M 5 60 Q 30 30 55 60 L 75 60 Z";
          fill = "#abcdef", stroke = "#123456")
    text!(d, 10, 35, "A < B & C"; anchor = :end)
    @test occursin("A &amp; B", svg(d))
    @test occursin("A &lt; B &amp; C", svg(d))
    tk = tikz(d)
    cz = cetz(d)
    @test occursin("rounded corners=5.0pt", tk)
    @test occursin("-- cycle", tk)
    @test occursin("radius: 5.0", cz)
    @test occursin("close: true", cz)
    @test_throws ArgumentError tikz(begin
        bad = Diagram(30, 30)
        path!(bad, "M 0 0 A 10 10 0 0 1 20 20")
        bad
    end)
    @test_throws ArgumentError arrow!(d, 0, 0, 1, 1)
end

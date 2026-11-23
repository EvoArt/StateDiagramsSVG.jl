# Keep the displayed SVG synchronized with the runnable README example.
source = read(joinpath(@__DIR__, "..", "README.md"), String)
blocks = [m.captures[1] for m in eachmatch(r"```julia\s*\n(.*?)```"s, source)]
example = only(filter(block -> occursin("d = Diagram", block), blocks))
mktempdir() do folder
    cd(folder) do
        Base.include_string(Main, example, "README.md example")
        destination = joinpath(@__DIR__, "src", "assets", "workflow.svg")
        mkpath(dirname(destination))
        cp("workflow.svg", destination; force = true)
    end
end

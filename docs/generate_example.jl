# Keep the displayed SVG synchronized with the runnable README example.
source = read(joinpath(@__DIR__, "..", "README.md"), String)
blocks = [m.captures[1] for m in eachmatch(r"```julia\s*\n(.*?)```"s, source)]
example = only(filter(block -> occursin("d = state_diagram", block), blocks))
mktempdir() do folder
    cd(folder) do
        Base.include_string(Main, example, "README.md example")
        assets = joinpath(@__DIR__, "src", "assets")
        mkpath(assets)
        for extension in ("svg", "tex", "typ")
            cp("workflow.$extension", joinpath(assets, "workflow.$extension"); force = true)
        end
    end
end

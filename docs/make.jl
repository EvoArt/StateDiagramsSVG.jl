using Documenter, StateDiagramsSVG

include("generate_example.jl")
in_ci = get(ENV, "CI", "false") == "true"

makedocs(
    sitename = "StateDiagramsSVG.jl",
    repo = in_ci ? "https://github.com/EvoArt/StateDiagramsSVG.jl" : "",
    remotes = in_ci ? Dict() : nothing,
    modules = [StateDiagramsSVG],
    format = Documenter.HTML(prettyurls = in_ci,
                             edit_link = "main",
                             repolink = "https://github.com/EvoArt/StateDiagramsSVG.jl"),
    pages = ["Home" => "index.md", "Backends" => "backends.md", "API" => "api.md"],
    checkdocs = :exports,
)

deploydocs(repo = "github.com/EvoArt/StateDiagramsSVG.jl.git", devbranch = "main")

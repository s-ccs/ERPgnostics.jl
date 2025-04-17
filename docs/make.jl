using ERPgnostics
using Documenter
using DocStringExtensions

# preload once

using CairoMakie
const Makie = CairoMakie # - for references
using AlgebraOfGraphics
using Unfold
using DataFrames
using DataFramesMeta
using Literate
using Glob

GENERATED = joinpath(@__DIR__, "src", "generated")
SOURCE = joinpath(@__DIR__, "literate")
for subfolder ∈ ["intro"] #["how_to", "intro", "tutorials", "explanations"]
    local SOURCE_FILES = Glob.glob(subfolder * "/*.jl", SOURCE)
    foreach(fn -> Literate.markdown(fn, GENERATED * "/" * subfolder), SOURCE_FILES)
end

DocMeta.setdocmeta!(ERPgnostics, :DocTestSetup, :(using ERPgnostics); recursive = true)

makedocs(;
    modules = [ERPgnostics],
    authors = "Vladimir Mikheev, Benedikt Ehinger",
    repo = Documenter.Remotes.GitHub("s-ccs", "ERPgnostics.jl"),
    sitename = "ERPgnostics.jl",
    warnonly = :cross_references,
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", "false") == "true",
        canonical = "https://s-css.github.io/ERPgnostics.jl",
        assets = String[],
    ),
    pages = [
        "ERPgnostics highlights" => "index.md",
        "ERP image and patterns" => "patterns.md",
        "Toposeries with patterns" => "generated/intro/toposeries.md",
        "Diagnostics" => "generated/intro/gnostics.md",
        "API / DocStrings" => "api.md",
    ],
)

deploydocs(;
    repo = "github.com/s-ccs/ERPgnostics.jl",
    devbranch = "main",
    versions = "v#.#",
    push_preview = true,
)

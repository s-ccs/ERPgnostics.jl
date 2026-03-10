begin
    import Pkg
    cd(".")
    stub = pwd()
    Pkg.activate(stub)
    using Revise
    Revise.retry()
    include("$(stub)/test/setup.jl")
    using ERPgnostics
    using JuliaFormatter
    ENV["JULIA_DEBUG"] = "ERPgnostics"
    cd("$(stub)/test")
end


Pkg.activate("$(stub)/docs")

begin
    cd("$(stub)/test")
    Pkg.activate("$(stub)/test")
end
cd("$(stub)")

include("/store/users/mikheev/projects/erpgnostics_dev/dev/ERPgnostics/docs/make.jl")

Pkg.activate("/store/users/mikheev/projects/erpgnostics_dev/dev/ERPgnostics")

DocumenterTools.genkeys(user="s-ccs",
       repo="ERPgnostics.jl")


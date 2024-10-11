begin
    using Pkg
    stub = "/store/users/mikheev/projects/erpgnostics_dev/dev/ERPgnostics"
    Pkg.activate(stub)
    using Revise
    Revise.retry()
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


include("/store/users/mikheev/projects/erpgnostics_dev/dev/ERPgnostics/docs/make.jl")

Pkg.activate("/store/users/mikheev/projects/erpgnostics_dev/dev/ERPgnostics")

DocumenterTools.genkeys(user="s-ccs",
       repo="ERPgnostics.jl")


begin
    using Pkg
    stub = pwd()
    Pkg.activate(stub)
    using Revise
    Revise.retry()
    using ERPgnostics
    include("$(stub)/test/setup.jl")
    using JuliaFormatter
    ENV["JULIA_DEBUG"] = "ERPgnostics"
    cd("$(stub)/test")
end


Pkg.activate("$(stub)/docs")
Pkg.activate("$(stub)")
cd("$(stub)/docs/src/generated/intro")

begin
    cd("$(stub)/test")
    Pkg.activate("$(stub)/test")
end
cd("..")
cd("$(stub)/docs")

begin
    test_entries = readdir("$(stub)/test")

    for i in test_entries
        format_file(i)
    end
    src_entries = readdir("$(stub)/src")
    cd("$(stub)/src")
    for i in src_entries
        format_file(i)
    end
    cd("$(stub)/test")
end

include("/store/users/mikheev/projects/erpgnostics_dev/dev/ERPgnostics/docs/make.jl")

Pkg.activate("/store/users/mikheev/projects/erpgnostics_dev/dev/ERPgnostics")

DocumenterTools.genkeys(user="s-ccs",
       repo="ERPgnostics.jl")

#= export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/julia-1.11.1/lib/julia/
/store/users/mikheev/projects/erpgnostics_dev/dev/ERPgnostics
 vglrun julia  =#
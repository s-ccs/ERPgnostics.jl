begin
    using Pkg                  # Load Julia’s package manager
    stub = pwd()                # Store current working directory
    Pkg.activate(stub)          # Activate the environment located at the current directory
    using Revise                # Enable live code reloading during development
    Revise.retry()              # Retry loading packages that previously failed (Revise hook)
    using ERPgnostics           # Load the ERPgnostics package
    include("test/setup.jl")    # Include test setup file (path is relative to the caller)
    using JuliaFormatter        # Load Julia code formatter
    ENV["JULIA_DEBUG"] = "ERPgnostics"  # Enable debug logging for ERPgnostics
    cd("$(stub)/test")          # Change working directory to the test folder
end

# activation of different environments
cd("$(stub)/examples")

Pkg.activate("$(stub)/docs")
Pkg.activate("$(stub)")
cd("$(stub)/docs/src/generated/intro")

# file formatting
begin
    cd("$(stub)/test")
    Pkg.activate("$(stub)/test")
end
cd("..")
cd("$(stub)/docs")
cd("$(stub)")
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
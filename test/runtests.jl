using ERPgnostics
include("setup.jl")

@testset "Interactive topoplots" begin
    include("interactive_topoplots_test.jl")
end

@testset "Interactive heatmap" begin
    include("interactive_heatmap_test.jl")
end

@testset "Simulations" begin
    include("pattern_simulation_test.jl")
end

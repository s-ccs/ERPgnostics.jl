using CairoMakie
using DataFrames
using UnfoldMakie
using JLD2
using ERPgnostics
CairoMakie.activate!()

# Data input
path = dirname(dirname(Base.current_project()))
include(path * "/docs/example_data.jl")

positions_128 = JLD2.load_object(path * "/data/positions_128.jld2")
pattern_detection_values = example_data()

# Example of interactive topoplot series

inter_toposeries(
    filter(x -> x.rows == "A", pattern_detection_values);
    positions = positions_128,
)

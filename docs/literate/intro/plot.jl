using CairoMakie
using DataFrames
using UnfoldMakie

positions_128 = JLD2.load_object("../data/positions_128.jld2")
include("../../../example_data.jl")

# Example of interactive topoplot series

inter_toposeries(
    filter(x -> x.rows == "A", pattern_detection_values);
    positions = positions_128,
)
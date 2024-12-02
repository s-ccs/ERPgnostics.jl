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
pattern_detection_values = example_data();

# Example of interactive topoplot series


desired_conditions = ["duration", "fix_avgpos_x", "fix_avgpos_y", "fix_avgpupilsize"]
inter_toposeries(
    filter(row -> row.condition in desired_conditions, pattern_detection_values);
    positions = positions_128,
)


inter_toposeries(
    pattern_detection_values;
    positions = positions_128,
    toposeries_configs = (; nrows = 4),
    figure_configs = (; size = (1500, 1200)),
)

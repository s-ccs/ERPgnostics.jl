# # Interactive topoplots

# These topoplots series are different: instead fo voltage they represent pattern detection value (here - entropy) for different sorting variables.

# By clicking on the markers you can see the channel name and sorted variabel in title.

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

# Interactive topoplot series with one row

desired_conditions = ["duration", "fix_avgpos_x", "fix_avgpos_y", "fix_avgpupilsize"]
inter_toposeries(
    filter(row -> row.condition in desired_conditions, pattern_detection_values);
    positions = positions_128,
)

# Interactive topoplot series with multiple rows
inter_toposeries(
    pattern_detection_values;
    positions = positions_128,
    toposeries_configs = (; nrows = 4),
    figure_configs = (; size = (1500, 1200)),
)

using CairoMakie
using DataFrames
using UnfoldMakie
using JLD2, CSV
using ERPgnostics

CairoMakie.activate!()

# Data input
path = dirname(dirname(Base.current_project()))
evts = DataFrame(CSV.File(path * "/data/events.csv"))
positions_128 = JLD2.load_object(path * "/data/positions_128.jld2")
erps_fix_32 = JLD2.load_object(path * "/data/erps_fix_32.jld2")
pattern_detection_values_32 = ERPgnostics.examples_data("pattern_detection_values_32");
desired_conditions = ["duration", "fix_avgpos_x", "fix_avgpos_y", "fix_avgpupilsize"]

# ERPgnostics in action
# *Static version*

inter_toposeries_image(
    filter(row -> row.condition in desired_conditions, pattern_detection_values_32),
    evts,
    erps_fix_32,
    1:151;
    positions = positions_128[1:32],
    figure_configs = (; size = (1500, 700)),
)

# *Interactive version*

# ![](ERRgnostics_inaction.gif)
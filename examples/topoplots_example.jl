Makie.inline!(false)
using HDF5
using DataFrames
using CSV, JLD2
using GLMakie
GLMakie.activate!()
# data
function drop_all_nan_columns(df::DataFrame)
    non_all_nan_cols = names(df)[.!all.(col -> all(x -> x isa Number && isnan(x), col), eachcol(df))]
    return df[:, non_all_nan_cols]
end
begin
    fid = h5open("../data/data_fixations.hdf5", "r")
    erps_fix = read(fid["data"]["data_fixations.hdf5"])
    close(fid)

    evts_raw = DataFrame(CSV.File("../data/events.csv"))
    evts_d = CSV.read("../data/evts_d.csv", DataFrame)
    evts_mf = CSV.read("../data/evts_mf.csv", DataFrame)
    positions_128 = JLD2.load_object("../data/positions_128.jld2")
    timing = -0.5:0.001953125:1.0

    
    evts = drop_all_nan_columns(evts_raw)
end

begin
    evts_d.channel = 1:nrow(evts_d)
    pattern_detection_values = stack(evts_d[1:32, :])
    rename!(pattern_detection_values, :variable => :condition, :value => :estimate)

    valid_conditions = names(evts)
    filtered_values = filter(row -> row.condition in valid_conditions, pattern_detection_values)
end

inter_toposeries_image(
    filtered_values,
    evts,
    erps_fix[1:32, :, :],
    1:769;
    positions = positions_128[1:32],
    toposeries_configs = (; nrows = 3),
    erpimage_configs = (; meanplot_axis = (; xlabel = "Time [s]")),
    figure_configs = (; size = (1500, 700)),
)

###################################
inter_toposeries_image(filter(x -> x.condition == "fix_samebox", pattern_detection_values), evts, erps_fix, timing)
erps_fix[1:32, :, :]

# make that workable
begin
    data_all, evts_sim = simulate_6patterns()
    timing = -0.5:0.001953125:1.0
end

inter_toposeries_image(pattern_detection_values, evts_sim, data_all, timing; positions_128 = positions_128)

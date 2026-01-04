includet("setup.jl")

Makie.inline!(false)

cd("..")
#stub = pwd()   
#cd("$(stub)/examples")
# data
begin
    fid = h5open("data/data_fixations.hdf5", "r")
    erps_fix = read(fid["data"]["data_fixations.hdf5"])
    close(fid)

    evts = DataFrame(CSV.File("data/events.csv"))
    evts_d = CSV.read("data/evts_d.csv", DataFrame)
    evts_mf = CSV.read("data/evts_mf.csv", DataFrame)
    positions_128 = JLD2.load_object("data/positions_128.jld2")
    timing = -0.5:0.001953125:1.0
    pattern_detection_values = example_data("pattern_detection_values"; mode = 2);
end

inter_toposeries(pattern_detection_values; positions = positions_128, toposeries_configs = (; nrows = 4))
inter_toposeries_image(pattern_detection_values, evts, erps_fix, timing; positions = positions_128, toposeries_configs = (; nrows = 4))


# make that workable
begin
    data_all, evts_sim = simulate_6patterns()
    timing = -0.5:0.001953125:1.0
end

inter_toposeries_image(pattern_detection_values, evts_sim, data_all, timing; positions_128 = positions_128)

includet("setup.jl")
includet("../src/topoplots.jl")

Makie.inline!(false)

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
end

begin
    pattern_detection_values = stack(evts_d)
    pattern_detection_values.timing = 1:nrow(pattern_detection_values)
    pattern_detection_values.label = 1:nrow(pattern_detection_values)
    rename!(pattern_detection_values, :variable => :condition, :value => :estimate)
    pattern_detection_values.rows = vcat(
        repeat(["A"], size(pattern_detection_values, 1) ÷ 4),
        repeat(["B"], size(pattern_detection_values, 1) ÷ 4),
        repeat(["C"], size(pattern_detection_values, 1) ÷ 4),
        repeat(["D"], size(pattern_detection_values, 1) ÷ 4),
    )
end

inter_toposeries(filter(x -> x.rows == "A", pattern_detection_values))
inter_toposeries(filter(x -> x.rows == "B", pattern_detection_values))
inter_toposeries(filter(x -> x.rows == "C", pattern_detection_values))
inter_toposeries(filter(x -> x.rows == "D", pattern_detection_values))

inter_toposeries_image(pattern_detection_values1, evts, erps)

inter_toposeries_image(filter(x -> x.rows == "A", pattern_detection_values), evts, erps_fix, timing)
inter_toposeries_image(filter(x -> x.rows == "B", pattern_detection_values), evts, erps_fix, timing) #fails
inter_toposeries_image(filter(x -> x.rows == "C", pattern_detection_values), evts, erps_fix, timing)
inter_toposeries_image(filter(x -> x.rows == "D", pattern_detection_values), evts, erps_fix, timing)

inter_toposeries_image(filter(x -> x.condition == "fix_samebox", pattern_detection_values), evts, erps_fix, timing)


# make that workable
begin
    data_all, evts_sim = simulate_6patterns()
    timing = -0.5:0.001953125:1.0
end

inter_toposeries_image(pattern_detection_values, evts_sim, data_all, timing; positions_128 = positions_128)


# debugging zone

begin
    pattern_detection_values2 = stack(evts_mf)
    pattern_detection_values2.timing = 1:nrow(pattern_detection_values)
    pattern_detection_values2.label = 1:nrow(pattern_detection_values)
    rename!(pattern_detection_values2, :variable => :condition, :value => :estimate)
    pattern_detection_values2.rows = vcat(
        repeat(["A"], size(pattern_detection_values2, 1) ÷ 4),
        repeat(["B"], size(pattern_detection_values2, 1) ÷ 4),
        repeat(["C"], size(pattern_detection_values2, 1) ÷ 4),
        repeat(["D"], size(pattern_detection_values2, 1) ÷ 4),
    )
end

inter_toposeries_image(filter(x -> x.rows == "A", pattern_detection_values2), evts, erps_fix, timing)

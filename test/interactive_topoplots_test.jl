evts = DataFrame(CSV.File("data/events.csv")) # this should be put into some data giving function
evts_d = CSV.read("data/evts_d.csv", DataFrame)
#evts_mf = CSV.read("../data/evts_mf.csv", DataFrame)
positions_128 = JLD2.load_object("data/positions_128.jld2")
timing = -0.5:0.001953125:1.0

# this should be simulated
#= begin
    fid = h5open("../data/data_fixations.hdf5", "r")
    erps_fix = read(fid["data"]["data_fixations.hdf5"])
    close(fid)
end =#

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


@testset "inter_toposeries" begin
    inter_toposeries(
        filter(x -> x.rows == "A", pattern_detection_values);
        positions = positions_128,
    )
end

#= @testset "inter_toposeries" begin
    inter_toposeries_image(
        filter(x -> x.rows == "A", pattern_detection_values),
        evts,
        erps_fix,
        timing;
        positions = positions_128,
    )
end
 =#
#evts = DataFrame(CSV.File("../data/events.csv")) # this should be put into some data giving function
#evts_d = CSV.read("../data/evts_d.csv", DataFrame)

positions_128 = JLD2.load_object("../data/positions_128.jld2")
timing = -0.5:0.001953125:1.0
pattern_detection_values = example_data("pattern_detection_values"; mode = 2);

@testset "inter_toposeries" begin
    desired_conditions = ["duration", "fix_avgpos_x", "fix_avgpos_y", "fix_avgpupilsize"]
    inter_toposeries(
        filter(row -> row.condition in desired_conditions, pattern_detection_values);
        positions = positions_128,
    )
end

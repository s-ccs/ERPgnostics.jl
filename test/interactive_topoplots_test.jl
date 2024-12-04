positions_128 = JLD2.load_object("../data/positions_128.jld2")
erps_fix_32 = JLD2.load_object("../data/erps_fix_32.jld2")
timing = -0.5:0.001953125:1.0
pattern_detection_values = example_data("pattern_detection_values"; mode = 2);
pattern_detection_values_32 = example_data("pattern_detection_values_32"; mode = 2);
desired_conditions = ["duration", "fix_avgpos_x", "fix_avgpos_y", "fix_avgpupilsize"]

@testset "inter_toposeries" begin
    inter_toposeries(
        filter(row -> row.condition in desired_conditions, pattern_detection_values);
        positions = positions_128,
    )
end

@testset "inter_toposeries" begin
    inter_toposeries_image(
        filter(row -> row.condition in desired_conditions, pattern_detection_values),
        evts,
        erps_fix,
        timing;
        positions = positions_128,
    )
end

@testset "inter_toposeries" begin
    inter_toposeries_image(
        filter(row -> row.condition in desired_conditions, pattern_detection_values_32),
        evts,
        erps_fix_32,
        1:151;
        positions = positions_128[1:32],
        figure_configs = (; size = (1500, 700)),
    )
end

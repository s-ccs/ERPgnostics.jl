evts = DataFrame(CSV.File("../data/events.csv"))
positions_128 = JLD2.load_object("../data/positions_128.jld2")
erps_fix_32 = JLD2.load_object("../data/erps_fix_32.jld2")
timing = -0.5:0.001953125:1.0
pattern_detection_values = example_data("pattern_detection_values"; mode = 2);
pattern_detection_values_32 = example_data("pattern_detection_values_32"; mode = 2);
desired_conditions = ["duration", "fix_avgpos_x", "fix_avgpos_y", "fix_avgpupilsize"]
filtered_data = filter(row -> row.condition in desired_conditions, pattern_detection_values)
filtered_data_32 = filter(row -> row.condition in desired_conditions, pattern_detection_values_32)

#WGLMakie.activate!() 

@testset "simple plot_topoplotseries" begin   
    plot_topoplotseries(
        filtered_data;
        nrows = 2,
        positions = positions_128,
        mapping = (; col = :condition),
    )
end

@testset "inter_toposeries_image" begin
    inter_toposeries_image(
        filtered_data_32,
        evts,
        erps_fix_32,
        1:151;
        positions = positions_128[1:32],
        figure_configs = (; size = (1500, 700)),
    )
end

@testset "inter_toposeries_image: toposeries_config" begin
    inter_toposeries_image(
        filtered_data_32,
        evts,
        erps_fix_32,
        1:151;
        positions = positions_128[1:32],
        figure_configs = (; size = (1500, 700)),
        toposeries_configs = (; colorbar = (; label = "test")),
    )
end

#= WGLMakie.activate!()
f = Figure()
interact_me = f[1, 1] = Makie.Axis(f)
h = lines!(interact_me, [1, 2, 3])
hs = scatter!(interact_me, [1, 2, 3], markersize = 20, strokewidth = 5, 
strokecolor = RGB.(colorant"red", colorant"green", colorant"blue"))  =#

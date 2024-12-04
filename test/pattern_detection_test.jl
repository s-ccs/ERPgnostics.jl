evts = DataFrame(CSV.File("../data/events.csv"))
sort_value = evts.duration
sort_values = evts[:, [:duration, :onset]]
single_channel = JLD2.load_object("../data/channel_123.jld2")
two_channels = JLD2.load_object("../data/channels_1_123.jld2")

@testset "pattern detection: plot mode" begin
    pattern_detector(single_channel[:, sortperm(sort_value)], slow_filter, Images.entropy)
end

@testset "pattern detection: numerical mode" begin
    pattern_detector(
        single_channel[:, sortperm(sort_value)],
        slow_filter,
        Images.entropy;
        mode = "num",
    )
end

@testset "complex pattern detection: slow filter" begin
    complex_pattern_detector(two_channels, sort_values, slow_filter, Images.entropy)
end

@testset "complex pattern detection: mean filter" begin
    complex_pattern_detector(two_channels, sort_values, mean_filter, Images.entropy)
end


@testset "complex pattern detection: permuted_means mode" begin
    complex_pattern_detector(
        two_channels,
        sort_values,
        slow_filter,
        Images.entropy;
        mode = "permuted_means",
    )
end

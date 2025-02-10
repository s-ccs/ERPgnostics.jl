begin
    events = DataFrame(CSV.File("../data/events.csv"))
    pattern_detection_values = CSV.read("../data/evts_d.csv", DataFrame)
end

@testset "interactive heatmap" begin
    inter_heatmap(pattern_detection_values)
end


#= fid = h5open("data/data_fixations.hdf5", "r")
erps_fix = read(fid["data"]["data_fixations.hdf5"])
close(fid)

@testset "interactive heatmap image" begin
    inter_heatmap_image(pattern_detection_values, events, erps_fix)
end
=#

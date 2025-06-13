
using Statistics, FFTW
using GLMakie
using UnfoldMakie, HDF5, JLD2, CSV, DataFrames
GLMakie.activate!() 

fid = h5open("../data/data_fixations.hdf5", "r")
erps_fix = read(fid["data"]["data_fixations.hdf5"])
close(fid)
erps_reordered = permutedims(erps_fix, (2, 3, 1))

positions_128 = JLD2.load_object("../data/positions_128.jld2")
evts = DataFrame(CSV.File("../data/events.csv"))


function spectral_std(data)
    return round(StatsBase.std(abs.(fft(data))[:]); sigdigits = 6)
end



detector_spectral_std = complex_pattern_detector(erps_reordered, evts, slow_filter, spectral_std)
detector_spectral_std.channel = 1:nrow(detector_spectral_std)
pattern_detection_values = stack(detector_spectral_std)
rename!(pattern_detection_values, :variable => :condition, :value => :estimate)
#JLD2.save_object("../data/pattern_detection_values_fft_std.jld2", pattern_detection_values)

pattern_detection_values = JLD2.load_object("../data/pattern_detection_values_fft_std.jld2")
desired_conditions = ["duration", "fix_avgpos_x", "fix_avgpos_y", "fix_avgpupilsize"]
filtered_data = filter(row -> row.condition in desired_conditions, pattern_detection_values)
inter_toposeries_image(
    filtered_data,
    evts,
    erps_fix,
    1:769;
    positions = positions_128,
    toposeries_configs = (; colorbar = (; label = "Standard deviation of Spectral Amplitude")),
    figure_configs = (; size = (1500, 700)),
    erpimage_configs = (; erpblur = 1)
)



for name in names(evts)
    println(name)
end
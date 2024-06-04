# FOR MULTITHREADING: 
# run: >julia -t [n_threads]
# instead of [n_threads] write a desired number of threads (<= amount of CPU cores)

include("setup.jl")
include("pattern_detection.jl")

# DATA
#events data
evts = DataFrame(CSV.File("data/events.csv"))

# data for single channel
fid = h5open("./data/single.hdf5", "r")
dat = read(fid["data"]["single.hdf5"])
close(fid)

begin # to visualise a single channel data
    # create figure
    f = Figure()
    plot_erpimage!(
        f[1, 1],
        dat;  # only rows of dat where evts.column is not NaN
        sortvalues = evts.sac_amplitude,
        axis = (; title = "One-sided fan; sorted by duration"),
    )
    f
end

# Data for multiple channels
# 128 channels x 769 time x 7522 events 

fid = h5open("data/mult.hdf5", "r")
dat2 = read(fid["data"]["mult.hdf5"])
close(fid)

# Data for multiple channels (only fixations)
# 128 channels x 769 time x 2508 events 

fid = h5open("data/data_fixations.hdf5", "r")
dat_fix = read(fid["data"]["data_fixations.hdf5"])
close(fid)


# PATTERN DECTECTION 1
# for single channel data
@time begin
    out1 = single_chan_pattern_detector(dat, Images.entropy, evts)
end

sort(out1, "Mean row range")
CSV.write("data/output1.csv", sort(out1, "Mean row range"))
out1 = CSV.read("data/output1.csv", DataFrame)
display(out1)

# PATTERN DECTECTION 2
@time begin
    out2 = mult_chan_pattern_detector_value(dat2, Images.entropy, evts) #5392 seconds = 89 minutes
end

CSV.write("data/output2.csv", out2)


begin
    f = Figure()
    ax = CairoMakie.Axis(f[1, 1], xlabel = "Channels", ylabel = "Sorting event variables")
    hm = heatmap!(ax, Matrix(out2))
    Colorbar(f[1, 2], hm, label = "entropy")
    f
    #save("assets/heatmap.png", f)
end

# PATTERN DECTECTION 3
evts_init = CSV.read("data/events_init.csv", DataFrame)
@time begin
    ix = evts_init.type .== "fixation"
    evts_d = mult_chan_pattern_detector_probability(dat2[:, :, ix], Images.entropy, evts) 
end

# PATTERN DETECTION 4 (FOR FIXATIONS ONLY)
# 10 cores: 50 s
@time begin
    evts_d = mult_chan_pattern_detector_probability(dat_fix, Images.entropy, evts) 
end

begin
    f = Figure()
    ax = CairoMakie.Axis(f[1, 1], xlabel = "Channels", ylabel = "Sorting event variables")
    hm = heatmap!(ax, Matrix(evts_d))
    Colorbar(f[1, 2], hm, labelrotation = -π / 2, label = "Probability of entropy different from entropy with no pattern")
    f
    save("assets/heatmap.png", f)
end
f

CSV.write("data/evts_d.csv", evts_d)


# formatting
using JuliaFormatter
format_file("pluto/patters_in_one_data.jl")
format_file("pluto/patterns_separated.jl")
format_file("pluto/validation_data.jl")
format_file("pluto/pattern_detection.jl")
format_file("src/get_data.jl")
format_file("src/interactive.jl")
format_file("src/pattern_detection.jl")
format_file("src/topoplots.jl")
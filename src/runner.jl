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
    # find indices where events.column is not NaN
    indices_notnan = findall(<(1), isnan.(evts.sac_amplitude))
    # create figure
    f = Figure()
    plot_erpimage!(
        f[1, 1],
        dat[:, indices_notnan];  # only rows of dat where evts.column is not NaN
        sortvalues = evts[indices_notnan, :].sac_amplitude,
        axis = (; title = "One-sided fan; sorted by duration"),
    )
    f
end

# Data for multiple channels
# 128 channels x 769 time x 7522 events 

fid = h5open("data/mult.hdf5", "r")
dat2 = read(fid["data"]["mult.hdf5"])
close(fid)


# PATTERN DECTECTION 1
# for single channel data
@time begin
    out1 = single_chan_pattern_detector(dat, Images.entropy)
end

sort(out1, "Mean row range")
CSV.write("data/output1.csv", sort(out1, "Mean row range"))
out1 = CSV.read("data/output1.csv", DataFrame)
display(out1)

# PATTERN DECTECTION 2
@time begin
    out2 = mult_chan_pattern_detector_value(dat2, Images.entropy) #5392 seconds = 89 minutes
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
@time begin
    out3 = mult_chan_pattern_detector_probability(dat2, Images.entropy) 
end

begin
    f = Figure()
    ax = CairoMakie.Axis(f[1, 1], xlabel = "Channels", ylabel = "Sorting event variables")
    hm = heatmap!(ax, Matrix(out3))
    Colorbar(f[1, 2], hm, labelrotation = -π / 2, label = "Probability of entropy different from entropy with no pattern")
    f
    save("assets/heatmap.png", f)
end
f

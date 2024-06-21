includet("../src/setup.jl")
includet("../src/pattern_detection.jl")
includet("../src/mean_filter.jl")

# DATA
#events data

begin
    # data for single channel
    fid = h5open("./data/single.hdf5", "r")
    erps_single = read(fid["data"]["single.hdf5"])
    close(fid)
    
    # Data for multiple channels
    # 128 channels x 769 time x 7522 events 
    fid = h5open("data/mult.hdf5", "r")
    erps_mult = read(fid["data"]["mult.hdf5"])
    close(fid)

    fid = h5open("data/data_fixations.hdf5", "r")
    erps_fix = read(fid["data"]["data_fixations.hdf5"])
    close(fid)

    evts = DataFrame(CSV.File("data/events.csv"))
    evts_d = CSV.read("data/evts_d.csv", DataFrame)
    positions_128 = JLD2.load_object("data/positions_128.jld2")
end

# PATTERN DECTECTION 1
# for single channel data
@time begin
    out1 = single_chan_pattern_detector(erps_single, Images.entropy, evts)
end

sort(out1, "Mean row range")
CSV.write("data/output1.csv", sort(out1, "Mean row range"))
out1 = CSV.read("data/output1.csv", DataFrame)
display(out1)

# PATTERN DECTECTION 2
# for multiple channel data
@time begin
    out2 = mult_chan_pattern_detector_value(erps_mult, Images.entropy, evts) #5392 seconds = 89 minutes
end

CSV.write("data/output2.csv", out2)


begin
    f = Figure()
    ax = CairoMakie.Axis(f[1, 1], xlabel="Channels", ylabel="Sorting event variables")
    hm = heatmap!(ax, Matrix(out2))
    Colorbar(f[1, 2], hm, label="entropy")
    f
    #save("assets/heatmap.png", f)
end

# PATTERN DECTECTION 3
@time begin
    evts_d = mult_chan_pattern_detector_probability(erps_fix, Images.entropy, evts) #249 sec, with threads - 30 sec
end

begin
    f = Figure()
    ax = CairoMakie.Axis(f[1, 1], xlabel="Channels", ylabel="Sorting event variables")
    hm = heatmap!(ax, Matrix(evts_d))
    Colorbar(
        f[1, 2],
        hm,
        labelrotation=-π / 2,
        label="Probability of entropy different from entropy with no pattern",
    )
    f
    save("assets/heatmap.png", f)
end
f

# PATTERN DECTECTION 4
@time begin
    evts_d = mult_chan_test(erps_fix, Images.entropy)
end

@time begin
    evts_d = mult_chan_test(dat_f, entropy_robust)
end

#entropy_rownormalized = (x)->Images.entropy(x.-mean(x,dims=2))

# PATTERN DECTECTION 5
evts_mf = mult_chan_pattern_detector_probability_meanfilter(erps_fix, Images.entropy, evts)

evts_mf = mult_chan_pattern_detector_probability_meanfilter(erps_fix, entropy_robust, evts, n_permutations=100)

inlude("setup.jl")

begin
    using PyMNE
    subject = 8
    dir_path = "/store/data/WLFO/derivatives/preproc_agert"
    file_stub = dir_path * "/sub-{1:02d}/eeg/sub-{1:02d}_task-WLFO_{2:s}"
    @info format(file_stub, subject, "eeg.set")
    raw = PyMNE.io.read_raw_eeglab(format(file_stub, subject, "eeg.set"))
    data = raw.get_data(units = "uV")
    events = CSV.read(format(file_stub, subject, "events.tsv"), DataFrame)
    srate = pyconvert(Float64, raw.info["sfreq"])
end

using JLD2
positions_128 = to_positions(raw)
JLD2.save_object("data/positions_128.jld2", positions_128)

begin
    events.latency .= events.onset .* srate
    data_epoch_raw, times = Unfold.epoch(pyconvert(Array, data), events, (-0.5, 1), srate)
    events_epoch, data_epoch0 = Unfold.dropMissingEpochs(events, data_epoch_raw)
    #data_epoch = data_epoch0 .- mean(data_epoch0, dims=2) #normalisation
end
typeof(data_epoch0[32, :, :])


size(data_epoch0)

h5open("data/single.hdf5", "w") do file
    write(file, "data/single.hdf5", data_epoch0[32, :, :])  # alternatively, say "@write file A"
    close(file)
end

h5open("data/mult.hdf5", "w") do file
    write(file, "data/mult.hdf5", data_epoch0)  # alternatively, say "@write file A"
    close(file)
end

CSV.write("data/events.csv", events_epoch)

begin
	using Pkg
	Pkg.activate("/home/mikheev/Desktop/ERPgnostics")
	Pkg.status()
end

begin 
	using PyMNE
	using UnfoldMakie
	using Unfold
	using CSV, DataFrames
	using Random, Format
	using CairoMakie
	using Statistics, StatsBase
	using HDF5, FileIO
end

begin
	subject = 8
	dir_path = "/store/data/WLFO/derivatives/preproc_agert"
	file_stub = dir_path * "/sub-{1:02d}/eeg/sub-{1:02d}_task-WLFO_{2:s}"
	@info format(file_stub, subject, "eeg.set")
	raw = PyMNE.io.read_raw_eeglab(format(file_stub, subject, "eeg.set"))
	data = raw.get_data(units = "uV")
	events = CSV.read(format(file_stub, subject, "events.tsv"), DataFrame)
	srate = pyconvert(Float64, raw.info["sfreq"])
end


begin 
    events.latency .= events.onset .* srate;
    data_epoch_raw, times = Unfold.epoch(pyconvert(Array, data), events, (-0.5,1), srate)
	events_epoch, data_epoch0 = Unfold.dropMissingEpochs(events, data_epoch_raw);
	#data_epoch = data_epoch0 .- mean(data_epoch0, dims=2) #normalisation
end
typeof(data_epoch0[32, :, :])


size(data_epoch0)
save("/home/mikheev/Desktop/ERPgnostics/data/test.h5", data_epoch0)

h5open("data/test.hdf5", "w") do file
    write(file, "data/test.hdf5", data_epoch0[32, :, :])  # alternatively, say "@write file A"
    close(file)
end

CSV.write("data/events.csv", events_epoch)


# formatting
using JuliaFormatter
format_file("src/6patters_in_one_data.jl")
format_file("src/6patters_sep.jl")
format_file("src/validation_data.jl")
format_file("src/ERP_detection.jl")
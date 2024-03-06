### A Pluto.jl notebook ###
# v0.19.37

using Markdown
using InteractiveUtils

# ╔═╡ 2bf57740-d6dd-11ee-0674-6f563d2c2015
begin 
	using PyMNE
	using UnfoldMakie
	using Unfold
	using CSV, DataFrames
	using Random, Format
	using CairoMakie
	using Statistics, StatsBase
end

# ╔═╡ 9d13380a-0a2f-4301-9189-71a98fe6f948
md"""
## Import data
Load the data using PyMNE
!!! important
	Sometimes we have to explicitly convert from Python to Julia using 
	`pyconvert(JuliaType, pythonobject)`
"""

# ╔═╡ f8fef3fc-5dc8-4ee0-9e86-98fc0dd3189f
begin
	subject = 8
	dir_path = "/store/data/WLFO/derivatives/preproc_agert"
	file_stub = dir_path * "/sub-{1:02d}/eeg/sub-{1:02d}_task-WLFO_{2:s}"
	@info format(file_stub, subject, "eeg.set")
	raw = PyMNE.io.read_raw_eeglab(format(file_stub, subject, "eeg.set"))
	data = raw.get_data(units = "uV")
	data = data.- mean(data, dims=2)
	events = CSV.read(format(file_stub, subject, "events.tsv"), DataFrame)
end

# ╔═╡ 356c966c-cac7-46a1-ada8-e048fdc2a66d
srate = pyconvert(Float64,raw.info["sfreq"])

# ╔═╡ 60de2b9e-e6b0-4e18-be9c-287dc691de2c
md"""
Add a latency column
"""

# ╔═╡ 9a7680f0-f874-4454-8877-8282e8facaa2
events.latency .= events.onset .* srate;

# ╔═╡ 255e4edc-a8aa-42af-986e-b06bc5516d44
md"""
Next, we slice the data according to all the events we have in the dataset (a lot!).
Interesting events are probably fixations, but more on that later.
"""

# ╔═╡ b49bf880-1ccc-40af-bf34-4317d40c789e
data_epoch_raw,times = Unfold.epoch(pyconvert(Array,data),events,(-0.5,1),srate)

# ╔═╡ 296cd8c4-3e6a-4044-ab3e-25ca62b612b2
md"""
If an event is at the boundary of our continuous data set, we may not have data that spans the range (-0.5,1). Such cells will be filled with missings. We do not want to deal with missings right now because they are not supported in UnfoldMakie (but they should be!). We will remove them for now. 
"""

# ╔═╡ 1e24eeca-70bb-4787-8b32-471581e6590d
events_epoch, data_epoch= Unfold.dropMissingEpochs(events,data_epoch_raw);

# ╔═╡ a51fac94-ea01-4763-8c23-29d00d14eda3
md"""
## First ERPimage
"""

# ╔═╡ 0f5d9c38-dd47-4f72-950e-10e5133f375c
plot_erpimage(data_epoch[32, :, :]) 

# ╔═╡ f29be6b3-e5ce-4f60-adb7-313b6c44eb7d
let
	ixlist = rand(1:size(data_epoch, 1), 9)
	f = Figure(resolution = (1200, 1400))
	ix = 0
	for i = 1:3
		for j = 1:3
			ix = ix+1
			plot_erpimage!(f[i, j], data_epoch[ixlist[ix], :, :], axis = (; title = "Epoch $(ix)"))
		end
	end
	f
end

# ╔═╡ 6b352dd5-6006-4b17-8503-8c3cb20b424f
let
	ixlist = rand(1:size(data_epoch, 1), 9)
	f = Figure(resolution = (1200, 1400))
	ix = 0
	for i = 1:3
		for j = 1:3
			ix = ix+1
			plot_erpimage!(f[i, j], data_epoch[ixlist[ix], :, :], 
				axis = (; title = "Epoch $(ix)"), sortvalues = events_epoch.duration)
		end
	end
	f
end

# ╔═╡ Cell order:
# ╠═2bf57740-d6dd-11ee-0674-6f563d2c2015
# ╟─9d13380a-0a2f-4301-9189-71a98fe6f948
# ╠═f8fef3fc-5dc8-4ee0-9e86-98fc0dd3189f
# ╠═356c966c-cac7-46a1-ada8-e048fdc2a66d
# ╟─60de2b9e-e6b0-4e18-be9c-287dc691de2c
# ╠═9a7680f0-f874-4454-8877-8282e8facaa2
# ╟─255e4edc-a8aa-42af-986e-b06bc5516d44
# ╠═b49bf880-1ccc-40af-bf34-4317d40c789e
# ╟─296cd8c4-3e6a-4044-ab3e-25ca62b612b2
# ╠═1e24eeca-70bb-4787-8b32-471581e6590d
# ╟─a51fac94-ea01-4763-8c23-29d00d14eda3
# ╠═0f5d9c38-dd47-4f72-950e-10e5133f375c
# ╠═f29be6b3-e5ce-4f60-adb7-313b6c44eb7d
# ╠═6b352dd5-6006-4b17-8503-8c3cb20b424f

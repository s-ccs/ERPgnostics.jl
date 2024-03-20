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
	using Printf
end
function filt(img)
    filtered_data = UnfoldMakie.imfilter(img, UnfoldMakie.Kernel.gaussian((1, max(30, 0))))
end

function range_mean(dat_filt)
	a = extrema(dat_filt, dims = 2)
	b = last.(a) .- first.(a)
	return mean(b)
end

# single channel
fid = h5open("data/single.hdf5", "r") 
dat = read(fid["data"]["single.hdf5"])
close(fid)

evts = DataFrame(CSV.File("data/events.csv"))

function sorter(dat)
	e = zeros(0)
	for n in names(evts)
		dat_sorted = filt((dat[:, sortperm(evts[!, n])]))
		e = append!(e, round.(range_mean(dat_sorted), digits = 2))
	end
	return DataFrame("Sorting values" => names(evts), "Mean row range" => e)
end


out = sorter(dat)
sort(out, "Mean row range")
CSV.write("data/output.csv", sort(out, "Mean row range"))
display(out)

# multiple channels

fid = h5open("data/mult.hdf5", "r") 
dat2 = read(fid["data"]["mult.hdf5"])
close(fid)

function mult_sorter(dat)
	row = Dict()
	for n in names(evts)
		col = zeros(0)
		for i in 1:size(dat)[1]
			dat_sorted = filt(dat[i, :, sortperm(evts[!, n])])
			col = append!(col, round.(range_mean(dat_sorted), digits = 2))
		end
		println(n)
		println(col)
		row[n] = get(row, n, col) 
	end
	return DataFrame(row)
end
out2 = mult_sorter(dat2)

CSV.write("data/output2.csv", out2)

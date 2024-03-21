inlude("setup.jl")

function filt(img)
    filtered_data = UnfoldMakie.imfilter(img, UnfoldMakie.Kernel.gaussian((1, max(30, 0))))
end

function range_mean(dat_filt)
	a = extrema(dat_filt, dims = 2)
	b = last.(a) .- first.(a)
	return mean(b)
end

# data for single channel
fid = h5open("data/single.hdf5", "r") 
dat = read(fid["data"]["single.hdf5"])
close(fid)

evts = DataFrame(CSV.File("data/events.csv"))

Images.entropy(dat)

function sorter(dat, f)
	e = zeros(0)
	for n in names(evts)
		dat_sorted = filt((dat[:, sortperm(evts[!, n])]))
		e = append!(e, round.(fun(dat_sorted), digits = 2))
	end
	return DataFrame("Sorting values" => names(evts), "Mean row range" => e)
end

sorter(dat, Images.entropy)
sorter(dat, range_mean)


@time begin
	out = sorter(dat, Images.entropy)
end


sort(out, "Mean row range")
CSV.write("data/output.csv", sort(out, "Mean row range"))
display(out)

begin
	f = Figure()
	plot_erpimage!(
			f[1, 1],
			dat;
			sortvalues = evts.duration,
			axis = (; title = "One-sided fan; sorted by duration"),
		)
	f
end
# data for multiple channels

fid = h5open("data/mult.hdf5", "r") 
dat2 = read(fid["data"]["mult.hdf5"])
close(fid)

function mult_sorter(dat, f)
	row = Dict()
	for n in names(evts)
		col = zeros(0)
		for i in 1:size(dat)[1]
			dat_sorted = filt(dat[i, :, sortperm(evts[!, n])])
			col = append!(col, round.(f(dat_sorted), digits = 2))
		end
		println(n)
		println(col)
		row[n] = get(row, n, col) 
	end
	return DataFrame(row)
end

@time begin
	out2 = mult_sorter(dat2, Images.entropy) #5392 seconds
end


CSV.write("data/output2.csv", out2)

heatmap(Matrix(out2))

plot_topoplotseries()
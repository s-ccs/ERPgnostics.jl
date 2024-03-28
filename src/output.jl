include("setup.jl")

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
# Data for multiple channels

fid = h5open("data/mult.hdf5", "r") 
dat2 = read(fid["data"]["mult.hdf5"])
close(fid)
# 128 channels x 769 time x 7522 events 

function mult_sorter(dat, f)
	row = Dict()
	for n in names(evts) # iterate over event variables
		col = zeros(0)
		for i in 1:size(dat)[1] # iterate over chanels 
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
	out2 = mult_sorter(dat2, Images.entropy) #5392 seconds = 89 minutes
end


CSV.write("data/output2.csv", out2)
out2 = CSV.read("data/output2.csv", DataFrame)

begin
	f = Figure()
	ax = CairoMakie.Axis(f[1, 1], xlabel = "Channels", ylabel = "Sorting event variables")
	hm = heatmap!(ax, Matrix(out2))
	Colorbar(f[1, 2], hm, label = "entropy")
	f
	#save("assets/heatmap.png", f)
end


# computing entropy's d

function mult_sorter_d(dat, f, trial)
	row = Dict()
	for n in names(evts)
		col = zeros(0)
		for i in 1:size(dat)[1]
			dat_sorted = filt(dat[i, :, sortperm(evts[!, n])]) # sorting (3 sec)
			e_dist = map((x) -> Images.entropy(filt(dat[i, :, shuffle(1:end)])), 1:trial) # (205 sec, 3.5 min) counting permuted entropy 
			#e_dist_50 = e_dist[50]
			d = f(dat_sorted) - mean(e_dist) # counting difference between the mean of permuted entropy distribution and entropy of the sorted dataset
			col = append!(col, round.(d, digits = 2))
		end
		println(n)
		println(col)
		row[n] = get(row, n, col) # add new key in dict
	end
	return DataFrame(row)
end

#= 
@time begin
	map((x) -> Images.entropy(filt(dat2[1, :, shuffle(1:end)])), 1:100)
end =#

@time begin
	out3 = mult_sorter_d(dat2, Images.entropy, 10)
end










# topoplots


plot_topoplotseries(out2, Δbin; positions = rand(Point2f, 128))
plot_topoplotseries(Matrix(out2))

data, positions = TopoPlots.example_data()
data[:, :, 1]

df = UnfoldMakie.eeg_matrix_to_dataframe(data[:, :, 1], string.(1:64))
df

select!(out2, Not(:row_num))
out.label = 1:nrow(out)

tmp = stack(out, 1:21)
tmp.time = 1:nrow(tmp)
rename!(tmp, :variable => :condition, :value => :estimate)

Δbin = 140
tmp2 = filter(x -> x.condition == "type" || x.condition == "duration", tmp) 

plot_topoplotseries(tmp2, Δbin; positions = rand(Point2f, 128), 
combinefun = x->x, mapping = (; :col=> :condition))



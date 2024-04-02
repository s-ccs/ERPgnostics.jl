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
fid = h5open("./data/single.hdf5", "r")
dat = read(fid["data"]["single.hdf5"])
close(fid)

evts = DataFrame(CSV.File("data/events.csv"))

function sorter(dat, func)
    e = zeros(0)
    for n in names(evts)
        dat_sorted = filt((dat[:, sortperm(evts[!, n])]))
        e = append!(e, round.(func(dat_sorted), digits = 2))
    end
    return DataFrame("Sorting values" => names(evts), "Mean row range" => e)
end


@time begin
    out = sorter(dat, Images.entropy)
end


sort(out, "Mean row range")
CSV.write("data/output.csv", sort(out, "Mean row range"))
display(out)

begin
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

fid = h5open("data/mult.hdf5", "r")
dat2 = read(fid["data"]["mult.hdf5"])
close(fid)

# 128 channels x 769 time x 7522 events 

function mult_sorter(dat, f)
    row = Dict()
    for n in names(evts) # iterate over event variables
        col = zeros(0)
        for i = 1:size(dat)[1] # iterate over chanels 
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

#---
using ImageFiltering
using ComputationalResources
function my_filter!(dat_filtered, dat, kernel)
    r = Images.ImageFiltering.ComputationalResources.CPU1(Images.ImageFiltering.FIR())
    #r = CPU1(FIR())

    #imfilter!(dat_filtered,dat,  kernel,Inner())
    #imfilter!(r,dat_filtered,dat,kernel,NoPad(),(1:size(dat_filtered,1),1:size(dat_filtered,2)));
    filt!(dat_filtered, kernel[1].data.parent, dat)
    return dat_filtered
end


function mult_sorter_d(dat, stat_function; n_permutations = 10)
    row = Dict()
    @debug "starting"
    kernel = (ImageFiltering.ReshapedOneD{2,1}(KernelFactors.gaussian(5)),)
    dat_filtered = similar(dat, size(dat, 3), size(dat, 2)) # transposition to have trials in first dimension already here
    #dat_padded = Images.ImageFiltering.padarray(dat,Pad(:replicate,0,0,length(kernel[1])÷2))
    #padsize = length(kernel[1]) ÷ 2
    #dat_padded = Images.ImageFiltering.padarray(dat,Fill(0,(0,0,padsize)))
    dat_padded = permutedims(dat, (1, 3, 2))
    d_perm = similar(dat, size(dat, 1), n_permutations) 
    @debug "starting permutation loop"
	# We permute data for all events in advance
    for ch = 1:size(dat, 1)
        for perm = 1:n_permutations

            sortix = shuffle(1:size(dat_filtered, 1))
            #sortix = vcat(-padsize+1:0,sortix,length(sortix)+1:length(sortix)+padsize)
            d_perm[ch, perm] = stat_function(
                my_filter!(dat_filtered, @view(dat_padded[ch, sortix, :]), kernel),
            )
            @show ch, perm
        end
    end
    mean_d_perm = mean(d_perm, dims = 2)[:, 1]

    for n in names(evts)
        sortix = sortperm(evts[!, n])
        # add padding
        #sortix = vcat(-padsize+1:0,sortix,length(sortix)+1:length(sortix)+padsize)
        #dat_sorted .= dat[:, :, sortix]
        col = fill(NaN, size(dat, 1))
        for ch = 1:size(dat, 1)
            my_filter!(dat_filtered, @view(dat_padded[ch, sortix, :]), kernel)
            d_emp = stat_function(dat_filtered)

            col[ch] = abs(d_emp - mean_d_perm[ch])
            print(ch, " ")
        end
        println(n)
        row[n] = get(row, n, col) # add new key in dict
    end
    return DataFrame(row)
end



@time begin
    out3 = mult_sorter_d(dat2, Images.entropy) # 12 min
end

dat2[1:10,1:10:end,:],


begin
    f = Figure()
    ax = CairoMakie.Axis(f[1, 1], xlabel = "Channels", ylabel = "Sorting event variables")
    hm = heatmap!(ax, Matrix(out3))
    Colorbar(f[1, 2], hm, label = "d")
    f
    #save("assets/heatmap.png", f)
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

plot_topoplotseries(
    tmp2,
    Δbin;
    positions = rand(Point2f, 128),
    combinefun = x -> x,
    mapping = (; :col => :condition),
)

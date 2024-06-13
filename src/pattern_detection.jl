function slow_filter(img)
    filtered_data = UnfoldMakie.imfilter(img, UnfoldMakie.Kernel.gaussian((1, max(30, 0))))
    return filtered_data
end

function fast_filter!(dat_filtered, kernel, dat) #
    #r = Images.ImageFiltering.ComputationalResources.CPU1(Images.ImageFiltering.FIR())
    DSP.filt!(dat_filtered, kernel[1].data.parent, dat)
    return dat_filtered
end

function single_chan_pattern_detector(dat, func, evts)
    e = zeros(0)
    for n in names(evts)
        dat_sorted = slow_filter((dat[:, sortperm(evts[!, n])]))
        e = append!(e, round.(func(dat_sorted), digits = 2))
    end
    return DataFrame("Sorting values" => names(evts), "Mean row range" => e)
end

function mult_chan_pattern_detector_value(dat, f, evts)
    row = Dict()
    for n in names(evts) # iterate over event variables
        col = zeros(0)
        for i = 1:size(dat)[1] # iterate over chanels 
            dat_sorted = slow_filter(dat[i, :, sortperm(evts[!, n])])
            col = append!(col, round.(f(dat_sorted), digits = 2))
        end
        println(n)
        println(col)
        row[n] = get(row, n, col)
    end
    return DataFrame(row)
end

function mult_chan_pattern_detector_probability(dat, stat_function, evts; n_permutations = 10)
    row = Dict()
    @debug "starting"
    kernel = (ImageFiltering.ReshapedOneD{2,1}(KernelFactors.gaussian(5)),)
    #println("kernel: ", kernel)
    dat_filtered = similar(dat, size(dat, 3), size(dat, 2)) # transposition to have trials in first dimension already here
    dat_padded = permutedims(dat, (1, 3, 2))
    #println("dat_padded: ", size(dat_padded))
    d_perm = similar(dat, size(dat, 1), n_permutations)
    @debug "starting permutation loop"
    # We permute data for all events in advance
    Threads.@threads for ch = 1:size(dat, 1)
        for perm = 1:n_permutations

            sortix = shuffle(1:size(dat_filtered, 1)) # a vector of indecies
            #println("dat_padded[ch, sortix, :]: ", size(dat_padded[ch, sortix, :]))
            d_perm[ch, perm] = stat_function(
                fast_filter!(dat_filtered, kernel, @view(dat_padded[ch, sortix, :])),
            )
            @show ch, perm
        end
    end
    mean_d_perm = mean(d_perm, dims = 2)[:, 1]

    Threads.@threads for n in names(evts)
        sortix = sortperm(evts[!, n])
        col = fill(NaN, size(dat, 1))
        for ch = 1:size(dat, 1)
            fast_filter!(dat_filtered, kernel, @view(dat_padded[ch, sortix, :]))
            d_emp = stat_function(dat_filtered)

            col[ch] = abs(d_emp - mean_d_perm[ch])
            print(ch, " ")
        end
        println(n)
        row[n] = get(row, n, col) # add new key in dict
    end
    return DataFrame(row)
end

function range_mean(dat_filt)
    a = extrema(dat_filt, dims = 2)
    b = last.(a) .- first.(a)
    return mean(b)
end

function mult_chan_test(dat, stat_function, n_permutations = 10)
    row = Dict()
    @debug "starting"
    kernel = (ImageFiltering.ReshapedOneD{2,1}(KernelFactors.gaussian(5)),)
    #println("kernel: ", kernel)
    dat_filtered = similar(dat, size(dat, 3), size(dat, 2)) # transposition to have trials in first dimension already here
    dat_padded = permutedims(dat, (1, 3, 2))
    #println("dat_padded: ", size(dat_padded))
    d_perm = similar(dat, size(dat, 1), n_permutations)
    @debug "starting permutation loop"
    # We permute data for all events in advance
    
    Threads.@threads for perm = 1:n_permutations
        for ch = 1:size(dat, 1)
            sortix = shuffle(1:size(dat_filtered, 1))
            d_perm[ch, perm] = stat_function(
                fast_filter!(dat_filtered, @view(dat_padded[ch, sortix, :]), kernel),
            )
            @show ch, perm
        end
    end
end
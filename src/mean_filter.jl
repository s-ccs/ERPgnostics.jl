function mean_filter!(dat_filtered, dat)
    n_out = size(dat_filtered, 1)
    dat_nrows = size(dat, 1)
    bins = Int.(round.(collect(range(1, stop=dat_nrows, length=n_out + 1))))
    bins[1] = 1
    bins[end] = dat_nrows
    #@debug size(dat_filtered)
    #@debug size(dat)
    for b = 1:length(bins)-1
        bin_start = bins[b]
        bin_stop = bins[b+1]
        #@debug size(dat_filtered[b, :])
        #@debug size(mean(@view(dat[bin_start:bin_stop, :]), dims=1)[1, :])
        dat_filtered[b, :] .= mean(@view(dat[bin_start:bin_stop, :]), dims=1)[1, :]
    end
    return dat_filtered
end


function mult_chan_pattern_detector_probability_meanfilter(
    dat,
    stat_function,
    evts;
    n_permutations=10,
)
    row = Dict()
    @debug "starting"

    #println("kernel: ", kernel)
    dat_permuted = permutedims(dat, (1, 3, 2))
    dat_filtered = similar(dat, 20, size(dat_permuted, 3))
    d_perm = similar(dat, size(dat, 1), n_permutations)
    @debug "starting permutation loop"
    # We permute data for all events in advance
    Threads.@threads for ch = 1:size(dat, 1)
        for perm = 1:n_permutations

            sortix = shuffle(1:size(dat_permuted, 2)) # a vector of indecies
            #println("dat_padded[ch, sortix, :]: ", size(dat_padded[ch, sortix, :]))
            d_perm[ch, perm] = stat_function(
                mean_filter!(dat_filtered, @view(dat_permuted[ch, sortix, :])),
            )
            @show ch, perm
        end
    end
    mean_d_perm = mean(d_perm, dims=2)[:, 1]

    Threads.@threads for n in names(evts)
        sortix = sortperm(evts[!, n])
        col = fill(NaN, size(dat, 1))
        for ch = 1:size(dat, 1)
            mean_filter!(dat_filtered, @view(dat_permuted[ch, sortix, :]))
            d_emp = stat_function(dat_filtered)

            col[ch] = abs(d_emp - mean_d_perm[ch])
            print(ch, " ")
        end
        println(n)
        row[n] = get(row, n, col) # add new key in dict
    end
    return DataFrame(row)
end

"""
    mult_chan_pattern_detector_probability_meanfilter(erp_data::Array{Float64, 3}, stat_function::Function, events::DataFrame; n_permutations = 10)

Pattern detector.\\
Method:\\
- For each channel permute data `n_permutations` of times.\\
- For each permuted data use filter for smearing.\\
- Use pattern dection function.\\
- Average all this datasets in one. That how we get random data with no pattern: noerp\\_data.\\
- Take the the data where we expect to find a pattern: erp\\_data. Sort its trials by experimental condition.\\
- Smear and use pattern detection function.\\
- Find absolute difference of values between erp\\_data and noerp\\_data.\\
- Do it for each channel and each variable.\\

## Arguments

- `erp_data::Array{Float64, 3}`\\
    3-dimensional Array of voltages of Event-related potentials. Dimensions: channels, time of recording, trials. 
- `stat_function::Function`\\
    Function used for pattern detection.\\
    For instance, `Images.entropy` form `Images.jl`.
- `events::DataFrame`\\
    DataFrame with columns of experimental events and rows with trials. Each value is an event value in a trial.
- `kwargs...`\\
    Additional styling behavior. \\

## Keyword arguments (kwargs)
- `n_permutations::Number = 10` \\
    Number fo permutations of the algorithm.

**Return Value:** DataFrame with pattern detection values. Dimensions: experimental events, trials.
"""
function mult_chan_pattern_detector_probability_meanfilter(
    erp_data::Array{Float64,3},
    stat_function::Function,
    events::DataFrame;
    n_permutations = 10,
)
    row = Dict()
    @debug "starting"

    dat_permuted = permutedims(erp_data, (1, 3, 2))
    dat_filtered = similar(erp_data, 20, size(dat_permuted, 3))
    d_perm = similar(erp_data, size(erp_data, 1), n_permutations)
    @debug "starting permutation loop"
    # We permute data for all events in advance
    pbar = ProgressBar(total = size(erp_data, 1))
    Threads.@threads for ch = 1:size(erp_data, 1)
        for perm = 1:n_permutations
            sortix = shuffle(1:size(dat_permuted, 2)) # a vector of indecies
            d_perm[ch, perm] = stat_function(
                mean_filter!(dat_filtered, @view(dat_permuted[ch, sortix, :])),
            )
        end
        update(pbar)
    end
    mean_d_perm = mean(d_perm, dims = 2)[:, 1]

    pbar = ProgressBar(total = length(names(events)))
    Threads.@threads for n in names(events)
        sortix = sortperm(events[!, n])
        col = fill(NaN, size(erp_data, 1))
        for ch = 1:size(erp_data, 1)
            mean_filter!(dat_filtered, @view(dat_permuted[ch, sortix, :]))
            d_emp = stat_function(dat_filtered)
            col[ch] = abs(d_emp - mean_d_perm[ch])
        end
        row[n] = get(row, n, col) # add new key in dict
        update(pbar)
    end
    return DataFrame(row)
end



function single_chan_pattern_detector(dat, func, events)
    e = zeros(0)
    for n in names(events)
        dat_sorted = slow_filter((dat[:, sortperm(events[!, n])]))
        e = append!(e, round.(func(dat_sorted), digits = 2))
    end
    return DataFrame("Sorting values" => names(events), "Mean row range" => e)
end

function mult_chan_pattern_detector_value(dat, f, events)
    row = Dict()
    for n in names(events) # iterate over event variables
        col = zeros(0)
        for i = 1:size(dat)[1] # iterate over chanels 
            dat_sorted = slow_filter(dat[i, :, sortperm(events[!, n])])
            col = append!(col, round.(f(dat_sorted), digits = 2))
        end
        println(n)
        println(col)
        row[n] = get(row, n, col)
    end
    return DataFrame(row)
end

function mult_chan_test(dat, stat_function, n_permutations = 10)
    row = Dict()
    @debug "starting"
    kernel = (ImageFiltering.ReshapedOneD{2,1}(KernelFactors.gaussian(5)),)
    dat_filtered = similar(dat, size(dat, 3), size(dat, 2)) # transposition to have trials in first dimension already here
    dat_padded = permutedims(dat, (1, 3, 2))
    d_perm = similar(dat, size(dat, 1), n_permutations)
    @debug "starting permutation loop"
    # We permute data for all events in advance

    Threads.@threads for perm = 1:n_permutations
        for ch = 1:size(dat, 1)
            sortix = shuffle(1:size(dat_filtered, 1))
            d_perm[ch, perm] = stat_function(
                fast_filter!(dat_filtered, kernel, @view(dat_padded[ch, sortix, :])),
            )
            @show ch, perm
        end
    end
end

"""
    mult_chan_pattern_detector_probability(erp_data::Array{Float64, 3}, stat_function::Function, events::DataFrame; n_permutations = 10)

Pattern detector.\\
Method:\\
- For each channel permute data `n_permutations` of times.\\
- For each permuted data use filter for smearing.\\
- Use pattern dection function.\\
- Average all this datasets in one. That how we get random data with no pattern: noerp\\_data.\\
- Take the the data where we expect to find a pattern: erp\\_data. Sort its trials by experimental condition.\\
- Smear and use pattern detection function.\\
- Find absolute difference of values between erp\\_data and noerp\\_data.\\
- Do it for each channel and each variable.\\

## Arguments

- `erp_data::Array{Float64, 3}`\\
    3-dimensional Array of voltages of Event-related potentials. Dimensions: channels, time of recording, trials. 
- `stat_function::Function`\\
    Function used for pattern detection.\\
    For instance, `Images.entropy` from `Images.jl`.
- `events::DataFrame`\\
    DataFrame with columns of experimental events and rows with trials. Each value is an event value in a trial.
- `kwargs...`\\
    Additional styling behavior. \\

## Keyword arguments (kwargs)
- `n_permutations::Number = 10` \\
    Number fo permutations of the algorithm.

**Return Value:** DataFrame with pattern detection values. Dimensions: experimental events, trials.
"""
function mult_chan_pattern_detector_probability(
    erp_data::Array{Float64,3},
    stat_function::Function,
    events::DataFrame;
    n_permutations = 10,
)
    if (size(erp_data, 3) != size(events, 1))
        error(
            "Different number of trials: erp data $(size(erp_data, 3)) and event $(size(events, 1))",
        )
    end
    row = Dict()
    # kernel = (ImageFiltering.ReshapedOneD{2,1}(KernelFactors.gaussian(5)),)
    dat_filtered = similar(erp_data, size(erp_data, 3), size(erp_data, 2)) # transposition to have trials in first dimension already here
    dat_padded = permutedims(erp_data, (1, 3, 2))
    d_perm = similar(erp_data, size(erp_data, 1), n_permutations)
    @debug "starting permutation loop"
    # We permute data for all events in advance
    pbar = ProgressBar(total = size(erp_data, 1))
    Threads.@threads for ch = 1:size(erp_data, 1)
        for perm = 1:n_permutations
            sortix = shuffle(1:size(dat_filtered, 1)) # a vector of indecies
            d_perm[ch, perm] = stat_function(slow_filter(@view(dat_padded[ch, sortix, :])))
        end
        update(pbar)
    end
    mean_d_perm = mean(d_perm, dims = 2)[:, 1]

    pbar = ProgressBar(total = length(names(events)))
    Threads.@threads for n in names(events)
        sortix = sortperm(events[!, n])
        col = fill(NaN, size(erp_data, 1))

        for ch = 1:size(erp_data, 1)
            d_emp = stat_function(slow_filter(@view(dat_padded[ch, sortix, :])))
            col[ch] = abs(d_emp - mean_d_perm[ch]) # calculate raw effect size
            #col[ch] = mean(d_emp .< @view(mean_d_perm[ch, :])) # calculate p-value
        end
        update(pbar)
        row[n] = get(row, n, col) # add new key in dict
    end
    return DataFrame(row)
end

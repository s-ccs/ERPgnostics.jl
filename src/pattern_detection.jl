"""
    pattern_detector(erp_data::Matrix{Float64}, filter::Function, detector::Function; mode = "plot")

Pattern detector for 2D dataframes.\\
For instance, single EEG channel (sensor) with trials over time.\\

Method:\\
- Filter dataset for smearing.\\
- Use pattern detection function.\\
- In `mode = "plot"` returns an ERP image with a value of pattern detection. Otherwise - only value.

## Arguments

- `erp_data::Matrix{Float64}`\\
    3-dimensional array of voltages of event-related potentials. Dimensions: channels, recording time, trials. 
- `detector::Function`\\
    Function used for pattern detection.\\
    For example, `Images.entropy` from `Images.jl`.
- `filter::Function`\\
    Function used for smearing.\\

## Keyword arguments (kwargs)
- `mode::String = "plot"` \\
    Plot an ERP image with the pattern detection value.

**Return Value:** (`Figure` with) pattern detection value.
"""
function pattern_detector(
    erp_data::Matrix{Float64},
    filter::Function,
    detector::Function;
    mode = "plot",
)
    dat_filtered = filter(erp_data)
    detector_value = detector(dat_filtered)

    if mode == "plot"
        f = Figure()
        image(
            f[1, 1],
            dat_filtered,
            axis = (title = "Entropy = $(round(detector_value, digits=2))",),
        )
        #map(σ -> ImageEdgeDetection.detect_edges(f, canny(spatial_scale=σ, high=Percentile(80), low=Percentile(20))), 1:5)
        return f
    else
        return detector_value
    end
end

"""
    complex_pattern_detector(erp_data::Array{Float64, 3}, filter::Function, detector::Function; mode = "basic", n_permutations = 10)

Pattern detector.\\
Basic mode:\\
- For each channel and soring variable, use the `complex_pattern' function.

Mode of permuted means:\\
- Create a data set of detector values based on given data, but shuffled randomly.\\
- Compute detector values for given data over each channel and sort value.\\
- Find the absolute difference between erp\\_data and shaffled\\_data.\\

## Arguments

- `erp_data::Array{Float64, 3}`\\
    3-dimensional Array of voltages of Event-related potentials. Dimensions: time of recording, trials, channels. 
- `detector::Function`\\
    Function used for pattern detection.\\
    For example, `Images.entropy` from `Images.jl`.
- `filter::Function`\\
    Function used for smearing.\\- `kwargs...`\\
    Additional styling behavior. \\

## Keyword arguments (kwargs)
- `n_permutations::Number = 10` \\
    Number fo permutations. Useful for mode "permuted_means" where it defines number of random permutations before averaging.
- `mode::String = "basic"` \\
    With the "permuted_means" mode, results are given as the absolute value between the detector result over the given data set and the randomly permuted data set.

**Return Value:** DataFrame with pattern detection values. Dimensions: experimental events, channels.
"""
function complex_pattern_detector(
    erp_data::Union{Array{Float64,3},Matrix{Float64}},
    sort_values::Union{Vector{Float64},DataFrame},
    filter::Function,
    detector::Function;
    n_permutations = 10,
    mode = "basic",
)
    error_checker(erp_data, sort_values)

    row = Dict()
    if mode == "permuted_means"
        permuted_means_data = permuted_means(erp_data, filter, detector, n_permutations)
    end

    pbar = ProgressBar(total = length(names(sort_values)))
    Threads.@threads for n in names(sort_values)
        sortix = sortperm(sort_values[!, n]) # sort a single value
        col = fill(NaN, size(erp_data, 3))
        for ch = 1:size(erp_data, 3) # iteration over channels
            value =
                pattern_detector(erp_data[:, sortix, ch], filter, detector; mode = "num")
            if mode == "permuted_means"
                col[ch] = abs(value - permuted_means_data[ch]) # calculate raw effect size
            else
                col[ch] = value
            end
            #col[ch] = mean(d_emp .< @view(mean_d_perm[ch, :])) # calculate p-value
        end
        update(pbar)
        row[n] = get(row, n, col) # add new key in dict
    end
    return DataFrame(row)
end

function error_checker(erp_data, sort_values) #more checkers

    if (size(erp_data, 2) != size(sort_values, 1))
        error(
            "Different number of trials: erp data $(size(erp_data, 2)) and event $(size(sort_values, 1))",
        )
    end
end

function permuted_means(erp_data, filter, detector, n_permutations) # better name?
    d_perm = similar(erp_data, size(erp_data, 3), n_permutations)
    @debug "starting permutation loop"
    # We permute data for all sort_values in advance
    pbar = ProgressBar(total = size(erp_data, 3))
    Threads.@threads for ch = 1:size(erp_data, 3)
        for perm = 1:n_permutations
            sortix = shuffle(1:size(erp_data, 2)) # a vector of indecies
            d_perm[ch, perm] =
                pattern_detector(erp_data[:, sortix, ch], filter, detector; mode = "num")
        end
        update(pbar)
    end
    permuted_means_data = mean(d_perm, dims = 2)[:, 1]
    return permuted_means_data
end

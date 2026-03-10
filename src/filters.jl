
function slow_filter(data_init; mu = 0, sigma = 3)
    return UnfoldMakie.imfilter(data_init, UnfoldMakie.Kernel.gaussian((mu, max(sigma, 0))))
end

function fast_filter!(dat_filtered, kernel, dat) # broken
    #r = Images.ImageFiltering.ComputationalResources.CPU1(Images.ImageFiltering.FIR())
    DSP.filt!(dat_filtered, kernel[1].data.parent, dat)
    return dat_filtered
end

function mean_filter(dat; output_dim = 20)
    mean_filter!(similar(dat, output_dim, size(dat, 2)), dat)
end

function mean_filter!(dat_filtered, dat)
    n_out = size(dat_filtered, 1)
    dat_nrows = size(dat, 1)
    bins = Int.(round.(collect(range(1, stop = dat_nrows, length = n_out + 1))))
    bins[1] = 1
    bins[end] = dat_nrows
    for b = 1:length(bins)-1
        bin_start = bins[b]
        bin_stop = bins[b+1]
        dat_filtered[b, :] .= mean(@view(dat[bin_start:bin_stop, :]), dims = 1)[1, :]
    end
    return dat_filtered
end

#= 
function range_mean(dat_filt)
    a = extrema(dat_filt, dims = 2)
    b = last.(a) .- first.(a)
    return mean(b)
end =#

entropy_robust(img::AbstractArray; kind = :shannon, nbins = 256) =
    entropy_robust(Images.ImageQualityIndexes._log(kind), img; nbins = nbins)
function entropy_robust(logᵦ::Log, img; nbins = 256) where {Log<:Function}
    img_trimmed = collect(trim(img[:], prop = 0.1))
    _, counts = Images.ImageContrastAdjustment.build_histogram(img_trimmed, nbins)
    n = length(img)
    _zero = zero(first(counts) / n)
    -sum(counts) do c
        c > 0 ? c / n * logᵦ(c / n) : _zero
    end
end

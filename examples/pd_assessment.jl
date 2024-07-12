includet("setup.jl")
includet("../src/pattern_generation.jl")
includet("../src/pattern_detection.jl")
includet("../src/mean_filter.jl")

data_all, evts = simulate_alldata()

plot_erpimage(data_all)
plot_erpimage(data_all; erpblur=51)
plot_erpimage(data_all; erpblur=51, sortvalues=evts.Δlatency)


# functions
function basic(data_all; erpblur=51)
    return (UnfoldMakie.imfilter(data_all, UnfoldMakie.Kernel.gaussian((erpblur, 0))))
end

function fast(data_all; erpblur=51) # broken
    kernel = (ImageFiltering.ReshapedOneD{1,2}(KernelFactors.gaussian((0, erpblur)),))
    #return (DSP.filt(kernel[1].data.parent, data_all))#[1:4, 1:4]
    return (imfilter(data_all, kernel))#[1:4, 1:4]
end

function d_probability(data_all, f)
    rand_data = zeros(100)
    for k = 1:100
        rand_data[k] = f(data_all[:, shuffle(1:end)])
    end
    mean_rand_data = mean(rand_data)
    return abs(f(data_all) - mean_rand_data)
end

# assessment
basic(data_all)
basic(data_all[:, sortperm(evts.Δlatency)])

fast(data_all)
fast(data_all[:, sortperm(evts.Δlatency)])

d_probability(data_all, basic)
d_probability(data_all[:, sortperm(evts.Δlatency)], basic)

# fast
d_probability(data_all, fast)
d_probability(data_all[:, sortperm(evts.Δlatency)], fast)

Images.entropy(mean_filter(data_all'))
Images.entropy(mean_filter(data_all[:, sortperm(evts.Δlatency)]'))

Images.entropy(basic(data_all'))
Images.entropy(basic(data_all[:, sortperm(evts.Δlatency)]'))

Images.entropy(fast(data_all))
Images.entropy(fast(data_all[:, sortperm(evts.Δlatency)]))

UnfoldMakie.imfilter(data_all, UnfoldMakie.Kernel.gaussian(1, erpblur))[1:4, 1:4]
UnfoldMakie.imfilter(data_all, UnfoldMakie.Kernel.gaussian(1, erpblur))[1:4, 1:4]


# DEBUG AREA

r = rand(500, 100) # repeats x times
r = zeros(5, 6)
r[3, 3] = 1
r


mean_filter(r)
basic(r; erpblur=1)
@time basic(data_all);
@time mean_filter(data_all);

#---
f = Figure()
heatmap(f[1, 1], data_all[:, sortperm(evts.Δlatency)]')
heatmap(f[1, 2], mean_filter(data_all[:, sortperm(evts.Δlatency)]';))
heatmap(f[1, 3], basic(data_all[:, sortperm(evts.Δlatency)]'))
heatmap(f[2, 1], data_all[:, :]')
heatmap(f[2, 2], mean_filter(data_all[:, :]'))
heatmap(f[2, 3], basic(data_all[:, :]'))
f
#---

size(UnfoldMakie.Kernel.gaussian((1, erpblur)))
size((ImageFiltering.ReshapedOneD{2,1}(KernelFactors.gaussian(1, erpblur)),))
size(KernelFactors.gaussian(1, erpblur))


# entropy

# more erpblur - more entropy of data with pattern
#Low Entropy Windows: Windows with lower entropy values indicate less randomness and potentially more regular patterns.
#High Entropy Windows: Windows with higher entropy values suggest higher randomness and less predictable patterns.


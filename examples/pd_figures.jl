includet("setup.jl")
includet("../src/pattern_generation.jl")

begin
    fid = h5open("data/data_fixations.hdf5", "r")
    erps_fix = read(fid["data"]["data_fixations.hdf5"])
    close(fid)

    evts_fix = DataFrame(CSV.File("data/events.csv"))
    data_all, evts = simulate_alldata()
end


let
    f = Figure(size = (500, 1200))
    plot_erpimage!(
        f[1, 1],
        data_all;
        sortvalues = evts.Δlatency,
        axis = (; title = "Sigmoid; sorted by Δlatency", xlabelvisible = false, xticklabelsvisible = false),
    )
    plot_erpimage!(
        f[end+1, 1],
        data_all;
        sortvalues = evts.duration,
        axis = (; title = "One-sided fan; sorted by duration", xlabelvisible = false, xticklabelsvisible = false),
    )
    plot_erpimage!(
        f[end+1, 1],
        data_all;
        sortvalues = evts.durationB,
        axis = (; title = "Two-sided fan; sorted by durationB", xlabelvisible = false, xticklabelsvisible = false),
    )
    plot_erpimage!(
        f[end+1, 1],
        data_all;
        sortvalues = evts.condition .== "car",
        axis = (; title = "Diverging bar; sorted by iscar", xlabelvisible = false, xticklabelsvisible = false),
    )
    plot_erpimage!(
        f[end+1, 1],
        data_all;
        sortvalues = evts.continuous,
        axis = (; title = "Hourglass bar; sorted by continuous", xlabelvisible = false, xticklabelsvisible = false),
    )
    plot_erpimage!(
        f[end+1, 1],
        data_all;
        sortvalues = evts.duration_linear,
        axis = (; title = "Abline; sorted by duration_linear"),
    )
    f
    #save("assets/patterns.png", f)
end


plot_erpimage(erps_fix[:, :, 1]; meanplot = true)


for i in 1:100
    f = Figure(; figure_padding = 0)
    plot_erpimage!(f, erps_fix[i, :, :]; 
    layout = (; hidespines = (), hidedecorations = (), use_colorbar = false),)
    save("gt/nopattern/patterns_$i.png", f)
end

k = 0
μ = 2.2
σ = 0.1
for i in 1:20
    μ  = μ + 0.1
    σ  = σ + 0.1
    data_all, evts = simulate_alldata(μ, σ)
    for j in [evts.duration, evts.durationB, evts.Δlatency, evts.condition .== "car", evts.continuous, evts.duration_linear,]
        k = k + 1
        f = Figure(; figure_padding = 0)
        plot_erpimage!(f, data_all; sortvalues = j, 
        layout = (; hidespines = (), hidedecorations = (), use_colorbar = false))
        save("gt/yespattern/patterns_$k.png", f)
    end
end


#########
for i in 1:128
    f = Figure()
    plot_erpimage!(f, erps_fix[i, :, :]; sortvalues = evts_fix.duration, 
    layout = (; hidespines = (), hidedecorations = (), use_colorbar = false))
    save("gt/yespattern2/patterns_$i.png", f)
end

plot_erpimage(erps_fix[1, :, :]; 
layout = (; hidespines = (), hidedecorations = (), use_colorbar = false))

plot_erpimage(erps_fix[i, :, :]; layout = (; show_colorbar = false))

plot_erpimage(erps_fix[i, :, :]; sortvalues = evts_fix.duration, 
    layout = (; hidespines = (), hidedecorations = (), use_colorbar = false)) 
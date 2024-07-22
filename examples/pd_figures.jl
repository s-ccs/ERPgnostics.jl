includet("setup.jl")
includet("../src/pattern_generation.jl")

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
end
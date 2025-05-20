using CairoMakie
using DataFrames
using UnfoldMakie
using ERPgnostics
using CSV

data_all, evts = simulate_6patterns()

# Here, you can see how sorting the same data by different values creates six distinct patterns.
# ```@raw html
# <details>
# <summary>Click to expand</summary>
# ```
begin
    f = Figure(size = (900, 600))
    plot_erpimage!(
        f[1, 1],
        data_all;
        sortvalues = evts.Δlatency,
        axis = (; title = "Sigmoid; sorted by Δlatency", xlabelvisible = false, xticklabelsvisible = false),
        colorbar = (; label = ""),
    )
    plot_erpimage!(
        f[2, 1],
        data_all;
        sortvalues = evts.duration,
        axis = (; title = "One-sided fan; sorted by duration", xlabelvisible = false, xticklabelsvisible = false),
        colorbar = (; label = ""),
    )
    plot_erpimage!(
        f[3, 1],
        data_all;
        sortvalues = evts.durationB,
        axis = (; title = "Two-sided fan; sorted by durationB", xlabel = "Time [ms]"),
        colorbar = (; label = ""),
    )
    plot_erpimage!(
        f[1, 2],
        data_all;
        sortvalues = evts.condition .== "car",
        axis = (; title = "Diverging bar; sorted by iscar", xlabelvisible = false, ylabelvisible = false, xticklabelsvisible = false,  yticklabelsvisible = false),
    )
    plot_erpimage!(
        f[2, 2],
        data_all;
        sortvalues = evts.continuous,
        axis = (; title = "Hourglass bar; sorted by continuous", xlabelvisible = false, ylabelvisible = false,  xticklabelsvisible = false,  yticklabelsvisible = false),
    )
    plot_erpimage!(
        f[3, 2],
        data_all;
        sortvalues = evts.duration_linear,
        axis = (; title = "Tilted bar; sorted by duration_linear", xlabel = "Time [ms]", ylabelvisible = false,  yticklabelsvisible = false),
    )
end
# ```@raw html
# </details >
# ```
f

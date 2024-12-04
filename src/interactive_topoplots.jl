"""
    inter_toposeries(pattern_detection_values::DataFrame; positions::Vector{Point{2, Float64}} = positions_128)

Plot interactive topoplot series.

## Arguments

- `pattern_detection_values::DataFrame`\\
    DataFrame with columns condition and estimate. Each condition is resposible for a topoplot. Estimates will be projected across channels. 
- `kwargs...`\\
    Additional styling behavior. \\

## Keyword arguments (kwargs)
- `positions::Vector{Point{2, Float64}} = positions_128` \\
    Array of topoplot coordinates for channels.

**Return Value:** Interactive `Figure` displaying topoplot series.
"""
function inter_toposeries(
    pattern_detection_values::DataFrame;
    positions::Vector{Point{2,Float64}} = positions_128,
    figure_configs = (; size = (1500, 400)),
    toposeries_configs = (; nrows = 1,),
)

    names = unique(pattern_detection_values.condition)
    obs_tuple = Observable((0, 1, 1)) # row, col, channel
    f = Makie.Figure(; figure_configs...)
    str = @lift(
        "Interactive topoplots: channel - " *
        string($obs_tuple[3]) *
        ", variable - " *
        string(names[$obs_tuple[2]])
    )
    ax = Makie.Axis(
        f[1, 1],
        title = str,
        xlabel = "Channels",
        ylabel = "Index of event variable",
        xpanlock = true,
        ypanlock = true,
        xzoomlock = true,
        yzoomlock = true,
        xrectzoom = false,
        yrectzoom = false,
    )

    on(events(f).mousebutton, priority = 1) do event
        if event.button == Mouse.left && event.action == Mouse.press
        end
    end
    hidespines!(ax)
    hidedecorations!(ax)
    plot_topoplotseries!( # make configurable
        f[1, 1],
        pattern_detection_values;
        mapping = (; col = :condition),
        positions = positions,
        nrows = nrows,
        interactive_scatter = obs_tuple,
        visual = (label_scatter = (markersize = 10, strokewidth = 2),),
        layout = (; use_colorbar = true),
        toposeries_configs...,
    )

    f

end

"""
    inter_toposeries_image(pattern_detection_values::DataFrame, events::DataFrame, erps::Array{Float64, 3}, timing; positions::Vector{Point{2, Float64}} = positions_128)

Plot interactive topoplot series and interactive ERP image.\\
ERP image will have trials on y-axis and time on x-axis


## Arguments

- `pattern_detection_values::DataFrame`\\
    DataFrame with columns condition and estimate. Each condition is resposible for a topoplot. Estimates will be projected across channels. 
- `events::DataFrame`\\
    DataFrame with columns of experimental events and rows with trials. Each value is an event value in a trial.
- `erps::Array{Float64, 3}`\\
    3-dimensional Array of voltages of Event-related potentials. Dimensions: channels, time of recording, trials. 
- `timing::?`\\
    Timing of recording. Should be similar to y-value of erps. 
- `kwargs...`\\
    Additional styling behavior. \\

## Keyword arguments (kwargs)
- `positions::Vector{Point{2, Float64}} = positions_128` \\
    Array of topoplot coordinates for channels.

**Return Value:** Interactive `Figure` displaying topoplot series and interactive ERP image.
"""
function inter_toposeries_image(
    pattern_detection_values,
    events,
    erps, #::Array{Float64,3},
    timing;
    figure_configs = (; size = (1500, 400)),
    positions = positions_128,
)

    cond_names = unique(pattern_detection_values.condition)
    obs_tuple = Observable((0, 1, 1))
    f = Makie.Figure(; figure_configs...)
    str = @lift(
        "Entropy topoplots: channel - " *
        string($obs_tuple[3]) *
        ", sorting variable - " *
        string(cond_names[$obs_tuple[2]])
    )

    ax = Makie.Axis(f[1, 1:5], xlabelvisible = false, title = str)
    hidespines!(ax)
    hidedecorations!(ax)

    plot_topoplotseries!(
        f[1, 1:5],
        pattern_detection_values;
        positions = positions,
        col_labels = true,
        mapping = (; col = :condition),
        axis = (; xlabel = "Conditions", xlabelvisible = false),
        visual = (
            label_scatter = (markersize = 10, strokewidth = 2),
            contours = (; levels = 0),
            colormap = Reverse(:RdGy_4),
        ),
        interactive_scatter = obs_tuple,
        colorbar = (;
            label = "Pattern detection function value",
            colorrange = (0, 1),
            height = 300,
        ),
    )

    single_channel_erpimage = @lift(erps[$obs_tuple[3], :, :])
    sortval = @lift(events[:, cond_names[$obs_tuple[2]]])

    str2 = @lift(string(cond_names[$obs_tuple[2]]))
    plot_erpimage!(
        f[2, 1:5],
        timing,
        single_channel_erpimage;
        sortvalues = sortval,
        show_sortval = true,
        meanplot = true,
        sortval_xlabel = str2,
        axis = (; title = "ERP image"),
    )

    #= on(events(f).mousebutton, priority = 1) do event
        if event.button == Mouse.left && event.action == Mouse.press
        end
    end  =#
    f
end

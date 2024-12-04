"""
    inter_heatmap(pattern_detection_values::DataFrame)

Plot interactive heatmap with channels on x-axis and index of event variable on y-axis.

## Arguments

- `pattern_detection_values::DataFrame`\\
    DataFrame with columns condition and estimate. Each condition is a value on y-axis. 
- `kwargs...`\\
    Additional styling behavior. \\

**Return Value:** Interactive `Figure` displaying heatmap.
"""
function inter_heatmap(pattern_detection_values::DataFrame)
    var_i = Observable(1)
    chan_i = Observable(1)
    m = Matrix(pattern_detection_values)
    f = Figure(size = (600, 600))
    str = @lift("Entropy d image, indexes: " * string($chan_i) * ", " * string($var_i))

    ax = WGLMakie.Axis(
        f[1, 1:4],
        xautolimitmargin = (0, 0),
        yautolimitmargin = (0, 0),
        title = str,
        xlabel = "Channels",
        ylabel = "Index of event variable",
    )
    ax.yticks = 1:size(m, 2)
    ax.xticks = 1:size(m, 1)
    hm = heatmap!(ax, m)
    Colorbar(f[1, 5], hm, labelrotation = -π / 2, label = "Pattern detection value")

    on(events(f).mousebutton, priority = 1) do event
        if event.button == Mouse.left && event.action == Mouse.press
            plot, _ = pick(ax.scene)
            a = DataInspector(plot)
            pos = Makie.position_on_plot(plot, -1, apply_transform = false)[Vec(1, 2)]
            b = Makie._pixelated_getindex(plot[1][], plot[2][], plot[3][], pos, true)
            chan_i[], var_i[] = b[1], b[2]
        end
    end
    f
end

"""
    inter_heatmap_image(pattern_detection_values::DataFrame, events::DataFrame, erps::Array{Float64, 3})

Plot heatmap and interactive ERP image.\\
Heatmap will have channels on x-axis and index of event variable on y-axis.\\
ERP image will have trials on y-axis and time on x-axis

## Arguments

- `pattern_detection_values::DataFrame`\\
    DataFrame with columns condition and estimate. Each condition is a value on y-axis.
- `events::DataFrame`\\
    DataFrame with columns of experimental events and rows with trials. Each value is an event value in a trial.
- `erps::Array{Float64, 3}`\\
    3-dimensional Array of voltages of Event-related potentials. Dimensions: channels, time of recording, trials. 
- `kwargs...`\\
    Additional styling behavior. \\

**Return Value:** Interactive `Figure` displaying topoplot series and interactive ERP image.
"""
function inter_heatmap_image(
    pattern_detection_values::DataFrame,
    events::DataFrame,
    erps::Array{Float64,3},
)
    m = Matrix(pattern_detection_values)
    var_i = Observable(1)
    chan_i = Observable(1)
    sort_names = names(pattern_detection_values)
    f = Figure()
    ax = WGLMakie.Axis(
        f[1, 1:4],
        title = "Entropy d image",
        xlabel = "Channels",
        ylabel = "Index of event variable",
        xpanlock = true,
        ypanlock = true,
        xzoomlock = true,
        yzoomlock = true,
        xrectzoom = false,
        yrectzoom = false,
    )
    hm = heatmap!(ax, m)
    Colorbar(f[1, 5], hm, labelrotation = -π / 2, label = "Pattern detection value")
    single_channel_erpimage = @lift(erps[$chan_i, :, :])
    sortval = @lift(events[:, $var_i])

    str = @lift(
        "ERP image: channel " *
        string($chan_i) *
        ", variable " *
        string(sort_names[$var_i])
    )

    str2 = @lift(string(sort_names[$var_i]))
    plot_erpimage!(
        f[2, 1:5],
        single_channel_erpimage;
        sortvalues = sortval,
        show_sortval = true,
        sortval_xlabel = str2,
        axis = (;
            title = str,
            xpanlock = true,
            ypanlock = true,
            xzoomlock = true,
            yzoomlock = true,
            xrectzoom = false,
            yrectzoom = false,
        ),
    )
    on(events(f).mousebutton, priority = 1) do event
        if event.button == Mouse.left && event.action == Mouse.press
            plot, _ = pick(ax.scene)
            pos = Makie.position_on_plot(plot, -1, apply_transform = false)[Vec(1, 2)]
            b = Makie._pixelated_getindex(plot[1][], plot[2][], plot[3][], pos, true)
            chan_i[], var_i[] = b[1], b[2]
            #a = DataInspector(plot)
        end
    end
    f
end

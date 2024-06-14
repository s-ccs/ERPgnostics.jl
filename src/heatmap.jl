function inter_heatmap_image(evts_d, evts, erps)
    m = Matrix(evts_d)
    var_i = Observable(1)
    chan_i = Observable(1)
    sort_names = names(evts_d)
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
    Colorbar(f[1, 5], hm, labelrotation = -π / 2, label = "Entropy d")
    single_channel_erpimage = @lift(erps[$chan_i, :, :])
    sortval = @lift(evts[:, $var_i])

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

function inter_heatmap(evts_d)
    var_i = Observable(1)
    chan_i = Observable(1)
    m = Matrix(evts_d)
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
    Colorbar(f[1, 5], hm, labelrotation = -π / 2, label = "Entropy d")

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

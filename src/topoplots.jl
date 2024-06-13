function inter_topo(tmp)
    names = unique(tmp.condition)
    obs_tuple = Observable((0, 1, 0))
    f = Figure(size = (3000, 1600))
    str = @lift(
        "Entropy topoplots: channel - " *
        string($obs_tuple[3]) *
        ", variable - " *
        string(names[$obs_tuple[2]])
    )

    ax = WGLMakie.Axis(
        f[1, 1],
        xautolimitmargin = (0, 0),
        yautolimitmargin = (0, 0),
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
    hidespines!(ax)
    hidedecorations!(ax)
    plot_topoplotseries!(
        f[1, 1],
        tmp,
        0;
        positions = positions_128,
        col_labels = true,
        mapping = (; col = :condition),
        visual = (label_scatter = (markersize = 15, strokewidth = 2),),
        layout = (; use_colorbar = true),
        interactive_scatter = obs_tuple,
        axis = (;
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
        end
    end
    f
end

function inter_topo_image(evts_d, evts, erps)
    names = unique(evts_d.condition)
    obs_tuple = Observable((0, 2, 1))
    f = Figure(size = (3000, 1600))
    str = @lift(
        "Entropy topoplots: channel - " *
        string($obs_tuple[3]) *
        ", variable - " *
        string(names[$obs_tuple[2]])
    )

    ax = GLMakie.Axis(
        f[1, 1:5],
        xautolimitmargin = (0, 0),
        yautolimitmargin = (0, 0),
        title = str,
        xlabel = "Channels",
        ylabel = "Index of event variable",
    )
    hidespines!(ax)
    hidedecorations!(ax)
    plot_topoplotseries!(
        f[1, 1:5],
        evts_d,
        0;
        positions = positions_128,
        col_labels = true,
        mapping = (; col = :condition),
        visual = (label_scatter = (markersize = 15, strokewidth = 2),),
        layout = (; use_colorbar = true),
        interactive_scatter = obs_tuple,
        colorbar = (; label = "Entropy [d]"),
    )

    single_channel_erpimage = @lift(erps[$obs_tuple[3], :, :])
    sortval = @lift(evts[:, names[$obs_tuple[2]]])

    str2 = @lift(string(names[$obs_tuple[2]]))
    println(size(single_channel_erpimage[]))
    plot_erpimage!(
        f[2, 1:5],
        single_channel_erpimage;
        sortvalues = sortval,
        show_sortval = true,
        meanplot = true,
        sortval_xlabel = str2,
        axis = (; title = str),
    )

    on(events(f).mousebutton, priority = 1) do event
        if event.button == Mouse.left && event.action == Mouse.press
        end
    end
    f
end

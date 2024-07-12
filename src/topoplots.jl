function inter_topo(tmp)
    names = unique(tmp.condition)
    obs_tuple = Observable((0, 1, 0))
    f = Figure(size = (1500, 800))
    str = @lift(
        "Interactive topoplots: channel - " *
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
        tmp;
        mapping = (; col = :condition),
        positions = positions_128,
        col_labels = true,
        interactive_scatter = obs_tuple,
        visual = (label_scatter = (markersize = 15, strokewidth = 2),),
        layout = (; use_colorbar = true),
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

function inter_topo_image(pattern_detection_values, evts, erps, time)
    cond_names = unique(pattern_detection_values.condition)
    obs_tuple = Observable((0, 1, 1))
    f = Figure()#size = (3000, 1600))
    str = @lift(
        "Entropy topoplots: channel - " *
        string($obs_tuple[3]) *
        ", sorting variable - " *
        string(cond_names[$obs_tuple[2]])
    )

    ax = GLMakie.Axis(
        f[1, 1:5],
        #xautolimitmargin = (0, 0),
        #yautolimitmargin = (0, 0),
        xlabelvisible = false,
        title = str,
    )
    hidespines!(ax)
    hidedecorations!(ax)
    plot_topoplotseries!(
        f[1, 1:5],
        pattern_detection_values;
        positions = positions_128,
        col_labels = true,
        mapping = (; col = :condition),
        axis = (; xlabel = "Conditions", xlabelvisible = false),
        visual = (label_scatter = (markersize = 15, strokewidth = 2), contours = (; levels = 0),
            colormap = Reverse(:RdGy_4)),
        layout = (; use_colorbar = true),
        interactive_scatter = obs_tuple,
        colorbar = (; label = "Pattern detection function value", colorrange = (0, 1), height = 300),
    )

    single_channel_erpimage = @lift(erps[$obs_tuple[3], :, :])
    sortval = @lift(evts[:, cond_names[$obs_tuple[2]]])
   
    str2 = @lift(string(cond_names[$obs_tuple[2]]))
   #=  str3 = @lift(
        "ERP image: channel - " *
        string($obs_tuple[3]) *
        ", sorting variable - " *
        string(cond_names[$obs_tuple[2]])
    ) =#
    plot_erpimage!(
        f[2, 1:5], time,
        single_channel_erpimage;
        sortvalues = sortval,
        show_sortval = true,
        meanplot = true,
        sortval_xlabel = str2,
        axis = (; title = "ERP image"),
    )

    on(events(f).mousebutton, priority = 1) do event
        if event.button == Mouse.left && event.action == Mouse.press
        end
    end
    f
end

begin
    using Pkg
    Pkg.activate(".")
    Pkg.status()
end

begin
    using UnfoldMakie
    using Unfold
    using CSV, DataFrames
    using Random, Format
    using WGLMakie, Makie
    using Statistics, StatsBase
    using HDF5, FileIO
    using Printf
    using Images
    using TopoPlots
    using ImageFiltering
    using ComputationalResources
    using Observables
end

using GLMakie
GLMakie.activate!(inline=false)

begin
    evts_init = CSV.read("data/events_init.csv", DataFrame)

    fid = h5open("data/mult.hdf5", "r")
    erps_init = read(fid["data"]["mult.hdf5"])
    close(fid)

    ix = evts_init.type .== "fixation"
    erps = erps_init[:, :, ix]
end
evts = DataFrame(CSV.File("data/events.csv"))
evts_d = CSV.read("data/evts_d.csv", DataFrame) # former output3

# erps (128 channels, 769 mseconds, 2508 trials) - voltage
# evts (2508 trials, 21 sorting variables) - parameters which can influence voltage
# evts_d (128 channels, 21 sorting variables) - d/entropy image

function x(evts_d, evts, erps)
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

    #single_channel_erpimage = Observable(erps[1,:,:])
    #sortval = Observable(collect(1. :size(evts,1)))

   #=  map(chan_i,var_i) do ch,va
        single_channel_erpimage.val = erps[ch, :, :]    
        sortval[] = ((evts[:,va]))

    end =#
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
        axis = (; title = str, xpanlock = true,
        ypanlock = true,
        xzoomlock = true,
        yzoomlock = true,
        xrectzoom = false,
        yrectzoom = false,),
       # xticks = (1:100:size(to_value(single_channel_erpimage), 1)),
        #yticks = (1:100:size(to_value(chosen_image), 2))),
    )
    #println(size(to_value(single_channel_erpimage)))

    on(events(f).mousebutton, priority = 1) do event
        if event.button == Mouse.left && event.action == Mouse.press
            plot, _ = pick(ax.scene)
            pos = Makie.position_on_plot(plot, -1, apply_transform = false)[Vec(1, 2)]
            #@debug pos plot
            b = Makie._pixelated_getindex(plot[1][], plot[2][], plot[3][], pos, true)
            #@debug b
            chan_i[], var_i[] = b[1], b[2]
            #a = DataInspector(plot)
        end
    end
    f
end

x(evts_d, evts, erps) # type varibale is excluded

using UnfoldMakie



function y(evts_d)
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
            #println(chan_i[], ' ', var_i[])
        end
    end
    f
end
y(evts_d)



# to do
# 1. disable dragging

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


fid = h5open("data/mult.hdf5", "r")
erps = read(fid["data"]["mult.hdf5"])
close(fid)
evts = DataFrame(CSV.File("data/events.csv"))

images = CSV.read("data/output3.csv", DataFrame)


function x(evts_d, all_images)
    m = Matrix(evts_d)
    var_i = Observable(1)
    chan_i = Observable(1)
    sort_names = names(evts_d)
    f = Figure()
    ax = WGLMakie.Axis(f[1, 1:4], title = "Entropy d image", xlabel = "Channels", ylabel = "Index of event variable")
    hm = heatmap!(ax, m)
    Colorbar(f[1, 5], hm, labelrotation = -π / 2, label = "Entropy d")
    
    indices_notnan = @lift(findall(<(1), isnan.(evts_d[:, $var_i[]])))
    chosen_image = @lift(@view(all_images[$chan_i, :, $indices_notnan]))
    sortval = @lift(evts_d[$indices_notnan, $var_i[]])
    str = @lift("ERP image: channel " * string($chan_i) * ", variable " * string(sort_names[$var_i]))
    plot_erpimage!(
        f[2, 1:5],
        chosen_image;
        sortvalues = sortval,
        show_sortval = true, 
        axis = (; #title = str, 
        xticks = 1:100:size(to_value(chosen_image), 1)),
    )
    println(size(sortval[]))

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

x(images, erps)

x(images[:, 2:end], erps[:, 2:end])

size(erps)
names(images)


function y(images)
    var_i = Observable(1)
    chan_i = Observable(1)
    m = Matrix(images)
    f = Figure(size = (600, 600))
    str = @lift("Entropy d image, indexes: " * string($chan_i) * ", " * string($var_i))
 
    ax = WGLMakie.Axis(f[1, 1:4], 
        xautolimitmargin = (0, 0),
        yautolimitmargin = (0, 0),
        title = str, xlabel = "Channels", ylabel = "Index of event variable"
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
y(images[1:10, 2:10])



# to do
# 1. disable dragging

###############


data, pos = TopoPlots.example_data()
function click_topoplot(data, pos; interpolation=ClaughTochter(),
    sensornum=64) 

    f = Figure(backgroundcolor = RGBf(0.98, 0.98, 0.98))
    N = 1:length(pos)

    topo_axis = WGLMakie.Axis(f[1, 1],  aspect = DataAspect())
    
	xlims!(low = -0.2, high = 1.2)
	ylims!(low = -0.2, high = 1.2)
    
    mark_size = repeat([21], sensornum)
    mark_color = repeat([1], sensornum)
    labels = ["s$i" for i in 1:sensornum]
    topo = eeg_topoplot!(topo_axis, data[:, 340, 1], labels;
        mark_color,  N, 
        positions=pos[1:sensornum], 
        interpolation=NullInterpolator(),
        enlarge=1,
        label_text=false, 
        label_scatter=(markersize=mark_size, color=:black)
    ) 
    hidedecorations!(current_axis())
    hidespines!(current_axis())

    i = Observable(1)
    str = lift((i, labels) -> "$(labels[i])", i, labels)
    text!(topo_axis, 1, 1, text = str,  align = (:center, :center))
    on(events(f).mousebutton, priority = 2) do event
        if event.button == Mouse.left && event.action == Mouse.press
            plt, p = pick(topo_axis)
            i[] = p
        end
    end
    f
end

click_topoplot(data, pos)
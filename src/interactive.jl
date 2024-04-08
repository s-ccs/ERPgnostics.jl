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

image = CSV.read("data/output3.csv", DataFrame)


function x(evts, image)
    var_i = Observable(3)
    chan_i = Observable(1)
    f = Figure()
    ax = WGLMakie.Axis(f[1, 1:4], title = "Entropy d image", xlabel = "Channels", ylabel = "Index of event variable")
    hm = heatmap!(ax, Matrix(image))
    Colorbar(f[1, 5], hm, labelrotation = -π / 2, label = "Entropy d")

    e = lift((chan_i, var_i) -> erps[chan_i, :, findall(<(1), isnan.(evts[:, var_i]))], chan_i, var_i)
    s = lift((var_i) -> evts[findall(<(1), isnan.(evts[:, var_i])), var_i], var_i)

    str = lift((var_i, chan_i) -> "$(var_i), $(chan_i)", chan_i, var_i)
    text!(ax, 40, 10, text = str,  align = (:center, :center))

    on(events(f).mousebutton, priority = 2) do event
        if event.button == Mouse.left && event.action == Mouse.press
            _, i = pick(ax.scene)
            chan_i[] = mod(i, size(m, 1))
            var_i[] = Integer(floor(i / size(m, 1)))
            println(chan_i[], ' ', var_i[])
            notify(e)
            notify(s)
            plot_erpimage!(
                f[2, 1:5],
                e[]; 
                sortvalues = s[],
                axis = (; title = "ERP image"),
            )
        end
    end
    f
end
x(evts[1:50, 2:end], image[1:50, 2:end])
x(evts[:, 2:end], image[:, 2:end])


function y()
    var_i = Observable(1)
    chan_i = Observable(1)
    m = Matrix(image[:, 1:6])
    f = Figure()
    ax = WGLMakie.Axis(f[1, 1:4], title = "Entropy d image", xlabel = "Channels", ylabel = "Index of event variable")
    hm = heatmap!(ax, m)
    Colorbar(f[1, 5], hm, labelrotation = -π / 2, label = "Entropy d")

    str = lift((var_i, chan_i) -> "$(var_i), $(chan_i)", var_i, chan_i)
    text!(ax, 100, 1, text = str,  align = (:center, :center))

    on(events(f).mousebutton, priority = 2) do event
        if event.button == Mouse.left && event.action == Mouse.press
            _, i = pick(ax.scene)
            chan_i[] = mod(i, size(m, 1))
            var_i[] = Integer(floor(i / size(m, 1)))
            println(chan_i[], ' ', var_i[])
        end
    end
    f
end
y()
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
begin
	using Pkg
    Pkg.activate(".")
	Pkg.status()
end

begin 
	#using PyMNE
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


function x()
    var_i = Observable(3)
    chan_i = Observable(1)
    f = Figure()
    ax = WGLMakie.Axis(f[1, 1:4], title = "Entropy d image", xlabel = "Channels", ylabel = "Index of event variable")
    hm = heatmap!(ax, Matrix(image))
    Colorbar(f[1, 5], hm, labelrotation = -π / 2, label = "Entropy d")

    evts[:, var_i[]]
    indices_notnan = findall(<(1), isnan.(evts[:, var_i[]]))
    plot_erpimage!(
        f[2, 1:5],
        erps[chan_i[], :, indices_notnan]; 
        sortvalues = evts[indices_notnan, var_i[]],
        axis = (; title = "ERP image"),
    )
    str = lift((var_i, chan_i) -> "$(var_i), $(chan_i)", var_i, chan_i)
    text!(ax, 1, 1, text = str,  align = (:center, :center))

    on(events(f).mousebutton, priority = 2) do event
        if event.button == Mouse.left && event.action == Mouse.press
            plt, p = pick(hm)
            println(p)
            i[] = p
        end
    end

    f
end
x()



function y()
    var_i = Observable(3)
    chan_i = Observable(1)
    points = Observable(Point2f[])
    f = Figure()
    ax = WGLMakie.Axis(f[1, 1:4], title = "Entropy d image", xlabel = "Channels", ylabel = "Index of event variable")
    hm = heatmap!(ax, Matrix(image))
    Colorbar(f[1, 5], hm, labelrotation = -π / 2, label = "Entropy d")

    str = lift((points[][]) -> "$(points)", points)
    #text!(ax, 100, 1, text = str,  align = (:center, :center))

    on(events(f).mousebutton, priority = 2) do event
        if event.button == Mouse.left && event.action == Mouse.press
            mp = events(f).mouseposition[]
            points[] = Point2f[]
            push!(points[], mp)
            notify(points)
            #Makie.project(f.scene, :pixel, :data, ax.scene.events.mouseposition[]) 
            println(points)
            #var_i[] = Int64(mp[1])
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
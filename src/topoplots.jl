
include("setup.jl")
#using PyMNE

using UnfoldMakie
using WGLMakie
using GLMakie

Makie.inline!(false)

# data
begin
    evts_init = CSV.read("data/events_init.csv", DataFrame)

    fid = h5open("data/mult.hdf5", "r")
    erps_init = read(fid["data"]["mult.hdf5"])
    close(fid)

    ix = evts_init.type .== "fixation"
    erps = erps_init[:, :, ix]
end
evts = DataFrame(CSV.File("data/events.csv"))
evts_d = CSV.read("data/evts_d.csv", DataFrame)
positions_128 = JLD2.load_object("data/positions_128.jld2")

#Δbin = 140

begin
    tmp = stack(evts_d)
    tmp.time = 1:nrow(tmp)
    tmp.label = 1:nrow(tmp)
    rename!(tmp, :variable => :condition, :value => :estimate)
    tmp.rows = vcat(repeat(["A"], size(tmp, 1) ÷ 4), 
        repeat(["B"], size(tmp, 1) ÷ 4), 
        repeat(["C"], size(tmp, 1) ÷ 4), 
        repeat(["D"], size(tmp, 1) ÷ 4))

    tmp1 = filter(x -> x.rows == "A", tmp)
end




function inter_topo(tmp)
    names = unique(tmp.condition)
    obs_tuple = Observable((0, 1, 0))
    f = Figure(size = (3000, 1600))
    str = @lift("Entropy d topoplot: channel - " * string($obs_tuple[3])* ", variable - " * string(names[$obs_tuple[2]]) )

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
    plot_topoplotseries!(f[1, 1],
        tmp,
        0;
        positions = positions_128,
        col_labels = true,
        mapping = (; col = :condition),
        visual = (label_scatter = (markersize = 15, strokewidth = 2),),
        layout = (; use_colorbar = true),
        interactive_scatter = obs_tuple,
        axis = (;xpanlock = true,
        ypanlock = true,
        xzoomlock = true,
        yzoomlock = true,
        xrectzoom = false,
        yrectzoom = false,),
    )


    on(events(f).mousebutton, priority = 1) do event
        if event.button == Mouse.left && event.action == Mouse.press
        end
    end
    f
end
inter_topo(tmp1)

inter_topo(filter(x -> x.rows == "A", tmp))
inter_topo(filter(x -> x.rows == "B", tmp))
inter_topo(filter(x -> x.rows == "C", tmp))
inter_topo(filter(x -> x.rows == "D", tmp))


function inter_topo_image(evts_d, evts, erps)
    names = unique(evts_d.condition)
    obs_tuple = Observable((0, 2, 1))
    f = Figure(size = (3000, 1600))
    str = @lift("Entropy d topoplot: channel - " * string($obs_tuple[3])* ", variable - " * string(names[$obs_tuple[2]]) )

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
    plot_topoplotseries!(f[1, 1:5],
        evts_d,
        0;
        positions = positions_128,
        col_labels = true,
        mapping = (; col = :condition),
        visual = (label_scatter = (markersize = 15, strokewidth = 2),),
        layout = (; use_colorbar = true),
        interactive_scatter = obs_tuple,
        colorbar = (; label = "Entropy [d]")
    )

    single_channel_erpimage = @lift(erps[$obs_tuple[3], :, :])
    sortval = @lift(evts[:, names[$obs_tuple[2]]])

    str2 = @lift(string(names[$obs_tuple[2]]))
    plot_erpimage!(
        f[2, 1:5],
        single_channel_erpimage;
        sortvalues = sortval,
        show_sortval = true,
        meanplot = true,
        sortval_xlabel = str2,
        axis = (; title = str) 
    )

    on(events(f).mousebutton, priority = 1) do event
        if event.button == Mouse.left && event.action == Mouse.press
        end
    end
    f
end
inter_topo_image(tmp1, evts, erps)

using Revise
Revise.retry()
using UnfoldMakie

inter_topo_image(filter(x -> x.rows == "A", tmp), evts, erps)
inter_topo_image(filter(x -> x.rows == "B", tmp), evts, erps)
inter_topo_image(filter(x -> x.rows == "C", tmp), evts, erps)
inter_topo_image(filter(x -> x.rows == "D", tmp), evts, erps)


sortvalues1 = Observable([1,2,4])

f = Figure()

axleft1 = GLMakie.Axis(f[1,1], xticks = @lift([minimum($sortvalues1), maximum($sortvalues1)]),
)
f



#### dump
#pager(tmp)
#filter!(x -> x.condition == "trialnum" || x.condition == "duration", tmp)
obs_tuple = Observable((0, 0, 0))

plot_topoplotseries(
    tmp,
    0;
    positions = positions_128,
    col_labels = true,
    row_labels = true,
    mapping = (; rows = :rows),
    visual = (label_scatter = (markersize = 15, strokewidth = 2)),
    layout = (; use_colorbar = true),
    interactive_scatter = obs_tuple,
)
pretty_table(tmp)



dat, positions = TopoPlots.example_data()
df = UnfoldMakie.eeg_matrix_to_dataframe(dat[:, 1:4, 1], string.(1:length(positions)))
df.condition = repeat(["A", "A","B","B"], size(df, 1) ÷ 4)
df.condition_row = repeat(["A", "B","A","B"], size(df, 1) ÷ 4)

obs_tuple = Observable((0, 0, 0))
plot_topoplotseries(
    df,
    0;
    col_labels = true,
    mapping = (; col=:condition, row = :condition_row),
    positions = positions,
    visual = (label_scatter = (markersize = 15, strokewidth = 2),),
    layout = (; use_colorbar = true),
    interactive_scatter = obs_tuple,
)

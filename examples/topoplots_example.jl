include("setup.jl")
include("topoplots.jl")

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

inter_topo(tmp1)

inter_topo(filter(x -> x.rows == "A", tmp))
inter_topo(filter(x -> x.rows == "B", tmp))
inter_topo(filter(x -> x.rows == "C", tmp))
inter_topo(filter(x -> x.rows == "D", tmp))

inter_topo_image(tmp1, evts, erps)

inter_topo_image(filter(x -> x.rows == "A", tmp), evts, erps)
inter_topo_image(filter(x -> x.rows == "B", tmp), evts, erps) #fails
inter_topo_image(filter(x -> x.rows == "C", tmp), evts, erps)
inter_topo_image(filter(x -> x.rows == "D", tmp), evts, erps)


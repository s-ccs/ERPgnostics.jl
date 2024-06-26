includet("../src/setup.jl")
includet("../src/topoplots.jl")

using WGLMakie
using GLMakie

Makie.inline!(false)

# data
begin
    fid = h5open("data/data_fixations.hdf5", "r")
    erps_fix = read(fid["data"]["data_fixations.hdf5"])
    close(fid)

    evts = DataFrame(CSV.File("data/events.csv"))
    evts_d = CSV.read("data/evts_d.csv", DataFrame)
    positions_128 = JLD2.load_object("data/positions_128.jld2")
    time = -0.5:0.001953125:1.0
end


begin
    tmp = stack(evts_d)
    tmp.time = 1:nrow(tmp)
    tmp.label = 1:nrow(tmp)
    rename!(tmp, :variable => :condition, :value => :estimate)
    tmp.rows = vcat(
        repeat(["A"], size(tmp, 1) ÷ 4),
        repeat(["B"], size(tmp, 1) ÷ 4),
        repeat(["C"], size(tmp, 1) ÷ 4),
        repeat(["D"], size(tmp, 1) ÷ 4),
    )
end

inter_topo(filter(x -> x.rows == "A", tmp))
inter_topo(filter(x -> x.rows == "B", tmp))
inter_topo(filter(x -> x.rows == "C", tmp))
inter_topo(filter(x -> x.rows == "D", tmp))

inter_topo_image(tmp1, evts, erps)

inter_topo_image(filter(x -> x.rows == "A", tmp), evts, erps_fix, time)
inter_topo_image(filter(x -> x.rows == "B", tmp), evts, erps_fix) #fails
inter_topo_image(filter(x -> x.rows == "C", tmp), evts, erps_fix)
inter_topo_image(filter(x -> x.rows == "D", tmp), evts, erps_fix)




begin
    tmp2 = stack(evts_mf)
    tmp2.time = 1:nrow(tmp)
    tmp2.label = 1:nrow(tmp)
    rename!(tmp2, :variable => :condition, :value => :estimate)
    tmp2.rows = vcat(
        repeat(["A"], size(tmp2, 1) ÷ 4),
        repeat(["B"], size(tmp2, 1) ÷ 4),
        repeat(["C"], size(tmp2, 1) ÷ 4),
        repeat(["D"], size(tmp2, 1) ÷ 4),
    )
end

inter_topo_image(filter(x -> x.rows == "C", tmp2), evts, erps_fix)
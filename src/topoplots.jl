include("setup.jl")
using PyMNE

# data
evts_d = CSV.read("data/evts_d.csv", DataFrame)
positions_128 = JLD2.load_object("data/positions_128.jld2")

Δbin = 140


tmp = stack(evts_d, 1:21)
tmp.time = 1:nrow(tmp)
tmp.label = 1:nrow(tmp)
rename!(tmp, :variable => :condition, :value => :estimate)
filter!(x -> x.condition == "type" || x.condition == "duration", tmp)

tmp1 = filter(x -> x.condition == "type", tmp)
plot_topoplotseries(
    tmp,
    Δbin;
    positions = positions_128,
    combinefun = x -> x,
    mapping = (; :col => :condition),
)

###########
data, positions = TopoPlots.example_data()
df = UnfoldMakie.eeg_matrix_to_dataframe(data[:, :, 1], string.(1:64))
df
plot_topoplotseries(df, 80; positions = positions)

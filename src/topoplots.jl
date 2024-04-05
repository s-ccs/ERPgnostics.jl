include("setup.jl")

# data
out3 = CSV.read("data/output2.csv", DataFrame)
Δbin = 140
positions = rand(Point2f, 128)


tmp = stack(out2, 1:21)
tmp.time = 1:nrow(tmp)
tmp.label = 1:nrow(tmp)
rename!(tmp, :variable => :condition, :value => :estimate)
filter!(x -> x.condition == "type" || x.condition == "duration", tmp)

plot_topoplotseries(
    tmp,
    Δbin;
    positions = positions,
    combinefun = x -> x,
    mapping = (; :col => :condition),
)





###########
data, positions = TopoPlots.example_data()
df = UnfoldMakie.eeg_matrix_to_dataframe(data[:, :, 1], string.(1:64))
df
plot_topoplotseries(
    df,
    80;
    positions = positions,
)
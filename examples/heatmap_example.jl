include("../src/setup.jl")
include("../src/heatmap.jl")

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
GLMakie.activate!(inline = false)

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

inter_heatmap(evts_d, evts, erps)

inter_heatmap_image(evts_d)

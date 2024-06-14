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
    fid = h5open("data/data_fixations.hdf5", "r")
    erps_init = read(fid["data"]["data_fixations.hdf5"])
    close(fid)

    evts = DataFrame(CSV.File("data/events.csv"))
    evts_d = CSV.read("data/evts_d.csv", DataFrame)
end

# erps (128 channels, 769 mseconds, 2508 trials) - voltage
# evts (2508 trials, 21 sorting variables) - parameters which can influence voltage
# evts_d (128 channels, 21 sorting variables) - d/entropy image

inter_heatmap(evts_d)

inter_heatmap_image(evts_d, evts, erps)

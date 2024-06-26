module ERPgnostics

using UnfoldMakie
using Unfold
using CSV, DataFrames
using Random, Format
using CairoMakie
using Statistics, StatsBase
using HDF5, FileIO
using Printf
using Images
using TopoPlots 
using ImageFiltering
using ComputationalResources
using Observables
using DSP
using JLD2

include("heatmap.jl")
include("topoplots.jl")
include("mean_filter.jl")
include("pattern_detection.jl")

export inter_topo
export inter_topo_image

export inter_heatmap
export inter_heatmap_image

export mult_chan_pattern_detector_probability
end

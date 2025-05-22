module ERPgnostics

using UnfoldMakie
using Unfold
using UnfoldSim
using CSV, DataFrames
using Random
using CairoMakie
using Statistics, StatsBase, Distributions
using HDF5, FileIO
using Printf
using Images
using TopoPlots
using ImageFiltering
using ComputationalResources
using Observables
using DSP
using JLD2
using ProgressBars

include("configs.jl")
include("interactive_heatmap.jl")
include("interactive_topoplots.jl")
include("pattern_detection.jl")
include("pattern_simulation.jl")
include("example_data.jl")
include("filters.jl")

export inter_toposeries # or better toposeries_inter
export inter_toposeries_image

export inter_heatmap
export inter_heatmap_image


export simulate_6patterns

export pattern_detector
export complex_pattern_detector

export slow_filter
export mean_filter
export example_data
end

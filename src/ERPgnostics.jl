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
using WGLMakie
using Revise
using ProgressBars

include("interactive_heatmap.jl")
include("interactive_topoplots.jl")
include("pattern_detection_mean_filter.jl")
include("pattern_detection_probability.jl")
include("pattern_simulation.jl")

export inter_toposeries # or better toposeries_inter
export inter_toposeries_image

export inter_heatmap
export inter_heatmap_image

export mult_chan_pattern_detector_probability
export mult_chan_pattern_detector_probability_meanfilter

export simulate_6patterns
end

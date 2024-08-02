module ERPgnostics

using UnfoldMakie
using Unfold
using UnfoldSim
using CSV, DataFrames
using Random, Format
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
using WGLMakie, GLMakie
using Revise
using ProgressBars

include("heatmap.jl")
include("topoplots.jl")
include("mean_filter.jl")
include("pattern_detection.jl")
include("pattern_generation.jl")

export inter_topo
export inter_topo_image

export inter_heatmap
export inter_heatmap_image

export mult_chan_pattern_detector_probability

export simulate_alldata
end

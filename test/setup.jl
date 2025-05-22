using ERPgnostics
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

using Test
path = dirname(Base.current_project())
CairoMakie.activate!() # for static images
#include("../docs/example_data.jl")

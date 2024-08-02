begin
	using Pkg
    Pkg.activate(".")
	Pkg.status()
	ENV["JULIA_DEBUG"] = "Main"
end

begin 
	#using PyMNE
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
	using WGLMakie
	using Revise
	using ProgressBars
end

# add dev /store/users/mikheev/projects/unfold_dev/dev/UnfoldMakie
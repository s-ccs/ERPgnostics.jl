begin
	using Pkg
    Pkg.activate(".")
	Pkg.status()
end

begin 
	#using PyMNE
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
	using WGLMakie
	using Revise
end

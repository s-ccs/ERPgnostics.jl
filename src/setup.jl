begin
	using Pkg
	Pkg.activate("/home/mikheev/Desktop/ERPgnostics")
	Pkg.status()
end

begin 
	using PyMNE
	using UnfoldMakie
	using Unfold
	using CSV, DataFrames
	using Random, Format
	using CairoMakie
	using Statistics, StatsBase
	using HDF5, FileIO
	using Printf
	using Images
end

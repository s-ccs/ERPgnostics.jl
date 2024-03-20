### A Pluto.jl notebook ###
# v0.19.40

using Markdown
using InteractiveUtils

# ╔═╡ 6183ce40-24bd-4485-9dfa-7b4473a4edaa
begin
    using Pkg
    Pkg.activate("/home/mikheev/Desktop/ERPgnostics")
    Pkg.status()
end

# ╔═╡ e8da0d72-cbf6-11ee-1eb1-bbeb64e86729
begin
    using CairoMakie
    using UnfoldMakie
    using UnfoldSim
    using Unfold
    using Statistics
    using Random
    using Images
    using Distributions

    import UnfoldSim.simulate_component
    import Base: length
end

# ╔═╡ 800822b9-4cf8-4c5d-a829-11798d8d581a
md"""
Here we want to plot the following patterns in ONE data set:
1. Sigmoid (missing)
2. Vertical band (?)
3. Horizontal band
4. Abline band
5. One-sided fan
6. Two-sided fan
7. Linear effect (hourglass with diverging colors)
8. Linear effect (bar with diverging colors)
"""

# ╔═╡ cdb771b6-35d1-4c2c-a37f-be8459dc2814
md"""
## Simulating functions
"""

# ╔═╡ 2cde7e6f-9c89-48c8-addb-519d5a970bfb


# ╔═╡ c01cca96-22cd-4758-af2b-b21fa8dec44c
md"""
## Plotting
"""

# ╔═╡ 4012631a-816f-4c61-ae22-ac867c49cfb4
md"""
## Exploring
"""

# ╔═╡ b7fa3bf1-ef01-46b3-96b3-05651d495ed0
struct TimeVaryingComponent <: AbstractComponent
    basisfunction::Any
    maxlength::Any
    beta::Any
end

# ╔═╡ df21adf1-9fd2-4085-94fb-7629c1e79873
Base.length(c::TimeVaryingComponent) = c.maxlength


# ╔═╡ 2d5ffccd-61bb-446b-b2a5-fd0c39075ed3
begin
    # this is for ab-line /
    function basis_linear(evts, maxlength)
        basis =
            pad_array.(Ref(UnfoldSim.DSP.hanning(50)), Int.(0 .- evts.duration_linear), 0)
        return basis
    end

    # this is for the asymetrical fan |/
    function basis_lognormal(evts, maxlength)
        basis =
            pdf.(
                LogNormal.(evts.duration ./ 40 .- 0.2, 1),
                Ref(range(0, 10, length = maxlength)),
            )
        basis = basis ./ maximum.(basis)
        return basis
    end

    # this is for the symmetrical fan \/
    function basis_hanning(evts, maxlength)
        if "durationB" ∈ names(evts)
            fn = "durationB"
            @info fn
        else
            fn = "duration"
        end
        maxdur = maximum(evts[:, fn])

        basis = UnfoldSim.DSP.hanning.(Int.(round.(evts[:, fn])))
        basis = pad_array.(basis, Int.(.-round.(maxdur .- evts[:, fn]) .÷ 2), 0) ## shift by adding 0 
        return basis
    end

    function truncate_basisfunction(basis, maxlength)
        # we should make sure that all bases have maxlength by appending / truncating
        difftomax = maxlength .- length.(basis)
        if any(difftomax .< 0)
            @warn "Basis longer than maxlength in at least one case. either increase maxlength or redefine function. Attempt to truncate the basis"
            basis[difftomax.>0] =
                pad_array.(basis[difftomax.>0], difftomax[difftomax.>0], 0)
            basis = [b[1:maxlength] for b in basis]
        else
            basis = pad_array.(basis, difftomax, 0)
        end
        return reduce(hcat, basis)
    end
end

# ╔═╡ cec679f9-62e9-49c4-a3b3-fbfcbdadb221
function simulate_alldata()
    design = SingleSubjectDesign(;
        conditions = Dict(
            :condition => ["car", "face"],
            :continuous => range(-2, 2, length = 8),
            :duration => range(20, 100, length = 8),
            :durationB => range(10, 30, length = 8),
            :duration_linear => range(5, 40, length = 8),
        ),
        event_order_function = x -> shuffle(MersenneTwister(1), x),
    )

    p1 = LinearModelComponent(; basis = p100(), formula = @formula(0 ~ 1), β = [5])

    n1 = LinearModelComponent(;
        basis = n170(),
        formula = @formula(0 ~ 1 + condition + continuous),
        β = [5, 3, 2],
    )

    p3 = LinearModelComponent(; basis = p300(), formula = @formula(0 ~ 1), β = [5])
    componentA = TimeVaryingComponent(basis_lognormal, 100, 5)
    componentB = TimeVaryingComponent(basis_hanning, 100, -10)
    componentC = TimeVaryingComponent(basis_linear, 100, 5)

    data, evts = simulate(
        MersenneTwister(1),
        design,
        [p1, n1, p3, componentA, componentB, componentC],
        LogNormalOnset(; μ = 3.2, σ = 0.5),#UniformOnset(; width = 30, offset = 30),
        PinkNoise(),
        return_epoched = true,
    )
    evts.Δlatency = vcat(diff(evts.latency), 0) # divide time on epochs
    data = data .- mean(data, dims = 2) # normalisation
    return data, evts
    #@info UnfoldSim.simulate_component(MersenneTwister(1),componentC,design)
end

# ╔═╡ 99343eb8-1a85-4481-9d82-fa5a9993e3ca
let
    dat, evts = simulate_alldata()
    @info size(dat)
    f = Figure(size = (800, 1200))
    plot_erpimage!(
        f[end+1, 1],
        dat;
        sortvalues = evts.Δlatency,
        axis = (; title = "Sigmoid; sorted by Δlatency"),
    )
    plot_erpimage!(
        f[end+1, 1],
        dat;
        sortvalues = evts.duration,
        axis = (; title = "One-sided fan; sorted by duration"),
    )
    plot_erpimage!(
        f[end+1, 1],
        dat;
        sortvalues = evts.durationB,
        axis = (; title = "Two-sided fan; sorted by durationB"),
    )
    plot_erpimage!(
        f[end+1, 1],
        dat;
        sortvalues = evts.condition .== "car",
        axis = (; title = "Diverging bar; sorted by iscar"),
    )
    plot_erpimage!(
        f[end+1, 1],
        dat;
        sortvalues = evts.continuous,
        axis = (; title = "Hourglass bar; sorted by continuous"),
    )
    plot_erpimage!(
        f[end+1, 1],
        dat;
        sortvalues = evts.duration_linear,
        axis = (; title = "Abline; sorted by duration_linear"),
    )
    f
end

# ╔═╡ 975cd239-bd7f-47f9-8478-42d9ce9dd5e7
function UnfoldSim.simulate_component(rng, c::TimeVaryingComponent, design::AbstractDesign)

    evts = generate_events(design)

    data = c.beta .* c.basisfunction(evts, c.maxlength)
    return truncate_basisfunction(data, c.maxlength)

end

# ╔═╡ 054516fd-7eae-4d0b-a4f5-51a4ff168fcc
let
    r = range(20, 100, length = 7) ./ 40 .- 0.2
    x = hcat(pdf.(LogNormal.(r, 1), Ref(range(0, 100, length = 50)))...)
    x = x ./ maximum(x, dims = 1)
    series(x')
end

# ╔═╡ Cell order:
# ╠═6183ce40-24bd-4485-9dfa-7b4473a4edaa
# ╠═e8da0d72-cbf6-11ee-1eb1-bbeb64e86729
# ╟─800822b9-4cf8-4c5d-a829-11798d8d581a
# ╟─cdb771b6-35d1-4c2c-a37f-be8459dc2814
# ╠═cec679f9-62e9-49c4-a3b3-fbfcbdadb221
# ╠═2cde7e6f-9c89-48c8-addb-519d5a970bfb
# ╟─c01cca96-22cd-4758-af2b-b21fa8dec44c
# ╠═99343eb8-1a85-4481-9d82-fa5a9993e3ca
# ╟─4012631a-816f-4c61-ae22-ac867c49cfb4
# ╠═2d5ffccd-61bb-446b-b2a5-fd0c39075ed3
# ╠═975cd239-bd7f-47f9-8478-42d9ce9dd5e7
# ╠═b7fa3bf1-ef01-46b3-96b3-05651d495ed0
# ╠═df21adf1-9fd2-4085-94fb-7629c1e79873
# ╠═054516fd-7eae-4d0b-a4f5-51a4ff168fcc

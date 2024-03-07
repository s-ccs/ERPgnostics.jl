### A Pluto.jl notebook ###
# v0.19.37

using Markdown
using InteractiveUtils

# ╔═╡ 601cde91-e0fe-4d59-92aa-bcfb740932cd
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
We aimed to plot the following patterns
- sigmoid
- vertical band
- horizontal band
- vertical fan
- abline band
- linear effect (hourglass with diverging colors)
- linear effect (bar with diverging colors)
"""

# ╔═╡ 5e6ff4bd-14e8-4d4f-a872-76c26371b36f
begin
    dat, evts =
        UnfoldSim.predef_eeg(; onset = LogNormalOnset(μ = 3.5, σ = 0.4), noiselevel = 5) # create a potential
    dat_e, times = Unfold.epoch(dat, evts, [-0.1, 1], 100) # divide data on trials
    evts, dat_e = Unfold.dropMissingEpochs(evts, dat_e)
    evts.Δlatency = vcat(0, diff(evts.latency)) # divide time on epochs
    dat_e = dat_e[1, :, :] # array to matrix
    dat_norm = dat_e[:, :] .- mean(dat_e, dims = 2) # normalisation
    evts = filter(row -> row.Δlatency > 0, evts)

end

# ╔═╡ a039daeb-4c04-4551-94e5-417bc2342a9a
md"""
## Sigmoid
"""

# ╔═╡ 2ac0e909-c466-408b-8ce8-1f90ae902895
begin
    f = Figure()
    plot_erpimage!(f[1, 1], times, dat_norm; axis = (; title = "Not sorted"))
    plot_erpimage!(
        f[2, 1],
        times,
        dat_norm;
        sortvalues = evts.Δlatency,
        axis = (; title = "Sorted by latency duration"),
    )
    f
end

# ╔═╡ cdb771b6-35d1-4c2c-a37f-be8459dc2814
md"""
## Fans
"""

# ╔═╡ 1275b62e-8712-48bc-8fe3-828ec50c032a
md"""
### One-sided fan
"""

# ╔═╡ 4b7d5400-dcbf-4243-9eae-df73e8d9e67c
md"""
### Two-sided fan
"""

# ╔═╡ 179956f6-6d33-4dd3-88c8-205f997616c9
md"""
## Linear effects
"""

# ╔═╡ 727d0a91-0386-4a90-b465-50a31e87989e
plot_erpimage(
    times,
    dat_norm;
    sortvalues = evts.continuous,
    axis = (; title = "Linear effect Sorted by latency duration"),
)

# ╔═╡ 1201094c-b571-4cd2-b8e8-28a361afd76e
md"""
## Library of patterns
"""

# ╔═╡ 4012631a-816f-4c61-ae22-ac867c49cfb4
md"""
## Exploring
"""

# ╔═╡ 936b7db7-66f3-4c8b-9c54-9dc07c83f209
function explore_pattern(a, b)

    dat1, evts1 = simulate_data()
    dat_e1, times1 = Unfold.epoch(dat1, evts1, [-0.1, 1], 100) # divide data on trials
    evts1, dat_e1 = Unfold.dropMissingEpochs(evts1, dat_e1)
    evts1.Δlatency = vcat(diff(evts1.latency), 0) # divide time on epochs
    dat_e1 = dat_e1[1, :, :] # array to matrix
    dat_norm1 = dat_e1[:, :] .- mean(dat_e1, dims = 2) # normalisation
    field = :Δlatency
    field = :duration

    f = Figure()
    plot_erpimage!(f[1, 1], times1, dat_e1; axis = (; title = "Not sorted"))
    plot_erpimage!(
        f[2, 1],
        times1,
        dat_e1;
        sortvalues = evts1[!, field],
        axis = (; title = "Sorted by latency duration"),
    )
    plot_erpimage!(f[1, 2], times1, dat_norm1; axis = (; title = "Normalised, not sorted"))
    plot_erpimage!(
        f[2, 2],
        times1,
        dat_norm1;
        sortvalues = evts1[!, field],
        axis = (; title = "Normalised, sorted by latency duration"),
    )
    return f
end

# ╔═╡ c868bafc-9c86-4882-9502-d062f435e689
explore_pattern(3.5, 0.4)

# ╔═╡ b7fa3bf1-ef01-46b3-96b3-05651d495ed0
struct TimeVaryingComponent <: AbstractComponent
    basisfunction::Any
    maxlength::Any
end

# ╔═╡ df21adf1-9fd2-4085-94fb-7629c1e79873
Base.length(c::TimeVaryingComponent) = c.maxlength


# ╔═╡ 2d5ffccd-61bb-446b-b2a5-fd0c39075ed3
begin
    # this is for the asymetrical fan |/
    function basis_lognormal(evts, maxlength)
        basis =
            pdf.(
                LogNormal.(evts.duration ./ 100 .- 0.2, 1),
                Ref(range(0, 10, length = maxlength)),
            )
        basis = basis ./ maximum.(basis)
        return basis
    end

    # this is for the symmetrical fan \/
    function basis_hanning(evts, maxlength)
        maxdur = maximum(evts.duration)

        basis = UnfoldSim.DSP.hanning.(Int.(round.(evts.duration)))
        basis = pad_array.(basis, Int.(.-round.(maxdur .- evts.duration) .÷ 2), 0) ## shift by adding 0 
        return basis
    end

    function truncate_basisfunction(basis, maxlength)
        # we should make sure that all bases have maxlength by appending / truncating
        difftomax = maxlength .- length.(basis)
        if any(difftomax .< 0)
            @warn "basis longer than max length in at least one case. either increase maxlength or redefine function. Trying to truncate the basis"
            basis[difftomax.>0] =
                pad_array.(basis[difftomax.>0], difftomax[difftomax.>0], 0)
            basis = [b[1:maxlength] for b in basis]
        else
            basis = pad_array.(basis, difftomax, 0)
        end

        return reduce(hcat, basis)
    end
end

# ╔═╡ f06ad211-2131-413c-bd27-15f792af3060
function simulate_fandata(; n_sides = 1)
    design =
        SingleSubjectDesign(;
            conditions = Dict(
                :condition => ["car", "face"],
                :duration => range(20, 100, length = 10),
            ),
        ) |> x -> RepeatDesign(x, 100)

    p1 = LinearModelComponent(; basis = p100(), formula = @formula(0 ~ 1), β = [5])

    n1 = LinearModelComponent(;
        basis = n170(),
        formula = @formula(0 ~ 1 + condition),
        β = [5, 3],
    )

    p3 = LinearModelComponent(;
        basis = p300(),
        formula = @formula(0 ~ 1 + duration + duration^2),
        β = [5, 1, 0.2],
    )
    if n_sides == 1
        component = TimeVaryingComponent(basis_lognormal, 500)
    else
        component = TimeVaryingComponent(basis_hanning, 500)
    end

    data, evts = simulate(
        MersenneTwister(1),
        design,
        component,
        UniformOnset(; width = 50, offset = 1000),
        PinkNoise(),
    )
end

# ╔═╡ 3a233c16-4ed9-4d27-adab-d1e4363f468e
begin
    dat1, evts1 = simulate_fandata(n_sides = 1;)
    dat_e1, times1 = Unfold.epoch(dat1, evts1, [-0.1, 1], 100) # divide data on trials
    evts1, dat_e1 = Unfold.dropMissingEpochs(evts1, dat_e1)
    dat_e1 = dat_e1[1, :, :] # array to matrix
    dat_norm1 = dat_e1[:, :] .- mean(dat_e1, dims = 2) # normalisation
    f2 = Figure()
    plot_erpimage!(f2[1, 1], times1, dat_e1; axis = (; title = "Not sorted"))
    plot_erpimage!(
        f2[2, 1],
        times1,
        dat_e1;
        sortvalues = evts1[!, :duration],
        axis = (; title = "Sorted by latency duration"),
    )
    f2
end

# ╔═╡ 2456f32a-b86d-41df-a56b-4ec2215f071e
begin
    dat3, evts3 = simulate_fandata(n_sides = 2)
    dat_e3, times3 = Unfold.epoch(dat3, evts3, [-0.1, 1], 100) # divide data on trials
    evts3, dat_e3 = Unfold.dropMissingEpochs(evts3, dat_e3)
    dat_e3 = dat_e3[1, :, :] # array to matrix
    dat_norm3 = dat_e3[:, :] .- mean(dat_e3, dims = 2) # normalisation
    f3 = Figure()
    plot_erpimage!(f3[1, 1], times3, dat_e3; axis = (; title = "Not sorted"))
    plot_erpimage!(
        f3[2, 1],
        times3,
        dat_e3;
        sortvalues = evts3[!, :duration],
        axis = (; title = "Sorted by latency duration"),
    )
    f3
end

# ╔═╡ 9b507972-429e-48f4-b11f-b54b56743308
begin
    f_g = Figure()
    plot_erpimage!(
        f_g[1, 1],
        times,
        dat_norm;
        sortvalues = evts.Δlatency,
        axis = (; title = "Sigmoid"),
    )
    plot_erpimage!(
        f_g[2, 1],
        times1,
        dat_e1;
        sortvalues = evts1[!, :duration],
        axis = (; title = "One-sided fan"),
    )
    plot_erpimage!(
        f_g[1, 2],
        times3,
        dat_e3;
        sortvalues = evts3[!, :duration],
        axis = (; title = "Two-sided fan"),
    )
    f_g
end

# ╔═╡ 975cd239-bd7f-47f9-8478-42d9ce9dd5e7
function UnfoldSim.simulate_component(rng, c::TimeVaryingComponent, design::AbstractDesign)

    evts = generate_events(design)

    data = 5 .* c.basisfunction(evts, c.maxlength)
    return truncate_basisfunction(data, c.maxlength)

end

# ╔═╡ 054516fd-7eae-4d0b-a4f5-51a4ff168fcc
series(
    hcat(
        pdf.(
            LogNormal.(range(20, 100, length = 7) ./ 100 .- 0.2, 1),
            Ref(range(0, 10, length = 50)),
        )...,
    )',
)

# ╔═╡ aea0cd23-0ec0-4803-97c9-ae316582010b


# ╔═╡ Cell order:
# ╠═601cde91-e0fe-4d59-92aa-bcfb740932cd
# ╠═e8da0d72-cbf6-11ee-1eb1-bbeb64e86729
# ╟─800822b9-4cf8-4c5d-a829-11798d8d581a
# ╠═5e6ff4bd-14e8-4d4f-a872-76c26371b36f
# ╟─a039daeb-4c04-4551-94e5-417bc2342a9a
# ╠═2ac0e909-c466-408b-8ce8-1f90ae902895
# ╟─cdb771b6-35d1-4c2c-a37f-be8459dc2814
# ╠═f06ad211-2131-413c-bd27-15f792af3060
# ╠═2d5ffccd-61bb-446b-b2a5-fd0c39075ed3
# ╟─1275b62e-8712-48bc-8fe3-828ec50c032a
# ╠═3a233c16-4ed9-4d27-adab-d1e4363f468e
# ╟─4b7d5400-dcbf-4243-9eae-df73e8d9e67c
# ╠═2456f32a-b86d-41df-a56b-4ec2215f071e
# ╟─179956f6-6d33-4dd3-88c8-205f997616c9
# ╠═727d0a91-0386-4a90-b465-50a31e87989e
# ╟─1201094c-b571-4cd2-b8e8-28a361afd76e
# ╠═9b507972-429e-48f4-b11f-b54b56743308
# ╟─4012631a-816f-4c61-ae22-ac867c49cfb4
# ╠═936b7db7-66f3-4c8b-9c54-9dc07c83f209
# ╠═c868bafc-9c86-4882-9502-d062f435e689
# ╠═975cd239-bd7f-47f9-8478-42d9ce9dd5e7
# ╠═b7fa3bf1-ef01-46b3-96b3-05651d495ed0
# ╠═df21adf1-9fd2-4085-94fb-7629c1e79873
# ╠═054516fd-7eae-4d0b-a4f5-51a4ff168fcc
# ╠═aea0cd23-0ec0-4803-97c9-ae316582010b


import UnfoldSim.simulate_component
import Base: length

struct TimeVaryingComponent <: AbstractComponent
    basisfunction::Any
    maxlength::Any
    beta::Any
end

Base.length(c::TimeVaryingComponent) = c.maxlength

# this is for abline /
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

function UnfoldSim.simulate_component(rng, c::TimeVaryingComponent, design::AbstractDesign)

    evts = generate_events(design)

    data = c.beta .* c.basisfunction(evts, c.maxlength)
    return truncate_basisfunction(data, c.maxlength)

end
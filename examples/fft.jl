
using FFTW
data_all, evts = simulate_6patterns()

plot_erpimage(data_all)
plot_erpimage(data_all; erpblur=51)
plot_erpimage(data_all; erpblur=51, sortvalues=evts.Δlatency)



data_all[:, sortperm(evts.Δlatency)]


# Assuming data_all is a 2D real array (e.g., from an image or spatial data)


function plot_fft_entropy(data_all; evt=nothing, dx=1.0, dy=1.0)
    # Size of the input data
    #Ny, Nx = size(data_all)

    #dx, dy = 1 / Nx, 1 / Ny  # You can adjust these based on physical spacing if known

    if evt === nothing
        print("no")
        sorted_data = data_all
    else
        print("sort")
        sorted_indices = sortperm(evt)
        sorted_data = data_all[:, sorted_indices]
    end

    entropy, std_spectrum, energy_concentration_ratio = pattern_metrics(slow_filter(sorted_data))
    # Create figure
    fig = Figure(size = (900, 420))  
    #Label(fig[0, 1:2], "2D Fourier Spectrum (Spectral Entropy = $(entropy))"; 
     #   fontsize = 24, halign = :center)

    # Frequency axes
    fx = fftshift(fftfreq(Nx, 1 / dx))
    fy = fftshift(fftfreq(Ny, 1 / dy))

    # Original data (left) with ERP image
    plot_erpimage!(
        fig[1:6, 1], data_all;
        sortvalues = evt === nothing ? nothing : evt,
        erpblur = 51,
        axis = (; title = "Original 2D Data")
    )

    # FFT magnitude (right)
    ax2 = CairoMakie.Axis(fig[1:6, 2], title = "2D Spectrum (Magnitude)")
    heatmap!(ax2, fx, fy, log.(100 .+ abs.(F2)); colormap = :viridis)

    ax_metrics = CairoMakie.Axis(fig[7, :], title = "Pattern Metrics")
    text!(
        ax_metrics, 1, 0.5,
        text = "Entropy: $(entropy)    |    Spectrum Std: $(std_spectrum)    |    Energy Ratio: $(energy_concentration_ratio)",
        align = (:center, :center),
        fontsize = 18  # optional
    )
    hidedecorations!(ax_metrics)
    return fig
end

plot_fft_entropy(data_all; dx=1.0, dy=1.0)
plot_fft_entropy(data_all; evt = evts.duration, dx=1.0, dy=1.0)
plot_fft_entropy(data_all, evt = evts.Δlatency; dx=1.0, dy=1.0)


begin
    F = fft(data_all)             # 1D or 2D FFT
    P = abs.(F)
    P ./= sum(P)              # Normalize to sum to 1
    P .+= eps()               # Avoid log(0)
    entropy = -sum(P .* log.(P))
end

begin
    F = fft(data_all[:, sortperm(evts.Δlatency)])             # 1D or 2D FFT
    P = abs.(F)
    P ./= sum(P)              # Normalize to sum to 1
    P .+= eps()               # Avoid log(0)
    entropy = -sum(P .* log.(P))
end





function pattern_metrics(data)
    F = abs.(fftshift(fft(data)))
    P = F[:] ./ sum(F) .+ eps()  # normalize & avoid log(0)
    entropy = -sum(P .* log.(P))  # Shannon entropy
    std_spectrum = std(abs.(fft(data))[:])

    total_energy = sum(F)
    top_energy = sum(sort(F[:], rev=true)[1:10])  # top 10 values
    energy_concentration_ratio = top_energy / total_energy  # higher = more structured
    return round.((entropy, std_spectrum, energy_concentration_ratio); sigdigits = 6)
end
pattern_metrics(data_all)
pattern_metrics(data_all[:, sortperm(evts.Δlatency)])
pattern_metrics(data_all[:, sortperm(evts.continuous)])
pattern_metrics(data_all[:, sortperm(evts.condition)])
pattern_metrics(data_all[:, sortperm(evts.duration_linear)])




pattern_metrics(slow_filter(data_all))
pattern_metrics(slow_filter(data_all[:, sortperm(evts.Δlatency)]))
pattern_metrics(slow_filter(data_all[:, sortperm(evts.continuous)]))
pattern_metrics(slow_filter(data_all[:, sortperm(evts.condition)]))
pattern_metrics(slow_filter(data_all[:, sortperm(evts.duration_linear)]))
########################

function spectral_entropy(data)
    F = abs.(fftshift(fft(data)))
    P = F[:] ./ sum(F) .+ eps()  # normalize & avoid log(0)
    entropy = -sum(P .* log.(P))  # Shannon entropy
    return round(entropy; sigdigits = 6)
end

two_channels = JLD2.load_object("../data/channels_1_123.jld2")
evts = DataFrame(CSV.File("../data/events.csv"))
sort_values = evts[:, [:duration, :onset]]
@time detector_value = complex_pattern_detector(two_channels, evts, slow_filter, spectral_entropy)


fid = h5open("/store/users/mikheev/projects/erpgnostics_dev/dev/ERPgnostics/data/data_fixations.hdf5", "r")
erps_fix = read(fid["data"]["data_fixations.hdf5"])
close(fid)

erps_reordered = permutedims(erps_fix, (2, 3, 1))
@time detector_value_long = complex_pattern_detector(erps_reordered, evts, slow_filter, spectral_entropy)
detector_value_long.channel = 1:nrow(detector_value_long)
pattern_detection_values = stack(detector_value_long)
rename!(pattern_detection_values, :variable => :condition, :value => :estimate)
JLD2.save_object("../data/pattern_detection_values_fft.jld2", pattern_detection_values)

size(erps_reordered)
size(evts)
positions_128 = JLD2.load_object("../data/positions_128.jld2")



inter_toposeries_image(
    pattern_detection_values,
    evts,
    erps_fix,
    1:769;
    positions = positions_128,
    figure_configs = (; size = (1500, 700)),
)

WGLMakie.activate!() 
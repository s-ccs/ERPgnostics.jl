# ERPgnostics Highlights

ERPgnostics is a great tool for exploring large EEG datasets with lots of experimental variables.

- **EEG Data Overview.** ERPgnostics lets you interactively explore EEG data through topoplot series and ERP images. By clicking on markers in the topoplot, you can easily select experimental variables and electrodes. The corresponding ERP image will appear, with trials sorted by the chosen variable. The color in the ERP image shows the voltage over time, giving you a clear view of how the electrical activity changes for selected electrode.

- **Pattern Detection.** Sorting trials in the ERP images can reveal interesting associations between experimental variables and ERP components. These associations may show up as patterns, like sigmoidal or fan-shaped trends. The color in the topoplots represents the probability of observing such patterns in the ERP image. This is incredibly helpful, as manually finding these patterns would be time-consuming and tricky.


## Usage

If you want just static image activate CairoMakie. 
```julia-repl
julia> using Pkg; Pkg.add("CairoMakie")
julia> using CairoMakie
julia> CairoMakie.activate!()
```

For interactive plots use and activate GLMakie.
```julia-repl
julia> using Pkg; Pkg.add("GLMakie")
julia> using GLMakie
julia> GLMakie.activate!()
```
In this documentation we use CairoMakie, because GLMakie requires a graphical environment, so it will not work on headless systems like GitHub Actions without a display server.

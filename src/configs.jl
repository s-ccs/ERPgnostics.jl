
"""
    supportive_defaults(cfg_symb::Symbol)

Default configurations for the supporting axis. Similar to PlotConfig, but these configurations are not shared by all plots.\\
Such supporting axes allow users to flexibly see defaults in docstrings and manipulate them using corresponding axes.
    
For developers: to make them updateable in the function, use `update_axis`.
**Return value:** `NamedTuple`.
"""
function supportive_defaults(cfg_symb::Symbol)
    # plot_splines
    if cfg_symb == :toposeries_default
        return (;
            nrows = 1,
            mapping = (; col = :condition),
            axis = (; xlabel = "Conditions", xlabelvisible = false),
            visual = (
                label_scatter = (markersize = 10, strokewidth = 2),
                contours = (; levels = 0),
                colormap = Reverse(:RdGy_4),
            ),
            colorbar = (;
                label = "Pattern detection function value",
                height = 300,
            ),
            layout = (; use_colorbar = true),
        )
    elseif cfg_symb == :erpimage_defaults
        return (; show_sortval = true, meanplot = true, axis = (; title = "ERP image"))
    end
end

"""
    update_axis(support_axis::NamedTuple; kwargs...)
Update values of `NamedTuple{key = value}`.\\
Used for supportive axes to make users be able to flexibly change them.
"""
function update_axis(support_axis::NamedTuple; kwargs...)
    support_axis = (; support_axis..., kwargs...)
    return support_axis
end

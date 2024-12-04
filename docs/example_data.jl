using UnfoldSim
using TopoPlots
using Unfold
using Random
using CSV

"""
    example_data(String) 

Creates example data. Currently, 1 dataset is available.

Datasets:
- `pattern_detection_values` (default) - Dataframe with 2 fields:\\
    sorting conditions, estimate (pattern detection values).\\


**Return Value:** `DataFrame`.
"""
function example_data(example = "pattern_detection_values"; mode = 1)
    if mode == 1
        datapath = dirname(dirname(Base.current_project())) * "/data/evts_d.csv"
    else
        datapath = dirname(Base.current_project()) * "/data/evts_d.csv"
    end
    if example == "pattern_detection_values"
        evts_d = CSV.read(datapath, DataFrame)
        pattern_detection_values = stack(evts_d)
        rename!(pattern_detection_values, :variable => :condition, :value => :estimate)
        evts_d = nothing
        return pattern_detection_values
    elseif example == "pattern_detection_values_32"
        evts_d = CSV.read(datapath, DataFrame)
        pattern_detection_values = stack(evts_d[1:32, :])
        rename!(pattern_detection_values, :variable => :condition, :value => :estimate)
        evts_d = nothing
        return pattern_detection_values
    else
        error("unknown example data")
    end
end

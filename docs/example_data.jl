using UnfoldSim
using TopoPlots
using Unfold
using Random
using CSV

"""
    example_data(String) 

Creates example data or model. Currently, 3 datasets and 6 models are available.

Datasets:
- `pattern_detection_values` (default) - Dataframe with 5 fields:\\
    sorting conditions, estimate (pattern detection values) lables, timing, rows.\\


**Return Value:** `DataFrame`.
"""
function example_data(example = "pattern_detection_values")
    if example == "pattern_detection_values"
        datapath = dirname(dirname(Base.current_project())) * "/data/evts_d.csv"
        evts_d = CSV.read(datapath, DataFrame)
        pattern_detection_values = stack(evts_d)
        rename!(pattern_detection_values, :variable => :condition, :value => :estimate)
        evts_d = nothing
        return pattern_detection_values
    else
        error("unknown example data")
    end
end

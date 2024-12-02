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
        pattern_detection_values.timing = 1:nrow(pattern_detection_values)
        pattern_detection_values.label = 1:nrow(pattern_detection_values)
        rename!(pattern_detection_values, :variable => :condition, :value => :estimate)
        pattern_detection_values.rows = vcat(
            repeat(["A"], size(pattern_detection_values, 1) ÷ 4),
            repeat(["B"], size(pattern_detection_values, 1) ÷ 4),
            repeat(["C"], size(pattern_detection_values, 1) ÷ 4),
            repeat(["D"], size(pattern_detection_values, 1) ÷ 4),
        )
        return pattern_detection_values
    else
        error("unknown example data")
    end
end

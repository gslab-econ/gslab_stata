version 12
set more off
adopath + ../ado
adopath + ../external/lib/stata/gslab_misc/ado
preliminaries

program main
    quietly prepare_figures_data, sen_file(../data/sensitivity_matrix.tsv)          ///
                                  stsen_file(../data/standardized_sensitivity_matrix.tsv) ///
                                  param_file(../data/param_data_nw2013.dta)         ///
                                  mom_file(../data/mom_data_nw2013.dta)             ///
                                  out_file(../data/figures_data.dta)                ///
                                  mom_type_order(real financial incentive)

    testgood test_graph_params
end

program test_graph_params
    quietly use ../data/figures_data.dta, clear

    quietly ds *_sen
    local all_vars = "`r(varlist)'"
    local param_list = subinstr("`all_vars'", "_sen", "", .)

    foreach param in `param_list' {
        quietly graph_param_default, param("`param'")
        quietly graph_param_changes, param("`param'")
    }
    
    quietly erase ../data/figures_data.dta
end
    
    program graph_param_default
        syntax, param(string)
        
        prepare_param_sensitivity, param("`param'")
        
        graph_param_sensitivity, param("`param'") ///
                                 mom_type_order(real financial incentive) ///
                                 legend_opts(`"order(1 "Real" 2 "Financial" 3 "Incentive") size(vsmall) rows(1)"')
    end
    
    program graph_param_changes
        syntax, param(string)
        
        prepare_param_sensitivity, param("`param'")
        
        get_trans_graph_defaults, param("`param'")
        local bar_opts = "`r(bar_opts)' fintensity(100)"
        
        graph_param_sensitivity, param("`param'") ///
                                 mom_type_order(real financial incentive) ///
                                 legend_opts(`"order(1 "Real" 2 "Financial" 3 "Incentive") size(vsmall) rows(1)"') ///
                                 bar_opts("`bar_opts'")
    end    

* EXECUTE
main

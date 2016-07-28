version 12
set more off
adopath + ../ado
adopath + ../external/lib/stata/gslab_misc/ado
preliminaries

program main
     testgood test_prepare_figures_data
end

program test_prepare_figures_data
    quietly use ../data/figures_data_compare.dta
    
    quietly describe *
    local nvars = `r(k)'
    local nobs  = _N
    
    local descra_compare = descra
    local keya_compare   = keya    

    quietly prepare_figures_data, sen_file(../data/sensitivity_matrix.tsv)          ///
                                  stsen_file(../data/standardized_sensitivity_matrix.tsv) ///
                                  param_file(../data/param_data_nw2013.dta)         ///
                                  mom_file(../data/mom_data_nw2013.dta)             ///
                                  out_file(../data/figures_data.dta)                ///
                                  mom_type_order(real financial incentive)
    
    quietly use ../data/figures_data.dta, replace
    
    quietly describe *
    assert `r(k)' == `nvars'
    assert _N     == `nobs'
    
    local descra_new = descra
    local keya_new   = keya
    
    assert "`descra_new'" == "`descra_compare'"
    assert "`keya_new'"   == "`keya_compare'"
    
    quietly clear
    quietly erase ../data/figures_data.dta
end

* EXECUTE
main

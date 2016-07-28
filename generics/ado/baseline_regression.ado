***********************************************************************************
*
* BASELINE_REGRESSION.ADO
*
* Performs regression by each group of variables defined by the user 
* and write the regression results to file.
*
***********************************************************************************

program baseline_regression
    version 13
    
    syntax, in_file(str) out_file(str) group_id(str) indep_vars(str) ///
        generic_ind(str) hh_demos(str) analytic_weight(str) main_fixed_effect(str) ///
        [ mean_var(str) condition_var(str) vce_cluster(str) ]
    
    file open regression_coefficients using `out_file', replace write
    file write regression_coefficients "`group_id'" _tab "df" _tab
    foreach iv of local indep_vars {
        file write regression_coefficients "mean_`iv'" _tab "coef_`iv'" _tab "se_`iv'" _tab
    }
    if "`mean_var'"~="" & "`condition_var'"~="" {
        file write regression_coefficients "mean_`mean_var'_`condition_var'" _tab
    }

    file write regression_coefficients _n
    
    local base_controls "i.household_income `hh_demos'"
    local base_control_vars : subinstr local base_controls "i." "", all 
    
    use `in_file', clear
    if "`vce_cluster'"~="" {
        local vce_opt "vce(cluster `vce_cluster')"
    }
    keep `group_id' `generic_ind' `indep_vars' `base_control_vars' `analytic_weight' `main_fixed_effect' `vce_cluster'
    vallist `group_id', local(list_of_`group_id') sort
    
    foreach gid of local list_of_`group_id' {
        use `in_file' if `group_id' == `gid', clear         
        set sortseed 661877353 // Ensures same sort order within hhld_id's across iterations
        oo `group_id': `gid'
        areg `generic_ind' `indep_vars' `base_controls' [aw=`analytic_weight'], absorb(`main_fixed_effect') `vce_opt'
        write_regression_to_file, group_id(`gid') indep_vars("`indep_vars'") analytic_weight(`analytic_weight') mean_var(`mean_var') condition_var(`condition_var')
    }
    
    file close regression_coefficients
end

program write_regression_to_file
    syntax, group_id(int) indep_vars(str) analytic_weight(str) [ mean_var(str) condition_var(str) ]
    
    file write regression_coefficients "`group_id'" _tab (e(df_r)) _tab
    foreach param of local indep_vars {
        sum `param' [aw=`analytic_weight'], meanonly 
        file write regression_coefficients %14.8f (r(mean)) _tab
        file write regression_coefficients %14.8f (_b[`param']) _tab 
        file write regression_coefficients %14.8f (_se[`param']) _tab 
    }
    if "`mean_var'"~="" & "`condition_var'"~="" {
        sum `mean_var' [aw=`analytic_weight'] if `condition_var' == 1, meanonly 
        file write regression_coefficients %14.8f (r(mean)) _tab
    }
    file write regression_coefficients _n
end 
    

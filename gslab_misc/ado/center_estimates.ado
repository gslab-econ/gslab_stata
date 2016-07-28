version 13
cap program drop center_estimates

program define center_estimates, rclass
    syntax anything [, target(varname) weight_cond(string)]
    
    preserve
    tempname COEF
    tempname COEF_WEIGHTS
    matrix `COEF' = e(b)

    local weight_exp = e(wexp)
    tempvar weight_var
    if "`weight_exp'" == "." gen byte `weight_var' = 1
    else gen `weight_var' `weight_exp'
    
    quietly fvexpand `anything'
    local relevant_coeffs = r(varlist)

    tempvar relevant_sample
    gen `relevant_sample' = 0
    
    if "`weight_cond'" != "" local weight_cond "& `weight_cond'"
    
    foreach coeff_name of local relevant_coeffs {
        if colnumb(`COEF', "`coeff_name'") == . {
            disp as error "ERROR: `coeff_name' not found in coefficient names."
            error -1
        }
        local level = regexr("`coeff_name'", "[a-zA-Z]*\..*", "")
        if regexm("`coeff_name'", "(\.)(.*)(#)") local varname = regexs(2)
        else local varname = regexr("`coeff_name'", ".*\.", "")

        quietly replace `relevant_sample' = 1 if (`varname' == `level') & e(sample) `weight_cond'
        quietly summarize `weight_var' if (`varname' == `level') & `relevant_sample' 
        matrix `COEF_WEIGHTS' = nullmat(`COEF_WEIGHTS') \ (`COEF'[1, "`coeff_name'"] , r(sum))
    }
    
    
    if ("`target'" == "") local target "`e(depvar)'"
    quietly summarize `target' [weight = `weight_var'] if `relevant_sample', meanonly
    local target_mean = r(mean)
    
    matrix colnames `COEF_WEIGHTS' = coeff cell_weight
    clear
    quietly svmat `COEF_WEIGHTS', names(col)
    
    quietly summarize coeff [weight = cell_weight], meanonly
    local weighted_b_mean = r(mean)
    
    return local target_mean = `target_mean'
    return local target_var = "`target'"
    return local weighted_b_mean = `weighted_b_mean'
    return local diff_to_mean = `target_mean' - `weighted_b_mean'
end

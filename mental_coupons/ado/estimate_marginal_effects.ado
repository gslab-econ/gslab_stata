program estimate_marginal_effects, rclass
    syntax anything(name=iv_cmd) [if], absorb(varlist) cluster(varlist) [ * ]
    
    tempname ESTIMATES P_EQUALITY OBS P_COEFF 
    local GET_ESTROW = "(_b[\`var'] \ _se[\`var'])"

    _iv_parse `iv_cmd'
    local depvar `s(lhs)'
    local endog `s(endog)'
    local exog `s(exog)'
    local inst `s(inst)'

    if (`: word count `endog'' > 2) {
        di in red "May not specify more than two endogenous regressors"
        exit 198
    }

    local reghdfe_opts "absorb(`absorb') cluster(`cluster') `options'"
    if ("`endog'" == "") {
        reghdfe `depvar' `exog' `if', `reghdfe_opts'
        foreach var of local exog {
            test `var' == 0
            matrix `P_COEFF' = (nullmat(`P_COEFF'), r(p))
            matrix `ESTIMATES' = (nullmat(`ESTIMATES'), `GET_ESTROW')
        }
        matrix colnames `ESTIMATES' = `exog'
        matrix colnames `P_COEFF' = `exog'
    }
    else {
        reghdfe `depvar' `exog' (`endog' = `inst') `if', `reghdfe_opts'
        foreach var in `endog' {
            test `var' == 0
            matrix `ESTIMATES' = (nullmat(`ESTIMATES') , `GET_ESTROW')
            matrix `P_COEFF' = (nullmat(`P_COEFF'), r(p))
        }
        matrix colnames `ESTIMATES' = `endog'
        matrix colnames `P_COEFF' = `endog'

        test `: word 1 of `endog'' == `: word 2 of `endog''
        matrix `P_EQUALITY' = r(p)
        return matrix p_mpc_equal = `P_EQUALITY'
    }

    matrix `OBS' = (e(N) \ e(N_clust1))
    matrix rownames `ESTIMATES' = b se
    matrix rownames `OBS' = obs clusters

    return matrix estimates = `ESTIMATES'
    return matrix p_coeff = `P_COEFF'
    return matrix obs = `OBS'
end

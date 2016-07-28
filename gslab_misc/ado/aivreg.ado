program aivreg, eclass
    syntax anything(name = iv_cmd) [if], absorb(varname) ///
        [ robust CLuster(varname) dfadj_absorb ]
    tempvar touse xb_endog resid_endog 
    tempname b V
    
    qui datasignature 
    local sig_before = r(datasignature)
    local sort_before "`: sortedby'"

    _iv_parse `iv_cmd'
    local depvar `s(lhs)'
    local endog `s(endog)'
    local exog `s(exog)'
    local inst `s(inst)'

    if ("`endog'" == "") | ("`inst'" == "") {
        di in red "Must specify at least 1 endogenous regressor and 1 instrument"
        exit 198
    }
    
    mark `touse' `if'
    markout `touse' `depvar' `endog' `exog' `inst' `absorb' `cluster', strok
    
    fvexpand `inst' if `touse'
    parse_fvar `r(varlist)'
    local inst_exp `s(without_base)'

    local num_inst  : word count `inst_exp'
    local num_endog : word count `endog'
    if `num_endog' > `num_inst' {
        di in red "Model is not identifed. Number of endogenous"
        di in red "regressors cannot exceed number of instruments"
        exit 481 
    }

    if "`exog'" != "" {
        fvexpand `exog' if `touse'
        parse_fvar `r(varlist)'
        local exog `s(with_base)'
        local exog_exp `s(without_base)'
    }

    if "`cluster'" != "" local cluster_opt "cluster(`cluster')"
    local sup_di_opt "noheader notable"
    
    local endog_iter = 1
    foreach x of local endog {
        tempvar x`endog_iter'
        qui _regress `x' `exog' `inst' if `touse', absorb(`absorb') `sup_di_opt'
        qui predict double `x`endog_iter'' if e(sample) == 1, xb
        local endog_hat "`endog_hat' `x`endog_iter''"
        local ++endog_iter
    }
    local endog_hat = trim("`endog_hat'")
    
    qui _regress `depvar' `endog_hat' `exog' if `touse', absorb(`absorb') `sup_di_opt'
    matrix `b' = e(b)
    
    local colnames : colnames `b' 
    local colnames : subinstr local colnames "`endog_hat'" "`endog'", count(local cols_renamed)
    if `cols_renamed' != 1 {
        di in red "Error in calculating residuals. Aborting."
        exit 198
    }
    
    matrix colnames `b' = `colnames'
    qui matrix score double `xb_endog' = `b' if e(sample) == 1
    qui gen double `resid_endog' = `depvar' - `xb_endog' if e(sample) == 1

    if ("`absorb'" == "`cluster'") & (_caller() >= 14.0) {
        local se_reg_cmd "_regress"
    }
    else local se_reg_cmd "areg"

    qui `se_reg_cmd' `resid_endog' `endog_hat' `exog' if `touse', ///
        absorb(`absorb') `cluster_opt' `robust'
    mata: st_local("se_error", strofreal(sum(abs(st_matrix("e(b)"):-0):> 10^(-4))))
    if `se_error' > 0 {
        di in red "Error in calculating standard errors. Aborting"
        exit 198
    }
    drop `endog_hat' `xb_endog' `resid_endog'

    matrix `V' = e(V)
    matrix colnames `V' = `colnames'
    matrix rownames `V' = `colnames'
    
    _ms_omit_info `V'
    local num_regressors = colsof(`V') - r(k_omit)
    local num_groups = e(df_a) + 1
    local dof_areg  = e(N) - `num_regressors' - `num_groups' + 1
    local dof_xtreg = e(N) - `num_regressors'
    local dof_resid = `dof_areg'
    
    if "`cluster'" != "" {
        local N_clust = e(N_clust)
        if "`absorb'" == "`cluster'" local absorb_nest_clust = 1
        else {
            cap _xtreg_chk_cl2  `cluster' `absorb'
            if _rc == 0 local absorb_nest_clust = 1
            else local absorb_nest_clust = 0
        }
        if "`dfadj_absorb'" == "" & `absorb_nest_clust' == 1  {
            matrix `V' = `V' * (`dof_areg' / `dof_xtreg')
        }
        else local dof_resid = `N_clust' - 1
    }

    ereturn post `b' `V', depname(`depvar') obs(`e(N)') ///
              esample(`touse')  dof(`dof_resid')
    
    if "`cluster'" != "" {
        ereturn local clustvar "`cluster'"
        ereturn scalar N_clust = `N_clust'
    }

    di in gr _newline "FIXED EFFECTS IV-2SLS ESTIMATION"
    di in gr "{hline 32}"
    di in gr "Group variable   : " in ye %13s abbrev("`absorb'",12)
    di in gr "Number of obs    = " in ye %13.0g e(N)
    di in gr "Number of groups = " in ye %13.0g `num_groups'
    if "`absorb_nest_clust'" == "0" {
        di in gr "Note: Absorbed fixed effects are not nested within clusters"
    }
    ereturn display, noemptycells
    di in gr "Instrumented : `endog'"
    di in gr "Instruments  : `inst_exp' `exog_exp'"
    di in gr "{hline 78}"
    
    qui datasignature
    local sig_changed = "`r(datasignature)'" != "`sig_before'"
    local sort_changed = "`: sortedby'" != "`sort_before'"
    if  (`sig_changed') | (`sort_changed') {
        di in red "Estimation resulted in unexpected changes to data in memory"
        exit 198
    }
end

program parse_fvar, sclass
    syntax anything(name = to_parse)
    foreach x of local to_parse {
        _ms_parse_parts `x'
        if r(base) == 1 local with_base "`with_base' `x'"
        else if r(omit) != 1 {
            local with_base "`with_base' `x'"
            local without_base "`without_base' `x'"
        }
    }
    local with_base = trim("`with_base'") 
    local without_base = trim("`without_base'") 
    sreturn local with_base "`with_base'"
    sreturn local without_base "`without_base'"
end 

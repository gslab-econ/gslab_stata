program plot_event_study
    syntax, event_factorvar(string) plot_factor_values(string)       ///
        [estimates(string) saving(string) center match_range(string) ///
         shift_targets(string) xtitle(string) ytitle(string)         ///
         weight_cond(string) yline_patterns(string) yaxis(string) *] 

    preserve
    if "`xtitle'" == "" local xtitle: var label `event_factorvar'
    local plot_vars "i(`plot_factor_values')bn.`event_factorvar'"

    local num_estimates: word count `estimates'
    local num_targets: word count `shift_targets'
    local num_yaxis: word count `yaxis'
    local num_range: word count `match_range'
    local num_yline_patterns: word count `yline_patterns'
    if `num_yline_patterns' == 0 local yline_pattern "lpattern(dot)"
    if `num_yaxis' > 0 & `num_estimates' != `num_yaxis' {
        dis as error "ERROR: The number of axis IDs in yaxis() must be zero or equal the number of"
        dis as error "       names in estimates()."
        error -1
    }
    else if `num_yaxis' == 0 {
        local yaxis = "1"
        local num_yaxis = 1
    }

    if "`center'" != "" & `num_estimates' == 0 {
        center_estimates `plot_vars', target(`shift_targets') weight_cond(`weight_cond') 
        local yshift_opts yshift(`r(diff_to_mean)')
        local yline_opts yline(`r(target_mean)', `yline_pattern')
        local y_center_1 = r(target_mean)
    }

    if "`center'" != "" & `num_estimates' > 0 {
        if !inlist(`num_targets', `num_estimates', 0) | !inlist(`num_yline_patterns', `num_estimates', 0) {
            dis as error "ERROR: The number of variables in either shift_targets() or"
            dis as error "       yline_patterns() must be zero or equal the number of"
            dis as error "       names in estimates()."
            error -1
        }

        forval i = 1/`num_estimates' {
            local estimate: word `i' of `estimates'
            local yaxis_id: word `i' of `yaxis'
            if `num_targets' > 0 local target: word `i' of `shift_targets'
            if `num_yline_patterns' > 0 local yline_pattern: word `i' of `yline_patterns' 
            quietly estimate restore `estimate'
            center_estimates `plot_vars', target(`target') weight_cond(`weight_cond')
            local yshifts "`yshifts' `r(diff_to_mean)'"
            local yline_opts "`yline_opts' yline(`r(target_mean)', `yline_pattern' axis(`yaxis_id'))"
            local y_center_`i' = r(target_mean)
        }
        local yshift_opts "yshift(`yshifts')"
    }

    if `num_range' > 0 {
        if `num_yaxis' != `num_estimates' {
            dis as error "ERROR: If match_range() is specified, the number of axis IDs in yaxis()"
            dis as error "       must equal the number of names in estimates()."
            error -1
        }
 
        forval i = 1/`num_range' {
            local match_range_file: word `i' of `match_range'
            local yaxis_id: word `i' of `yaxis'
            * Include at least as much range as estimation results in `match_range'
            extract_plot_range using `match_range_file'
            local include_range_lower = `y_center_`i'' - `r(range)' / 2
            local include_range_upper = `y_center_`i'' + `r(range)' / 2
            local yscale_opts = "`yscale_opts' ylabel(#6, axis(`yaxis_id')) " + ///
                "yscale(range(`include_range_lower' `include_range_upper') axis(`yaxis_id'))"
        }           
    }

    forval i = 1/`num_yaxis' {
        local yaxis_`i': word `i' of `yaxis'
        local yaxis_opts "`yaxis_opts' yaxis(`yaxis_`i'')"
    }

    plotcoeffs `plot_vars', estimates(`estimates') lcolor(gs8) fcolor(gs8) `yline_opts' ///
        `yshift_opts' `yscale_opts' ytitle(`ytitle') xtitle(`xtitle') yaxis(`yaxis_opts') `options' 

    if "`saving'" != "" graph export `saving', as(eps) replace
    restore
end

program extract_plot_range, rclass
    syntax using
    
    preserve
    use `using'
    local minimum = .
    local maximum = .
    foreach var of varlist l_* {
        quietly sum `var'
        local minimum = min(`minimum', r(min))
    }
    foreach var of varlist u_* {
        quietly sum `var'
        local maximum = max(`maximum', r(max))
    }
    return local range = (`maximum' - `minimum') * 1.05
    restore
end

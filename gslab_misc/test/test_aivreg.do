version 13
set more off
adopath + ../ado
preliminaries

program main
    build_data, num_hhlds(50) num_periods(10)
    testgood test_basic
    testgood test_nested_cluster
    testgood test_errors
    
    // PRIOR TO STATA 14 XTIVREG DIDN'T SUPPORT CLUSTERING
    if _caller() >= 14.0 testgood test_basic, cluster(mask_cust_id)
end

program build_data 
    syntax, num_hhlds(str) num_periods(str)
    
    clear 
    set obs `=`num_hhlds' * `num_periods''
    gen mask_cust_id = int((_n-1)/`num_periods') + 1
    bysort mask_cust_id : gen transaction_month = ym(2002, 12) + _n 
    gen z1 = rnormal()
    gen z2 = rnormal()
    gen x1 = z1 + rnormal()
    gen x2 = z2 + rnormal()
    gen y = 10*x1 + 10*x2 + rnormal()
    
    xtset mask_cust_id transaction_month 
end 

program test_basic
    syntax [, cluster(varname) ]
    if "`cluster'" != "" local clustopt "cluster(`cluster')"

    test_run y (x1 = z1), `clustopt'
    test_run y (x1 x2 = z1 z2), `clustopt'
    test_run y i.transaction_month (x1 = z1), `clustopt'
    test_run y (x1 x2 = z1 z2) i.transaction_month, `clustopt'
    test_run y (x1 x2 = i.transaction_month), `clustopt'
    test_run y (x1 x2 = i.transaction_month z1 z2), `clustopt'
    test_run y (x1 = z1) if x1 < 0, `clustopt'
    test_run y i.transaction_month (x1 = z1) if x2 > 0, `clustopt'
    test_run y (z1 = z1), `clustopt'
end

program test_run 
    syntax anything(name = cmd) [if] [, cluster(varname) tolerance(real `=10^(-12)') ]
    
    if "`cluster'" != "" {
        local aivreg_clustopt "cluster(`cluster')"
        local xtivreg_clustopt "vce(cluster `cluster')"
    }
    
    timer clear 1
    timer clear 2

    timer on 1
    xtivreg `cmd', fe small `xtivreg_clustopt'
    timer off 1
    
    mata: b_xt = st_matrix("e(b)")
    mata: V_xt = st_matrix("e(V)")

    timer on 2
    aivreg `cmd', absorb(mask_cust_id) `aivreg_clustopt'
    timer off 2
    
    mata: b_aiv = st_matrix("e(b)")
    mata: V_aiv = st_matrix("e(V)")

    mata {
        assert(sum(abs(b_xt:-b_aiv):> `tolerance') == 0)
        assert(sum(abs(V_xt:-V_aiv):> `tolerance') == 0)
    }

    di "Run time of xtivreg (in seconds)"
    timer list 1
    di "Run time of aivreg (in seconds)"
    timer list 2
end

program test_nested_cluster
    test_run_nc, exog(x1)
    test_run_nc if z1 > 0, exog(x1)
    test_run_nc, exog(x1 x2)
    test_run_nc, exog(x1) controls(i.transaction_month)
    test_run_nc if z1 < 0, exog(x1) controls(i.transaction_month)
end 

program test_run_nc 
    syntax [if], exog(varlist) [ controls(varlist fv) tolerance(real `=10^(-12)') ]
    
    /* WHEN X ARE EXOGENOUS AND PANELS ARE NESTED W/I CLUSTERS AIVREG SHOULD REPLICATE XTREG */
    xtreg y `exog' `controls' `if', fe cluster(mask_cust_id)
    
    mata: b_xt = st_matrix("e(b)")
    mata: V_xt = st_matrix("e(V)")
    
    aivreg y `controls' (`exog' = `exog') `if', absorb(mask_cust_id) cluster(mask_cust_id)
    
    mata: b_aiv = st_matrix("e(b)")
    mata: V_aiv = st_matrix("e(V)")

    mata {
        assert(sum(abs(b_xt:-b_aiv):>  `tolerance') == 0)
        assert(sum(abs(V_xt:-V_aiv):>  `tolerance') == 0)
    }
    
    /* WHEN X ARE EXOGENOUS, PANELS ARE NESTED W/I CLUSTERS, AND DFADJ_ABSORB 
    OPTION IS SPECIFIED AIVREG SHOULD REPLICATE AREG */
    areg y `exog' `if', absorb(transaction_month) cluster(transaction_month)
    
    mata: b_a = st_matrix("e(b)")
    mata: V_a = st_matrix("e(V)")
    
    aivreg y (`exog' = `exog') `if', absorb(transaction_month) cluster(transaction_month) dfadj_absorb
    
    mata: b_aiv = st_matrix("e(b)")
    mata: V_aiv = st_matrix("e(V)")

    mata {
        assert(sum(abs(b_a:-b_aiv):>  `tolerance') == 0)
        assert(sum(abs(V_a:-V_aiv):>  `tolerance') == 0)
    }
    
    /* WHEN X ARE EXOGENOUS AND PANELS ARE NOT NESTED W/I CLUSTERS 
    AIVREG SHOULD REPLICATE AREG */
    areg y `exog' `controls' `if', absorb(mask_cust_id) cluster(transaction_month)
    
    mata: b_a = st_matrix("e(b)")
    mata: V_a = st_matrix("e(V)")
    
    aivreg y `controls' (`exog' = `exog') `if', absorb(mask_cust_id) cluster(transaction_month)
    
    mata: b_aiv = st_matrix("e(b)")
    mata: V_aiv = st_matrix("e(V)")

    mata {
        assert(sum(abs(b_a:-b_aiv):>  `tolerance') == 0)
        assert(sum(abs(V_a:-V_aiv):>  `tolerance') == 0)
    }
end

program test_errors
    // NO ABSORB()
    cap aivreg y x1
    assert _rc == 198
    
    // NO ENDOGENOUS VARIABLES
    cap aivreg y x1, absorb(mask_cust_id)
    assert _rc == 198
    
    // NOT IDENTIFIED
    cap aivreg y (x1 x2 = z1), absorb(mask_cust_id)
    assert _rc == 481
end

main

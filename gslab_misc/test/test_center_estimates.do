quietly {
    version 13
    set more off
    adopath + ../ado
    preliminaries
    
    program main
        quietly setup_dataset
        testgood test_basic
        testgood test_weights
        testgood test_alternate_target
        testbad test_var_missing
        testbad test_wrong_notation
    end
    
    program setup_dataset
        set obs 100
        gen group = 1
        replace group = 2 if (_n >= 30 & _n < 60)
        replace group = 3 if (_n >= 60 & _n < 90)
        replace group = 4 if (_n >= 90)
        gen x = round(5*runiform(), 1)
        gen a = _n
        gen y = a*rnormal(1)
        gen weights = 85 + int(13 * runiform())
    end
    
    program test_basic
        reg y x i.group
        center_estimates i.group
        center_estimates i(1/3).group
        center_estimates i(2/3)bn.group
        center_estimates i2bn.group i3bn.group
    end
    
    program test_weights
        reg y i.group [weight = weight], nocons
        center_estimates i(2/4)bn.group
        assert abs(`r(diff_to_mean)') < 1e-5
    end
    
    program test_alternate_target
        summarize a
        local expected_mean = r(mean)
        reg y x i.group
        center_estimates i.group, target(a)
        assert (r(target_var) == "a")
        
        assert (`r(target_mean)' == `expected_mean')
        assert abs(`r(diff_to_mean)' - (`expected_mean' - `r(weighted_b_mean)')) < 1e-5
    end
    
    program test_var_missing
        reg y x i.group
        center_estimates this_var_doesnt_exist
    end
    
    program test_wrong_notation
        reg y x i.group
        center_estimates group
    end
}

* EXECUTE
main

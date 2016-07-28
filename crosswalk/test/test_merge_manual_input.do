version 12
set more off
adopath + ../ado
adopath + ../external/lib/stata/gslab_misc/ado
preliminaries

program main

    * Test csv file
    load_raw_data
    testgood merge_manual_input using manual_input.csv, from(name) to(code)
    cap sum code
    assert `r(sum)' == 13
    testgood confirm var _merge
    
    * Test replace 
    load_raw_data
    testgood merge_manual_input using manual_input.csv, from(name) to(code) replace
    cap sum code
    assert `r(sum)' == 15
    testgood confirm var _merge
    
    * Test nogen
    load_raw_data
    testgood merge_manual_input using manual_input.csv, from(name) to(code) nogen
    cap sum code
    assert `r(sum)' == 13
    testbad confirm var _merge
    
    * Test replace nogen
    load_raw_data
    testgood merge_manual_input using manual_input.csv, from(name) to(code) replace nogen 
    cap sum code
    assert `r(sum)' == 15
    testbad confirm var _merge
end

program load_raw_data
    qui insheet using "raw_data.csv", comma clear
end

* EXECUTE
main

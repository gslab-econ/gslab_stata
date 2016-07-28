version 12
set more off
adopath + ../ado
adopath + ../external/lib/stata/gslab_misc/ado
preliminaries

program main

    * Test no options
    load_raw_data
    testgood save_crosswalk ./temp/name-code.dta, from(name) to(code)
    cap sum code
    assert `r(sum)' == 4
    cap count if missing(code)
    assert `r(N)' == 0
    
    * Test to_missok
    load_raw_data
    testgood save_crosswalk ./temp/name-code.dta, from(name) to(code) ///
                            to_missok replace
    cap sum code
    assert `r(sum)' == 4
    cap count if missing(code)
    assert `r(N)' == 3
    
    * Test fromfile 
    create_from_to_files
    load_raw_data
    testgood save_crosswalk ./temp/name-code.dta, from(name) to(code) ///
                            fromfile(./temp/from_file_good.dta) replace
    cap sum code
    assert `r(sum)' == 4
    cap count if missing(code)
    assert `r(N)' == 0
    
    * Test fromfile mismatch
    load_raw_data
    testbad save_crosswalk ./temp/name-code.dta, from(name) to(code) ///
                           fromfile(./temp/from_to_file_bad.dta) replace
    
    * Test tofile 
    load_raw_data
    testgood save_crosswalk ./temp/name-code.dta, from(name) to(code) ///
                            tofile(./temp/to_file_good.dta) replace
    cap sum code
    assert `r(sum)' == 4
    cap count if missing(code)
    assert `r(N)' == 0
    
    * Test tofile mismatch
    load_raw_data
    testbad save_crosswalk ./temp/name-code.dta, from(name) to(code) ///
                           tofile(./temp/from_to_file_bad.dta) replace
    
    * Test tofile fromfile to_missok
    load_raw_data
    testgood save_crosswalk ./temp/name-code.dta, from(name) to(code) ///
                            fromfile(./temp/from_file_good.dta) ///
                            tofile(./temp/to_file_good.dta) to_missok replace
    cap sum code
    assert `r(sum)' == 4
    cap count if missing(code)
    assert `r(N)' == 3

end

program load_raw_data
    qui insheet using "raw_data.csv", comma clear
end

program create_from_to_files
    quietly {
        insheet using "raw_data.csv", comma clear
        save ./temp/from_file_good.dta
        
        insheet using "raw_data.csv", comma clear
        replace code = 1 if code == .
        keep if name == "a"
        save ./temp/to_file_good.dta
        
        qui insheet using "manual_input.csv", comma clear
        keep if name == "a" | name == "b"
        save ./temp/from_to_file_bad.dta
    }
end

* EXECUTE
main

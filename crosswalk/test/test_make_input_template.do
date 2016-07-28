version 12
set more off
adopath + ../ado
adopath + ../external/lib/stata/gslab_misc/ado
preliminaries

program main

    * Test no options
    load_raw_data
    testgood make_input_template ./temp/name-code_template.csv, from(name) to(code)
    qui insheet using "./temp/name-code_template.csv", comma clear
    testgood confirm var name
    testgood confirm var current_code
    testgood confirm var code
    cap sum current_code
    assert `r(sum)' == 4
    
    * Test current
    load_raw_data
    testgood make_input_template ./temp/name-code_template.csv, from(name) to(code) ///
                                 current(manual_input.csv)
    qui insheet using "./temp/name-code_template.csv", comma clear
    testgood confirm var name
    testgood confirm var current_code
    testgood confirm var code
    cap sum current_code
    assert `r(sum)' == 4
    cap sum code
    assert `r(sum)' == 12
    
    * Test from_info_vars
    load_raw_data
    testgood make_input_template ./temp/name-code_template.csv, from(name) to(code) ///
                                 from_info_vars(info)
    qui insheet using "./temp/name-code_template.csv", comma clear
    testgood confirm var name
    testgood confirm var current_code
    testgood confirm var code
    testgood confirm var name_info
    cap sum current_code
    assert `r(sum)' == 4
    
    * Test to_info_vars
    create_to_info_file
    load_raw_data
    testgood make_input_template ./temp/name-code_template.csv, from(name) to(code) ///
                                 to_info_vars(info) to_info_file(./temp/to_info.dta)
    qui insheet using "./temp/name-code_template.csv", comma clear
    testgood confirm var name
    testgood confirm var current_code
    testgood confirm var code
    testgood confirm var current_code_info
    cap sum current_code
    assert `r(sum)' == 4
    
    * Test to_info_vars no file
    load_raw_data
    testbad make_input_template ./temp/name-code_template.csv, from(name) to(code) ///
                                to_info_vars(info)
    
    * Test from_prefix
    load_raw_data
    testgood make_input_template ./temp/name-code_template.csv, from(name) to(code) ///
                                 from_info_vars(info) from_prefix(from_)
    qui insheet using "./temp/name-code_template.csv", comma clear
    testgood confirm var name
    testgood confirm var current_code
    testgood confirm var code
    testgood confirm var from_info
    cap sum current_code
    assert `r(sum)' == 4
    
    * Test to_prefix
    load_raw_data
    testgood make_input_template ./temp/name-code_template.csv, from(name) to(code) ///
                                 to_info_vars(info) to_info_file(./temp/to_info.dta) ///
                                 to_prefix(to_)
    qui insheet using "./temp/name-code_template.csv", comma clear
    testgood confirm var name
    testgood confirm var current_code
    testgood confirm var code
    testgood confirm var to_info
    cap sum current_code
    assert `r(sum)' == 4
    
    * Test current from_info_vars to_info_vars
    load_raw_data
    testgood make_input_template ./temp/name-code_template.csv, from(name) to(code) /// 
                                 current(manual_input.csv) to_info_vars(info) /// 
                                 to_info_file(./temp/to_info.dta)
    qui insheet using "./temp/name-code_template.csv", comma clear
    testgood confirm var name
    testgood confirm var current_code
    testgood confirm var code
    testgood confirm var current_code_info
    cap sum current_code
    assert `r(sum)' == 4
    cap sum code
    assert `r(sum)' == 12
    
end

program load_raw_data
    qui insheet using "raw_data.csv", comma clear
end

program create_to_info_file
    quietly {
        insheet using "raw_data.csv", comma clear
        replace code = 1 if code == .
        keep code 
        duplicates drop
        gen info = "the number one"
        save ./temp/to_info.dta
    }
end

* EXECUTE
main

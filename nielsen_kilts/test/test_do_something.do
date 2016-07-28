****************************************************************************************************
*
* TEST_DO_SOMETHING.DO
*
****************************************************************************************************

version 12
set more off
adopath + ../ado
adopath + ../external/gslab_misc/ado
preliminaries

program main
    quietly setup_data
    testgood do_something test, option1(test) 
    testbad do_something test, optionblah
end

program setup_data
    set obs 100
    gen n = _n
end


* EXECUTE
main



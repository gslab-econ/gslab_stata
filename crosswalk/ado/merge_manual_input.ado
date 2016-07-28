 /**********************************************************
 *
 *  merge_manual_input.ado
 * 
 **********************************************************/ 

 program merge_manual_input
    version 12
    syntax  using, from(varlist) to(str) [replace NOGEN insheet_options(str)]

    tempfile temp
    preserve
    insheet `using', clear `insheet_options'
    save `temp'
    restore

    merge 1:1 `from' using `temp', `nogen' keep(1 3 4 5) keepus(`to') update force `replace'
end
    

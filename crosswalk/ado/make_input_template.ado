/***************************************************************************************************
*
* MAKE_INPUT_TEMPLATE.ADO
*
**************************************************************************************************/

program make_input_template

    version 12
    syntax  anything(name=outputfile) [if], from(varlist) to(varlist) [ current(str) /// 
        from_info_vars(varlist) to_info_file(str) to_info_vars(str) from_prefix(str) to_prefix(str)]

    if "`from_prefix'" == "" {
        local from_prefix = "`from'_"
    }

    if "`to_prefix'" == "" {
        local to_prefix = "current_`to'_"
    }

    if "`current'" != "" {
        tempfile temp
        preserve
        insheet using `current', clear
        save `temp', replace
        restore
    }

    preserve
    if "`if'" != "" {
        keep `if'
    }

    keep `from' `to' `from_info_vars'
    if "`from_info_vars'" != "" {
        renvars `from_info_vars', prefix(`from_prefix')
    }

    if "`to_info_vars'" != "" {
        qui merge m:1 `to' using `to_info_file', nogen keep(1 3) keepus(`to_info_vars')
        renvars `to_info_vars', prefix(`to_prefix')
    }

    local current_name = substr("current_`to'",1,25)
    ren `to' `current_name'

    if "`current'" != "" {
        qui merge 1:1 `from' using `temp', nogen keep(1 3) keepus(`to')
    }
    else {
        gen `to' = ""
    }

    placevar `from' `to' `current_name'
    outsheet using `outputfile', comma replace
    restore
end


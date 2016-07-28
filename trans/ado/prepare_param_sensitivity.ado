****************************************************************************************************
*
* PREPARE_PARAM_SENSITIVITY.ADO
*
* Defines graph variables for given parameter.
*
****************************************************************************************************

program prepare_param_sensitivity
    version 13
    
    syntax, param(string) [sen_type(str)]
    
    if "`sen_type'"=="" | "`sen_type'"=="stsen" {
        define_stsen_by_type, param("`param'")
    }
    else {
        define_sen_by_type, param("`param'")
    }
    add_sign_to_label,    param("`param'")
    define_param_key,     param("`param'")
    define_moment_order,  param("`param'")
end

program define_stsen_by_type
    syntax, param(string)
    
    quietly levelsof moment_type, clean local(types)
    foreach type of local types {
        local type = lower("`type'")
        replace param_`type' = .
        replace param_`type' = `param'_stsen if lower(moment_type) == "`type'"
    }
end

program define_sen_by_type
    syntax, param(string)
    
    quietly levelsof moment_type, clean local(types)
    foreach type of local types {
        local type = lower("`type'")
        replace param_`type' = .
        replace param_`type' = `param'_sen if lower(moment_type) == "`type'"
    }
end

program add_sign_to_label
    syntax, param(string)

    replace sign_label = " (+)" if `param'_sen > 0
    replace sign_label = " (-)" if `param'_sen < 0
    replace moment_label = moment_descrip + sign_label
end
    
program define_param_key
    syntax, param(string)

    gsort -key`param'
    local key_mom = key`param'
    replace param_key = 0
    
    foreach mom of local key_mom {
        replace param_key = 1 if moment == "`mom'"
    }
    
    // Keep empty observation for blank space in plot
    replace param_key = .5 if moment == " "
end

program define_moment_order
    gsort -param_key type_order moment_descrip
    replace moment_order = _n    
end


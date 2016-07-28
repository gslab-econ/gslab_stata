****************************************************************************************************
*
* PREPARE_FIGURES_DATA.ADO
*
* Combines sensitivity matrices with parameter and moment information and generates placeholders
* for graph-related variables.
*
****************************************************************************************************

program prepare_figures_data
    version 13
    
    syntax, sen_file(string) stsen_file(string) param_file(string) mom_file(string) out_file(string) ///
            mom_type_order(string)

    foreach sens in sen stsen {
        prepare_sensitivity_data, in_file("``sens'_file'") varstub("_`sens'")
    }
    merge_mom_data, param_file("`param_file'") mom_file("`mom_file'") out_file("`out_file'")
    gen_graph_vars, mom_type_order("`mom_type_order'") out_file("`out_file'")
end

program prepare_sensitivity_data
    syntax, in_file(string) varstub(string)
    
    import delimited "`in_file'", clear varnames(1)
    rename * *`varstub'
    rename v1`varstub' moment
    replace moment = trim(moment)
    
    local filename = subinstr("`varstub'", "_", "", 1)
    save "./`filename'.dta", replace 
end 

program merge_mom_data
    syntax, param_file(string) mom_file(string) out_file(string)
    
    use "`param_file'", clear
    append using "`mom_file'"
    
    replace moment = " " if moment == ""
    
    foreach sens in sen stsen {
        mmerge moment using ./`sens'.dta, ///
            type(1:1) unmatched(master) ukeep(*_`sens')
        drop _merge
        erase ./`sens'.dta
    }

    save "`out_file'", replace
end

program gen_graph_vars
    syntax, mom_type_order(string) out_file(string)
    
    use "`out_file'", clear

    local num_types = wordcount("`mom_type_order'")
    
    gen type_order = .
    forvalues i = 1/`num_types' {
        local type = lower(word("`mom_type_order'", `i'))
        replace type_order = `i' if lower(moment_type) == "`type'"
        gen param_`type' = .
    }

    gen sign_label   = " "
    gen moment_label = " "
    gen param_key    = .
    gen moment_order = .
    
    save "`out_file'", replace
end

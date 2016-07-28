****************************************************************************************************
*
* GET_TRANS_GRAPH_DEFAULTS.ADO
*
* Returns default TRANS graph options.
*
****************************************************************************************************

program get_trans_graph_defaults, rclass
    version 13
    
    syntax, param(string)
    
    define_mom_labels, param("`param'")
    return local mom_labels = `"`r(mom_labels)'"'
    
    return local mom_label_opts = "labsize(small) noticks angle(60)"
    return local bar_opts       = "barwidth(.8) lcolor(black)"
    return local bar_colors     = "blue*4 lime*.1 red*.5"

    define_graph_opts, param("`param'")
    return local graph_opts = "`r(graph_opts)'"
end

program define_mom_labels, rclass
    syntax, param(string)

    sort moment
    local key_count = wordcount(key`param')
    local separator_x = `key_count' + 1    
    
    // Return moment labels in "# <label>" format
    sort moment_order
    local mom_labels ""
    forvalues i = 1/`=_N' {
        if `i' ~= `separator_x' {
            local moment = moment_label[`i']
            local mom_labels = `"`mom_labels' `i' "`moment'""'
        }
    }
    
    return local mom_labels = `"`mom_labels'"'
end

program define_graph_opts, rclass
    syntax, param(string)

    sort moment
    
    local param_descrip = descr`param'
    
    local key_count = wordcount(key`param')
    local separator_x = `key_count' + 1
    
    quietly sum `param'_stsen
    local max_stsen = `r(max)'    
    local label_inc = .05
    local ymax = round(`max_stsen' + `label_inc' / 2, `label_inc')
                       
    return local graph_opts = "title(`param_descrip', size(medium)) "                                 + ///
                              "ylabel(0(.1)`ymax', labsize(small) grid gstyle(major)) "               + ///
                              "xtitle(Key moments (left) and other moments (right), size(medsmall)) " + ///
                              "ytitle(Standardized sensitivity, size(medsmall)) "                           + ///
                              "xline(`separator_x', lpattern(dash) lcolor(150 150 150)) "             + ///
                              "yline(`ymax') yscale(range(0 `ymax')) "                                + ///
                              "plotregion(margin(1 1 0 0))"
end

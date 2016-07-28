****************************************************************************************************
*
* GRAPH_PARAM_SENSITIVITY.ADO
*
* Graph standardized sensitivity for a given parameter (assumes that variables defined in 
* prepare_param_sensitivity have been defined).
*
****************************************************************************************************

program graph_param_sensitivity
    version 13
    
    syntax, param(string) mom_type_order(string) legend_opts(string)       ///
            [mom_labels(string) mom_label_opts(string) bar_opts(string) bar_colors(string) graph_opts(string)]
    
    get_trans_graph_defaults, param("`param'")
    foreach arg in mom_labels mom_label_opts bar_opts bar_colors graph_opts {
        if `"``arg''"' == "" {
            local `arg' = `"`r(`arg')'"'
        }
    }

    local num_types = wordcount("`mom_type_order'")
    
    local bars ""
    forvalues i = 1/`num_types' {
        local type = lower(word("`mom_type_order'", `i'))
        local bar_color = word("`bar_colors'", `i')
        local bars = `"`bars' bar param_`type' moment_order, fcolor(`bar_color') `bar_opts'"'
        if `i' < `num_types' {
            local bars = `"`bars' ||"'
        }
    }
    
    twoway `bars' `graph_opts' xlabel(`mom_labels', `mom_label_opts') legend(`legend_opts')
end

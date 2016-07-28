program plot_average
    syntax [if], depvar(string) indepvar(string) [saving(string) *]

    preserve
    local ytitle : var label `depvar'
    collapse (mean) mean_`depvar'=`depvar' (semean) semean_`depvar'=`depvar' `if', ///
        by(`indepvar') fast

    mkmat mean_`depvar', matrix(beta)
    mkmat semean_`depvar', matrix(se)

    if !(regexm("`options'", "graphs\([a-z]+\)")) local graph_opts "graphs(nose)"

    plotcoeffs, b(beta) se(se) `graph_opts' lcolor(gs8) fcolor(gs8) ///
        yline() ytitle(`ytitle') xtitle(`: var label `indepvar'') `options'
    if "`saving'" != "" graph export `saving', as(eps) replace
    restore
end

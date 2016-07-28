/**********************************************************
 *
 * PLOTCOEFFS.ADO: Plot coefficients after a regression.
 *
 * Date: May 2009
 * Creator: Matt Gentzkow, Pat Dejarnette, & James Mahon
 *
 **********************************************************/

* Grab program plotcoeffs and drop it (clear it so we can create plotcoeffs program)
cap program drop plotcoeffs

* Defines  a program called plotcoeffs:
* http://www.stata.com/help.cgi?program
program define plotcoeffs
    set more off
    version 10
    * Allows time series operators 
    syntax [anything], [estimates(string) b(string) se(string) graphs(string) label(string) cumulative(string) lcolor(string) fcolor(string) yshift(string) savedata(string asis) combine yaxis(string) *]

    * save & temporarily clear data
    preserve
    
    * error checks
    * * output error if the graphs string has incorrect number of words
     local n_est = wordcount( "`estimates'")
    if "`b'" != ""  local n_col_mat = colsof(`b')
    local n_gr = wordcount( "`graphs'")
    local n_ax = wordcount("`yaxis'")
    if ("`b'" != "") {
        if (((`n_col_mat' != `n_gr' & `n_col_mat' >= 2) | (`n_gr' >= 2 & `n_col_mat' == 1)) & "`combine'" != "combine") {
            disp as error "ERROR: If b() and se() contain one column,"
            disp as error "       graphs() must contain at most one name."
            disp as error "       If b() and se() contain two or more columns,"
            disp as error "       graphs() must contain an equal number of names."
            error -1
        }
        if (`n_col_mat' != `n_ax' & `n_ax' >= 2) {
            disp as error "ERROR: If yaxis() contains two or more elements,"
            disp as error "       b() and se() must contain an equal number of columns."
            error -1
        }
    }
    else {
        if (((`n_est' != `n_gr' & `n_est' >= 2) | (`n_gr' >= 2 & `n_est' <= 1)) & "`combine'" != "combine") {
            disp as error "ERROR: If estimates() contain either zero or one name,"
            disp as error "       graphs() must contain at most one name. If estimates()"
            disp as error "       contains two or more names, graphs() must contain"
            disp as error "       an equal number of names."
            error -1
        }
        if (`n_est' != `n_ax' & `n_ax' >= 2) {
            disp as error "ERROR: If yaxis() contains two or more elements,"
            disp as error "       estimates() must contain an equal number of names."
            error -1
        }
    }
    
    * * output error if the cumulative string has incorrect number of binary indicators
    local n_c = wordcount( "`cumulative'")
    if (( `n_est' != `n_c' & "`cumulative'" != "" & "`estimates'" != "") | ( "`estimates'" == "" & `n_c' > 1)) {
        disp as error "ERROR: The number of binary indicators in cumulative()" 
        disp as error "       must equal the number of names in estimates()."
        error -1
    }
    
    * * output error if the cumulative string contents are not binary
    foreach C in `cumulative' {
        if ( "`C'" != "0" & "`C'" != "1") {
            disp as error "ERROR: cumulative() can only contain 1's or 0's." 
            error -1
        }
    }
    
    * * output error if cumulative is used with b()
    if ( "`b'" != "" & "`cumulative'" != "") {
        disp as error "ERROR: cumulative() cannot be used with b() and se()." 
        error -1
    }
    
    * * output error if the graphs string has incorrect input
    local test = "`graphs'"
    foreach V in bar err line area nose connect {
        local test = subinstr( "`test'", "`V'", "", .)
    }
    if wordcount( "`test'") != 0 {
        disp as error "ERROR: graphs() contains illegitimate input."
        error -1
    }
    
    * *  output error if estimates are incorrectly specified
    if ( "`anything'" != "") & ( "`b'" != "" | "`se'" != "") {
        disp as error "ERROR: anything() cannot be specified with either b() or se()."
        error -1
    }
    if ( "`estimates'" != "") & ( "`b'" != "" | "`se'" != "") {
        disp as error "ERROR: estimates() cannot be specified with either b() or se()."
        error -1
    }
    if ( "`b'" == "" & "`se'" != "") | ( "`b'" != "" & "`se'" == "") {
        disp as error "ERROR: If se() is specified, then b() must be specified as well and visa versa."
        error -1
    }
    if ( "`combine'" != "") & ( "`b'" != "" | "`se'" != "") {
        disp as error "ERROR: Combine cannot be specified with either b() or se()."
        error -1
    }
    if ("`b'" != "" & "`se'" != "") {
        if (colsof(`b') != colsof(`se') | rowsof(`b') != rowsof(`se')) {
            disp as error "ERROR: If b() and se() are both specified, then they must have the same dimensions."
            error -1
        }
    }
    
    * * output error if the yshift string has incorrect number of numbers
    local n_yshift = wordcount("`yshift'")
    if ( "`estimates'" == "" & "`b'" == "" & `n_yshift' > 1) {
        disp as error "ERROR: If estimates() and b() are not specified,"
        disp as error "       yshift() must have 0 or 1 elements."
        error -1
    }
    if ( "`combine'" == "" & "`estimates'" != "" & "`b'" == "" & `n_est' != `n_yshift' & `n_yshift' > 0) {
        disp as error "ERROR: The number of numbers in yshift() must"
        disp as error "       equal the number of names in estimates()."
        error -1
    }
    if ("`b'" != "" & "`se'" != "") {
        if ( "`combine'" == "" & colsof(`b') != `n_yshift' & `n_yshift' > 0) {
            disp as error "ERROR: The number of numbers in yshift() must equal"
            disp as error "       either the number of columns in b() and se()."
            error -1
        }
    }
    if ( "`combine'" != "" & `n_yshift' > 1) {
        disp as error "ERROR: If combine is specified, then"
        disp as error "       yshift() must contain 0 or 1 elements."
        error -1
    }
    
    * preparation
    * * expand any varlists in anything
    local templist ""
    foreach A in `anything' {
        cap unab A: `A'
        cap fvexpand `A'
        local templist "`templist' `r(varlist)'"
    }
    local anything "`templist'"
    
    * * save name of initial current estimates (in order to restore at the end of the program)
    local orig_est = "`e(_estimates_name)'"
    if "`orig_est'" == "" & "`e(cmd)'" != "" {
        local date = subinstr( "`c(current_date)'", " ", "_", .)
        local time = subinstr( "`c(current_time)'", ":", "", .)
        local name = "TS_`date'_`time'" 
        quietly estimates store `name'
    }
    
    * * localize wildcards in estimates
    if "`estimates'" != "" {
        foreach E in `estimates' {
            if strpos( "`E'", "*") != 0 {
                local temp = "_est_" + "`E'"
                local temp = subinstr( "`estimates'", "*", "", .)
                quietly lookfor `temp'
                local templist = "`r(varlist)'"
                local estimates = subinword( "`estimates'", "`E'", "`templist'", 1)
            }
        }
    }
    
    * * handle unspecified estimates
    if "`b'" == "" {
        local noest = 0
        if "`estimates'" == "" {
            local estimates "reg1"
            local noest = 1
        }
    }
    
    * * create cumulative estimates
    local word = 1
    foreach E in `estimates' {
        if "`cumulative'" == "" {
            local cumul = 0
        }
        else {
            local cumul = word( "`cumulative'", `word')
        }
        if `cumul' == 1 {
            if `noest' == 0 {
                quietly estimates restore `E'
            }
            local past "" 
            local level_anything ""
            local level_nlcom ""
            foreach V in `anything' {
                local past "`past' `V'"
                local level_anything "`level_anything' level_`V'"
                local level_`V' "`V':"
                local i = 1
                foreach P in `past' {
                    if `i' == 1 {
                        local level_`V' "`level_`V'' _b[`P']"
                    }
                    else {
                        local level_`V' "`level_`V'' + _b[`P']"
                    }
                    local i = 0
                }
                local level_`V' "(`level_`V'')"
                local level_nlcom "`level_nlcom' `level_`V''"
            }
            quietly nlcom `level_nlcom', post
            estimates store level_`E'
            local estimates = subinword( "`estimates'", "`E'", "level_`E'", 1)
        }
        local word = `word' + 1
    }
    
    * create dataset for graphs
    * * move stored estimates from ereturn to matrices
    if "`b'" == "" {
        
        * * * loop over stored estimates
        foreach V in `estimates' {
            drop _all
            if ( `noest' == 0) {
                quietly estimates restore `V'
            }
            matrix temp_b = get(_b)'
            matrix colnames temp_b = b 
            matrix temp_V = vecdiag(get(VCE))'
            matrix colnames temp_V = var
            matrix temp = temp_b , temp_V 
            cap matrix drop `V'
            foreach W in `anything' {
                cap matrix `V' = nullmat( `V') \ temp["`W'",.]
            }
        }
    }
    
    * * combine beta & standard error input vectors
    else if "`b'" != "" & "`se'" != "" {
        local estimates ""
        forval i = 1/`n_col_mat' {
            matrix var = vecdiag(`se'[1..., `i'] * `se'[1..., `i']')'
            matrix reg`i' = `b'[1..., `i'] , var
            matrix colnames reg`i' = b var
            local estimates "`estimates' reg`i'"
        }
    }
    
    * * combine matrices into one data set
    local n = 1
    tempfile temp data
    foreach V in `estimates' {
        
        * * * convert estimates into datasets
        drop _all
        cap quietly svmat2 `V', names(col) rnames(coeff) full
        if _rc == 111 {
            display "Error: You have given plotcoeffs a varlist that it doesn't understand or where the variable is not found."
            error -1
        }
        else if _rc != 0 {
            display "Error: svmat2 died for an unknown reason.  Exit code: _rc"
            error -1
        }
        
        * * * edit data if combine command is not specified
        if "`combine'" == "" {
            ren b b_`V'
            ren var var_`V'
            quietly gen order = _n
        }
        else if "`combine'" == "combine" {
            gen est = "`V'"
        }
        quietly save `temp', replace
        
        * * * combine tempfiles
        if `n' == 1 {
            quietly save `data', replace
        } 
        * * * * merge estimates (separate time-series)
        else if "`combine'" == "" {
            use `data', clear
            quietly mmerge coeff order using `temp', type(1:1) missing(none) unmatched(both)
            drop _merge
            quietly save `data', replace
        }
        
        * * * * append estimates (one time-series)
        else if "`combine'" == "combine" {
            use `data', clear
            append using `temp'
            quietly save `data', replace
        }
        
        local n = `n' + 1
    }
    
    * * edit data if combine option specified
    if "`combine'" == "combine" {
    * * * rename variables
        ren b b_combine
        ren var var_combine
        
    * * * create order variable for one time-series
        quietly gen order = _n
        
    * * * revise estimates local
        local estimates "combine"
    }
    
    * * create upper & lower bounds
    foreach V in `estimates' {
        quietly gen u_`V' = b_`V' + 2*(var_`V')^0.5
        quietly gen l_`V' = b_`V' - 2*(var_`V')^0.5
    }
    
    * * shifts all coefficients by constant
    forval i = 1/`: word count `yshift'' {
        local shift_i : word `i' of `yshift'
        local estimate_i : word `i' of `estimates'
        quietly replace b_`estimate_i' = b_`estimate_i' + `shift_i'
        quietly replace u_`estimate_i' = u_`estimate_i' + `shift_i'
        quietly replace l_`estimate_i' = l_`estimate_i' + `shift_i'
    }
    
    * label vars
    * * preliminaries
    sort order
    quietly sum order
    local max = r(max)
    tempname lab
    label define `lab' 0 "xx"
    
    * * create name for labels
    * * * use coefficient names if no user-provided labels & not combine
    if "`label'" == "" & "`combine'" == "" {
        quietly sum order
        forvalues i=1(1)`r(max)' {
            local coeff = coeff in `i'
            label define `lab' `i' "`coeff'", modify
        }
    }
    * * * use coefficient names if no user-provided labels & combine
    if "`label'" == "" & "`combine'" == "combine" {
        quietly sum order
        gen name = coeff + "_" + est
        forvalues i=1(1)`r(max)' {
            local name = name in `i'
            label define `lab' `i' "`name'", modify
        }
    }
    
    * * * use user-provided labels if available
    else if "`label'" != "" {
        local n = 1
        foreach V in `label' {
            label define `lab' `n' "`V'", modify
            local n = `n' + 1
        }
    }
    
    * * apply labels to order variable
    label values order `lab'
    
    * create graph
    * * add graph formatting if omitted
    local auto = ""
    if strpos(`"`options'"',"scheme") <= 0 {
        local auto = "scheme(s1mono)"
    }
    if strpos(`"`options'"',"yline") <= 0 {
        local auto = "`auto'" + " yline(0, lcolor(gs12))"
    }
    if strpos(`"`options'"',"ytitle") <= 0 {
        local auto = "`auto'" + " ytitle" + "(Coefficient)"
    }
    if strpos(`"`options'"',"xtitle") <= 0 {
        local auto = "`auto'" + " xtitle" + "(Variable)"
    }
    if strpos(`"`options'"',"xlabel") <= 0 {
        local auto = "`auto'" + " xlabel(#`max', value angle(vertical))"
    }
    if strpos(`"`options'"',"legend") <= 0 {
        local auto = "`auto'" + " legend(off)"
    }
    if "`lcolor'" == "" {
        local lcolor = "black"
    }
    if "`fcolor'" == "" {
        local fcolor = "white"
    }
    
    * * localize graph commands per set of estimation results
    local i = 1
    foreach V in `estimates' {
        * * * identify graph type
        local j = 1
        foreach G in `graphs' {
            if `i' == `j' {
                local type = "`G'"
            }
            local j = `j' + 1
        }
        local k = 1
        foreach A in `yaxis' {
            if `i' == `k' {
                local yaxis_opt = "`A'"
            }
            local k = `k' + 1
        }

        * * * store graph commands
        if ( "`type'" == "bar") {
            local graph_`V' "(bar b_`V' order, color(`lcolor') fintensity(inten100) barwidth(.5) `yaxis_opt')"
        }
        
        if ( "`type'" == "err" | "`type'" == "") {
            local graph_`V' "(scatter b_`V' order, mlcolor(`lcolor') mfcolor(`fcolor') mstyle(p1) `yaxis_opt') (rcap u_`V' l_`V' order, lcolor(`lcolor') `yaxis_opt')"
        }
        
        if ( "`type'" == "line") {
            local graph_`V' "(line b_`V' order, lcolor(`lcolor') `yaxis_opt') (line u_`V' order, lpattern(dash) lcolor(`color1') `yaxis_opt') (line l_`V' order, lpattern(dash) lcolor(`lcolor') `yaxis_opt')"
        }
        
        if ( "`type'" == "linearea") {
            local graph_`V' "(rarea u_`V' l_`V' order, color(`lcolor'*.5) `yaxis_opt') (line b_`V' order, lcolor(`lcolor') `yaxis_opt')"
        }
        
        if ( "`type'" == "linenose") {
            local graph_`V' "(line b_`V' order, lpattern(dash) lcolor(`lcolor') `yaxis_opt')"
        }

        if ( "`type'" == "nose") {
            local graph_`V' "(scatter b_`V' order, mlcolor(`lcolor') mfcolor(`fcolor') `yaxis_opt')"
        }
        
        if ("`type'" == "connect") {
            local graph_`V' "(connected b_`V' order, lcolor(`lcolor') mlcolor(`lcolor') mfcolor(`fcolor') msymbol(circle) lpattern(solid) `yaxis_opt')"
        }
        
        local i = `i' + 1
        local graphlist "`graphlist' graph_`V'"
    }
    
    * * compile graph command
    local i = 1
    foreach G in `graphlist' {
        if `i' == 1 {
            local graphcmd "graph twoway ``G''"
        }
        else {
            local graphcmd "`graphcmd' || ``G''"
        }
        local i = `i' + 1
    }

    * * use graph command
    `graphcmd', `options' `auto'
    
    * * save data used for plotting
    if `"`savedata'"' != "" save `savedata'
    
    * restore data & original estimates
    restore
    if "`orig_est'" != "" & "`e(cmd)'" != "" {
        quietly estimates restore `orig_est'
    }
    else if "`e(cmd)'" != "" {
        quietly estimates restore `name'
        quietly estimates drop `name'
    }   
end

version 11
set more off
adopath + ../ado
preliminaries

program main
    quietly setup_dataset
    testgood test_basic
    testgood test_with_options
    testgood test_with_multiple_regs
    testgood test_with_matrix_notation
    testgood test_with_factor_variables
end

program setup_dataset
    set obs 100
    gen n = round(_n,10)
    gen x1 = round(5*runiform(), 1)
    gen x2 = round(5*runiform(), 1)
    gen x3 = round(5*runiform(), 1)
    gen x4 = round(5*runiform(), 1)
    gen a = _n
    gen y = a*rnormal(1)
end

program test_basic
    reg y x1 x2 x3 x4
    plotcoeffs x1 x2 x4, nodraw
end

program test_with_options
    reg y x1 x2 x3 x4
    plotcoeffs x1 x2 x4, graphs(bar) label("cows sheep grass") ytitle(Meat Production) nodraw
    plotcoeffs x1 x2 x4, graphs(err) label("cows sheep grass") ytitle(Meat Production) nodraw
    plotcoeffs x1 x2 x4, graphs(line) label("cows sheep grass") ytitle(Meat Production) nodraw
    plotcoeffs x1 x2 x4, graphs(linearea) label("cows sheep grass") ytitle(Meat Production) nodraw
    plotcoeffs x1 x2 x4, graphs(linenose) label("cows sheep grass") ytitle(Meat Production) nodraw
    plotcoeffs x1 x2 x4, graphs(nose) label("cows sheep grass") ytitle(Meat Production) nodraw
    plotcoeffs x1 x2 x4, graphs(connect) label("cows sheep grass") ytitle(Meat Production) nodraw
    plotcoeffs x1 x2 x4, yshift(10) lcolor(gs8) fcolor(gs6) nodraw
    plotcoeffs x1 x2 x4, nodraw savedata(plotted_coefs, replace)
    erase plotted_coefs.dta
    plotcoeffs x1 x2 x4, nodraw yshift(10) savedata("Plotted coefficients", replace)
    erase "Plotted coefficients.dta"
end

program test_with_multiple_regs
    reg y x1 x2 x3
    estimates store reg1
    reg y a x1 x2 x3 x4
    estimates store reg2
    plotcoeffs x1 x2 x3, estimates(reg1 reg2) graphs(err line) nodraw
    plotcoeffs x1 x2 x3, ///
        scheme(s1color) estimates(reg1 reg2) graphs(connect connect) yshift(5 10) nodraw
    plotcoeffs x1 x2 x3, ///
        combine estimates(reg1 reg2) graphs(connect) yshift(5) lcolor(blue) nodraw
end

program test_with_matrix_notation
    foreach V in x1 x2 x3 x4 {
        reg y `V'
        matrix beta1 = nullmat(beta1) \ _b[`V']
        matrix stderr1 = nullmat(stderr1) \ _se[`V']
    }
    matrix beta2 = beta1 + J(rowsof(beta1), 1, 15)
    matrix stderr2 = stderr1 * 0.5
    matrix beta = beta1 , beta2
    matrix stderr = stderr1 , stderr2
    plotcoeffs, b(beta1) se(stderr1) nodraw
    plotcoeffs, b(beta1) se(stderr1) graphs(line) nodraw
    plotcoeffs, b(beta) se(stderr) graphs(err linearea) nodraw
end

program test_with_factor_variables
    reg y i.n#c.a
    plotcoeffs i.n#c.a, nodraw
    plotcoeffs i.n#c.a, graphs(line) label( "1 2 3 4 5 6 7 8 9 10 11") ytitle(Production per year) xtitle(Year) nodraw
    reg y i.n#i.a
    plotcoeffs i.n#i.a, nodraw
    reg y c.n#c.a
    plotcoeffs c.n#c.a, nodraw
    reg y c.n#i.a
    plotcoeffs c.n#i.a, scheme(s1color) graphs(connect) nodraw
    reg y i.n##c.a
    plotcoeffs i.n##c.a, scheme(s1color) graphs(connect) nodraw
end


* EXECUTE
main

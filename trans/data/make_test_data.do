version 12
set more off
adopath + ../external/lib/stata/gslab_misc/ado
preliminaries

program main
    build_data
    save test_data, replace
end

program build_data
    syntax, [nobs(int 1000)] [intercept(real 1)] [slope(real 2)]
    set obs `nobs'
    gen x = uniform()
    gen y = `intercept'+`slope'*x
    matrix M = 0, 0, 0
    matrix C = (9, 5, 2 \ 5, 4, 1 \ 2, 1, 1)
    drawnorm x1 x2 y_nomean, n(`nobs') cov(C) means(M)
end

* EXECUTE
main
    
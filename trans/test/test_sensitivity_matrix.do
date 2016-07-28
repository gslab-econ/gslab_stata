version 12
set more off
adopath + ../ado
adopath + ../external/lib/stata/gslab_misc/ado
preliminaries

program main
    testgood test_basic_handling
    testbad test_non_gmm
    testgood test_two_regressors
end

program test_basic_handling
    quietly use ../data/test_data
    
    quietly gmm (y-{a}-{b}*x), instruments(x)
    quietly sensitivity_matrix
    checkdims
    
    quietly gmm (y-{b}*x), instruments(x)
    quietly sensitivity_matrix
    checkdims
    
    quietly gmm (y-exp({a}+{b}*x)), instruments(x)
    quietly sensitivity_matrix
    checkdims
    
    quietly gmm (x-exp({a}+{b}*x1+{c}*x2)) (y-{b0}+{b1}*x), ///
        instruments(x1 x2) winitial(unadjusted, independent)
    quietly sensitivity_matrix
    checkdims
end

program checkdims
    assert colsof(r(sensitivity)) == e(n_moments)
    assert rowsof(r(sensitivity)) == e(k)
    assert colsof(r(standardized_sensitivity)) == e(n_moments)
    assert rowsof(r(standardized_sensitivity)) == e(k)
end
    
program test_non_gmm
    quietly use ../data/test_data
    quietly reg y x
    quietly sensitivity_matrix
end

program test_two_regressors
    quietly use ../data/test_data
    quietly gmm (y-{b1}*x1-{b2}*x2), instruments(x1 x2, noconstant)
    quietly sensitivity_matrix
    matrix lambda = r(sensitivity)
    quietly correlate x1 x2, cov
    matrix XZ = r(C)
    matrix inv_XZ = inv(XZ)
    assert round(lambda[1,1], 0.01)==round(inv_XZ[1,1], 0.01)
    assert round(lambda[1,2], 0.01)==round(inv_XZ[1,2], 0.01)
    assert round(lambda[2,2], 0.01)==round(inv_XZ[2,2], 0.01)
end

* EXECUTE
main



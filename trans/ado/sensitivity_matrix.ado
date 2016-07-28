****************************************************************************************************
*
* SENSITIVITY_MATRIX.ADO
*
* Computes sensitivity matrix defined in Gentzkow and Shapiro (2013)
*
****************************************************************************************************

program sensitivity_matrix, rclass
    version 13
    is_valid_estimate
    
    compute_sensitivity
    matrix list Lambda
    matrix list Lambda_tilde
    return matrix sensitivity = Lambda
    return matrix standardized_sensitivity = Lambda_tilde
end

program is_valid_estimate
    assert e(cmd) == "gmm"
end

program compute_sensitivity
    matrix W = e(W)
    matrix Omega = e(S)
    matrix V = e(V)
    matrix G = e(G)
    
    matrix Lambda = - inv(G'*W*G)*(G'*W)
    
    matrix Lambda_tilde = J(e(k), e(n_moments), 0)
    forval i = 1/`e(k)' {
        forval j = 1/`e(n_moments)' {
            matrix Lambda_tilde[`i', `j'] = Lambda[`i', `j'] * sqrt(Omega[`j', `j'] / V[`i', `i'])
        }
    }
end

/***************************************************************
* fungible_outmatrix.ado: Program to output matrices for tables.
***************************************************************/

program fungible_outmatrix


	syntax, [robust] [ratio] matname(string)
	
	if "`ratio'"~="" {
		local ratiorow "\ (e(coef_gasexp)/e(coef_totexp))"
		local ratiocol ", (e(coef_gasexp)/e(coef_totexp))"
		local ratiomissing ", ."
	}
		
	local robust_table "( e(coef_price), e(coef_gasexp), e(coef_totexp) `ratiocol' , e(p_value) \ e(se_price), e(se_gasexp), e(se_totexp) `ratiomissing', . )"
	local mlogit_table "( -[2]_b[gasexp_prem] \ [2]_se[gasexp_prem] \ [2]_b[totexp_prem] \ [2]_se[totexp_prem] \ e(coef_price) \ e(se_price) \ e(coef_gasexp) \ e(se_gasexp) \ e(coef_totexp) \ e(se_totexp) `ratiorow' \ e(p_value) \ e(N) \ e(numid) )"
	local clogit_table "( -_b[gasexp_gap] \ _se[gasexp_gap] \ _b[totexp_gap] \ _se[totexp_gap] \ e(coef_price) \ e(se_price) \ e(coef_gasexp) \ e(se_gasexp) \ e(coef_totexp) \ e(se_totexp) `ratiorow' \ e(p_value) \ e(numgroups) \ e(numid) )"
	local linear_table "( -_b[gasexp] \ _se[gasexp] \ _b[totexp] \ _se[totexp] \ e(coef_price) \ e(se_price) \ e(coef_gasexp) \ e(se_gasexp) \ e(coef_totexp) \ e(se_totexp) `ratiorow' \ e(p_value) \ e(N) \ e(N_clust) )"

	if "`robust'"~="" {
		matrix `matname' = `robust_table'
		}
	else {
		if e(cmd)=="mlogit" {
			matrix `matname' = `mlogit_table'
			}
		if e(cmd)=="clogit"|e(cmd)=="mixlogit" {
			matrix `matname' = `clogit_table'
			}
		if e(cmd)=="regress"|e(cmd)=="ivregress" {
			matrix `matname' = `linear_table'
			}
		}

end


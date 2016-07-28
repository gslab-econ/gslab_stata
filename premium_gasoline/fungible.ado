/***************************************************************
* fungible.ado: Program to estimate model of grade choice
*                        and formally test fungibility hypothesis
***************************************************************/

program fungible, eclass

	version 11.1
	syntax [if], grade(varname) [cluster(varname)] quantity(varname) share(varname) gapvar(varname) depvar(varname) totexp(varname) gasexp(varname) inciv(varlist fv) priceiv(varlist fv) controls(varlist fv) adjust(real) [ols]
	
	* List of possible grades
	vallist `grade' `if', local(gradelist)
	
	* Normalize expenditure variables for readability
	cap drop totexp gasexp
	gen totexp = `totexp'/`adjust'
	gen gasexp = `gasexp'/`adjust'

	* Estimate model via 2SLS or OLS
	local clustcommand ""
	if "`cluster'"~="" {
		local clustcommand ", cluster(`cluster')"
		}
	if "`ols'"=="" {
	ivregress 2sls `depvar' (totexp gasexp = `inciv' `priceiv') `controls' `if' `clustcommand'
	}
	else {
	reg `depvar' totexp gasexp `controls' `if' `clustcommand'
	}
	
	* Constant to translate coefficient into marginal effect on regular share
	tempvar deriv
	quietly gen `deriv' = `share'*(1-`share')*`gapvar'
	local regshare_deriv = 0
	foreach grade in `gradelist' {
		quietly sum `deriv' if `grade'==`grade'&e(sample)
		local regshare_deriv = `regshare_deriv' - r(mean)
		}

	* Constant to translate gas expenditure coefficient into implied effect per $1 price of gas
	tempvar deriv_implied
	quietly gen `deriv_implied' = `deriv'*`quantity'/`adjust'
	local regshare_deriv_implied = 0
	foreach grade in `gradelist' {
		quietly sum `deriv_implied' if `grade'==`grade'&e(sample)
		local regshare_deriv_implied = `regshare_deriv_implied' + r(mean)
		}
	
	oo Compute average marginal effect of $1 price increase on regular share
	lincom -`regshare_deriv_implied'*_b[gasexp]
	ereturn scalar coef_price = r(estimate)
	ereturn scalar se_price = r(se)

	oo Compute effect of $`adjust' of gas expenditure on regular share
	lincom -`regshare_deriv'*_b[gasexp]
	ereturn scalar coef_gasexp = r(estimate)
	ereturn scalar se_gasexp = r(se)

	oo Compute effect of $`adjust' of other expenditure on regular share
	lincom `regshare_deriv'*_b[totexp]
	ereturn scalar coef_totexp = r(estimate)
	ereturn scalar se_totexp = r(se)

	oo Formal test of fungibility
	test totexp = -gasexp
	ereturn scalar Chi2 = r(chi2)
	ereturn scalar p_value = r(p)

end


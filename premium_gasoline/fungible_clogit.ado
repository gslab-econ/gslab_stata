/***************************************************************
* fungible_clogit.ado: Program to estimate conditional logit model of grade choice
*                        and formally test fungibility hypothesis
***************************************************************/

program fungible_clogit, eclass

	version 11.1
	syntax [if], group(varname) grade(varname) [cluster(varname)] quantity(varname) choice(varname) /// 
				gapvar(varname) totexp(varname) gasexp(varname) [controls(varlist fv)] adjust(real) ///
				id(varname) [nrep(int 50)]  [rand(varlist)] [mix] [corr] [sgi] [accuracy(int 3)] ///
				[iterate(int 50)] [first_step_estimates(string)] [max_options(string)]
	
	* Load first-step esitmates (if specified)
	if "`first_step_estimates'"~="" {
		estimates use `first_step_estimates'
		matrix b1 = e(b)
		matrix V1 = e(V)
		* code assumes first-step model has a constant and a coefficient
		assert colsof(b1)==2
		assert colnumb(b1, "_cons")==2
	}		
	
	
	* List of possible grades
	quietly vallist `grade' `if', local(gradelist)
	
	* Normalize expenditure variables for readability
	cap drop totexp gasexp
	gen totexp = `totexp'/`adjust'
	gen gasexp = `gasexp'/`adjust'
		
	* Build interactions
	cap drop totexp_gap gasexp_gap
	quietly gen totexp_gap = totexp*`gapvar'
	quietly gen gasexp_gap = gasexp*`gapvar'

	if "`mix'"=="" {
		* Estimate model
		clogit `choice' totexp_gap gasexp_gap `controls' `if', group(`group') cluster(`cluster')

		* Predicted probabilities
		tempvar share
		predict `share', pc1
		
		* Marginal effect
		tempvar deriv
		quietly gen `deriv' = `share'*(1-`share')*`gapvar'
		
	}		
	
	else {
		* Estimate model
		mixlogit_sgi `choice' totexp_gap gasexp_gap `controls' `if',  /// 
		group(`group') cluster(`cluster') id(`id') rand(`rand') `corr'  /// 
		nrep(`nrep') `sgi' accuracy(`accuracy') iterate(`iterate') `max_options'

		* Predicted probabilities (not used--included for parallelism)
		tempvar share
		mixlpred `share'
		
		* Marginal effect (cannot be calculated from predicted probabilities because this is a nonlinear function inside an integral)
		tempvar tempderiv deriv
		mixlderiv `tempderiv'
		quietly gen `deriv' = `tempderiv'*`gapvar'
		
	}
	
	* Adjust standard errors if first-step model is specified
	if "`first_step_estimates'"~="" {		
		matrix V2 = e(V)
		matrix b2 = e(b)
		matrix J = J(colsof(b2), 2, 0)
		matrix J[rownumb(V2, "gap"), 2]=-1/`adjust'
		matrix J[rownumb(V2, "totexp_gap"), 1]=-scalar(b2[1, colnumb(b2, "totexp_gap")])/scalar(b1[1, 1])
		matrix V2_adj = V2+J*V1*J'
		ereturn repost V = V2_adj
		display "After adjusting e(V) for two-step estimation:"
		estimates replay
	}
		
	* Constant to translate coefficient into marginal effect on regular share
	local regshare_deriv = 0
	foreach g in `gradelist' {
		if `g'~=0 {
			quietly sum `deriv' if `grade'==`g'&e(sample)
			local regshare_deriv = `regshare_deriv' - r(mean)
			}
		}

	* Constant to translate gas expenditure coefficient into implied effect per $1 price of gas
	tempvar deriv_implied
	quietly gen `deriv_implied' = `deriv'*`quantity'/`adjust'
	local regshare_deriv_implied = 0
	foreach g in `gradelist' {
		if `g'~=0 {
			quietly sum `deriv_implied' if `grade'==`g'&e(sample)
			local regshare_deriv_implied = `regshare_deriv_implied' + r(mean)
			}
		}
	
	oo Compute average marginal effect of $1 price increase on regular share
	lincom -`regshare_deriv_implied'*_b[gasexp_gap]
	ereturn scalar coef_price = r(estimate)
	ereturn scalar se_price = r(se)

	oo Compute effect of $`adjust' of gas expenditure on regular share
	lincom -`regshare_deriv'*_b[gasexp_gap]
	ereturn scalar coef_gasexp = r(estimate)
	ereturn scalar se_gasexp = r(se)

	oo Compute effect of $`adjust' of other expenditure on regular share
	lincom `regshare_deriv'*_b[totexp_gap]
	ereturn scalar coef_totexp = r(estimate)
	ereturn scalar se_totexp = r(se)

	oo Formal test of fungibility
	test totexp_gap = -gasexp_gap
	ereturn scalar Chi2 = r(chi2)
	ereturn scalar p_value = r(p)
	
	* Compute number of households
	unique `id' if e(sample)
	ereturn scalar numid = r(sum)

	* Compute number of transactions
	unique `group' if e(sample)
	ereturn scalar numgroups = r(sum)

end


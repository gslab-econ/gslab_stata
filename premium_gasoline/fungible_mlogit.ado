/***************************************************************
* fungible_mlogit.ado: Program to estimate multinomial logit model of 
*                        grade choice and formally test fungibility hypothesis
***************************************************************/

program fungible_mlogit, eclass

	version 11.1
	syntax [if], idvar(varname) depvar(varname) plusgap(varname) premgap(varname) adjust(real) ///
	quantity(varname) totexp(varname) gasexp(varname) ///
	[cluster(varname)] [controls(varlist fv)] [controls_constrained(varlist)] [fungible] ///
	[controls_stub(namelist)] [first_step_estimates(string)]
	
	* Load first-step esitmates (if specified)
	if "`first_step_estimates'"~="" {
		estimates use `first_step_estimates'
		matrix b1 = e(b)
		matrix V1 = e(V)
		* code assumes first stage model has a constant and a coefficient
		assert colsof(b1)==2
		assert colnumb(b1, "_cons")==2
	}		
	
	* Normalize expenditure variables for readability
	cap drop totexp gasexp
	quietly gen totexp = `totexp'/`adjust'
	quietly gen gasexp = `gasexp'/`adjust'

	* Build interactions
	cap drop totexp_plus totexp_prem gasexp_plus gasexp_prem
	quietly gen totexp_plus = totexp*`plusgap'
	quietly gen totexp_prem = totexp*`premgap'
	quietly gen gasexp_plus = gasexp*`plusgap'
	quietly gen gasexp_prem = gasexp*`premgap'
	
	local constrainlist ""
	if "`controls_constrained'"~=""{
		foreach variable of varlist `controls_constrained' {
			quietly gen `variable'_plus = `variable'*`plusgap'
			quietly gen `variable'_prem = `variable'*`premgap'
			local constrainlist "`constrainlist' `variable'_plus `variable'_prem"
		}
	}
	
	local stublist ""
	if "`controls_stub'"~=""{
		foreach stub in `controls_stub' {
			local stublist "`stublist' `stub'_plus `stub'_prem"
		}
	}
	
	
	* Define cluster command
	local clustcommand ""
	if "`cluster'"~="" {
		local clustcommand "cluster(`cluster')"
		}
	
	* Define constraints
	constraint 1 [1]`premgap'=0
	constraint 2 [2]`plusgap'=0
	constraint 3 [1]`plusgap'=[2]`premgap'

	constraint 4 [1]totexp_prem=0
	constraint 5 [2]totexp_plus=0
	constraint 6 [1]totexp_plus=[2]totexp_prem

	constraint 7 [1]gasexp_prem=0
	constraint 8 [2]gasexp_plus=0
	constraint 9 [1]gasexp_plus=[2]gasexp_prem
	
	local numconstraints = 9
	if "`controls_constrained'"~=""{
		foreach variable of varlist `controls_constrained' {
			local numconstraints = `numconstraints'+1
			constraint `numconstraints' [1]`variable'_prem=0
			local numconstraints = `numconstraints'+1
			constraint `numconstraints' [2]`variable'_plus=0
			local numconstraints = `numconstraints'+1
			constraint `numconstraints' [1]`variable'_plus=[2]`variable'_prem
		}
	}
	
	if "`controls_stub'"~=""{
		foreach stub in `controls_stub' {
			local numconstraints = `numconstraints'+1
			constraint `numconstraints' [1]`stub'_prem=0
			local numconstraints = `numconstraints'+1
			constraint `numconstraints' [2]`stub'_plus=0
			local numconstraints = `numconstraints'+1
			constraint `numconstraints' [1]`stub'_plus=[2]`stub'_prem
		}
	}

	
	if "`fungible'"~=""{
		local numconstraints = `numconstraints' + 1
		constraint `numconstraints' [1]totexp_plus=-[1]gasexp_plus
	}
	
	* Estimate model
	mlogit `depvar' `plusgap' `premgap' totexp_plus totexp_prem gasexp_plus gasexp_prem ///
		`controls' `stublist' `constrainlist' `if', col constraint(1/`numconstraints') `clustcommand'
	cap drop pred0 pred1 pred2
	predict pred0 pred1 pred2

	* Adjust standard errors if first-step model is specified
	if "`first_step_estimates'"~="" {		
		matrix V2 = e(V)
		matrix b2 = e(b)
		matrix J = J(colsof(b2), 2, 0)
		matrix J[rownumb(V2, "1:diff_plus"), 2]=-1/`adjust'
		matrix J[rownumb(V2, "2:diff_prem"), 2]=-1/`adjust'
		matrix J[rownumb(V2, "1:totexp_plus"), 1]=-scalar(b2[1, colnumb(b2, "1:totexp_plus")])/scalar(b1[1, 1])
		matrix J[rownumb(V2, "2:totexp_prem"), 1]=-scalar(b2[1, colnumb(b2, "2:totexp_prem")])/scalar(b1[1, 1])
		matrix V2_adj = V2+J*V1*J'
		ereturn repost V = V2_adj
		display "After adjusting e(V) for two-step estimation:"
		estimates replay
	}		
	
	* Constant to translate coefficients into marginal effects on regular share
	tempvar deriv deriv_qty
	quietly gen `deriv' = 0-((pred1*(1-pred1))*`plusgap')-((pred2*(1-pred2))*`premgap')
	quietly sum `deriv' if e(sample)
	local mean_deriv = r(mean)
	
	quietly gen `deriv_qty' = `deriv'*`quantity'/`adjust'
	quietly sum `deriv_qty' if e(sample)
	local mean_deriv_qty = -r(mean)
	
	oo Compute average marginal effect of $1 price increase on regular share
	lincom -`mean_deriv_qty'*[2]_b[gasexp_prem]
	ereturn scalar coef_price = r(estimate)
	ereturn scalar se_price = r(se)

	oo Compute effect of $`adjust' of gas expenditure on regular share
	lincom -`mean_deriv'*[2]_b[gasexp_prem]
	ereturn scalar coef_gasexp = r(estimate)
	ereturn scalar se_gasexp = r(se)

	oo Compute effect of $`adjust' of other expenditure on regular share
	lincom `mean_deriv'*[2]_b[totexp_prem]
	ereturn scalar coef_totexp = r(estimate)
	ereturn scalar se_totexp = r(se)

	oo Formal test of fungibility
	test [2]_b[totexp_prem] = -[2]_b[gasexp_prem]
	ereturn scalar Chi2 = r(chi2)
	ereturn scalar p_value = r(p)
	
	* Compute number of unique households
	unique `idvar' if e(sample)
	ereturn scalar numid = r(sum)

end


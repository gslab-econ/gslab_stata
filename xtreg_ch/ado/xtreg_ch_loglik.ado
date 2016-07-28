/**********************************************************
 *
 * xtreg_ch_loglik.ado: log likelihood for xtreg_ch
 *
 **********************************************************/

program xtreg_ch_loglik

	version 10
	args todo b lnf g
	tempname lns_e lns_u sig_e sig_u gamma eta
	tempname dxb dse dsu dg
	tempvar xb meanxb ytilde sigtilde2 last T Slnsig2 Sinvsig2 Sytilde2_sig2 Sytilde_sig2 Sinvsig4 Sytilde_sig4 Sytilde2_sig4

	mleval `xb' = `b', eq(1)
	mleval `lns_u' = `b', eq(2) scalar
	mleval `lns_e' = `b', eq(3) scalar
	mleval `gamma' = `b', eq(4) scalar

	scalar `sig_e' = exp(`lns_e')
	scalar `sig_u' = exp(`lns_u')

	// $ML_y1-3 contain lhs var, panel id, and heteroskedasticity
	// variable respectively
	local y $ML_y1
	local by $ML_y2
	local r $ML_y3 

	sort `by'

	quietly {


		egen double `meanxb' = mean(`xb'), by(`by')
		gen double `ytilde' = `y' - `xb' - `meanxb'*`gamma'
		gen double `sigtilde2' = `sig_e'^2 + `r'
		by `by': gen `last' = _n==_N
		by `by': gen `T' = _N
		by `by': gen double `Slnsig2' = sum(ln(`sigtilde2'))
		by `by': gen double `Sinvsig2' = sum(1/`sigtilde2')
		by `by': gen double `Sinvsig4' = sum(1/`sigtilde2'^2)
		by `by': gen double `Sytilde_sig2' = sum(`ytilde'/`sigtilde2')
		by `by': gen double `Sytilde2_sig2' = sum(`ytilde'^2/`sigtilde2')
		by `by': gen double `Sytilde_sig4' = sum(`ytilde'/`sigtilde2'^2)
		by `by': gen double `Sytilde2_sig4' = sum(`ytilde'^2/`sigtilde2'^2)

		// compute the likelihood
		mlsum `lnf' = -.5 *					///
			(						///
				`Slnsig2' +				///
				ln(1 + `sig_u'^2*`Sinvsig2') +		///
				`Sytilde2_sig2' -				///
				`Sytilde_sig2'^2 / (1/`sig_u'^2 + `Sinvsig2') +	///
				`T'*ln(2*c(pi))				///
			) 						///
			if `last' == 1
		if (`todo'==0 | `lnf'>=.) exit

		// compute the gradient

		// gradient for xb is summed observation-by-observation whereas 
		// other gradients are summed only for last==1; this is because sum
		// for xb must be weighted by each observation's x; see Stata ML book
		// for details
		by `by': gen double `dxb' =					///
			(1 + `gamma'/`T') * (					///
				`ytilde'/`sigtilde2' -				///
				`Sytilde_sig2'[_N] *				///
				(1/`sigtilde2') /				///
				(1/`sig_u'^2 + `Sinvsig2'[_N])			///
			)
		mlvecsum `lnf' `dxb' = `dxb', eq(1)
		
		// gradient for lns_e
		// (this is `sig_e' times gradient w.r.t. `sig_e')
		mlvecsum `lnf' `dse' = `sig_e' *					///
			-`sig_e' * (							///
			`Sinvsig2' -							///
			`sig_u'^2 *`Sinvsig4' / (1 + `sig_u'^2*`Sinvsig2') -		///
			`Sytilde2_sig4' +						///
			2*`Sytilde_sig2'*`Sytilde_sig4' / (1/`sig_u'^2 + `Sinvsig2') -	///
			`Sytilde_sig2'^2*`Sinvsig4' / (1/`sig_u'^2 + `Sinvsig2')^2	///
			) if `last'==1, eq(2)

		// gradient for lns_u
		// (this is `sig_u' times gradient w.r.t. `sig_u')
		mlvecsum `lnf' `dsu' = `sig_u'*	(					///
			-`sig_u'*`Sinvsig2'/(1+`sig_u'^2*`Sinvsig2') +			///
			(1/`sig_u'^3)*`Sytilde_sig2'^2 / (1/`sig_u'^2 + `Sinvsig2')^2	///
			) if `last'==1, eq(3)

		// gradient for gamma
		mlvecsum `lnf' `dg' =						///
			`meanxb'*`Sytilde_sig2' * (					///
			1 - `Sinvsig2' / (1/`sig_u'^2 + `Sinvsig2')			///
			)							///
			if `last'==1, eq(4)
	
		mat `g' = (`dxb',`dsu',`dse',`dg')
	}
end





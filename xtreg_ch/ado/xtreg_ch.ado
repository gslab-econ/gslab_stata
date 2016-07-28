/**********************************************************
 *
 * xtreg_ch
 *
 **********************************************************/

program xtreg_ch
	version 10
	if replay() {
		if (`"`e(cmd)'"' != "myrereg") error 301
		Replay `0'
	}
	else	Estimate `0'
end

program Estimate, eclass sortpreserve
	syntax varlist(ts) [if] [in] ,		///
		i(varname)			///
	[					///
		Hetero(varname)			/// my options
		Corr				///
		noLOg noCONStant		/// -ml model- options
		noLRTEST			///
		Level(cilevel)			/// -Replay- options
		*				/// -mlopts- options
	]

	// check syntax
	local diopts level(`level')
	mlopts mlopts , `options'
	local cns `s(constraints)'
	gettoken lhs rhs : varlist
	if "`cns'" != "" {
		local lrtest nolrtest
	}
	if "`log'" != "" {
		local qui quietly
	}

	// mark the estimation sample
	marksample touse
	markout `touse' `i', strok

	// define constraint for correlation parameter (gamma)
	constraint 1 [gamma]_cons = 0
	if "`corr'"=="" {
		local fullcons = "1"
	}
	else {
		local fullcons = ""
	}

	// define heterogeneity variable
	tempvar hvar
	if "`hetero'"=="" {
		// if we want no heterogeneity arbitrarily define hvar=1 and fix eta=0
		gen `hvar' = 1
	}
	else {
		// otherwise take user-defined variable and user-defined eta (default = 1)
		gen `hvar' = `hetero'
	}

	// capture block to ensure removal of global macro
capture noisily {

	// identify the panel variable for the evaluator
	global MY_panel `i'
	sort `i'

	// fit the constant-only model
	if "`constant'" == "" {
		// initial values: variance components from one-way ANOVA
		sum `lhs' if `touse', mean
		local mean = r(mean)
		quietly oneway `lhs' `i' if `touse'
		local np  = r(df_m) + 1
		local N   = r(N)
		local bms = r(mss)/r(df_m)	// between mean squares
		local wms = r(rss)/r(df_r)	// within mean squares
		local lns_u = log( (`bms'-`wms')*`np'/`N' )/2
		if missing(`lns_u') {
			local lns_u = 0
		}
		local lns_e = log(`wms')/2

		local	initopt 		///
			init(/xb=`mean' /lns_u=`lns_u' /lns_e=`lns_e')


		`qui' di as txt _n "Fitting constant-only model:"
		ml model d1 xtreg_ch_loglik				///
			(xb: `lhs' `i' `hvar' = , `offopt' `expopt' )	///
			/lns_u					///
			/lns_e					///
			/gamma					///
			if `touse',				///
			`log' `mlopts' `initopt'		///
			constraint(1)				///
			nocnsnotes missing maximize
		if "`lrtest'" == "" {
			local contin continue search(off)
*			local contin continue

		}
		else {
			tempname b0
			mat `b0' = e(b)
			local contin init(`b0') search(off)
*			local contin init(`b0')

		}
	}

	// fit the full model
	`qui' di as txt _n "Fitting full model:"
	ml model d1 xtreg_ch_loglik			///
		(xb: `lhs' `i' `hvar' = `rhs',			///
			`constant' `offopt' `expopt'	///
		)					///
		/lns_u					///
		/lns_e					///
		/gamma					///
		if `touse',				///
		`log' `mlopts' `contin'			///
		constraint(`fullcons')			///
		missing maximize
*	ml maximize, gradient trace

	// clear MY global
	global MY_panel

} // capture noisily

	// exit in case of error
	if c(rc) exit `c(rc)'

	ereturn scalar k_aux = 3
	// save the panel variable
	ereturn local i `i'
	// save a title for -Replay- and the name of this command
	ereturn local title "My rereg estimates"
	ereturn local cmd myrereg

	Replay , `diopts'
end

program Replay
	syntax [, Level(cilevel) ]
	ml display , level(`level')			///
		diparm(lns_u, exp label("sigma_u"))	///
		diparm(lns_e, exp label("sigma_e"))
end

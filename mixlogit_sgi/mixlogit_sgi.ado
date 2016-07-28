*! mixlogit 1.2.2 18Oct2010
*! author arh

*  1.1.0:  	-mixlogit- now uses analytical gradients by default 
*		and allows robust and cluster-robust SEs and weights

*  1.1.1:  	a bug in the routine for dealing with weights and 
*		cluster-robust SEs has been fixed. The bug did not
*		affect the estimation results. 

*  1.2.0:	-mixlbeta-, a postestimation command for calculating
*		individual-level parameters has been added. 

*  1.2.1:	a bug affecting the constraints option has been fixed

*  1.2.2:	a bug affecting the mixlbeta module has been fixed

program mixlogit_sgi
	version 9.2
	if replay() {
		if (`"`e(cmd)'"' != "mixlogit") error 301
		Replay `0'
	}
	else	Estimate `0'
end

program Estimate, eclass
	syntax varlist [if] [in] 		///
		[fweight pweight iweight/],	///
		GRoup(varname) 			///
		RAND(varlist) [			///
		ID(varname) 			///
		LN(integer 0) 			///
		CORR					///
		NREP(integer 50)			///
		BURN(integer 15)			///
		ACCuracy(integer 3)			///
		SGI					///
		Robust				///
		CLuster(varname)			///
		FRom(string)			/// 
		Level(integer `c(level)')	///
		NUMerical				///
		TRace					///
		GRADient				///
		HESSian				///
		SHOWSTEP				///
		ITERate(passthru)			///
		TOLerance(passthru)		///
		LTOLerance(passthru)		///
		GTOLerance(passthru)		///
		NRTOLerance(passthru)		///
		CONSTraints(passthru)		///
		TECHnique(passthru)		///
		DIFficult				///
	]

	local mlopts `trace' `gradient' `hessian' `showstep' `iterate' `tolerance' ///
	`ltolerance' `gtolerance' `nrtolerance' `technique' `difficult'

	if ("`technique'" == "technique(bhhh)") {
		di in red "technique(bhhh) is not allowed."
		exit 498
	}

	** Check that group, id and cluster variables are numeric **
	capture confirm numeric var `group'
	if _rc != 0 {
		di in r "The group variable must be numeric"
		exit 498
	}
	if ("`id'" != "") {
		capture confirm numeric var `id'
		if _rc != 0 {
			di in r "The id variable must be numeric"
			exit 498
		}
	}
	if ("`cluster'" != "") {
		capture confirm numeric var `cluster'
		if _rc != 0 {
			di in r "The cluster variable must be numeric"
			exit 498
		}
	}

	** Mark the estimation sample **
	marksample touse
	markout `touse' `group' `rand' `id' `cluster'

	** Check that no variables have been specified to have both fixed and random coefficients **
	gettoken lhs fixed : varlist
	local k1 : word count `fixed'
	local k2 : word count `rand' 
	forvalues i = 1(1)`k1' {
		forvalues j = 1(1)`k2' {
			local w1 : word `i' of `fixed' 
			local w2 : word `j' of `rand'
			if ("`w1'" == "`w2'") {
				di in red "The variable `w1' is specified to have both fixed and random coefficients"
				exit 498
			} 	
		}
	}

	** Use robust SEs with pweight even if not specified **
	if ("`weight'" == "pweight" & "`robust'" == "" & "`cluster'" == "") local robust robust

	** Create local wgt for use with clogit if weights are specified **
	if ("`weight'" != "") local wgt "[`weight' = `exp']"

	** Check that starting values are specified with the constraints option **
	if ("`constraints'" != "" & "`from'" == "") {
		di in red "When constraints are specified it is compulsory to supply starting values using the from option"
		exit 498
	}

	** Check for multicollinearity **
	local rhs `fixed' `rand'
	qui _rmcoll `rhs' 
	if ("`r(varlist)'" != "`rhs'" & "`constraints'" != "") {
		di in gr "Some variables are collinear - make sure this is intended, i.e. because you are"
		di in gr "estimating an error-components model with the necessary constraints imposed"
	}
	if ("`r(varlist)'" != "`rhs'" & "`constraints'" == "") {
		di in red "Some variables are collinear - check your model specification"
		exit 498
	}

	** Estimate conditional logit model - if constraints are specified this is simply to set estimation sample **
	if ("`constraints'" == "") {
		qui clogit `lhs' `rhs' if `touse' `wgt', group(`group')
		local nobs = e(N)
		local ll = e(ll)
		local k  = e(k)
		qui replace `touse' = e(sample)
	}
	else {
		qui clogit `lhs' `rhs' if `touse' `wgt', group(`group')
		local nobs = e(N)
		qui replace `touse' = e(sample)
	}

	** Drop missing data **
	preserve
	qui keep if `touse'

	** Check that the independent variables vary within groups **
	sort `group'
	foreach var of varlist `rhs' {
		capture by `group': assert `var'==`var'[1]
		if (_rc == 0) {
			di in red "Variable `var' has no within-group variance"
			exit 459		
		}
	}

	** Check that the dependent variable only takes values 0-1 **
	capture assert `lhs' == 0 | `lhs' == 1
	if (_rc != 0) {
		di in red "The dependent variable must be a 0-1 variable indicating which alternatives are chosen"
		exit 450		
	}

	** Check that each group has only one chosen alternative **
	tempvar chonum
	sort `group'
	qui by `group': egen `chonum' = sum(`lhs')
	capture assert `chonum' == 1
	if (_rc != 0) {
		di in red "At least one group has more than one chosen alternative"
		exit 498		
	}

	** Check that weights are the same within decision-makers **
	if ("`weight'" != "" & "`id'" != "") {
		capture confirm number `exp'
 		if _rc != 0 {
			tempvar sum1 sum2
			sort `id' 
			qui by `id': egen `sum1' = sum(1)
			sort `id' `exp'
			qui by `id' `exp': egen `sum2' = sum(1)
			capture assert `sum1' == `sum2'  
			if _rc != 0 {
				di in r "Weights must be the same within decision-makers"
				exit 498
			}
			drop `sum1' `sum2'
		}
	}

	** Generate individual id **
	if ("`id'" != "") {
		tempvar nchoice pid
		sort `group'
		by `group': gen `nchoice' = cond(_n==_N,1,0)
		sort `id'
		by `id': egen `pid' = sum(`nchoice')		
		qui duplicates report `id'
		mata: mixl_np = st_numscalar("r(unique_value)")
		mata: mixl_T = st_data(., st_local("pid"))
	}
	else {
		qui duplicates report `group'
		mata: mixl_np = st_numscalar("r(unique_value)")
		mata: mixl_T = J(st_nobs(),1,1)
	}

	** Generate dummy for last obs for each decision-maker**
	if ("`weight'" != "" | "`cluster'" != "") { 
		tempvar last
		if ("`id'" != "") {
			by `id': gen `last' = cond(_n==_N,1,0)
		}
		else {
			sort `group'
			by `group': gen `last' = cond(_n==_N,1,0)
		}
	}

	** Generate choice occasion id **
	tempvar csid
	sort `group'
	by `group': egen `csid' = sum(1)

	** Sort data **
	sort `id' `group'

	** Set Mata matrices and scalars to be used in optimisation routine **
	local kfix: word count `fixed'
	local krnd: word count `rand'

	mata: mixl_X = st_data(., tokens(st_local("rhs")))
	mata: mixl_Y = st_data(., st_local("lhs"))
	mata: mixl_CSID = st_data(., st_local("csid"))

	mata: mixl_nrep = strtoreal(st_local("nrep"))
	mata: mixl_accuracy = strtoreal(st_local("accuracy"))
	mata: mixl_kfix = strtoreal(st_local("kfix"))
	mata: mixl_krnd = strtoreal(st_local("krnd"))
	mata: mixl_krln = strtoreal(st_local("ln"))
	mata: mixl_burn = strtoreal(st_local("burn"))
	mata: mixl_robust = 0
	mata: mixl_cluster = 0
	
	if ("`sgi'" != "") {
		mata: mixl_sgi = 1
		}
	else {
		mata: mixl_sgi = 0
		}
		
	if ("`weight'" != "") { 
   		capture confirm number `exp'
   		if _rc != 0 {
			mata: mixl_WGT = st_data(., st_local("exp"), st_local("last"))
   		}
		else {
			mata: mixl_WGT = J(mixl_np,1,strtoreal(st_local("exp")))
		}
		mata: mixl_wgttyp = st_local("weight")
	}
	else {
		mata: mixl_WGT = J(mixl_np,1,1)
		mata: mixl_wgttyp = ""
	}

	if ("`cluster'" != "") {
		mata: mixl_CLUST = st_data(., st_local("cluster"), st_local("last"))
		qui duplicates report `cluster'
		mata: mixl_nclust = st_numscalar("r(unique_value)")
		local nclust = r(unique_value)
	}

	** Restore data **
	restore

	** Create macro to define equations for optimisation routine **
	local mean (Mean: `rhs', noconst)
	if ("`corr'" == "") {
		mata: mixl_corr = 0
		local sd (SD: `rand', noconst)
		local max `mean' `sd' 
	}
	else {
		mata: mixl_corr = 1
		local cho = `krnd'*(`krnd'+1)/2
		mata: mixl_ncho = strtoreal(st_local("cho"))
		local max `mean'
		forvalues i = 1(1)`krnd' {
			forvalues j = `i'(1)`krnd' {
				local max `max' /l`j'`i'
			}
		}
	}

	** Create matrix of starting values unless specified **
	if ("`from'" == "") {
		tempname b from
		matrix `b' = e(b)
		if ((`kfix'+`krnd')>`ln') matrix `from' = `b'[1,1..(`kfix'+`krnd'-`ln')]
		forvalues i = 1(1)`ln' {
			if (`b'[1,(`kfix'+`krnd'-`ln'+`i')] <= 0) {
				di in red "Variables specified to have log-normally distributed coefficients should have positive"
				di in red "coefficients in the conditional logit model. Try multiplying the variable by -1."
				exit 498
			}
			if ((`kfix'+`krnd')==`ln' & `i'==1) matrix `from' = ln(`b'[1,1])
			else matrix `from' = `from', ln(`b'[1,(`kfix'+`krnd'-`ln'+`i')])
		} 
		if ("`corr'" == "") matrix `from' = `from', J(1,`krnd',0.1)
		else matrix `from' = `from', J(1,`cho',0.1)
		local copy , copy
	}

	** Run optimisation routine **
	if ("`numerical'" != "") local method d0
	else local method d1
	ml model `method' mixlog_d1_sgi						///
		`max' if `touse', search(off) init(`from' `copy') 	///
		`mlopts' maximize	lf0(`k' `ll') missing nopreserve	///
		obs(`nobs') `constraints' 			

	** Calculate robust or cluster-robust SEs if requested **
	if ("`robust'" != "" | "`cluster'" != "") {
		tempname from V
		matrix `from' = e(b)
		matrix `V' = e(V)
		mata: mixl_V = st_matrix("`V'")
		mata: mixl_robust = 1
		if ("`cluster'" != "") mata: mixl_cluster = 1
		ml model d2 mixlog_d1_sgi 							///
			`max' if `touse', search(off) init(`from' `copy') 	///
			maximize missing nopreserve iter(0) nowarning nolog	///
			obs(`nobs') `constraints' 
	}

	** To be returned as e() **
	ereturn local title "Mixed logit model"
	ereturn local indepvars `rhs'
	ereturn local depvar `lhs'
	ereturn local group `group'
	ereturn local sgi `sgi'
	ereturn scalar kfix = `kfix'

	ereturn scalar krnd = `krnd'
	ereturn scalar krln = `ln'
	ereturn scalar nrep = `nrep'
	ereturn scalar accuracy = `accuracy'
	ereturn scalar burn = `burn'
	if ("`corr'" != "") {
		ereturn scalar corr = 1
		ereturn scalar k_aux = `cho'
	}
	else ereturn scalar corr = 0
	if ("`id'" != "") ereturn local id `id'
	if ("`robust'" != "") ereturn local vcetype Robust
	if ("`cluster'" != "") {	
		ereturn scalar N_clust = `nclust'
		ereturn local clustvar `cluster'
		ereturn local vcetype Robust
	}
	if ("`weight'" != "") { 
		ereturn local wexp `exp'
		ereturn local wtype `weight'
	}
	ereturn local cmd "mixlogit"

	if ("`corr'" == "") Replay , level(`level')
	else Replay , level(`level') corr
end

program Replay
	syntax [, Level(integer `c(level)') CORR]
	ml display , level(`level')
	if ("`corr'" == "") {
		di in gr "The sign of the estimated standard deviations is irrelevant: interpret them as"
		di in gr "being positive"
	}
end

exit



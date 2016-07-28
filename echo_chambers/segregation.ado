/**********************************************************
 *
 * SEGREGATION.ADO: CALCULATIONS OF SEGREGATION
 *  Loops over different measures of website size and
 *  outputs statistics related to website segregation.
 *
 *  Output location, measure(s) of website size, and ideology measure
 *  must be specified. Description of specification must also be specified.
 *  IF allows the user to specify different sample restrictions
 *  (e.g., top 20, exclude top 20), and the default is the entire sample.
 *  SOURCE allows the user to specify the data source
 *  (ComScore, MRI, GSS), and the default is ComScore.
 *
 **********************************************************/

program define segregation

	version 11
	syntax anything using/, ideology(varname) [if(string) source(string) adjusted(varlist)] descrip(string)
	
	if "`if'"=="" {
		local if "0==0"
	}
	
	tempvar cons_`anything' lib_`anything'
	gen `cons_`anything'' = `anything'*`ideology'
	gen `lib_`anything'' = `anything'*(1-`ideology')
	
	** DESCRIPTION OF SPECIFICATION **
	file write `using' "`descrip'" _tab

	** DATA SOURCE (COMSCORE, MRI, GSS) **
	if "`source'"!="" {
		file write `using' "`source'" _tab
	}
	else {
		file write `using' "COMSCORE" _tab
	}

	** ADJUSTED MEASURES OF IDEOLOGY **
	if "`adjusted'"=="" {
		file write `using' "" _tab
		file write `using' "" _tab
		file write `using' "" _tab
	}
	
	else {
		local i=1
		foreach var of varlist `adjusted' {
			tempvar var_`i'
			quietly gen `var_`i'' = `var'
			local i=`i'+1
		}
		
		** output error if adjusted() does not contain 2 variables **
		if `i'!=3 {
			disp as error "ERROR: Must specify two variables for adjusted()."
			disp as error "       Order matters: first variable is for conservatives,"
			disp as error "       second is for liberals."
			error -1
		}
	
		quietly sum `var_1' [w=`cons_`anything''] if `if'
		local mean_cons_adj=r(mean)
		file write `using' "`mean_cons_adj'" _tab
		
		quietly sum `var_2' [w=`lib_`anything''] if `if'
		local mean_lib_adj=r(mean)
		file write `using' "`mean_lib_adj'" _tab
		
		local diff_adj=`mean_cons_adj'-`mean_lib_adj'
		file write `using' "`diff_adj'" _tab
	}
	
	** SHARE OF CONSERVATIVES'/LIBERALS' INTERACTIONS WITH CONSERVATIVES **
	sum `ideology' [w=`cons_`anything''] if `if'
	local mean_cons=r(mean)
	file write `using' "`mean_cons'" _tab

	sum `ideology' [w=`lib_`anything''] if `if'
	local mean_lib=r(mean)
	file write `using' "`mean_lib'" _tab
	
	sum `ideology' [w=`anything'] if `if'
	local mean=r(mean)
	file write `using' "`mean'" _tab

	quietly count if `if' & `ideology'!=. & `anything'!=.
	local count=r(N)
	file write `using' "`count'" _tab
	
	quietly sum `anything' if `if' & `ideology'!=.
	local sizesum=r(sum)
	file write `using' "`sizesum'" _tab
	
	local diff=`mean_cons'-`mean_lib'
	file write `using' "`diff'" _tab

	** ISOLATION, DISSIMILARITY, AND SYMMETRIC ATKINSON INDICES **
	quietly sum `cons_`anything'' if `if'
	local cons_tot=r(sum)
	quietly sum `lib_`anything'' if `if'
	local lib_tot=r(sum)

	local isolation=(`mean_cons'-`cons_tot'/(`cons_tot'+`lib_tot'))/(1-`cons_tot'/(`cons_tot'+`lib_tot'))
	file write `using' "`isolation'" _tab

	tempvar sharediff_`anything'
	gen `sharediff_`anything''=abs(`cons_`anything''/`cons_tot'-`lib_`anything''/`lib_tot') if `if'
	quietly sum `sharediff_`anything'' if `if'
	local sharediff_sum=r(sum)
	local dissimilarity=0.5*`sharediff_sum'
	file write `using' "`dissimilarity'" _tab

	tempvar atkinson_temp_`anything'
	gen `atkinson_temp_`anything''=((`cons_`anything''/`cons_tot')*(`lib_`anything''/`lib_tot'))^0.5 if `if'
	quietly sum `atkinson_temp_`anything'' if `if'
	local atkinson_tempsum=r(sum)
	local atkinson=1-`atkinson_tempsum'
	file write `using' "`atkinson'" _tab

	if "`if'"=="0==0" {
		file write `using' "`anything'" _tab
	}
	else {
		file write `using' `"`anything' `if'"' _tab
	}
	file write `using' "`ideology'" _n
	
end

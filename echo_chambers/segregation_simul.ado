/**********************************************************
 *
 * SEGREGATION_SIMUL.ADO
 *  Uses bootstrap methodology to obtain a measure of the bias
 *  and standard error of our segregation statistics.
 *
 *  Output location, measure of website size, ideology measure,
 *  sample size, and number of replications must be specified.
 *  Description of specification must also be specified.
 *  IF allows the user to specify different sample restrictions
 *  (e.g., top 20, exclude top 20), and the default is the entire sample.
 *  SOURCE allows the user to specify the data source
 *  (ComScore, MRI, GSS), and the default is ComScore.
 *
 **********************************************************/

program define segregation_simul

	version 11
	syntax anything using/, ideology(varname) samplesize(varname) rep(integer) seed(integer) [if(string) source(string)] descrip(string)
	
	preserve
	set seed `seed'

	tempfile segregation_simul
	file open temp_seg_simul using `segregation_simul', write replace
	
	if "`if'"=="" {
		local if "0==0"
	}
	if "`source'"=="" {
		local source "COMSCORE"
	}
	
	segregation `anything' using temp_seg_simul, ideology(`ideology') if(`if') source(`source') descrip(0)

	** Bootstrap the sampling distribution of `ideology' **
	foreach r of numlist 1(1)`rep' {
		quietly tempvar temp_ideology
		quietly gen `temp_ideology' = rbinomial(int(`samplesize'), `ideology')/int(`samplesize') if `if'
		quietly segregation `anything' using temp_seg_simul, ideology(`temp_ideology') if(`if') source(`source') descrip(`r')
	}
	
	file close temp_seg_simul

	** Obtain a measure of the bias and standard error of each segregation statistic **
	insheet using `segregation_simul', nonames clear
	rename v1 draw
	rename v2 source
	rename v3 conscons_adj
	rename v4 libcons_adj
	rename v5 diff_adj
	rename v6 conscons
	rename v7 libcons
	rename v8 cons_mean
	rename v9 count
	rename v10 size
	rename v11 diff
	rename v12 isolation
	rename v13 dissimilarity
	rename v14 atkinson
	rename v15 sizemeasurerestriction
	rename v16 ideologymeasure
	
	foreach var in diff isolation dissimilarity atkinson {
		quietly sum `var' if draw==0
		local unadjusted_`var' = r(mean)
		quietly sum `var' if draw!=0
		local bootstrap_mean_`var' = r(mean)
		local bias_`var' = `bootstrap_mean_`var'' - `unadjusted_`var''
		local adjusted_`var' = `unadjusted_`var'' - `bias_`var''
		local se_`var' = r(sd)
	}

	file write `using' ("`descrip'") _tab ("`source'") _tab (conscons_adj[1]) _tab (libcons_adj[1]) _tab (diff_adj[1]) _tab (conscons[1]) _tab (libcons[1]) _tab (cons_mean[1]) _tab (count[1]) _tab (size[1]) _tab
	foreach var in diff isolation dissimilarity atkinson {
		file write `using' (`var'[1]) _tab (`bootstrap_mean_`var'') _tab (`bias_`var'') _tab (`adjusted_`var'') _tab (`se_`var'') _tab
	}
	file write `using' (sizemeasurerestriction[1]) _tab (ideologymeasure[1]) _n
	
	restore
	
end

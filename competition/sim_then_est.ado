 /**********************************************************
 *
 *  SIM_THEN_EST.ADO: SIMULATE DATA, ESTIMATE A MODEL, SAVE THE PARAMETERS
 *  
 *  For details of required inputs and relationship to other competition ado files see /trunk/tools/ado (Competition)/mle_readme.txt
 *
 *  Given a demand equation and parameters, this ado file simulates, newspapers choice of
 *  political affilation.  It then estimates the parameters and saves them in a Stata data file.
 * In the data file, parameters used to simulate data have the prefix "sim" and estimated 
 * parameters have the prefix "est"
 *
 **********************************************************/ 
 program define sim_then_est

	version 11
	syntax , output(string) paranames(string) paravals(string) papers_per_mkt(real) obs(real) demandfct(string) [bounds(numlist sort >=0 <=1 max=2 min=2) truncation(numlist max=1 >0 integer) seed(string) seed_draw(string) init_vals(string) cons_paranames(string) cons_vals(string)]
	
	quietly{
		clear
 	
		* Determine which simdata options are specified and load them into a local
		local sim_options=""
		foreach option in bounds truncation seed seed_draw{
			if "``option''" !=""{
				local sim_options="`sim_options'`option'(``option'')"
			}
		}
	
		* Determine which estmle options are specified and load them into a local
		local est_options=""
		foreach option in init_vals cons_paranames cons_vals{
			if "``option''" !=""{
				local est_options="`est_options'`option'(``option'')"
			}
		}
	}
	
	* Simulate data
	simdata, paranames(`paranames') paravals(`paravals') papers_per_mkt(`papers_per_mkt') obs(`obs') demandfct(`demandfct') ///
		`sim_options'
	
	* Estimate model
	estmle index, dependent(tau) paranames(`paranames')  demandfct(`demandfct')   ///
		`est_options'
	
	* Save Results
	quietly{
		clear
		set obs 1
	
		* Save Simulated and Estimated Parameter Values
		local numparas =wordcount("`paranames'")
		forvalues c= 1 / `numparas'{
			local pname = word("`paranames'",`c')
			gen sim_`pname' = real(word("`paravals'",`c'))
			gen est_`pname'= [`pname']_cons
		}
	}
	save "`output'", replace
end

 /**********************************************************
 *
 *  SIM_MOMENTS.ADO: SIMULATE DATA, ESTIMATE A MODEL, SAVE THE PARAMETERS
 *  
 *  For details of required inputs and relationship to other competition ado files see /trunk/tools/ado (Competition)/mle_readme.txt
 *
 *  Given a demand equation and parameters, this ado file simulates, newspapers choice of
 *  political affilation.  It then calculates certain moments of the simulated data
 * and saves the moments and parameters in a data set specified by the optional output command
 * 
 *
 **********************************************************/ 
 program define sim_moments

	version 11
	syntax , id(string) paranames(string) paravals(string) papers_per_mkt(real) obs(real) demandfct(string) [seed(string) seed_draw(string) output(string) ] 
	
	quietly{
		clear
 	
		* Determine which simdata options are specified and load them into a local
		local sim_options=""
		foreach option in seed seed_draw{
			if "``option''" !=""{
				local sim_options="`sim_options'`option'(``option'')"
			}
		}
	
		* Simulate data
		simdata, paranames(`paranames') paravals(`paravals') demandfct(`demandfct') papers_per_mkt(`papers_per_mkt') obs(`obs') ///
		`sim_options' bounds(0.4 0.69) truncation(1)
		
		* repshare and n_net coefficients
		reg tau gamma if order==1
		gen n_net=nr-nd
		local gamma_coef = _b[gamma] 
		reg tau n_net if gamma==0.5&order==2 
		local n_net = _b[n_net]
	
		* diversity statistic
		gen diverse = (tau~=nr) if gamma==0.5&order==2 
		sum diverse 
		local diversity = r(mean) 
	
		* Save Data
		clear
		set obs 1
		gen id="`id'"
		
		* Define parameters of Demand Function
		local numpara =wordcount("`paranames'")
	
		forvalues para= 1 / `numpara'{
			local sname = word("`paranames'",`para')
			gen	double para_`sname' = real(word("`paravals'",`para'))
		}
	
		gen repshr_coef=`gamma_coef'
		gen n_net_coef=`n_net'
		gen diversity = `diversity'
		
		if "`output'"!=""{
			save "`output'", replace
		}
	}
end

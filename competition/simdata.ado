 /**********************************************************
 *
 *  SIMDATA.ADO: SIMULATES PAPER'S CHOICE OF POLITICAL AFFILATION
 *  Given a demand equation and parameters, simulates, newspapers choice of
 *  political affilation.  Outputs choice of affiliation (tau), repshare (gamma), constant (index), number of Rep papers (nr),
 * number of Dem papers (nd), market (market), order in which papers enter in a market (order),
 * value of demand function(deltad), and probability of choosing a republican affiliation (prob_rep)
 *  
 *  Parameters of demand function and number of observations of simulated data must be specified.
 *  Demand function is read in from an ado file. 
 *
 * For details of required inputs and relationship to other competition ado files see /trunk/tools/ado (Competition)/mle_readme.txt
 *
 **********************************************************/ 
 program define simdata

	version 11
	syntax , paranames(string) paravals(string) papers_per_mkt(real) obs(real) demandfct(string) [bounds(numlist sort >=0 <=1 max=2 min=2) truncation(numlist max=1 >0 integer) seed(string) seed_draw(string)]
	
	clear
 	
	quietly{
	* Set seed
	if "`seed'"==""{
		set seed 1
	}
	else{
		local s=`seed'
		set seed `s'
	}
	
	* Set size of data set
	set obs `obs'
		
	* Define parameters of Demand Function
	local numpara =wordcount("`paranames'")
	
	forvalues para= 1 / `numpara'{
		local sname = word("`paranames'",`para')
		gen	double `sname' = real(word("`paravals'",`para'))
	}
	
	* Markets
	local mkts=round(`obs'/`papers_per_mkt',1)
	egen market=seq(), from(1) to(`mkts') block(`papers_per_mkt')
			
	* Parse Bounds
	if "`bounds'"=="" {
		scalar lower=0
		scalar upper=1
	}
	
	else{
		local it=1
		foreach x in `bounds'{
			if "`it'"=="1"{
				scalar lower=`x'
			}
			if "`it'"=="2"{
				scalar upper=`x'
			}
			local it=`it'+1
		}
	}
	
	* Parse truncation{
	if "`truncation'"==""{
		scalar trunc=8
	}
	else{
		scalar trunc=`truncation'
	}
	
	* Order of entry by market
	egen order=seq(), by(market)
	
		* Generate share Republican variable
	sort market order
	by market: gen gamma=scalar(lower)+runiform()*(scalar(upper)-scalar(lower)) if _n==1
	replace gamma=int(gamma*10^scalar(trunc))/(10^scalar(trunc))
	replace gamma=gamma[_n-1] if gamma==.
	
	* Constant value
	gen index=1

	* Set seed of unobservables
	if "`seed_draw'"!=""{
		set seed `seed_draw'
	}
	gen uni=runiform()	
	
	* Define tau, the paper's choice of political affiliation
		* Used for defining newspaper political affilation variable with random error
		* Calculate detad and political affiliation of entrants
	gen nr=0
	gen nd=0
	gen double deltad=.
	gen double prob_rep=.
	gen tau=.
	gen double input=.
	
	sort market order
	xtset market order
		
	forvalues x= 1/ `papers_per_mkt'{
				* Number of Democratic and Republican Incumbents
		foreach c in nr nd {
			replace `c'=L.`c' if L.`c' !=. & order==`x'
		}
		replace nr=L.nr+1 if L.tau==1 & order==`x'
		replace nd=L.nd+1 if L.tau==0 & order==`x'
		
		* Value of DeltaD
		`demandfct'
		replace deltad =mu*input if `x'==order
	
		* Probability the paper is Republican
		replace prob_rep=exp(deltad)/(1+exp(deltad))  if `x'==order
	
		*  Define newspaper political affilation variable with random error
		replace tau = prob_rep>uni  if `x'==order
		
	}
	
	*Drop variables we don't want to keep
	drop uni input
	forvalues para= 1 / `numpara'{
		local sname = word("`paranames'",`para')
		drop `sname'
	}
}
	* Simulation only works if papers_per_mkt divides evenly in to obs
	if int(`obs'/`papers_per_mkt')!=`obs'/`papers_per_mkt'{
		clear
		di as error "obs divided by papers_per_mkt must be a natural number"
		exit 198
	}
	save ..\temp\simdata,replace
	
end




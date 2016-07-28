/**********************************************************
 *
 *  DEMAND_NLA.ADO: Value of the demand equation if the entrant is a Republican minus the value if the entant is a democrat
 *
 * For details of required inputs, outputs, and relationship to other competition ado files see /trunk/tools/ado (Competition)/mle_readme.txt
 *
 * Requires that the following variables are in memory at the time it is run: gamma (Share Republican ), 
 * nr ( Number of Republican Papers, excluding entrant), nd (Number of Democratic Papers, excluding entrant), 
 * bt (parameter to estimate) .
 *
 * Outputs a variable called "input" that is the demand if a paper enters as a Republican
 * minus the demand if it enters as a Democrat.
 *
 **********************************************************/

program define demand_nla
	version 11
	syntax
	
	quietly replace input=(bt*(2*gamma-1)+(1-bt)*(gamma/(nr+1)-(1-gamma)/(nd+1)))
		
end	


/**********************************************************
 *
 *  DEMAND_CH1.ADO: Value of the demand equation if the entrant is a Republican minus the value if the entant is a Democrat
 *
 * For details of required inputs, outputs, and relationship to other competition ado files see /trunk/tools/ado (Competition)/mle_readme.txt
 *
 * Requires that the following variables are in memory at the time it is run: gamma (Share Republican ), 
 * nr ( Number of Republican Papers, excluding entrant), nd (Number of Democratic Papers, excluding entrant), 
 * bt (parameter to estimate), and a (a constant value) .
 *
 * Outputs a variable called "input" that is the demand if a paper enters as a Republican
 * minus the demand if it enters as a Democrat.
 *
 **********************************************************/

program define demand_ch1
	version 11
	syntax
	quietly replace input= ((gamma*exp(a+bt)/(1+(nr+1)*exp(a+bt)+nd*exp(a))+(1-gamma)*exp(a)/(1+(nr+1)*exp(a)+nd*exp(a+bt)))-(gamma*exp(a)/(1+nr*exp(a+bt)+(nd+1)*exp(a))+(1-gamma)*exp(a+bt)/(1+nr*exp(a)+(nd+1)*exp(a+bt))))
		
end	


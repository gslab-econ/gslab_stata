###################################################################################
#  mle_readme.txt - Help/Documentation for Maximum Likelihood Estimation Ado Files
#  Created by: Nathan Petek, September 2010
###################################################################################

Description:
The ado files in /tools/ado(Competition) perform maximum likelihood estimation using demand models.

Usage:
simdata.ado is used to generate a panel data set with multiple markets over multiple periods.  The simulation causes one newspaper to enter each market in each period and choose a political affilation (no papers exit). Choice of political affilation is made using a demand model. The data produced includes the share Republican in the market (gamma), the number of Democratic papers (nd), the number of Republican papers (nr), and the entering papers choice of political affiliation (tau).

estmle.ado estimate a demand model's parameters
-estmle calls likelihood.ado which contains the log likelihood function
-estmle also calls demand_XXX.ado which contains the demand model

sim_then_est.ado calls simdata.ado then estmle.ado.  It simulates a data set given parameters, then estimates the parameters off the simulated data, and saves the simulated and estimated parameters in a data set.

########################################
# General procedure
########################################

The general steps of this program are:

1. Read a data set into memory OR
2. Run estmle.ado
OR 
1. Run sim_then_est.ado 


#############################
# Using simdata.ado
#############################

syntax , paranames(string) paravals(string) papers_per_mkt(natural number) obs(natural number) demandfct(string) [bounds(numlist sort >=0 <=1 max=2 min=2) truncation(numlist max=1 >0 integer) seed(natural number) seed_draw(natural number)]

	paranames - Name of each parameter, delimited with a space. Paravals are matched to paranames by the order in which they are entered.
	
	paravals - Value of each parameter, delimited with a space. Paranames are matched to paravals by the order in which they are entered.
	
	papers_per_mkt - Number of papers in each market
	
	obs - Number of observations to generate
	
	demandfct - Name of demand function ado file

	bounds - Upper and lower bounds of share Republican. The number list in bounds is restricted two 2 arguments (max=2 min=2) between 0 and 1 (>=0 and <=1).  It automatically sorts the number list from smallest (lower bound) to largest (upper bound) if the bounds are entered in the wrong order.
	
	truncation - Decimal place at which to truncate share Republican. The number list is restricted to no more than one argument (max=1) and that argument must be and integer greater than zero (>0 integer)
	
	seed - Sets the seed that simdata.ado uses to draw random variables. Must be a natural number.  Seed defaults to 1 so if the SEED option is not set each time simdata.ado is run, all random variables will have the same values each time simdata is run.
	
	seed_draw - Set the seed that simdata.ado uses to draw the random unobservable variable ("uni"). Must be a natural number.  Seed_draw defaults to 1 if the SEED option is not set or to the value of the SEED option if SEED is specified.
	
	
Notes:
* Names of parameters in paranames must match name of parameters in demand function. In addition, you must specify the value of a parameter called mu which scales Delta D by its value before the probability the entering paper is Republican is calculated.
* obs and papers_per_market should be chosen so that obs / papers_per_market is a natural number.

Additional Inputs:
	None

Outputs:
	1) market - indicates which observations belong to each market

	2) order - order in which papers enter each market

	3) tau - political affiliation of entering newspaper

	4) gamma - share Republican

	5) nr - number of Republican papers (not including entrant)

	6) nd - number of  Democratic papers (not including entrant)

	7) index - a constant 1, used by estmle.ado to estimate one of the parameters

	8) deltad - value of deltad (not an input into other ado files)

	9) prob_rep - probability the paper will choose to be Republican (not an input into other ado files) 
	
#############################
# Using estmle.ado
#############################

syntax varlist , dependent(string) paranames(string) demandfct(string) [init_vals(string) cons_paranames(string) cons_vals(string)]

	varlist - List of independent variables
	
	dependent - Name of dependent variable
	
	paranames - List of the names of parameters to estimate. Delimited with a space.
	
	demandfct - Name of demand function ado file.
		
	init_vals - List initial values of parameters estmle will use. Elements in the list of inital values are delimited with a space and should be listed in the same order as paranames.
	
	cons_paranames - list of parameters that you want to constrain, delimited by a space.
	
	cons_vals - list of linear constraints for estimated parameter values. Elements in the list of constraints values are delimited with a space and should be listed in the same order as cons_paranames.
	
Notes:
* Names of parameters in paranames must match name of parameters in the demand function.

* In addition you must specify the parameter name mu which scales Delta D by its value before it enters the likelihood function.

Additional Inputs:
	1) Names of variables in open data set must match names of variables in the demand function.
	
	2) input - Input to likelihood.ado from demand_XXX.ado

#############################
# Using likelihood.ado
#############################

Likelihood.ado is hard coded in estmle.ado as an argument in the ml model command.  It specifies log likelihood function given the demand function entered as an argument in estmle. It assumes the output of the demand function has a logistic distribution.  Likelihood.ado does not take any arguments.  It can estimate up to five parameters, but it is easy to modify it to add additional parameters
	

#############################
# Using sim_then_est.ado
#############################

syntax , output(string) paranames(string) paravals(string) papers_per_mkt(natural number) obs(natural number) demandfct(string) [bounds(numlist sort >=0 <=1 max=2 min=2) truncation(numlist max=1 >0 integer) seed(natural number) seed_draw(natural number) init_vals(string) cons_paranames(string) cons_vals(string)]

	output - Name and location of output data set, e.g., output(..\temp\sim_est)
	
	paranames - Name of each parameter, delimited with a space. Paravals are matched to paranames by the order in which they are entered.
	
	paravals - Value of each parameter, delimited with a space. Paranames are matched to paravals by the order in which they are entered.
	
	papers_per_mkt - Number of papers in each market
	
	obs - Number of observations to generate
	
	demandfct - Name of demand function ado file

	bounds - Upper and lower bounds of share Republican. The number list in bounds is restricted two 2 arguments (max=2 min=2) between 0 and 1 (>=0 and <=1).  It automatically sorts the number list from smallest (lower bound) to largest (upper bound) if the bounds are entered in the wrong order.
	
	truncation - Decimal place at which to truncate share Republican. The number list is restricted to no more than one argument (max=1) and that argument must be and integer greater than zero (>0 integer)
	
	seed - Sets the seed that simdata.ado uses to draw random variables. Must be a natural number.  Seed defaults to 1 so if the SEED option is not set each time simdata.ado is run, all random variables will have the same values each time simdata is run.
	
	seed_draw - Set the seed that simdata.ado uses to draw the random unobservable variable ("uni"). Must be a natural number.  Seed_draw defaults to 1 if the SEED option is not set or to the value of the SEED option if SEED is specified.
	
	init_vals - List initial values of parameters estmle will use. Elements in the list of inital values are delimited with a space and should be listed in the same order as paranames.
	
	cons_paranames - list of parameters that you want to constrain, delimited by a space.
	
	cons_vals - list of linear constraints for estimated parameter values. Elements in the list of constraints values are delimited with a space and should be listed in the same order as cons_paranames.
	
Notes:
* Names of parameters in paranames must match name of parameters in demand function. In addition, you must specify the value of a parameter called mu which scales Delta D by its value before the probability the entering paper is Republican is calculated.
* obs and papers_per_market should be chosen so that obs / papers_per_market is a natural number.

Additional Inputs:
	None

Outputs:
	1) A data set with the name/location specified in the "output" option that contains the paramater values used to simulate the data and the parameter values estimated off of the simulated data.  Variables named "sim_parameter name" are the parameters used to simulate the data and variables named "est_parameter name" are the parameters estimated from the simulated data. 
	
	
#############################
# Using sim_momments.ado
#############################

	syntax , id(string) paranames(string) paravals(string) papers_per_mkt(real) obs(real) demandfct(string) [seed(natural number) seed_draw(natural number)  output(string)] 

	paranames - Name of each parameter, delimited with a space. Paravals are matched to paranames by the order in which they are entered.
	
	paravals - Value of each parameter, delimited with a space. Paranames are matched to paravals by the order in which they are entered.
	
	papers_per_mkt - Number of papers in each market
	
	obs - Number of observations to generate
	
	demandfct - Name of demand function ado file

	seed - Sets the seed that simdata.ado uses to draw random variables. Must be a natural number.  Seed defaults to 1 so if the SEED option is not set each time simdata.ado is run, all random variables will have the same values each time simdata is run.
	
	seed_draw - Set the seed that simdata.ado uses to draw the random unobservable variable ("uni"). Must be a natural number.  Seed_draw defaults to 1 if the SEED option is not set or to the value of the SEED option if SEED is specified.
	
	output - Name and location of output data set, e.g., output(..\temp\sim_est)
	
Notes:
* Names of parameters in paranames must match name of parameters in demand function. In addition, you must specify the value of a parameter called mu which scales Delta D by its value before the probability the entering paper is Republican is calculated.
* obs and papers_per_market should be chosen so that obs / papers_per_market is a natural number.

Additional Inputs:
	None

Outputs:
	1) ID - Variable you can specify to identify each observation

	2) Variables with the value of each parameter:  para_a (alpha), para_bt (beta), para_mu (mu), para_Gs (Gamma Same), para_Gd (Gamma Different)

	3) repshr_coef - Effect of gamma (share republican) on tau (newspaper affiliation 1=Rep,0=Dem) for the first paper to enter each market, where gamma =.4, .5, or .6

	4) n_net_coef - Effect of n_net (#Rep papers - #Dem papers) on tau newspaper affiliation 1=Rep,0=Dem) for the second paper to enter each market, where gamma = .5

	5) diversity - Percentage of markets with two firms that have both a Dem and Rep paper, where where gamma = .5


#############################
# Using demand_nla.ado
#############################
Inputs:
	Required Variables in Data (name in Lyx doc)
		1) gamma (gamma) - Share Republican 

		2) nr (N^R) - Number of Republican Papers, excluding entrant

		3) nd (N^D) - Number of Democratic Papers, excluding entrant

	Parameters to Estimate (name in Lyx doc)
		1) bt (alpha) - ranges from 0 to 1. When you estimate a model or simulate data, you must list this parameter in the "paranames" option and in the case of simdata, the value of each parameter in the "paravals" option.

		Notes:
		* If you want to run this ado file outside of the estmle or simdata adofiles, you will need to specify values for the parameters to estimate by generate variables named a and bt with the desired parameter value, e.g., gen bt= 2.2.  You will also need to "gen input=."
	
Outputs:
		1) input - The value of Delta D (demand if a paper enters as a Republican minus the demand if it enters as a Democrat) which is the input into likelihood.ado, the likelihood function.

#############################
# Using demand_ch1.ado
#############################
Inputs:
	Required Variables in Data (name in Lyx doc):
		1) gamma (gamma) - Share Republican 

		2) nr (N^R) - Number of Republican Papers, excluding entrant

		3) nd (N^D) - Number of Democratic Papers, excluding entrant

	Parameters to Estimate (name in Lyx doc):
		When you estimate a model or simulate data, you must list each of these parameters in the "paranames" option and in the case of simdata, the value of each parameter in the "paravals" option.
		1) a (alpha) - Value of paper to consumers independent of consumer and paper political affiliation
		
		2) bt (beta) - Value of paper to consumers independent of when paper and consumer share the same political affiliation
		
		
		Notes:
		* When we estimate this model, we usually constrain "a" to a constant using the cons_paranames and cons_vals options
		* If you want to run this ado file outside of the estmle or simdata adofiles, you will need to specify values for the parameters to estimate by generate variables named a and bt with the desired parameter value, e.g., gen bt= 2.2.  You will also need to "gen input=."
		
Outputs:
		1) input - The value of Delta D (demand if a paper enters as a Republican minus the demand if it enters as a Democrat) which is the input into likelihood.ado, the likelihood function.


#############################
# Using demand_chb.ado
#############################
Inputs:
	Required Variables in Data (name in Lyx doc):
		1) gamma (gamma) - Share Republican 
	
		2) nr (N^R) - Number of Republican Papers, excluding entrant
	
		3) nd (N^D) - Number of Democratic Papers, excluding entrant

	Parameters to Estimate (name in Lyx doc):
		When you estimate a model or simulate data, you must list each of these parameters in the "paranames" option and in the case of simdata, the value of each parameter in the "paravals" option.
		1) a (alpha) - Value of paper to consumers independent of consumer and paper political affiliation
		
		2) bt (beta) - Value of paper to consumers independent of when paper and consumer share the same political affiliation
		
		3) G (capital gamma) - Substitution/complementarity parameter

		
		Notes:
		* When we estimate this model, we usually constrain "a" to a constant using the cons_paranames and cons_vals options
		* If you want to run this ado file outside of the estmle or simdata adofiles, you will need to specify values for the parameters to estimate by generate variables named a, bt, G with the desired parameter value, e.g., gen bt= 2.2.  You will also need to "gen input=."

Outputs:
		1) input - The value of Delta D (demand if a paper enters as a Republican minus the demand if it enters as a Democrat) which is the input into likelihood.ado, the likelihood function.

#############################
# Using demand_b2G.ado
#############################
Inputs:
	Required Variables in Data (name in Lyx doc):
		1) gamma (gamma) - Share Republican 
	
		2) nr (N^R) - Number of Republican Papers, excluding entrant
	
		3) nd (N^D) - Number of Democratic Papers, excluding entrant

	Parameters to Estimate (name in Lyx doc):
		When you estimate a model or simulate data, you must list each of these parameters in the "paranames" option and in the case of simdata, the value of each parameter in the "paravals" option.
		1) a (alpha) - Value of paper to consumers independent of consumer and paper political affiliation
		
		2) bt (beta) - Value of paper to consumers independent of when paper and consumer share the same political affiliation
		
		3) Gs (capital gamma^ 0) - Substitution/complementarity parameter for number of pairs of same-type papers (both Republican or both Democrat)

		3) Gd (capital gamma^ 1) - Substitution/complementarity parameter for number of pairs of differnt-type papers (one Republican and one Democrat)
		
		Notes:
		* When we estimate this model, we usually constrain "a" to a constant using the cons_paranames and cons_vals options
		* If you want to run this ado file outside of the estmle or simdata adofiles, you will need to specify values for the parameters to estimate by generate variables named a, bt, Gs, Gd with the desired parameter value, e.g., gen bt= 2.2.  You will also need to "gen input=."

Outputs:
		1) input - The value of Delta D (demand if a paper enters as a Republican minus the demand if it enters as a Democrat) which is the input into likelihood.ado, the likelihood function.

#############################
# Example Usage
#############################

See /analysis/Competition/code/mle.do


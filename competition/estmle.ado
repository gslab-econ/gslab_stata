/**********************************************************
 *
 *  ESTMLE.ADO: FINDS MAXIMUM LIKELIHOOD ESTIMATOR
 *  Given a likelihood equation, finds maximum likelihood estimator
 *  
 * For details of required inputs and relationship to other competition ado files see /trunk/tools/ado (Competition)/mle_readme.txt
 *
 * You must specify all parameters in the demand function you are using and you must have 
 * a data set in memory with all of the data the demand function uses, e.g., number of Rep
 *  papers, Dem papers, and share conservative.
 * In addition, you must specify the parameter name mu which scales Delta D by its value 
 * before it enters the likelihood function. Names of parameters in paranames must match 
 * name of parameters in the demand function.
 *
 **********************************************************/

program define estmle
	version 11
	syntax varlist , dependent(string) paranames(string) demandfct(string) [init_vals(string) cons_paranames(string) cons_vals(string)]
	global demandfct="`demandfct'"
	quietly{
		gen double bt=.	
		gen double input=.
		gen double G=.
		gen double Gs=.
		gen double Gd=.
		gen double a=.
	}
	
	* Parse Paranames
	local numcons =wordcount("`paranames'")
	forvalues c= 1 / `numcons'{
		local paranames`c' = word("`paranames'",`c')
	}
	
	* Parse Contraint
	if "`cons_paranames'"!=""{
		local numconstraints =wordcount("`cons_paranames'")
		forvalues c= 1 / `numconstraints'{
			local cons_paranames`c' = word("`cons_paranames'",`c')
			local cons_vals`c' = word("`cons_vals'",`c')
			
			* Value of constraint
			constraint `c' [`cons_paranames`c'']_cons=`cons_vals`c''
			
			* Local that lists number of constraints in model statement
			local num_cons_build =`"`num_cons_build'_`c'"'
		}
		* Replace underscores with spaces so the formatting is correct
		local num_cons=trim(subinstr("`num_cons_build'","_"," ",.))
	}
	
	local constraint=", constraint(`num_cons')"
	* Write model Statement
	
	if `numcons'==2{
		ml model d0 likelihood (`paranames1': `dependent' = `varlist') /`paranames2' `constraint' 
	}
	if `numcons'==3{
		ml model d0 likelihood (`paranames1': `dependent' = `varlist') /`paranames2' /`paranames3' `constraint' 
	}
	if `numcons'==4 {
		ml model d0 likelihood (`paranames1': `dependent' = `varlist') /`paranames2' /`paranames3' /`paranames4' `constraint' 
	}
	if `numcons'==5 {
		ml model d0 likelihood (`paranames1': `dependent' = `varlist') /`paranames2' /`paranames3' /`paranames4' /`paranames5' `constraint' 
	}
	ml check

	* Parse and set init_vals
	if "`init_vals'"==""{
		ml search, repeat(100)
	}
	else{
		local num_init=wordcount("`init_vals'")
		forvalues c= 1 / `num_init'{
			local init`c' = word("`init_vals'",`c')
		}
		
		if `num_init'==1{
			ml init `paranames1':_cons=`init1'
		}
		if `num_init'==2{
			ml init `paranames1':_cons=`init1' `paranames2':_cons=`init2'
		}
		if `num_init'==3{
			ml init `paranames1':_cons=`init1' `paranames2':_cons=`init2' `paranames3':_cons=`init3'
		}
		if `num_init'==4{
			ml init `paranames1':_cons=`init1' `paranames2':_cons=`init2' `paranames3':_cons=`init3' `paranames4':_cons=`init4'
		}
		if `num_init'==5{
			ml init `paranames1':_cons=`init1' `paranames2':_cons=`init2' `paranames3':_cons=`init3' `paranames4':_cons=`init4' `paranames5':_cons=`init5'
		}
	}
	
	ml maximize, difficult trace
	*ml graph 
	
	drop bt input G Gs Gd a
end


/**********************************************************
 *
 *  LIKELIHOOD.ADO: DEFINES LIKELIHOOD FUNCTION
 *  
 *  Given a demand equation saved in a textfile, program defines a likelihood function
 *
 **********************************************************/

program define likelihood
	version 11
	args todo b lnf 
	tempvar a bt mu g gs gd lj

	if "$demandfct"=="demand_nla"{	
		mleval `bt'=`b', eq(1)
		mleval `mu'=`b', eq(2)	
	}
	else{
		mleval `a'=`b', eq(1)
		mleval `bt'=`b', eq(2)
		mleval `mu'=`b', eq(3)	
		
		if "$demandfct"=="demand_chb"{	
			mleval `g'=`b', eq(4)
		}
		if "$demandfct"=="demand_b2G"{	
			mleval `gs'=`b', eq(4)
			mleval `gd'=`b', eq(5)
		}
	}
	
	quietly replace bt=`bt'
	if "$demandfct"!="demand_nla"{	
		quietly replace a=`a'
	}
	
	if "$demandfct"=="demand_chb"{	
		quietly replace G=`g'
	}
	if "$demandfct"=="demand_b2G"{	
		quietly replace Gs=`gs'
		quietly replace Gd=`gd'
	}
	
	$demandfct
	
	* Define Parameter of Demand Function
	
	quietly{
		gen double `lj'= exp(`mu'*input)/(1+exp(`mu'*input)) if $ML_y1 == 1
		replace `lj'= 1/(1+exp(`mu'*input)) if $ML_y1 == 0
		mlsum `lnf' = ln(`lj')
		if (`lnf' >= .) exit
	}
		
end	


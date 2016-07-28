/**********************************************************
 *
 *  DEMAND_B2G.ADO: Value of the demand equation if the entrant is a Republican minus the value if the entant is a Democrat
 *  
 * For details of required inputs, outputs, and relationship to other competition ado files see /trunk/tools/ado (Competition)/mle_readme.txt
 *
 * Requires that the following variables are in memory at the time it is run: gamma (Share Republican ), 
 * nr ( Number of Republican Papers, excluding entrant), nd (Number of Democratic Papers, excluding entrant), 
 * bt (parameter to estimate), Gs (parameter to estimate), Gd (parameter to estimate), and a (a constant value) .
 *
 * Outputs a variable called "input" that is the demand if a paper enters as a Republican
 * minus the demand if it enters as a Democrat.
 **********************************************************/
program define Gcom_rplus
	version 11
 			if $r>=2{
				replace Grep = comb($r,2) if ((nr+1)>=$r)*(nd>=$d)==1
			}
			else{
				replace Grep=0 if ((nr+1)>=$r)*(nd>=$d)==1
			}
			if $d>=2{
				replace Gdem = comb($d,2) if ((nr+1)>=$r)*(nd>=$d)==1
			}
			else{
				replace Gdem=0 if ((nr+1)>=$r)*(nd>=$d)==1
			}			
			replace Gcomb=(Grep+Gdem)*Gs+($r*$d)*Gd if ((nr+1)>=$r)*(nd>=$d)==1
end
 
program define Gcom_dplus
	version 11
 			if $r>=2{
				replace Grep = comb($r,2) if ((nr)>=$r)*((nd+1)>=$d)==1
			}
			else{
				replace Grep=0 if ((nr)>=$r)*((nd+1)>=$d)==1
			}
			if $d>=2{
				replace Gdem = comb($d,2) if ((nr)>=$r)*((nd+1)>=$d)==1
			}
			else{
				replace Gdem=0 if ((nr)>=$r)*((nd+1)>=$d)==1
			}			
			replace Gcomb=(Grep+Gdem)*Gs+($r*$d)*Gd if ((nr)>=$r)*((nd+1)>=$d)==1
end
 
 
program define demand_b2G
	version 11
	syntax
	
	quietly {
	* Generate the necessary variables
	forvalues x = 1/4 {
		gen double numer_i`x'=.
		gen double numer_t`x'=0
		gen double denom_i`x'=.
		gen double denom_t`x'=0
	}
	gen double Gcomb=.
	gen double Grep=0
	gen double Gdem=0
	
	* Create locals that determine the number of iterations for each loop
	sum nr
	local nr=r(max)
	sum nd
	local nd=r(max)
	local nr_bt=`nr'+1		
	local nd_bt=`nd'+1	
	
	* First fraction in Delta D
	* Calculate the numerator
	forvalues r=1 /`nr_bt'{
		forvalues d=0/`nd'{
			* Set gamma terms to zero if there are less than two goods in the bundle
			global r=`r'
			global d=`d'
			Gcom_rplus
			
			* Sum each iteration
			replace numer_i1 = comb(nr+1-1,`r'-1)*comb(nd,`d')*exp((`r'+`d')*a + `r'*bt + Gcomb) if ((nr+1)>=`r')*(nd>=`d')==1
			replace numer_t1= numer_t1 + numer_i1 if ((nr+1)>=`r')*(nd>=`d')==1
		}
	}
		
	* Calculate the denominator
	forvalues r=0/`nr_bt'{
		forvalues d=0/`nd'{
			* Set gamma terms to zero if there are less than two goods in the bundle
			global r=`r'
			global d=`d'
			Gcom_rplus
			
			* Sum each iteration
			replace denom_i1= comb(nr+1,`r')*comb(nd,`d')*exp((`r'+`d')*a+`r'*bt+Gcomb)  if ((nr+1)>=`r')*(nd>=`d')==1
			replace denom_t1 = denom_t1 + denom_i1 if ((nr+1)>=`r')*(nd>=`d')==1
		}		   
	}
	
	* Second fraction in Delta D
	* Calculate the numerator
	forvalues r=1 /`nr_bt'{
		forvalues d=0/`nd'{
			* Set gamma terms to zero if there are less than two goods in the bundle
			global r=`r'
			global d=`d'
			Gcom_rplus
			
			* Sum each iteration
			replace numer_i2 = comb(nr+1-1,`r'-1)*comb(nd,`d')*exp((`r'+`d')*a + `d'*bt + Gcomb) if ((nr+1)>=`r')*(nd>=`d')==1
			replace numer_t2= numer_t2 + numer_i2  if ((nr+1)>=`r')*(nd>=`d')==1
		}
	}

	* Calculate the denominator	
	forvalues r=0/`nr_bt'{
		forvalues d=0/`nd'{
			* Set gamma terms to zero if there are less than two goods in the bundle
			global r=`r'
			global d=`d'
			Gcom_rplus
			
			* Sum each iteration
			replace denom_i2=comb(nr+1,`r')*comb(nd,`d')*exp((`r'+`d')*a+`d'*bt+Gcomb) if ((nr+1)>=`r')*(nd>=`d')==1
			replace denom_t2 = denom_t2 + denom_i2	 if ((nr+1)>=`r')*(nd>=`d')==1
		}		   
	}


	* Third fraction in Delta D
	* Calculate the numerator
	forvalues d=1 /`nd_bt'{
		forvalues r=0/`nr'{
			* Set gamma terms to zero if there are less than two goods in the bundle
			global r=`r'
			global d=`d'
			Gcom_dplus
			
			* Sum each iteration
			replace numer_i3 = comb(nd+1-1,`d'-1)*comb(nr,`r')*exp((`r'+`d')*a + `r'*bt + Gcomb) if (nr>=`r')*((nd+1)>=`d')==1
			replace numer_t3= numer_t3 + numer_i3  if (nr>=`r')*((nd+1)>=`d')==1 
		}
	}

	* Calculate the denominator	
	forvalues d=0/`nd_bt'{
		forvalues r=0/`nr'{
			* Set gamma terms to zero if there are less than two goods in the bundle
			global r=`r'
			global d=`d'
			Gcom_dplus
			
			* Sum each iteration
			replace denom_i3=comb(nd+1,`d')*comb(nr,`r')*exp((`r'+`d')*a+`r'*bt+Gcomb) if (nr>=`r')*((nd+1)>=`d')==1
			replace denom_t3 = denom_t3 + denom_i3	 if (nr>=`r')*((nd+1)>=`d')==1
		}		   
	}


	* Fourth fraction in Delta D
	* Calculate the numerator
	forvalues d=1 /`nd_bt'{
		forvalues r=0/`nr'{
			* Set gamma terms to zero if there are less than two goods in the bundle
			global r=`r'
			global d=`d'
			Gcom_dplus
			
			* Sum each iteration
			replace numer_i4 = comb(nd+1-1,`d'-1)*comb(nr,`r')*exp((`r'+`d')*a + `d'*bt + Gcomb) if (nr>=`r')*((nd+1)>=`d')==1
			replace numer_t4= numer_t4 + numer_i4  if (nr>=`r')*((nd+1)>=`d')==1 
		}
	}

	* Calculate the denominator	
	forvalues d=0/`nd_bt'{
		forvalues r=0/`nr'{
			* Set gamma terms to zero if there are less than two goods in the bundle
			global r=`r'
			global d=`d'
			Gcom_dplus
		
			replace denom_i4= comb(nd+1,`d')*comb(nr,`r')*exp((`r'+`d')*a+`d'*bt+Gcomb) if (nr>=`r')*((nd+1)>=`d')==1
			replace denom_t4= denom_t4 + denom_i4	 if (nr>=`r')*((nd+1)>=`d')==1
			}		   
		}


	* Save deltad as a variable
	replace input = gamma*numer_t1/denom_t1+(1-gamma)*numer_t2/denom_t2-(gamma)*numer_t3/denom_t3-(1-gamma)*numer_t4/denom_t4
	drop  numer_i1- Gdem
}

		
end	


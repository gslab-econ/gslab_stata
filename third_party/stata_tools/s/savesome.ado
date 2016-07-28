*! 1.1.0 NJC 23 February 2015 
*! 1.0.1 NJC 9 August 2011 
*! 1.0.0 NJC 25 April 2001 
program def savesome
	version 7.0 
	syntax [varlist] [if] [in] using/ [ , old * ] 
	preserve
	quietly { 
		if `"`if'`in'"' != "" { keep `if' `in' } 
		keep `varlist' 
	} 

	if "`old'" != "" { 
		capture which saveold 
		if `"`r(fn)'"' != "" { 
			saveold `"`using'"', `options' 
		}
		else save `"`using'"', old `options' 
	}
	else save `"`using'"', `options' 
end 	

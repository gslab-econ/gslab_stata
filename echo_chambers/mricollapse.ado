**********************************************************
*
* mricollapse.ado
*
* Creates multiples of weights, measures, and ideology
* and then collapses data.
*
**********************************************************

cap program drop mricollapse

program define mricollapse

version 11
syntax , ideology(varname) weights(string) measures(varlist) sites(varlist)
foreach wt in `weights' {
	foreach measure in `measures' {
		gen `measure'_`wt'_prod = wgt`wt'*`measure'
		gen `measure'_`wt'_nmiss_prod = wgt`wt'*`measure' if `ideology'~=.
		gen `measure'_`wt'_cons_prod = wgt`wt'*`measure' if `ideology'==1
		gen `measure'_`wt'_lib_prod = wgt`wt'*`measure' if `ideology'==0
		gen `ideology'_`measure'_`wt'_prod = `ideology'*`measure'_`wt'_prod
		leaveout `ideology'_`measure'_`wt'_adj, variable(`ideology') weight(`measure'_`wt'_prod) by(`sites')
		gen `ideology'_`measure'_`wt'_adjcon = `ideology'_`measure'_`wt'_adj if `ideology'==1
		gen `ideology'_`measure'_`wt'_adjlib = `ideology'_`measure'_`wt'_adj if `ideology'==0
		gen `ideology'_`measure'_`wt'_adjcon_prod = `ideology'_`measure'_`wt'_adjcon*`measure'_`wt'_prod
		gen `ideology'_`measure'_`wt'_adjlib_prod = `ideology'_`measure'_`wt'_adjlib*`measure'_`wt'_prod
	}
}

collapse (sum) *_prod, by(`sites')
foreach wt in `weights' {
	foreach measure in `measures' {
		gen `ideology'_`measure'_`wt' = `ideology'_`measure'_`wt'_prod/`measure'_`wt'_nmiss_prod
		gen `ideology'_`measure'_`wt'_adjcon = `ideology'_`measure'_`wt'_adjcon_prod/`measure'_`wt'_cons_prod
		gen `ideology'_`measure'_`wt'_adjlib = `ideology'_`measure'_`wt'_adjlib_prod/`measure'_`wt'_lib_prod
		rename `measure'_`wt'_prod `measure'_`wt'
	}
}
drop *_prod
end




/**********************************************************
 *
 * DEFINE_EVENT.ADO: Create event dummies and polynomials
 *  for voting analysis. 
 *
 **********************************************************/

program define define_event

	version 10
	syntax anything, [	changein(string) ///
				eventis(string) ///
				if(string) ///
				maxchange(integer -9999) ///
				window(integer $maxhorizon) ///
				nopoly ///
				conspoly ///
				polyorder(integer $maxpolyorder) ///
				polymidpoint(real $polymidpoint) ///
				]
	
	tempvar level event

	** ERROR CHECKING **
	if "`changein'"=="" & "`eventis'"=="" {
		di "Error: Must specify either option changein() or option eventis()"
		return -1
	}
	if "`changein'"!="" & "`eventis'"!="" {
		di "Error: Cannot specify both option changein() and option eventis()"
		return -1
	}
	if `polymidpoint'>1 | `polymidpoint'<0 {
		di "Error: value of option polymidpoint() must be between zero and one"
		return -1
	}

	local pre "`anything'"

	quietly {

		xtset $panelvar $yearvar, delta($delta)

		** DEFINE EVENT VARIABLE **
		if "`changein'"!="" {
			gen `level' = `changein'
			gen `event' = D.`level'
		}
		if "`eventis'"!="" {
			gen `event' = `eventis'
		}

		** IMPOSE MINYEAR AND MAXYEAR **
		replace `event' = 0 if $yearvar<=$datastart | $yearvar>$dataend

		** IMPOSE MAXCHANGE **
		if `maxchange'!=-9999 {
			replace `event' = abs(`maxchange') if `event'>abs(`maxchange') & `event'!=.
			replace `event' = -abs(`maxchange') if `event'<-abs(`maxchange')
		}

		** IMPOSE IF CONDITION **
		if "`if'"!="" {
			replace `event' = 0 if ~(`if')
		}

		** GENERATE EVENT DUMMIES **
		if `window'>0 {
			foreach horizon of numlist `window'/1 {
				gen `pre'_n`horizon' = F`horizon'.`event'
			}
		}
		gen `pre'_0 = `event'
		mvencode `pre'_0, mv(0) override
		if `window'>0 {
			foreach horizon of numlist 1/`window' {
				gen `pre'_p`horizon' = L`horizon'.`event'
			}
			mvencode `pre'_n`window'-`pre'_n1 `pre'_p1-`pre'_p`window', mv(0) override
		}


		if "`nopoly'"=="" {

			** GENERATE POLYNOMIALS (SEPARATELY FOR LEFT AND RIGHT SIDES) **
			foreach order of numlist 0/`polyorder'{			
				gen `pre'_npoly`order' = 0
				gen `pre'_ppoly`order' = 0
				replace `pre'_npoly`order' = `pre'_npoly`order' + `polymidpoint' * `pre'_0*(0^`order')
				replace `pre'_ppoly`order' = `pre'_ppoly`order' + (1-`polymidpoint') * `pre'_0*(0^`order')
				foreach horizon of numlist 1/$maxwindow {
					replace `pre'_npoly`order' = `pre'_npoly`order' + `pre'_n`horizon'*(-`horizon')^`order'
					replace `pre'_ppoly`order' = `pre'_ppoly`order' + `pre'_p`horizon'*(`horizon')^`order'
				}

			}

			** DEFINE POLYNOMIALS CONSTRAINED TO BE CONSTANT FOR LEFT/RIGHT **
			foreach order of numlist 0/`polyorder'{			
				gen `pre'_poly`order' = `pre'_npoly`order' + `pre'_ppoly`order'
			}

			placevar `pre'_npoly*, after(`pre'_poly`polyorder')
			placevar `pre'_ppoly*, after(`pre'_poly`polyorder')

		}



		** DEFINE & RETURN LOCALS **
		c_local `pre'_all "`pre'_n$maxwindow-`pre'_p$maxwindow"
		c_local `pre'_local "`pre'_n$localgraphwindow-`pre'_p$localgraphwindow"
		foreach window of numlist 1/$maxwindow {
			c_local `pre'_win`window' "`pre'_n$maxwindow-`pre'_n`window' `pre'_p`window'-`pre'_p$maxwindow"
		}
		foreach order of numlist 0/$maxpolyorder {
			c_local `pre'_poly`order' "`pre'_poly0-`pre'_poly`order'"
			c_local `pre'_nppoly`order' "`pre'_npoly0-`pre'_npoly`order' `pre'_ppoly0-`pre'_ppoly`order'"
		}		
	}

end


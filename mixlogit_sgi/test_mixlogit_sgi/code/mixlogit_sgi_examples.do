/**********************************************************
 *
 * MIXLOGIT_SGI_EXAMPLES.DO: Estimates choice model on simulated data
 * using SGI
 *
 **********************************************************/
set linesize 255

**********************************************************
* PRELIMINARIES
**********************************************************
version 11
clear all
set mem 1g
set matsize 5000
set more off
adopath + "..\external\"

/* true DGP for test data:
mid = 0.2
sd_mid = 1
high = 0.5
sd_high = 1
price = 1
sd_price = 1
*/

u ../input/testdata.dta, clear
egen grp = group(indiv trip)

foreach a of numlist 3(1)12 {
display "SGI: accuracy `a'"
timer on 1
mixlogit_sgi choice, rand(mid high price ) group(grp) id(indiv) iterate(10) acc(`a') sgi
display e(nrep)
timer off 1
timer list 1
timer clear
}

foreach h of numlist 30(10)100 {
display "Halton: draws `h'"
timer on 1
mixlogit_sgi choice, rand(mid high price ) group(grp) id(indiv) iterate(10) nrep(`h')
timer off 1
timer list 1
timer clear
}

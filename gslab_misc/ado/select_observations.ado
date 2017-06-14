****************************************************************************************************
*
* SELECT_OBSERVATIONS.ADO
*
* Keep observations from the dataset in memory that match a using dataset.
*
****************************************************************************************************

program select_observations
    version 11
    syntax varlist using, [utostring(str) udestring(str) delim(str) uif(str) umatch(str) *]
    
    preserve
    tempfile temp
    
    if "`delim'"=="comma" {
        insheet `using', comma clear
    }
    else if "`delim'"=="tab" {
        insheet `using', tab clear
    }
    else {
        use `using', clear
    }
    
    if "`utostring'" ~= "" {
        tostring `utostring', replace
    }
    if "`udestring'" ~= "" {
        destring `udestring', replace
    }
    
    if "`umatch'" ~= "" {
        forv i = 1/`nvar'{
            local oname: word `i' of `umatch'
            local nname: word `i' of `varlist'
            if "`oname'" ~= "`nname'"{
                rename `oname' `nname'
            }
        }
    }

    if "`uif'"~="" {
        keep if `uif'
    }

    keep `varlist'
    duplicates drop
    save `temp'
    
    restore
    merge m:1 `varlist' using `temp', keep(match) nogen    
end

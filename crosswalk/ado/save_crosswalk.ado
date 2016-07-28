 /**********************************************************
 *
 *  save_crosswalk.ado: Save a crosswalk file
 * 
 **********************************************************/ 

 program save_crosswalk
    version 12
    syntax  anything(name=filename), from(varlist) to(varname) [fromfile(str) tofile(str) ///
        to_missok *]

    * validate from data
    if "`fromfile'" ~= "" {
        preserve
        qui merge 1:1 `from' using `fromfile', nogen assert(2 3)
        restore
    }

    * validate to data
    if "`tofile'" ~= "" {
        preserve
        drop if missing(`to')
        qui merge m:1 `to' using `tofile', nogen assert(2 3) 
        restore
    }

    keep `from' `to'

    if "`to_missok'" == "" {
        drop if missing(`to')
    }

    save_data `filename', key(`from') `options'
end
    

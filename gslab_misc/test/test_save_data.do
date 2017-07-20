quietly {
    version 11
    set more off
    adopath + ../ado
    preliminaries

    program main
        tempfile tempdta temptxt tempcsv templog
        clean_up
        quietly setup_data

        testgood save_data `tempdta', key(id)
        testgood save_data `tempdta', key(id) replace
        testgood save_data `tempdta', key(id1 id2) replace
        testgood save_data `tempdta', key(strid) replace
        testgood save_data `temptxt', key(id) outsheet
        testgood save_data `tempcsv', key(id) outsheet delim("'")
        testgood save_data `tempdta', key(id) log(`templog') replace
        testgood save_data `tempdta', key(id) log(none) replace
        testgood save_data `tempdta', key(id) nopreserve replace
        
        * Confirm that log file is saved to ../output when that directory exists
        * and when it's part of the file you're saving.
        mkdir ../output
        testgood save_data ../output/temp.dta, key(id) replace

        * Confirm that log files were created successfully
        testgood type `templog'
        testgood type ../output/data_file_manifest.log
        
        testbad save_data `tempdta'
        testbad save_data `tempdta', key(id1)   
        testbad save_data `tempdta', key(badid) 
        testbad save_data `tempdta', key(badstrid)    
        testbad save_data `tempdta', key(id) log(./blah/output.log) 
        
        * Help file exists
        testgood type ado/save_data.hlp        
   
        * Confirm if expression works for .dta and .csv
        testgood save_data `tempdta' if id<=50, key(id) replace
        testgood save_data `tempcsv' if id<=40, key(id) outsheet delim("'") replace
        use `tempdta', clear
        assert _N==50
        insheet using `tempcsv', delim("'") clear
        assert _N==40
        
        test_datasignature
        
        quietly clean_up
    end

    program clean_up
        cap erase data_file_manifest.log
        cap erase ../output/data_file_manifest.log
        cap erase ../output/temp.dta
        cap rmdir ../output
    end 

    program setup_data
        set obs 100
        gen id = _n
        gen id1 = floor(_n/10)
        gen id2 = mod(_n,10)
        gen strid = string(id)
        gen badid = id
        replace badid = . in 1
        gen badstrid = strid
        replace badstrid = "" in 1
    end
    
    program test_datasignature
        clear
        quietly set seed 100
        quietly set obs 100
        gen b = runiform()
        gen a = runiform()
        gen c = rnormal()
        gen double d = _n // too much precision
        save_data ../output/temp.dta, key(a) replace log_replace
        
        use ../output/temp.dta, clear
        quietly datasignature
        local signature = r(datasignature)
        tempname fh
        file open `fh' using ../output/data_file_manifest.log, read
        file read `fh' line
        while r(eof)==0 {
            if strpos("`line'", "`signature'")>0 {
                local correct_signature_found = "true"
            }
            file read `fh' line
        }
        file close `fh'
        
        assert "`correct_signature_found'"=="true"
    end
}

* EXECUTE
main



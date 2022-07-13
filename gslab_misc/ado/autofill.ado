/**********************************************************
 *
 * AUTOFILL.ADO: Facilitates exporting TeX macros.
 *
 * 
 * 
 *
 **********************************************************/

program autofill
	syntax, value(str) commandname(str) outfile(str) [append(str) mode(str)]
	if "`append'" == "append" {
	    file open f using "`outfile'", write append	
	}
	else {
	    file open f using "`outfile'", write replace	
	}
    if "`mode'" == "text" {			
		file write f "\newcommand{\\`commandname'}{\textnormal{`text'}}" _n
	} 
	else {	    
		file write f "\newcommand{\\`commandname'}{`text'}" _n
	}	
	file close f	
end


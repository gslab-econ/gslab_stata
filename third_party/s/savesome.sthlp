{smcl}
{* 25 April 2001/9 August 2011/23 February 2015}{...}
{hline}
help for {hi:savesome}
{hline}

{title:Save subset of data}

{p 8 17 2}{cmd:savesome} [{it:varlist}] [{cmd:if} {it:exp}] [{cmd:in} {it:range}] 
{cmd:using} {it:filename} [{cmd:,} {cmd:old} {it:save_options}]


{title:Description} 

{p 4 4 2}{cmd:savesome} saves part of the data in memory to {it:filename}.
If {it: filename} is specified without an extension, {cmd:.dta} is used. 


{title:Options} 

{p 4 8 2}{cmd:old} specifies use of {c -} 
depending on which is current in your Stata {c -} 
either the {help saveold} command or {help save: save, old} to save
datasets to be readable by an older version of Stata. 

{p 4 4 2}{it:save_options} are (other) options of {cmd:save} or,
as the case may be, {cmd:saveold}. See help on {help save} either way. 


{title:Examples}

{p 4 8 2}{cmd:. savesome if foreign using foreign.dta}

{p 4 8 2}{cmd:. savesome mpg weight make using small}

{p 4 8 2}{cmd:. savesome mpg weight make using small6, old}


{title:Author} 

{p 4 4 2}Nicholas J. Cox, Durham University, U.K.{break}
         n.j.cox@durham.ac.uk


{title:Acknowledgments}

{p 4 4 2}(August 2011) Kenneth L. Simons suggested a fix to cope with spaces in filenames. 

{p 4 4 2}(February 2015) David Radwin alerted me to a problem with the {cmd:old} option, which was not finding {cmd:saveold} in recent versions of Stata. 


{title:Also see}

{p 4 4 2}On-line: help for {help save}{p_end}
{p 4 4 2} Manual: {hi:[D] save}


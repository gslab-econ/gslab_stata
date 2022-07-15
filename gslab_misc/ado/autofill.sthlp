{smcl}

{* *! version 16.0 13jul2022}{...}

{p2col:{bf:autofill}}Export autofill values

 

{marker syntax}{...}

{title:Syntax}

{p}

{cmd:autofill} {cmd:,} {opt value(str)} {opt commandname(str)} {opt outfile(str)} [{opt append(str)} {opt mode(str)} ]

 
{marker description}{...}

{title:Description}

{pstd}

{cmd:autofill} facilitates exporting values as TeX macros.


{marker options}{...}

{title:Options}

{phang}{opt value(str)} is required, it corresponds to the value or text you would like to export.

{phang}{opt commandname(str)} is required, it gives the command name you would like to use in the macro.

{phang}{opt outfile(str)} is required, it gives the file into which you would like to export.

{phang}{opt append(str)} is optional, write "append" if you would like to append to an existing file.

{phang}{opt mode(str)} is optional, writing "text" will add \textnormal to the macro.


{marker examples}{...}

{title:Examples}

{hline}

{pstd}Setup

 

{phang2}{cmd:. autofill, value(0.004) commandname(pValue) outfile(pValue.tex)}

{phang2}{cmd:. autofill, value(0.004) commandname(pValue) outfile(pValue.tex) append("append")}

{phang2}{cmd:. autofill, value("p-value <= 0.05") commandname(pValue) outfile(pValue.tex) append("append") mode("text")}
 

{hline}

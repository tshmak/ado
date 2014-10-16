#delim ;
prog def eclplot;
version 8;
/*
  Create plot of estimates and confidence limits
  (vertical or horizontal)
  against a numeric parameter ID variable..
*! Author: Roger Newson
*! Date: 23 July 2003
*/

syntax varlist(numeric min=4 max=4) [if] [in] [,HORizontal RPLOTtype(string) ESTOPTS(string asis) CIOPTS(string asis) PLOT(string asis) *];
/*
 -varlist- is a list of 4 variables
  (estimate, lower confidence limit, upper confidence limit,
  and numeric parameter ID variable to plot them against).
 -horizontal- specifies that a horizontal CI plot will be drawn
  (instead of the default vertical CI plot).
 -rplottype- specifies the range plot type used to draw the confidence limits
  (defaulting to -rcap- to give capped CI plots).
 -estopts- specifies the estimates options
  (to be passed to -graph twoway scatter- to control the estimate points)
 -ciopts- specifies the confidence interval options
  (to be passed to -graph twoway `rplottype' - to control the confidence limits).
 -plot- specifies other plots to be added to the generated graph.
*/

* Mark sample to be used by plot of estimates and confidence limits *;
marksample touse,novarlist;

* Check range plot type and set to default if empty *;
if `"`rplottype'"'=="" {;local rplottype "rcap";};

* Variables to plot and their labels *;
local estimate:word 1 of `varlist';
local clmin:word 2 of `varlist';
local clmax:word 3 of `varlist';
local parmid:word 4 of `varlist';
local estlab:var lab `estimate';
if `"`estlab'"'=="" {;local estlab "`estimate'";};
local parmlab:var lab `parmid';
if `"`parmlab'"'=="" {;local parmlab "`parmid'";};

* Generate plots *;
if "`horizontal'"=="" {;
  * Vertical plot *;
  twoway `rplottype' `clmax' `clmin' `parmid' if `touse' & !missing(`clmin') & !missing(`clmax') & !missing(`parmid'), `ciopts'
    || scatter `estimate' `parmid' if `touse' & !missing(`estimate') & !missing(`parmid'), `estopts'
    || `plot' || ,
    xlabel(,valuelabel) ytitle(`"`estlab'"') xtitle(`"`parmlab'"') legend(off)
    `options';
};
else {;
  * Horizontal plot *;
  twoway `rplottype' `clmax' `clmin' `parmid' if `touse' & !missing(`clmin') & !missing(`clmax') & !missing(`parmid'),horizontal `ciopts'
    || scatter `parmid' `estimate' if `touse' & !missing(`estimate') & !missing(`parmid'), `estopts'
    || `plot' || ,
    yscale(reverse) ylabel(,valuelabel angle(0)) ytitle(`"`parmlab'"') xtitle(`"`estlab'"') legend(off)
    `options';
};

end;

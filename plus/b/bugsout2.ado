*! version 1.0.1 DCGreenwood 25 April 2006

*! To convert BUGS output to Stata !!
* Based on bugsout.ado by A.P.Mander
* Adapted by D.C.Greenwood 10-05-05

program define bugsout2
version 8.2
pause on

syntax , FILE(string) [WIDE CHains(integer 1) TEMP(string)]

if "`temp'"=="" { 
	tempfile ade 
}
else { 
	local ade="`temp'" 
}

di in gr "Reading index for `file' ....."
infile str20 var start end using "`file'Index.txt"
compress
local max=_N
local maxobs=end[_N]
set obs `maxobs'

gen str20 variable=""
local now=1
local i=1
while `i'<=`max' {
	local j=start[`i']
	local k=end[`i']
	while `j'<=`k' {
		qui replace variable=var[`i'] in `j'
	local j=`j'+1
	}
local i=`i'+1
}
keep variable
cap save `ade', replace

local c = `chains'

while `c'>0 {
	capture drop _all
	di in gr "Reading file `file'`c'.txt ....."
	infile iter sample using "`file'`c'.txt"
	merge using `ade'
	drop _merge
	compress
	drop if variable==""
	gen chain = `c'
	cap save bugsouttemp`c', replace
	local c = `c'-1
}	

capture drop _all
use bugsouttemp1
if `chains'>1 {
	forvalues num = 2/`chains' {
		append using bugsouttemp`num'
	}
}

/*	the next stuff will make the data wide */

if "`wide'"~="" {
	qui {
		replace variable = subinstr(variable,"[","_",.)
		replace variable = subinstr(variable,"]","_",.)
		reshape wide sample, i(chain iter) j(variable) string
	}
*drop iter
renpfix sample
}
end

*! version 1.0.4 DCGreenwood 28Jul2006

/* Program to convert stata data into format for WinBugs					*/
/* Based on bugsdat.ado by A.P.Mander 25th Nov 1998						*/
/*														*/
/* Nobs requests the number of observations to be output as a constant			*/
/* ARRAY is name of variables to be output as an array 					*/
/*  Variables to be in an array must have common stub followed by a number		*/
/*  Only 2 dimensional arrays are currently permitted						*/
/* NArray requests the width of each array to be output as constants			*/
/* CONST allows addition of constants to the output dataset, e.g. ", mu=10"		*/
/*  It also allows any other information to be added						*/
/* WIdth is the number of observations to display on the screen on one line		*/
/* Format allows the format of the output to be altered, e.g. number of decimal places */ 
/* Linesize allows the length of the lines to be altered to avoid ">" wrapping symbols */
/* FILE is the name of the output dataset								*/
/*  For the file to be saved, this program must not be run in quiet mode		*/	

program define bugsdat2
version 8.2

syntax [varlist(default=none)]  [, Nobs NArray Const(string) ARray(string) WIdth(integer 5) Format(string) Linesize(integer 160) FILE(string) REPLACE]

preserve

tokenize `varlist'

capture set linesize `linesize'
cap log close
if "`file'"~="" {
	capture log using "`file'", text `replace'
}
else {
	capture log using bugs.dat, text `replace'
}

local maxobs=_N
local length=`maxobs'

di "list("
if "`nobs'"~="" {
	di "N= `maxobs', " 
}

while "`1'"~="" {
	local where=1
	di "`1'" "= c("
	local i=1
	while(`i'<=`length') {
		if `i'==1 {
			if `where'<=`maxobs' {
				if `1'[`where']==. {
					di _continue,"NA"
				}
				else {
					di _continue, `format' `1'[`where']
				}
			}
			local j=2
			local where=`where'+1
		}
		else {
			local j=1
		}
		while(`j'<=`width') {
			if `where'<=`maxobs' {
				if `1'[`where']==. {
					di _continue, ",","NA"
				}
				else {
					di _continue, ",", `format' `1'[`where']
				}
			}
			local j=`j'+1
			local where=`where'+1
		}
		if `where'<=`maxobs' {
			di
		}
		local i=`i'+1
		if `where'>`maxobs' {
			local i=`length'+1
		}
	}
	if "`2'"~="" {
		di ")",","
	}
	else if "`2'"=="" & "`array'"~="" {
		di ")",","
	}
	else if "`2'"=="" & "`array'"=="" {
		di ")"
	}
	mac shift
}

tokenize `array'

while "`1'"~="" {
	qui gen _id = _n
	qui reshape long `1', i(_id) j(repeat)
	qui summ(repeat)
	local rep = r(max)
	local maxobs=_N
	local length=`maxobs'
	local where=1
	di "`1'" "= structure(.Data= c("
	local i=1
	while(`i'<=`length') {
		if `i'==1 {
			if `where'<=`maxobs' {
				if `1'[`where']==. {
					di _continue,"NA"
				}
				else {
					di _continue, `format' `1'[`where']
				}
			}
			local j=2
			local where=`where'+1
		}
		else {
			local j=1
		}
		while(`j'<=`width') {
			if `where'<=`maxobs' {
				if `1'[`where']==. {
					di _continue, ",","NA"
				}
				else {
					di _continue, ",", `format' `1'[`where']
				}
			}
			local j=`j'+1
			local where=`where'+1
		}
		if `where'<=`maxobs' {
			di
		}
		local i=`i'+1
		if `where'>`maxobs' {
			local i=`length'+1
		}
	}
	local dim1 = `maxobs'/`rep'
	di "),"
	di ".Dim = c(`dim1',`rep'))" _continue 
	if "`narray'"~="" {	
		di ","
		di  _continue "N`1'=`rep'" 
	}
	if "`2'"~="" {
		di "," 
	}
	qui reshape wide `1', i(_id) j(repeat)
	capture drop _id
	capture drop repeat
	mac shift
}
if "`const'"~="" {
	di ", `const'"
}

di ")"

qui log cl
qui capture drop _all
end




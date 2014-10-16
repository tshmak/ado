*! version 1.0.1 DCGreenwood 25 April 2006

*! To convert BUGS results to Stata !!
* by D.C.Greenwood 17-05-05

program define bugsres, rclass
version 8.2
pause on

syntax , FILE(string) [CLEAR]

tempfile original
if "`clear'"~="" {
	qui capture drop _all
	qui insheet using "`file'"
}
else {
	qui capture erase `original'
	qui capture save `original', replace
	qui insheet using "`file'"
}

qui keep if v1==""
qui describe
local colmax = r(k)
qui drop v1

forvalues col = 2/`colmax' {
	local stat = v`col'[1]
	if "`stat'"=="MC error" {
		local stat = "mc_error"
	}
	if "`stat'"=="2.5%" {
		local stat = "lower_ci"
	}
	if "`stat'"=="97.5%" {
		local stat = "upper_ci"
	}
	rename v`col' `stat' 
}
qui drop if _n==1
qui destring, replace

local nodelist = ""
local rowmax = _N
forvalues row = 1/`rowmax' {
	local nodelist = "`nodelist' "+node[`row']
	return scalar mean`row' = mean[`row']
}
return local nodelist = `"`nodelist'"'

foreach var of varlist mean-sample {
	mkmat	`var'
	matrix rownames `var' = `nodelist'
	return matrix `var' `var'
}
return scalar N = `rowmax'

display ""
display in text "        Node {c |}     Mean        SD     MC_Error      2.5%     Median      97.5%      Start     Sample"
display in text "{hline 13}{c +}{hline 87}"
forvalues row = 1/`rowmax' {
	display _continue in text %12s node[`row'] " {c |}" 
	foreach var of varlist mean-sample {
		display _continue as result " " %8.0g `var'[`row'] "  "
	}
	display 
}
display in text "{hline 13}{c BT}{hline 87}"

if "`clear'"==""  {
	qui capture drop _all
	qui capture use `original'
	qui capture erase `original'
}

end


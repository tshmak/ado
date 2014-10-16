*! Program to give values as well as value label in tabulate
capture program drop tab_
program define tab_ , byable(recall)

	version 9
	
	syntax varlist(max=2) [if] [in] [fw aw pw iw] [, *]
	
	tempvar var1 var2
	local i=1
	foreach var in `varlist' {
		local valuelabel : value label `var'
		if "`valuelabel'" == "" {
			local varlist2 `varlist2' `var'
			local i=`i'+1
			continue
		}
		
		qui gen `var`i'' = `var'
		
		// Get value labels
		qui levelsof `var' 
		tempname label`i' 
		foreach level in `r(levels)' {
			local label : label `valuelabel' `level', strict
			label define `label`i'' `level' `"(`level') `label'"', add
		}
		label values `var`i'' `label`i''
		
		// Get variable name
		local varlabel : variable label `var'
		if "`varlabel'" == "" label var `var`i'' "`var'"
		else label var `var`i'' `"`varlabel'"'
		local varlist2 `varlist2' `var`i''
		local i=`i'+1

	}
	
	tab `varlist2' `if' `in' `weight'`exp', `options'
end

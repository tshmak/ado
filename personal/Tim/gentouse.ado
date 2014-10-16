*! Program to generate a "touse" variable based on non-missing values
capture program drop gentouse 
program define gentouse

	syntax anything(equalok) [if] [in] 
	tokenize `"`anything'"', parse("=")
	
	local nameequal `1' `2'
	local 0 `3' `if' `in'
	syntax varlist(fv) [if] [in]
	marksample touse
	gen `nameequal' `touse' 
	
end

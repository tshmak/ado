*! Program to list other family members of individuals characterized by 'if' conditions
*! Version 0.1
capture program drop listfam 
program define listfam

	syntax if/ , FAMily(varname) [ALSOlist(varlist) *]
	marksample selected
	
	tempvar selected_family
	qui bysort `family' : egen `selected_family' = max(`selected')
	
	local tocheck `if'
	foreach symbol in & | ( ) [ ] = > < ! {
		local tocheck : subinstr local tocheck "`symbol'" " ", all
	}
	local nwords : word count `tocheck'
	tokenize `"`tocheck'"'
	forval i=1/`nwords' {
		if `"``i''"' != "" {
			capture confirm variable ``i'' 
			if _rc == 0 {
				local varlist `varlist' ``i''
			}
		}
	}
	
	list `selected' `varlist' `family' `alsolist' if `selected_family' , sepby(`family') `options'
	
end

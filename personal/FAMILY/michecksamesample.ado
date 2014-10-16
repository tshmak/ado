program define michecksamesample 

	/* Program to check whether the same sample is used 
		when running a series of models with -mi- 
		(so that you don't find that out after spending ages 
		-mi estimate-) */ 
	
	syntax varlist(min=2 fv) [if] [in], [nopreserve]
	if "`preserve'" != "nopreserve" preserve

	mi update 
	marksample touse, novarlist
	
	mi extract 1, clear
	qui keep if `touse' 
	
	tempvar test
	fvrevar `varlist', list
	local varlist `r(varlist)'
	gettoken firstvar varlist : varlist

	qui gen `test' = .
	foreach var in `varlist' {
		qui replace `test' = (`var' <.) == (`firstvar' < .)
		sum `test', meanonly
		if r(mean) < 1 {
			di as err "Missing values pattern differ between {res:`firstvar'} and {res:`var'}"
			error 999
		}
	}
			
end
	

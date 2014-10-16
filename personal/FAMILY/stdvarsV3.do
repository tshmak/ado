* Program to generate variables that are standardized/centred variables 
* Can do it -by- a variable. Meant for use with -mi set flong- type data.
capture program drop stdvars
program define stdvars, nclass 

	version 9
	syntax varlist [if] [in], [ PREfix(name) replace CENter ALSOuse(varlist) mean(string) sd(string) by(varname) ] 
	
	local mean2 `mean'
	local sd2 `sd'
	
	if "`prefix'" == "" local prefix _STD_
	local varlist2 `varlist'
	local varlist : list varlist | alsouse
	marksample touse
	
	tempvar temp BY
	if "`by'" == "" gen `BY' = `touse'
	else gen `BY' = `by'

	qui levelsof `BY' 
	local levels `r(levels)'
	foreach var in `varlist2' {
		capture gen `prefix'`var' = .
		if _rc == 110 & "`replace'" == "replace" {
			qui replace `prefix'`var' = .
		}
		else if _rc != 0 {
			gen `prefix'`var' = .
		}

		foreach level in `levels' {
		
			if "`mean2'" == "" {
				qui sum `var' if `touse' & `BY' == `level', meanonly
				local mean = r(mean)
			}
			else if real("`mean2'") == . {
				unab meanvar : `mean2'
				qui sum `meanvar' if `touse' & `BY' == `level', meanonly
				local mean = r(mean)
			}
		
			if "`center'" != "center" {
				if "`sd2'" == "" {
					qui sum `var' if `touse' & `BY' == `level'
					local sd = r(sd)
				}
				else if real("`sd2'") == . {
					unab sdvar : `sd2'
					qui sum `sdvar' if `touse' & `BY' == `level'
					local sd = r(sd)
				}
		
				gen `temp' = (`var' - `mean') / `sd' if `touse' & `BY' == `level'
			}
			else {
				gen `temp' = (`var' - `mean') if `touse' & `BY' == `level'
			}
			qui replace `prefix'`var' = `temp' if `touse' & `BY' == `level'
			drop `temp' 
		}
	}
end
				

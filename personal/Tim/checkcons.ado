*! Program to check whether a list of variables are constant within groups 
capture program drop checkcons
program define checkcons , sortpreserve

	version 9
	syntax varlist [if] [in], by(varname) [Missing ALLMissing] 
	marksample touse, novarlist

	tempvar tag test tag2 test2
	
	foreach var in `varlist' {
		di as txt "`var':" 
	
		qui egen `tag' = tag(`by' `var') if `touse' , `missing'
		qui bysort `by' : egen `test' = total(`tag') if `touse'
		
		qui egen `tag2' = tag(`by' `var') if `touse' 
		qui bysort `by' : egen `test2' = total(`tag2') if `touse'
		
		if "`allmissing'" == "allmissing" {	
			// Check whether it's all missing as well
			di as txt "The following are all missing within `by':" 
			qui levelsof `by' if `touse' & `test2' == 0, miss
			if `"`r(levels)'"' == "" di "{it: <none>}"
			else di as res `"`r(levels)'"'
		}
		
		di as txt "The following are not unique:" 
		qui levelsof `by' if `touse' & `test' > 1, miss
		if "`r(levels)'" != "" {
			local levels `"`r(levels)'"'
			local levels : subinstr local levels `"""' `""""', all
			foreach level in `levels' {
				qui levelsof `var' if `by' == `level' & `touse', `missing'
				di as txt `"`by' == `level': "'_c
				di as res `"`r(levels)'"'
			}
		}
		else di "{it: <none>}"
		drop `test' `tag' `test2' `tag2'
	}
end

	
	

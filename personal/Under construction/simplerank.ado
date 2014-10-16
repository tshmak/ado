* Program to get simple rank of a variable
* Created Aug 2009 by Timothy Mak

program define simplerank, nclass sortpreserve

	version 8 

	syntax name =/exp [if] [in]

	marksample touse

	tempvar newvar

	qui gen `newvar' = `exp' if `touse' 

	sort `newvar' 

	qui gen `namelist' = 1 if `touse' & `exp' <.

	local exp `exp'

	tempname currentvar

	local start = 0
	local currentrank = 1
	forval i=1/`c(N)' {

		local currentranktest = `namelist'[`i']

		if `currentranktest' < . {

			if `start' == 0 | `i' == 1 {
				local start 1
				scalar `currentvar' = `exp'[`i']
			}
			else {
				if `newvar'[`i'] == `currentvar' {
					qui replace `namelist' = `currentrank' in `i'
				}
				else {
					local currentrank = `currentrank' + 1
					qui replace `namelist' = `currentrank' in `i'
					scalar `currentvar' = `exp'[`i']
				}
			}
		}
	}

end




capture program drop bugsdata
* Version 1.0.0 Jan 2014 Timothy Mak
program define bugsdata

	syntax [anything(equalok)] [if] [in] [using] , [by(varlist) replace bylevel append ///
		Scalars(string) nopreserve sort(varlist)]
	
	if "`preserve'" == "" preserve
	// use syntax for clist in -collapse- for anything, except don't put (stat)
	// e.g. mean=ABC 
	local firsttime firsttime
	
	if "`anything'" != "" {
		marksample touse, novarlist
		
		qui keep if `touse'
		if "`sort'" == "" {
			tempvar sort
			qui gen `sort' = _n
			if "`bylevel'" == "" {
				di as txt "Data sorted by current order within {bf:by} levels"
			}
		}
		
		if "`by'" != "" {
			// Test if there are missing in `by'
			foreach byvar in `by' {
				qui count if `byvar' >= .
				if `r(N)' > 0 {
					di as err "There are missing values in `byvar'"
					error 999
				}
			}

			if "`bylevel'" == "" {
				tempvar id
				qui bysort `by' (`sort') : gen `id' = _n
				local by `by' `id'
			}
			else {
				di as txt "It's your responsibility to make sure {res:`anything'} are constant across {res:`by'}"
			}
		}
		else {
			tempvar id
			qui gen `id' = _n
			local by `by' `id'
		}
		
		// Collapse data
		qui collapse (first) `anything', by(`by')
		unab allvars : _all
		unab byvars : `by'
		local varlist : list allvars - byvars
		
		// Create tempvars
		tempvar cons
		qui gen `cons' = 1
		local i=1
		foreach byvar in `by' {
			local level`i'var `byvar'
			tempvar level`i'Var
			local cumvarold `cumvar'
			local cumvar `cumvar' `byvar'
			qui egen `level`i'Var' = tag(`cumvar')
			qui recode `level`i'Var' (0=.)
			if `i' == 1 {
				qui bysort `cons' (`byvar' `level`i'Var') : replace `level`i'Var' = sum(`level`i'Var')
			}
			else {
				qui bysort `cumvarold' (`byvar' `level`i'Var') : replace `level`i'Var' = sum(`level`i'Var')
			}
			local BYvarlist `BYvarlist' `level`i'Var'
			qui sum `level`i'Var' 
			local nlevels`i' = r(max)
			local i = `i' + 1
		}

	* list `by' `BYvarlist' in 1/100 

		// Define nlevels
		local nlevels : word count `by'

		// Rectangularize data
		if `nlevels' > 1 fillin `BYvarlist' 
		foreach var in `varlist' {
			qui tostring `var', replace force
			qui replace `var' = "NA" if `var' == "." | `var' == ""
		}
	* list `by' `BYvarlist' `varlist' in 1/100 
	}
	
	// Outputs heading
	if `"`using'"' == "" {
		local output di as txt
		local ending _cont
	}
	else {
		local output file write _H_
		if "`append'" == "" {
			file open _H_ `using', write `replace' 
		}
		else {
			local firsttime
			file open _H_ `using', read write
			file seek _H_ eof
			file seek _H_ query
			local startfrom = r(loc) - 3
			file seek _H_ `startfrom'
			file read _H_ test
			if "`test'" != ")" {
				file close _H_
				di as err "Cannot find end of file. I can't append to this file."
				error 999
			}
			file seek _H_ `startfrom'
		}
	}
		
	// Headers
	if "`firsttime'" == "firsttime" {
		`output' "list(" `ending' 
	}
	else {
		`output' ", " `ending'
	}

	if "`anything'" != "" {
		
		// Loop over varlist
		local I = 1
		foreach var in `varlist' {
		
			// Add comma
			if `I' > 1 {
				`output' ", " `ending'
			}
			
			// Headers
			if `nlevels' > 1 {
				`output' _n "`var'=structure(.Data=c(" `ending' 
			}
			else {
				`output' _n "`var'=c(" `ending' 
			}

			// Meat
			`output' "`=`var'[1]'" `ending'
			forval i=2/`=c(N)' {
				`output' ",`=`var'[`i']'" `ending'
			}
			
			// Ending
			if `nlevels' > 1 {
				`output' "), .Dim=c(`nlevels1'" `ending'
				forval j=2/`nlevels' {
					`output' ", `nlevels`j''" `ending'
				}
				`output' "))" `ending'
			}
			else {
				`output' ")" `ending'
			}
			local firsttime
			local I = `I' + 1
			
		}
	}
	
	if "`scalars'" != "" {
		if "`anything'" != "" {
			`output' ", " `ending'
		}
		`output' _n "`scalars'" `ending'
	}
			
	`output' ")" _n
		

	if `"`using'"' != "" {
		file close _H_
	}
	
end

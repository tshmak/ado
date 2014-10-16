*! Version 1.0.0 02-Nov-2010
program define eencode, sortpreserve nclass 
	
	* eencode: Extended encode to allow alternative coding of string variables

	version 8

	syntax varlist [if] [in] [, Generate(namelist) replace Levels(numlist) noRestrict]

	*** Syntax checking ***
	capture confirm string variable `varlist' 
	if _rc != 0 {
		di "Not all of varlist are string variables" 
		exit _rc
	}

	if "`replace'" == "" {
		local n_gen_varlist : word count `generate'
		local n_varlist : word count `varlist'
		if `n_varlist' != `n_gen_varlist' {
			di in red "Length of generated varlist does not match length of varlist"
			exit 198
		}
	}
	else {
		if "`generate'" != "" {
			di in yellow "replace" in gr " may not be specified together with " in ye "generate" in gr "."
			exit 198
		}
	}

	tempvar presentsort
	gen `presentsort' = _n
	marksample touse, strok 

	local restrict_clause = cond(`"`restrict'"' == "norestrict", `""', `" & \`touse'"')

	foreach var in `varlist' {

		tempvar newvar
		qui gen byte `newvar' = .

		tempvar select 
		bysort `touse' `var' (`presentsort') : gen byte `select' = (_n == 1) & `touse'
		qui count if `select' == 0 & `touse'
		local extras = r(N)
		qui count if `touse'
		local ntouse = r(N)
		local numlevs = `ntouse' - `extras'
		qui count if `select' == 0
		local j = 1 + r(N)
		local nvals = c(N)

		local no_specified_levels : word count `levels'

		if `no_specified_levels' > 0 { 
			if `no_specified_levels' != `numlevs' {
				di in gr "Number of levels in " in ye "`var'" in gr " does not equal"_c
				di " the number of levels supplied."
				if "`replace'" == "replace" {
					di _n
					local useuser 0					
					continue 
				}
				else {
					di "Natural levels (i.e. 1,2,3,4...) used."
					local useuser 0
				}
			}
			else {
				local useuser 1

			}
		}
		else {
			local useuser 0
		}

		sort `select' `presentsort'
		tempname label

		local valtouse 1

		forval i=`j'/`nvals' {

			if `useuser' {
				local valtouse2 : word `valtouse' of `levels' 
			}
			else {
				local valtouse2 `valtouse'
			}
			local valtouse = `valtouse' + 1

			local name = `var'[`i']
			label define `label' `valtouse2' "`name'", add

			qui replace `newvar' = `valtouse2' if `var' == "`name'" `restrict_clause'


		}

		
		local varlabel : variable label `var'

		if "`replace'" == "replace" {
			tempvar newvar2
			gen `newvar2' = `newvar'
			move `newvar2' `var'
			drop `var'
			ren `newvar2'  `var'
			label var `var' "`varlabel'"
			capture label list `var'
			if _rc != 0 {
				label copy `label' `var'
				label values `var' `var'
			}
			else {
				local suffix 0
				while _rc == 0 {
					local suffix = `suffix' + 1
					capture label list `var'`suffix'
					if _rc != 0 {
						label copy `label' `var'`suffix'
						label values `var' `var'`suffix'
					}
				}
			}
		}
		else {
			gettoken genvar generate : generate
			gen `genvar' = `newvar'
			label var `genvar' "`varlabel'"
			capture label list `genvar'
			if _rc != 0 {
				label copy `label' `genvar'
				label values `genvar' `genvar'
			}
			else {
				local suffix 0
				while _rc == 0 {
					local suffix = `suffix' + 1
					capture label list `genvar'`suffix'
					if _rc != 0 {
						label copy `label' `genvar'`suffix'
						label values `genvar' `genvar'`suffix'
					}
				}
			}
		}
	}

end


			
		

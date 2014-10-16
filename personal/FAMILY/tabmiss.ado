program define tabmiss, nclass byable(recall)

	version 10
	syntax varlist [if] [in], [BY(varname)]
	
	marksample touse, novarlist strok
	tempvar depvar 
	tempname missing 
	label define `missing' 1 "Missing" 0 "Not missing" 
	foreach var in `varlist' {
	
		qui gen `depvar' = missing(`var') if `touse' 
		label var `depvar' "Missing pattern of `var'"
		label values `depvar' `missing'
		if "`by'" == "" tab `depvar' if `touse'
		else tab `by' `depvar' if `touse', row miss
		drop `depvar' 
		
	}
	
end


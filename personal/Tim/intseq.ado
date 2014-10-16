*! Program to create a variable which is a positive integer sequence based on 
*! its rank
capture program drop intseq
program define intseq, byable(onecall)

	// May want to create an option for treating missing values as normal values

	version 8
	
	syntax anything(equalok) [if] [in]
	// Effective syntax: intseq newvar = vartouse [if] [in]
	
	marksample touse
	
	tokenize `"`anything'"', parse("=")
	
	if `"`2'"' != "=" {
		di as err `""=" not found."'
		exit 111
	}
	
	local newvar `1'
	local vartouse `3'
	
	qui replace `touse' = . if `touse' == 0
	qui replace `touse' = . if `vartouse' >= . 
	
	if "`by'" == "" {
		qui bysort `touse' `vartouse' : gen `newvar' = 1 if _n == 1
		qui replace `newvar' = sum(`newvar') if `touse' == 1
	}
	else {
		qui replace `touse' = . if `by' >= .
		qui bysort `touse' `by' `vartouse' : gen `newvar' = 1 if _n == 1
		qui bysort `touse' `by' (`newvar') : replace `newvar' = sum(`newvar') if `touse' == 1
	}
		
	
end

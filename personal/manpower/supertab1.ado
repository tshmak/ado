program define supertab1, nclass byable(recall)

	syntax varname [if] [in] [, Quiet fw(varname numeric) stat1(string) stat2(string) stat3(string)]

	marksample touse, novarlist

	capture drop _freq 
	capture drop _perc
	capture drop _stat*

	tempvar touse2 
	if "`fw'" == "" {
		qui bysort `varlist' `touse' : gen _freq = _N if `touse' 
	}
	else {
		qui bysort `varlist' `touse' : egen _freq = total(`fw') if `touse'
	}
	if "`stat1'" != "" {
		forval i=1/3 {
			if "`stat`i''" != "" {
				qui bysort `varlist' `touse' : egen _stat`i' = `stat`i'' if `touse'
				local tolist_aswell `tolist_aswell' _stat`i'
			}
		}
	}

	qui bysort `varlist' `touse' : gen `touse2' = _n == 1 if `touse' 
	qui gsort -`touse' -`touse2' -_freq
	qui sum _freq if `touse2' == 1
	local total = `r(mean)' * `r(N)'
	qui gen _perc = _freq / `total' if `touse2' == 1
	if "`in'" != "" local in in `in'
	if "`quiet'" == "" {
		list `varlist' _freq _perc `tolist_aswell' if `touse2' == 1 `in', clean fast 
	}

end

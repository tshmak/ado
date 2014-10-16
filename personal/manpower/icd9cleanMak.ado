program define icd9cleanMak

	version 10
	syntax varname, [GENerate(name) replace PROCedure NOIsily]
	
	if "`generate'" == "" & "`replace'" == "" {
		di as err "Either {txt}generate {err}or {txt}replace {err} must be specified"
		error 999
	}
	else if "`generate'" != "" {
		capture gen str6 `generate' = ""
		if _rc != 0 gen str6 `generate' = ""
	}
	
	if "`noisily'" == "noisily" local quietly noisily
	else local quietly quietly
	tempvar newvar ok ok2 ok3
	`quietly' {
	
		local type : type `varlist'
		if substr("`type'",1,3) != "str" {	
			tostring `varlist', gen(`newvar') force format(%6.0g)
		}
		else gen str6 `newvar' = `varlist'
		replace `newvar' = "" if `newvar' == "."

		replace `newvar' = "" if regexm(`newvar', "^0+")

		if "`procedure'" == "procedure" {
			replace `newvar' = "0" + `newvar' if regexm(`newvar', "^[0-9]\.[0-9]+") | length(`newvar') == 1
			local p p
		}
		
		icd9`p' check `newvar', gen(`ok')
		replace `newvar' = substr(`newvar', 1, length(`newvar')-1) if `ok' == 10 & regexm(`newvar', "^[0-9]+\.[0-9]+")
		icd9`p' check `newvar', gen(`ok2')
		replace `newvar' = substr(`newvar', 1, length(`newvar')-1) if `ok2' == 10 & regexm(`newvar', "^[0-9]+\.[0-9]+")
		icd9`p' check `newvar', gen(`ok3') list
		replace `newvar' = "" if `ok3' > 0
		drop `ok' `ok2' `ok3'
	
	
		if "`generate'" != "" replace `generate' = `newvar'
		else if "`replace'" == "replace" replace  `varlist' = `newvar'

	
	}
	
end

program define egenreplace, byable(onecall)

	version 8 
	
	gettoken newvar 1 : 0
	capture confirm variable `newvar', exact
	if _rc == 111 {
		if "`_byvars'" == "" egen `0'
		else by `_byvars' : egen `0'
	}
	else {
		tempvar var 
		if "`_byvars'" == "" egen `var' `1'
		else by `_byvars' : egen  `var' `1'
		
		qui replace `newvar' = `var'		
	}
end

		

	

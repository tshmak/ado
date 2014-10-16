program define genreplace, byable(onecall)

	version 8 
	
	gettoken newvar : 0
	capture confirm variable `newvar', exact
	if _rc == 111 {
		if "`_byvars'" == "" gen `0'
		else by `_byvars' : gen `0'
	}
	else {
		if "`_byvars'" == "" replace `0'
		else by `_byvars' : replace `0'
	}
end

		

	

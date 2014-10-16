*! Version 1.0.1 Timothy Mak, Sep 2013
program define matamatrix

	version 10
	gettoken left right : 0 , parse("=")
	if `"`right'"' == "" {
		local right "=`left'"
		local left
	}
	
	if substr("`right'",1,1) == "=" local right : subinstr local right "=" "= " 
	
	// Rename e(), r() matrices
	local expression `"`right'"'
	local i = 0
	foreach type in r e {
		local search = 1
		while `search' == 1 {
			local hasmatrix = regexm("`expression'", "[ \-\+\*\(\)\^\|&=<>/:]`type'\([a-zA-Z0-9_]+\)")
			if `hasmatrix' {
				local match = regexs(0)
				local firstchar = substr(regexs(0),1,1)
				if "`firstchar'" == "" local macro `match'
				else local macro : subinstr local match "`firstchar'" ""

				capture matrix list `macro'
				if _rc == 0 {
					tempname macro`i' 
					matrix `macro`i'' = `macro'
					mata: `macro`i'' = st_matrix("`macro`i''")
					local list_of_macro `list_of_macro' `macro`i''
					local expression : subinstr local expression "`match'" "`firstchar'`macro`i''"
					local i = `i' + 1
				}
			}
			else local search = 0
		}
	}
	
	// Remove all non-name characters, e.g. + - 
	local expression2 `"`expression'"'
	foreach char in + - * / # ! = @ ' ^ & ( ) [ ] | \ : ; < > , ! {
		local expression2 : subinstr local expression2 "`char'" " ", all
	}
	tokenize `expression2'
	// Earmark all the functions
	local j = 1
	while "``j''" != "" {
		if regexm("``j''", "[0-9]+") == 0 {
			local expression : subinstr local expression "``j''(" "###`j'(" , all 
		}
		local j = `j' + 1
	}

	// change matrix names to tempnames
	local j = 1
	while "``j''" != "" {
		if regexm("``j''", "^[0-9]+") == 0 {
			tempname macro`i'
			local expression : subinstr local expression "``j''" "`macro`i''" , all count(local count1)
			if `count1' > 0 {
				matrix `macro`i'' = ``j''
				mata: `macro`i'' = st_matrix("`macro`i''")
				local list_of_macro `list_of_macro' `macro`i''
			}
			local i = `i' + 1
		}
		local j = `j' + 1
	}
	
	// Rename the functions 
	local j = 1
	while "``j''" != "" {
		if regexm("``j''", "^[0-9]+") == 0 {
			local expression : subinstr local expression "###`j'(" "``j''(" , all 
		}
		local j = `j' + 1
	}
	
	tempname macro`i'
	mata: `macro`i'' `expression' ; st_matrix("`macro`i''", `macro`i'') 
	mata: mata drop `list_of_macro' `macro`i''
	
	if "`left'" == "" {
		matrix list `macro`i''
	}
	else {
		matrix `left' = `macro`i''
	}

end

	
	
		
	
	

*! 1.0.0, Timothy Mak, 18 Nov 2010
capture program drop bugsfindexec
program bugsfindexec, rclass

	// Syntax is: 
	// bugsfindexec [{directory} , {targetnum}, {currentnum}]
	// {targetnum} is the nth find in the search (i.e. if bugsfindexec is expected
	// to find multiple versions of the bugs executive.)
	// {currentnum} is only for internal use and should not be specified upfront. 
	

	local list_of_names winbugs.exe winbugs14.exe openbugs.exe

	local slash = cond("`c(os)'"=="Windows", "\", "/")

	tokenize `"`0'"' , parse(",")
	local firstdir `1'
	local targetnum `3' 
	if "`targetnum'" == "" local targetnum .
	local currentnum = cond("`4'"==",","`5'", "`4'")
	if "`currentnum'" == "" {
		local currentnum 0
		global currentnum `currentnum'
	}
	else local currentnum $currentnum
	if $currentnum == `targetnum' exit


	tokenize `"`firstdir'"' , parse("`slash'")
	local i = 1
	while "``i''" != "" {
		local i = `i' + 1
	}
	local i = `i' - 1
	if "``i''" != "`slash'" {
		local firstdir `firstdir'`slash'
	}
	foreach name in `list_of_names' {
		capture findfile "`name'", path(`"`firstdir'"')
		if _rc == 0 {
			local foundfile `r(fn)'
			local foundfile : subinstr local foundfile "/" "`slash'", all
			local foundfile : subinstr local foundfile "\" "`slash'", all
			di in ye "`foundfile'"
			global bugsexec `"`foundfile'"'
			global currentnum = $currentnum + 1
			if $currentnum == `targetnum' exit
		}
	}

	capture local dirlist : dir "`firstdir'" dir "*"	
	if _rc > 0 exit

	tokenize `"`dirlist'"', parse(`"" ""')

	local i = 1
	while "``i''" != "" {
		bugsfindexec `"`firstdir'\``i''"' , `targetnum' , `currentnum'
		local i = `i' + 1
	}

end

capture program drop wbstructure2
*! 1.0.0, Timothy Mak, 16 Nov 2010
program wbstructure2

	*** wrapper program for wbstructure by John Thompson ***

	syntax varlist [if] [in], GRoup(varlist) [Saving(string) noList *]
	version 8.2
	marksample touse , novarlist
	tempvar id originalorder
	tempfile tempfile
	local firstvar : word 1 of `varlist'
	tempname filetemp
	qui gen `originalorder' = _n

	if "`list'" == "nolist" {
		local commentout *
	}

	local no_group : word count `group'
	if `no_group' > 1 {
		di in gr "At the moment, the program only supports group defined by one variable." 
		exit
	}

	foreach var in `varlist' {

		preserve
		keep if `touse'
		bysort `group' (`originalorder'): gen `id' = _n 
		keep `id' `var' `group' 

		qui reshape wide `var' , i(`id') j(`group')
		if "`var'" != "`firstvar'" {
			file open `filetemp' using `"`tempfile'"', write text append
			file write `filetemp' ","
			file close `filetemp'
		}

		wbstructure `var'* , name(`var') nolist noprint saving(`"`tempfile'"', append) `options'

		restore
	}

	type "`tempfile'"
	if "`saving'" != "" {
		gettoken saving replace : saving, parse(",")
		local replace : subinstr local replace "," ""

		file open writefile using "`saving'",  write text `replace'
		file open readfile using "`tempfile'",  read text

		`commentout' file write writefile "list(" _n
		file read readfile line

		while r(eof) == 0 {
	
			file write writefile "`line'" _n
			file read readfile line
		}
		`commentout' file write writefile ")"
		file close writefile
		file close readfile
	}

end

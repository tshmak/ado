capture program drop bugsreadlog
*! 1.0.0, Timothy Mak, 18 Nov 2010
program bugsreadlog, rclass

	**** Program to read Summary output from a BUGS log file****

	version 8.2

	syntax [, Logfile(string) clear]
	
	if "`clear'" == "" preserve

	local slash = cond("`c(os)'"=="Windows", "\", "/")

	tempname log

	if "`logfile'" == "" {

		local tempdir `c(tmpdir)'
		local tempdir : subinstr local tempdir "/" "`slash'" , all
		local tempdir : subinstr local tempdir "\" "`slash'" , all
		capture file open `log' using `"`tempdir'bugslog.txt"' , read text

		if _rc > 0 {
			di in red "No log file found"
			exit
		}

	}
	else {
		capture file open `log' using `"`logfile'"' , read text

		if _rc > 0 {
			di in red "log file not found"
			exit
		}

	}

	file read `log' line
	while r(eof) == 0 {

		local word1 : word 1 of `line'
		local word2 : word 2 of `line'
		if "`word1'" == "Node" & "`word2'" == "statistics" continue, break
		file read `log' line

	}

	tempname writefile
	tempfile write

	file open `writefile' using "`write'", write text 
	file read `log' line
	while r(eof) == 0 {
		file write `writefile' `"`line'"' _n
		file read `log' line
	}
	file close `log'
	file close `writefile'

	clear
	insheet using "`write'", tab
	drop v1
	ren v2 variable
	if "`clear'" == "" {
		list, sep(0)
	}
	mkmat mean-sample, matrix(results) rownames(variable)
	
	return matrix results = results

end

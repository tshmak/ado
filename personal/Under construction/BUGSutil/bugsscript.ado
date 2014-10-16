capture program drop bugsscript
*! 1.0.0, Timothy Mak, 16 Nov 2010
program bugsscript, rclass

	**** Program to write a script file for BUGS ****
	**** Many options not yet included ****

	version 8.2

	syntax , Model(string) DAta(string) Monitor(string) [ File(string) NChains(integer 1) NThin(integer 1) Initial(string) ///
		BUrnin(integer 1000) SAMPle(integer 1000) Totalsample(integer 2000) CODA(string) LOG(string) ///
		SEED(numlist max=1 missingok) PREcision(integer 7) REPLACE APPEND WINbugs noClose] 
		
	// Initial values for different chains must be given in different files. Separate them using ',' 

	local slash = cond("`c(os)'"=="Windows", "\", "/")

	local test : subinstr local model "/" "", count(local test2)
	local test : subinstr local model "\" "", count(local test3)
	if `test2' + `test3' == 0 {
		local model `c(pwd)'\\`model'
	}
	local model : subinstr local model "\" "/", all
	local model : subinstr local model "//" "/", all

	// Parse data files
	local data1 `"`data'"'
	local i = 1
	local j = 2
	while `"`data`i''"' != "" {
		gettoken data`i' data`j' : data`i' , parse(",")
		local test : subinstr local data`i' "`slash'" "", count(local test2)
		if `test2' == 0 {
			local data`i' `c(pwd)'\\`data`i''
		}
		local data`i' : subinstr local data`i' "\" "/", all
		local data`j' : subinstr local data`j' "," ""
		local i = `i' + 1
		local j = `j' + 1
	}

	// Parse initial values files
	local initial1 `"`initial'"'
	local i = 1
	local j = 2
	while `"`initial`i''"' != "" {
		gettoken initial`i' initial`j' : initial`i' , parse(",")
		local test : subinstr local initial`i' "`slash'" "", count(local test2)
		if `test2' == 0 {
			local initial`i' `c(pwd)'\\`initial`i''
		}
		local initial`i' : subinstr local initial`i' "\" "/", all
		local initial`j' : subinstr local initial`j' "," ""
		local i = `i' + 1
		local j = `j' + 1
	}


	if "`file'" == "" {
		tempfile scriptfile
		
	}
	else local scriptfile `file'
	tempname handler

	if "`winbugs'" == "" {
		local test : subinstr global bugsexec "winbugs14.exe" "", count(local test2)
		if `test2' > 0 local winbugs winbugs
		if "`test'" != "$bugsexec" {
			di in gr "\$bugsexec not set: script created using OpenBUGS commands."
		}
	}

	if `"`initial'"' != "" {
		tokenize `"`initial'"', parse(",") 
		local i = 1 
		local j = 1
		while `"``i''"' != "" {
			local initfile`j' `"``i''"'
			local i = `i' + 2
			local j = `j' + 1
		}
		local ninitfiles = `j' - 1
	}

	if "`winbugs'" == "winbugs" {
		di in red "WinBUGS 1.4 settings not yet implemented!!!"
		exit
	}

	file open `handler' using "`scriptfile'" , write text `replace' `append'

	file write `handler' `"modelCheck("`model'")"' _n
	local i = 1
	while `"`data`i''"' != "" {
		file write `handler' `"modelData("`data`i''")"' _n
		local i = `i' + 1
	}
	file write `handler' "modelCompile(`nchains')" _n
	local i = 1
	while `"`initial`i''"' != "" {
		file write `handler' `"modelInits("`initial`i''", `i')"' _n
		local i = `i' + 1
	}
	file write `handler' "modelGenInits()" _n
	file write `handler' "modelUpdate(`burnin', `nthin')" _n
	if "`seed'" != ""	{
		file write `handler' "modelSetRN(`seed')" _n
	}
	file write `handler' "modelPrecision(`precision')" _n
	local monitor : subinstr local monitor "," "" , all
	foreach word in `monitor' {
		file write `handler' `"samplesSet("`word'")"' _n
	}
	if `totalsample' != 2000 {
		local sample = `totalsample' - `burnin'
	}
	file write `handler' "modelUpdate(`sample', `nthin')" _n
	local tempdir `c(tmpdir)'
	local tempdir : subinstr local tempdir "\" "/" , all

	file write `handler' `"samplesStats("*")"' _n
	file write `handler' `"modelSaveLog("`tempdir'bugslog.txt")"' _n

	if "`log'" != "" {
		local test : subinstr local log "`slash'" "", count(local test2)
		if `test2' == 0 {
			local log `c(pwd)'\\`log'
		}
		local log : subinstr local log "\" "/", all
		file write `handler' `"modelSaveLog("`log'")"' _n
	}


	if "`coda'" != "" {
		local test : subinstr local coda "`slash'" "", count(local test2)
		if `test2' == 0 {
			local coda `c(pwd)'\\`coda'
		}
		local codadir : subinstr local coda "\" "/", all
		file write `handler' `"samplesCoda("*", "`codadir'")"' _n
	}
		

	if "`close'" != "noclose" {
		file write `handler' "modelQuit('yes')" _n
	}


	file close `handler'

	type "`scriptfile'"
	if "`file'" != "" {
		di in gr "File written to " _cont
		di in ye "`scriptfile'" _n
		return local scriptfile "`scriptfile'"
	}


end


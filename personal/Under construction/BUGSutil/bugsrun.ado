capture program drop bugsrun
*! 1.0.0, Timothy Mak, 17 Nov 2010, modifying -wbrun- by John Thompson, 6 May 2006
program bugsrun
    syntax , Script(string) [Winbugs(string) Batch full]
    version 8.2
    
	if "`full'" == "full" local star *

	if "`winbugs'" == "" {
		if "$bugsexec" == "" {
			di in red "\$bugsexec has not yet been defined. Set by -global bugsexec- "
			exit
		} 
		else local winbugs $bugsexec
	}

	local slash = cond("`c(os)'"=="Windows", "\", "/")

	local test : subinstr local script "`slash'" "", count(local test2)
	if `test2' == 0 {
		local script `c(pwd)'\\`script'
	}

    local script = subinstr(`"`script'"',"\","/",.)
    
    if "`batch'" == "" {
		shell "`winbugs'" /PAR "`script'"
		local tempdir `c(tmpdir)'
		local tempdir : subinstr local tempdir "/" "`slash'" , all
		local tempdir : subinstr local tempdir "\" "`slash'" , all
		capture file open logfile using `"`tempdir'bugslog.txt"' , read text
		if _rc == 0 {
			file read logfile line
			local part = 1
			while r(eof)==0  {
				local word1 : word 1 of `line'
				local word2 : word 2 of `line'
				`star' if "`word1'" == "Node" & "`word2'" == "statistics" continue, break
				di in gr "`line'" 
				file read logfile line
			}
		}
		capture file close logfile
    }
    else {
        winexec "`winbugs'" /PAR "`script'"
    }



end

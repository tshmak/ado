*! version 1.0.0  27jul2004  <website distribution>
program ukgrtalk
	version 8.2

	syntax [, UPDATE]

	capture confirm file `"`c(sysdir_personal)'uk04grtalk/alaska.do"'
	if !_rc & "`update'" == "" {
		di as error "`c(sysdir_personal)'uk04grtalk already exists"
		di as text "{p 4 4 0}specify {cmd:update} option if you wish to update the existing version of the talk"
		exit 198
	}

	if ("`update'" != "") local replace replace

				// read file names from users/vwiggins
				// copying contents to temporary staging
				// files.

	di "Copying talk materials from www.stata.com"
	local end 0
	tempname fh
	file open `fh' using						///
		  http://www.stata.com/users/vwiggins/ukgrtalk/filelist ///
		  , read text
	file read `fh' filenm
	while r(eof) == 0 & !`end' {
	    if (`"`filenm'"' == `"<end>"') {
		local end 1
		continue, break
	    }
	    tempfile tf
	    di in yellow `"	copying `filenm'"'
	    copy http://www.stata.com/users/vwiggins/ukgrtalk/`filenm' `"`tf'"'
	    local filenms `filenms' `filenm'
	    local tfiles `"`tfiles' `"`tf'"'"'
    
	    file read `fh' filenm
	}
	file close `fh'

	if !`end' {
		di as error "{p 0 4 4}problem copying full set of files from www.stata.com, no changes made"
		exit 612
	}

				// all files sucessfully copied, copy from
				// temps to final destination.
	di ""
	di "Moving talk materials to  PERSONAL:/uk04grtalk"

	capture confirm file `"`c(sysdir_personal)'uk04grtalk/alaska.do"'
	if _rc {
		mkdir `"`c(sysdir_personal)'uk04grtalk"'
	}

	foreach file of local tfiles {
	    gettoken name filenms : filenms

	    copy `"`file'"' `"`c(sysdir_personal)'uk04grtalk/`name'"' ,  ///
			`replace'
	}

	di ""
	di "Type {stata whelp ukgrtalk} to access talk materials"
end

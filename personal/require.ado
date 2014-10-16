* Program to immitate the "require" or "library" behaviour of R
program define require 

	/* You must have various different libraries organized as 
	folders within your `c(sysdir_personal)' folder */
	version 8
	syntax anything(name=library id="Library name" equalok everything) ///
		[, remove last ///
		Subdir list]	// Not yet implemented
						// `subdir' should load/unload all subdirectories also
						// `list' should list the do-files and ado-files in the directory
	
	if "`remove'" == "remove" local sign - 
	else if "`last'" == "last" local sign +
	else local sign ++ 
	local saved_dir `c(pwd)'
	local library `library'			// To remove quotes
	capture cd `"`c(sysdir_personal)'`library'"'
	if _rc == 0 qui cd `"`saved_dir'"'
	else {
		di as err `"Cannot find `c(sysdir_personal)'`library'"'
		// di as err `"Make sure your library is a folder in \`c(sysdir_personal)' = "`c(sysdir_personal)'""'
		exit 170
	}
	qui adopath `sign' `"`c(sysdir_personal)'`library'"'
	if "`remove'" == "remove" {
		program drop _all
		di as txt "{res:`library'} unloaded"
	}
	else {
		program drop _all
		di as txt "{res:`library'} successfully loaded"
	}
	
end

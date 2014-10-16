* Program to load do-files within the search path
program define load_do

	version 8
	local 0 `0'			// Remove quotes
	if substr(`"`0'"',-3,3) == ".do" findfile `"`0'"'
	else findfile `"`0'.do"' 
	run `"`r(fn)'"'
	
end

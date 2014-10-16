*! 1.0.0, Timothy Mak, 19 Nov 2010
program viewfile

	version 8.2
	findfile `"`0'"'
	local file `r(fn)'

	local slash = cond("`c(os)'"=="Windows", "\", "/")

	local file : subinstr local file "/" "`slash'" , all
	local file : subinstr local file "\" "`slash'" , all

	view "`file'"

end

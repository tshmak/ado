*! 1.0.5, Tom Palmer, 10jul2006
program wbdic, rclass
version 8.2
syntax  using/ [, NOPrint]
local tab = char(9)
tempname fh

* Count the number of DIC statistics in the WinBUGS log-file
file open `fh' using `"`using'"', read text
file read `fh' line
local diccount = 0
while r(eof) == 0 {
	file read `fh' line
	if "`line'" == "DIC" {
		local diccount = `diccount' + 1
	}
}
file close `fh'

* No DIC statistics in the log-file error message
if `diccount' == 0 {
	di as error `"Log-file does not contain any DIC statistics as identified by a "DIC" line"'
	exit
}

* Count the number of lines of DIC statistics for each occurrence in the log-file
file open `fh' using `"`using'"', read text
file read `fh' line
local dic = 0
while r(eof) == 0 {
	file read `fh' line
	if "`line'" == "DIC" {
		local dic = `dic' + 1
		local count`dic' = 1
		while r(eof) == 0 {
			file read `fh' line
			tokenize `line', p("`tab'")
			local count`dic' = `count`dic'' + 1
			if "`1'" == "total" {
				local counted`dic' = `count`dic''
				local varlines`dic' = `counted`dic'' - (`counted`dic'' - 4)
				continue, break
			}
		}
	}
}
file close `fh'

* Save the DIC statistics as returned scalars for each occurrence in the log-file
file open `fh' using `"`using'"', read text
file read `fh' line
local dic = 0
while r(eof) == 0 {	
	file read `fh' line
	if "`line'" == "DIC" {
		local dic = `dic' + 1
		if "`noprint'" == "" {
			di as text "DIC statistics `dic'"
		}
		forvalues i = 1/`counted`dic'' {	
			if "`noprint'" == "" {
				di as res "`line'"
			}
			if `i' >= `varlines`dic'' {
				tokenize `line', p("`tab'")
				ret sca Dbar`dic'_`1' = `3'
				ret sca Dhat`dic'_`1' = `5'
				ret sca pD`dic'_`1' = `7'
				ret sca DIC`dic'_`1' = `9'
				if "`1'" == "total" & "`noprint'" == "" & `dic' != `diccount' {
					di 
				}
			}
			file read `fh' line
		}
	}
}
file close `fh'
end

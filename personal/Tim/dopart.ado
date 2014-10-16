*! Program to do a part of a do-file 
*! Version 0.1.0
*! Won't work if your do-file has \`
capture program drop dopart 
program define dopart

	syntax anything , [start(numlist max=1 integer) end(numlist max=1 integer) *]
	
	tempname dofile tempdo
	gettoken filename therest : anything
	file open `dofile' using `"`filename'"', read
	tempfile temp
	file open `tempdo' using `temp', write text 
	if "`start'" == "" local start = 1
	local linenum = `start' - 1
	forval i=1/`linenum' {
		file read `dofile' whatever
	}
	if "`end'" == "" local end .

	file read `dofile' whatever
	while r(eof)==0 {
		local linenum = `linenum' + 1
		if `linenum' <= `end' {
			local whatever2 : subinstr local whatever "`" "\`", all
// 			di `"`whatever2'"'
			file write `tempdo' `"`whatever2'"' _n
		}
		else {
			continue, break
		}
		file read `dofile' whatever
	}
	file close `dofile'
	file close `tempdo'
	do `temp' `therest',  `options'
	
end

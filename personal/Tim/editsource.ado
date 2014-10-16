*!Version 1.0
program define editsource
	qui findfile `0'
	doedit `"`r(fn)'"'
end
	
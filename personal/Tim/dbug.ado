*! Program to debug a do-file or a command
capture program drop dbug
program define dbug

	// Syntax is: 
	// dbug [#] {command}
	// where # is the tracedepth
	
	gettoken number other : 0
	capture confirm number `number'
	if _rc == 0 {
		set tracedepth `number'
		local todo `other'
	}
	else local todo `0'

	set trace on
	capture noisily break {
		`todo'
	}
	set trace off
	
end

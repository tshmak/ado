* Based on restoreestV1.do
capture program drop restoreest 
program define restoreest 

	syntax using/ 
	
	local i=1
	local finish = 0
	while `finish' == 0 {
		capture est use "`using'", number(`i')
		if _rc == 111 {
			local finish = 1
			continue
		}
		else {
			est store `e(name)'
			local i = `i' + 1
		}
	}

end

		

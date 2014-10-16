program myticks 
*! NJC 1.0.0 5 May 2003 
	version 8 
	syntax anything(name=values) , MYscale(str) Local(str) 

	numlist "`values'" 
	local values "`r(numlist)'" 

	if !index("`myscale'","@") { 
		di as err "myscale() does not contain @"
		exit 198 
	} 	
	
	foreach v of local values { 
		local val : subinstr local myscale "@" "(`v')", all 
		local val : di %8.0g `val' 
		local myticks "`myticks' `val'" 
	} 

	di as res "{p}`myticks'" 
	c_local `local' "`myticks'" 
end 	
		

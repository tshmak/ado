*! NJC 1.1.0 2 July 2008 
*! NJC 1.0.0 5 May 2003 
program mylabels 
	version 8 
	syntax anything(name=values) , MYscale(str) Local(str) ///
	[Format(str) PREfix(str) SUFfix(str)]  

	numlist "`values'" 
	local values "`r(numlist)'" 

	if !index("`myscale'","@") { 
		di as err "myscale() does not contain @"
		exit 198 
	} 	

	if "`format'" != "" { 
		capture di `format' 1.2345 
	} 	
	
	foreach v of local values { 
		local val : subinstr local myscale "@" "(`v')", all 
		local val : di %8.0g `val' 
		if "`format'" != "" local v : di `format' `v' 
		local mylabels `"`mylabels' `val' "`prefix'`v'`suffix'""' 
	} 

	di as res `"{p}`mylabels'"' 
	c_local `local' `"`mylabels'"' 
end 	
		

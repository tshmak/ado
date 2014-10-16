*! version 2.0.0 Timothy Mak 27Jun2007.
program define lgraph, sortpreserve
version 9.2

// Parse
syntax varlist(num min=2 max=3) [if] [in] [aweight iweight fweight] [, ERRortype(string) noLegend SEParate(real 0) /// 
	LOPtions(string) EOPtions(string) median Quantile(numlist min=2 max=2) minmax bw fit(string) FOPtions(string) noMarker *]
gettoken depvar xvar : varlist 
gettoken xvar1 xvar2 : xvar

// Selecting subsample
marksample touse

// Parse options and store them in loption`level' & eoption`level' OR loption & eoption

tempvar dummy mean sd count minval maxval lquant uquant

if "`xvar2'" == "" { 
	qui gen `dummy' = 1 if `touse' 
	local xvar2 `dummy' 
}

foreach le in l e f { 
	tokenize `"``le'options'"', parse(";")
	qui levelsof `xvar2' if `touse'
	local xvar2levels `r(levels)' 
	foreach level in `xvar2levels' { 
		local i = 1
		while "``i''" != "" { 
			gettoken levelo op : `i'
			if "`level'" == "`levelo'" { 
				local `le'option`level' ``le'option`level'' `op'
			}
			else if "`levelo'" != ";" & real("`levelo'") == . { 
				local `le'option`level' ``le'option`level'' ``i''
			}
			local i = `i' + 1
		}
	}	
}

// Parse Other options

local average = cond("`median'" == "median", "median", "mean")
local colorpat = cond("`bw'" == "bw", "lcolor(black) lpattern", "lcolor")
local colormark = cond("`bw'" == "bw", "mcolor(black) msym", "mcolor")
local nomarker = cond("`marker'" == "", "", "msymbol(none)")

if "`quantile'" != "" { 
	tokenize `quantile' 
	local quantile (p`1') `lquant' = `depvar' (p`2') `uquant' = `depvar' 
}

// Preserve original data
preserve
local ylabel : variable label `depvar'

// Collapsing data

qui collapse (`average') `mean'=`depvar' (sd) `sd'=`depvar' (count) `count'=`depvar' /// 
	(min) `minval' = `depvar' (max) `maxval' = `depvar' `quantile' if `touse' [`weight' `exp'], by(`xvar1' `xvar2')

// Setting colors
local colororder navy maroon orange midgreen magenta black brown cyan lime ebblue ltblue pink olive /// 
	yellow dimgray dkorange gold red
local patternorder solid dash dot dash_dot shortdash shortdash_dot longdash longdash_dot
local markerorder o oh smplus x dh th sh O 
local colornumber : word count `colororder' 
local patternnumber : word count `patternorder' 
local markernumber : word count `markerorder' 

// Determining the look of the lines

qui tab `xvar2'
local max = r(r)

local i = 1
foreach level in `xvar2levels' { 
	local numbertouse = cond("`bw'" == "bw", `patternnumber' - 1, `colornumber' - 1)
	local ii = mod(`i'- 1,`numbertouse' ) + 1
	local precolor1 : word `ii' of `colororder' 
	local precolor2 : word `ii' of `patternorder' 
	local premcolor1 : word `ii'  of `colororder' 
	local premcolor2 : word `ii' of `markerorder'
	local precolor = cond("`bw'" == "bw", "`precolor2'", "`precolor1'")
	local color = cond("`fit'" != "", cond("`bw'"=="bw","blank","none"), "`precolor'")
	local mcolor = cond("`bw'" == "bw", "`premcolor2'", "`premcolor1'")

	local argument `argument' (connect `mean' `xvar1' if `xvar2' == `level', `colormark'(`mcolor') `colorpat'(`color') `nomarker' `loption`level'') 
	// generate labels for legend
	local x2label`i' : label (`xvar2') `level'
	local i = `i' + 1 
}


// Determine look of errorbars

local argument2 
tempvar lbound ubound

if `"`errortype'"' == "sd" {
	qui gen `lbound' = `mean' - `sd'
	qui gen `ubound' = `mean' + `sd'

}
if `"`errortype'"' == "se" { 
	qui gen `lbound' = `mean' - `sd'/sqrt(`count')
	qui gen `ubound' = `mean' + `sd'/sqrt(`count')
}
cap display `errortype' > 0
if _rc == 0 {
	if `errortype' > 50 & `errortype' <100 {
		qui gen `lbound' = `mean' - invttail(`count' - 1,((100-`errortype')/2)/100)*`sd'/sqrt(`count')
		qui gen `ubound' = `mean' + invttail(`count' - 1,((100-`errortype')/2)/100)*`sd'/sqrt(`count')
	}
}
if "`quantile'" != "" { 
	capture drop `lbound' `ubound' 
	qui gen `lbound' = `lquant'
	qui gen `ubound' = `uquant' 
}

if "`minmax'" == "minmax" { 
	capture drop `lbound' `ubound' 
	qui gen `lbound' = `minval'
	qui gen `ubound' = `maxval' 
}

if "`errortype'" != "" | "`minmax'" == "minmax" | "`quantile'" != "" {
	 
	local i = 1
	foreach level in `xvar2levels' {
		local numbertouse = cond("`bw'" == "bw", `patternnumber' - 1, `colornumber' - 1)
		local ii = mod(`i'- 1,`numbertouse' ) + 1
		local precolor1 : word `ii' of `colororder' 
		local precolor2 : word `ii' of `patternorder' 
		local color = cond("`bw'" == "bw", "`precolor2'", "`precolor1'")
		local argument2 `argument2' (rcap `ubound' `lbound' `xvar1' if `xvar2' == `level' , `colorpat'(`color') `eoption`level'')
		local i = `i' + 1
	}
}

// Separating error bars

tempvar rank

qui egen `rank' = group(`xvar2')
qui sum `xvar1', meanonly
qui replace `xvar1' = `xvar1' + (`rank' - (`max' + 1)/2) *  `separate' * (r(max) - r(min))

// Determine line of best fit 

if "`fit'" != "" {

	qui tab `xvar2'
	local max = r(r)

	// generate argument for twoway command + labels for legend
	local i = 1
	foreach level in `xvar2levels' { 
			
		local numbertouse = cond("`bw'" == "bw", `patternnumber' - 1, `colornumber' - 1)
		local ii = mod(`i'- 1,`numbertouse' ) + 1
		local precolor1 : word `ii' of `colororder' 
		local precolor2 : word `ii' of `patternorder' 
		local color = cond("`bw'" == "bw", "`precolor2'", "`precolor1'")

		local argument3 `argument3' (`fit' `mean' `xvar1' [aw=`count'] if `xvar2' == `level', `colorpat'(`color') `foption`level'') 
		local i = `i' + 1
	}
}


// Drawing the graph 
sort `xvar1'
local options_def = cond("`median'"== "", `"ytitle(`"Mean `ylabel'"')"', `"ytitle(`"Median `ylabel'"')"')

if `"`legend'"' == "nolegend" | `max' == 1 { 
	local options_def `options_def' legend(off)
}
else {
	// Create default legend
	local options_def `options_def' legend(on order(

	forvalues i = 1/`max' { 
		if "`fit'" != "" { 
			local j = `i' + `max'
			local options_def `options_def' `j' `"Fitted line for `x2label`i''"'
		}
		local options_def `options_def' `i' `"`x2label`i''"'
	}

		
	local options_def `options_def' ))
}

twoway `argument' `argument3'  `argument2' , `options_def' `options'


end

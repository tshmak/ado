*! 1.0.4 Tom Palmer 26oct2007; based on con_funnel by Jaime Peters
program confunnel
version 8.2
syntax varlist(min=2 max=2) [if] [in], [ASPECTratio(string) Contours(string) CONTCOLor(string) ///
			EXTRAplot(string) ///
			FUNCTIONLOWopts(string) FUNCTIONUPPopts(string) ///
			LEGENDLABels(string) LEGENDopts(string) ///
			Metric(string) ONEsided(string) ///
			SCATTERopts(string) SHADEDContours SOLIDContours TWOWAYopts(string)]

marksample touse

tokenize `varlist'
local est `1'
local se `2'

if "`metric'" != "se" & "`metric'" != "invse" & "`metric'" != "var" & "`metric'" != "invvar" & "`metric'" != "" { // metric error check
	di as error "metric() must be unspecified, se, invse, var or invvar"
	error 198
} 

if "`onesided'" != "" & "`onesided'" != "lower" & "`onesided'" != "upper" {
	di as error "onesided() must be unspecified, lower or upper"
	error 198
}

if "`contours'" == "" { // default significance contours
	local contours "1 5 10"
}
local ncontours = wordcount("`contours'")

if "`metric'" == "" { // y-axis
	local metric se
}

qui su `est', meanonly
local estmin = r(min)
local estmax = r(max)

if "`solidcontours'" == "solidcontours" { // use dashed or solid contours
	forvalues m = 1/`ncontours' {
		local linepatt `"`linepatt' solid"'
	}
}
else if "`solidcontours'" == "" {
	local linepatt "longdash dash shortdash dot shortdash_dot dash_dot longdash_dot" // line pattern styles for the contours
}
local n 0
foreach lp in `linepatt' {
	local lp`++n' `lp'
}

forvalues j = 1/`ncontours' { // shades for shaded contours
	if "`contcolor'" == "" {
		local shadedcontcol black
	}
	else {
		local shadedcontcol `contcolor'
	}
	if "`shadedcontours'" == "shadedcontours" { 
		local lc`j' "`shadedcontcol'*`=1 - `j'/(`ncontours'*1.25)'"
	}
	else if "`shadedcontours'" == "" & "`contcolor'" == "" {
		local lc`j' "gs8"
	}
	else if "`shadedcontours'" == "" & "`contcolor'" != "" {
		local lc`j' "`contcolor'"
	}
}

local xtitle "Effect estimate" // default x-axis title
if "`aspectratio'" == "" { // default aspectratio
	local aspectratio 1
}

local i 1 // used as a counter for labelling the contours in the legend
tempvar yvar
if "`metric'" == "invse" { // y-axis variable: inverse standard error
	qui gen `yvar' = 1/`se'
	qui su `yvar', meanonly
	local ymax = r(max)
	local ytitle "Inverse standard error"
	if "`onesided'" == "lower" {
		foreach c in `contours' {
			local i = `i' + 1
			local h = `i' - 1
			local Lz = invnorm(`c'/100)
			local function `"`function' function `Lz'/x, horizontal range(`yvar') lc(`lc`h'') lp(`lp`h'') lw(thin) `functionlowopts' || "'
			local Rz = invnorm(1 - `c'/100)
			local function `"`function' function `Rz'/x, horizontal range(`yvar') lc(none) || "'
			local contourlabels `"`contourlabels' `=2*`h' - 1' "`c'%""'
		}
	}
	else if "`onesided'" == "upper" {
		foreach c in `contours' {
			local i = `i' + 1
			local h = `i' - 1
			local Rz = invnorm(1 - `c'/100)
			local function `"`function' function `Rz'/x, horizontal range(`yvar') lc(`lc`h'') lp(`lp`h'') lw(thin) `functionuppopts' || "'
			local Lz = invnorm(`c'/100)
			local function `"`function' function `Lz'/x, horizontal range(`yvar') lc(none) || "'
			local contourlabels `"`contourlabels' `=2*`h' - 1' "`c'%""'
		}
	}
	else {
		foreach c in `contours' {
			local i = `i' + 1
			local h = `i' - 1
			local Lz = invnorm(`c'/(100*2))
			local Rz = invnorm(1 - `c'/(100*2))
			local function `"`function' function `Lz'/x, horizontal range(`yvar') lc(`lc`h'') lp(`lp`h'') lw(thin) `functionlowopts' || "'
			local function `"`function' function `Rz'/x, horizontal range(`yvar') lc(`lc`h'') lp(`lp`h'') lw(thin) `functionuppopts' || "'
			local contourlabels `"`contourlabels' `=2*`h'' "`c'%""'
		}
	}
}
else if "`metric'" == "se" { // y-axis variable: standard error
	qui gen `yvar' = `se'
	local reverse "reverse"
	local ytitle "Standard error"
	qui su `yvar', meanonly
	local ymax = r(max)
	if "`onesided'" == "lower" {
		foreach c in `contours' {
			local i = `i' + 1
			local h = `i' - 1
			local Lz = invnorm(`c'/100)
			local function `"`function' function x*`Lz', horizontal range(0 `=abs(`ymax')') lc(`lc`h'') lp(`lp`h'') lw(thin) `functionlowopts' || "'
			local Rz = invnorm(1 - `c'/100) // require invsible rhs contours to ensure symmetric plot
			local function `"`function' function x*`Rz', horizontal range(0 `=abs(`ymax')') lc(none) || "'
			local contourlabels `"`contourlabels' `=2*`h' - 1' "`c'%""'
		}
	}
	else if "`onesided'" == "upper" {
		foreach c in `contours' {
			local i = `i' + 1
			local h = `i' - 1
			local Rz = invnorm(1 - `c'/100)
			local function `"`function' function x*`Rz', horizontal range(0 `=abs(`ymax')') lc(`lc`h'') lp(`lp`h'') lw(thin) `functionuppopts' || "'
			local Lz = invnorm(`c'/100)
			local function `"`function' function x*`Lz', horizontal range(0 `=abs(`ymax')') lc(none) || "'
			local contourlabels `"`contourlabels' `=2*`h' - 1' "`c'%""'
		}
	}
	else {
		foreach c in `contours' {
			local i = `i' + 1
			local h = `i' - 1
			local Lz = invnorm(`c'/(100*2))
			local Rz = invnorm(1 - `c'/(100*2))
			local function `"`function' function x*`Rz', horizontal range(0 `=abs(`ymax')') lc(`lc`h'') lp(`lp`h'') lw(thin) `functionlowopts' || "'
			local function `"`function' function x*`Lz', horizontal range(0 `=abs(`ymax')') lc(`lc`h'') lp(`lp`h'') lw(thin) `functionuppopts' || "'
			local contourlabels `"`contourlabels' `=2*`h'' "`c'%""'
		}
	}
}
else if "`metric'" == "var" { // variance on y-axis
	qui gen `yvar' = `se'^2
	local reverse "reverse"
	local ytitle "Variance"
	qui su `yvar', meanonly
	local ymax = r(max)
	if "`onesided'" == "lower" {
		foreach c in `contours' {
			local i = `i' + 1
			local h = `i' - 1
			local Lz = invnorm(`c'/100)
			local function `"`function' function (sqrt(x)*`Lz'), horizontal range(0 `=abs(`ymax')') lc(`lc`h'') lp(`lp`h'') lw(thin) `functionlowopts' || "'
			local Rz = invnorm(1 - `c'/100)
			local function `"`function' function (sqrt(x)*`Rz'), horizontal range(0 `=abs(`ymax')') lc(none) || "'
			local contourlabels `"`contourlabels' `=2*`h' - 1' "`c'%""'
		}
	}
	else if "`onesided'" == "upper" {
		foreach c in `contours' {
			local i = `i' + 1
			local h = `i' - 1
			local Rz = invnorm(1 - `c'/100)
			local function `"`function' function (sqrt(x)*`Rz'), horizontal range(0 `=abs(`ymax')') lc(`lc`h'') lp(`lp`h'') lw(thin) `functionuppopts' || "'
			local Lz = invnorm(`c'/100)
			local function `"`function' function (sqrt(x)*`Lz'), horizontal range(0 `=abs(`ymax')') lc(none) || "'
			local contourlabels `"`contourlabels' `=2*`h' - 1' "`c'%""'
		}
	}
	else {
		foreach c in `contours' {
			local i = `i' + 1
			local h = `i' - 1
			local Lz = invnorm(`c'/(100*2))
			local Rz = invnorm(1 - `c'/(100*2))
			local function `"`function' function (sqrt(x)*`Rz'), horizontal range(0 `=abs(`ymax')') lc(`lc`h'') lp(`lp`h'') lw(thin) `functionlowopts' || "'
			local function `"`function' function (sqrt(x)*`Lz'), horizontal range(0 `=abs(`ymax')') lc(`lc`h'') lp(`lp`h'') lw(thin) `functionuppopts' || "'
			local contourlabels `"`contourlabels' `=2*`h'' "`c'%""'
		}
	}

}
else { // inverse variance on y-axis
	qui gen `yvar' = (1/`se')^2
	qui su `yvar', meanonly
	local ymax = r(max)
	local ytitle "Inverse variance"
	if "`onesided'" == "lower" {
		foreach c in `contours' {
			local i = `i' + 1
			local h = `i' - 1
			local Lz = invnorm(`c'/100)
			local function `"`function' function (`Lz'^2/x^2), horizontal range(`yvar') lc(`lc`h'') lp(`lp`h'') lw(thin) `functionlowopts' || "'
			local Rz = invnorm(1 - `c'/100)
			local function `"`function' function (`Rz'^2/x^2), horizontal range(`yvar') lc(none) || "'
			local contourlabels `"`contourlabels' `=2*`h' - 1' "`c'%""'
		}
	}
	else if "`onesided'" == "upper" {
		foreach c in `contours' {
			local i = `i' + 1
			local h = `i' - 1
			local Rz = invnorm(1 - `c'/100)
			local function `"`function' function (`Rz'^2/x^2), horizontal range(`yvar') lc(`lc`h'') lp(`lp`h'') lw(thin) `functionuppopts' || "'
			local Lz = invnorm(`c'/100)
			local function `"`function' function (`Lz'^2/x^2), horizontal range(`yvar') lc(none) || "'
			local contourlabels `"`contourlabels' `=2*`h' - 1' "`c'%""'
		}
	}
	else {
		foreach c in `contours' {
			local i = `i' + 1
			local h = `i' - 1
			local Lz = invnorm(`c'/(100*2))
			local Rz = invnorm(1 - `c'/(100*2))
			local function `"`function' function (`Lz'^2/x^2), horizontal range(`yvar') lc(`lc`h'') lp(`lp`h'') lw(thin) `functionlowopts' || "'
			local function `"`function' function (`Rz'^2/x^2), horizontal range(`yvar') lc(`lc`h'') lp(`lp`h'') lw(thin) `functionuppopts' || "'
			local contourlabels `"`contourlabels' `=2*`h'' "`c'%""'
		}
	}
}

if "`legendopts'" != "off" {
	if "`legendopts'" == "" { // default legend options
		local legendopts "ring(0) pos(2) size(small) symxsize(*.4) cols(1)"
	}
	local legendopts `"order(`=2*`ncontours' + 1' "Studies" `contourlabels' `legendlabels') `legendopts'"'	
}

/* contour enhanced funnel plot */
twoway ///
	`function' ///
	scatter `yvar' `est' if `touse', mc(black) `scatteropts' || ///
	`extraplot' ///
	, aspectratio(`aspectratio') yscale(`reverse') ylabel(, angle(horizontal)) ///
	xtitle(`xtitle') ytitle(`ytitle') ///
	`twowayopts' ///
	legend(`legendopts')  
end

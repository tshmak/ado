*! version 1.0 April 1998  STB-45 sbe24.1
program define funnel
	version 5.0
	if ( substr("`1'",1,1)!="," & "`*'"!="") { local varlist "opt ex min(2) max(2)" }
	local if "opt"
	local in "opt"
	#delimit ;
	local options "SAmple noINVert YSQrt YLAbel(string) OVerall(string) YLOg XLOg 
 SAving(string) *";
	#delimit cr
	parse "`*'"
	qui {
		parse "`options'", parse(" ")
		parse "`varlist'", parse(" ")	
		tempvar stat Y
		if "`varlist'"=="" {
*No variables specified: use _ES & _seES and/or _SS, saved previously from metan
			if "`sample'"=="" { 
*Plot se or 1/se vs effect size 
				if "`invert'"=="" { local oneover "1/" }
				local 1 "_seES" 
				local varlab1 "`oneover'SE(Effect size)"
			}
*Plot sample size vs effect size
			 else  { 
				local 1 "_SS" 
				local varlab1 "Sample size"
			}
			local 2 "_ES"
			local varlab2 : var label _ES
			if "`varlab2'"=="" { local varlab2 "Effect size" }
		}
		confirm var `1' `2'
		if "`varlist'"!="" { 
* variables are specified
			if "`sample'"=="" & "`invert'"=="" { local oneover "1/" }
			local varlab1 : var label `1'
			if "`varlab1'"=="" { local varlab1 `1'}
			local varlab1 "`oneover'`varlab1'"
			local varlab2 : var label `2'
			if "`varlab2'"=="" { local varlab2 `2' }
		}
		gen `Y' =`oneover'`1' `if' `in' 
		gen `stat' =`2' `if' `in'
		label var `Y' "`varlab1'"
		label var `stat' "`varlab2'"
		if "`ylabel'"=="" {
		   sum `Y',meanonly
		   local r5= _result(5)
		   local r6= _result(6)
		   local ylabel "`r5',`r6'"
		}
		if "`ysqrt'"!="" {
		   tempvar temp
		   gen `temp'=`Y'
		   drop `Y'
		   tempvar Y
		   axiscale `Y'=`temp' `if' `in', label(`ylabel') function(sqrt[@]) 
*fname(sqrt) builtin 
		   local ylabel $S_13
		   label var `Y' "`varlab1', square root scale"
		}
	}  /* end of qui section*/
	graph `Y' `stat' , ylabel(`ylabel') `xlog' `ylog' `options'
	if "`saving'"!="" { local saving "saving(`saving')" }
	gph open, `saving'
	graph
	gph font 300 200
	local Gymin=_result(1)
	local Gymax=_result(2)
	local r5 =_result(5)
	local r6 =_result(6)
	local r7 =_result(7)
	local r8 =_result(8)
	local flag1=0
	if "`overall'"!="" {
* add dashed line
		sum `stat'
		local minstat=_result(5)
		local maxstat=_result(6)
		parse "`overall'", parse(" ")
		cap {
		   assert "`2'"==""
		   assert `1'>=`minstat'
		   assert `1'<=`maxstat'
		}
		if _rc!=0 {local flag1=1}
		 else {
		   gph pen 9
		   local Gxov=`1'
		   if "`xlog'"!="" {local xlog "log"}
		   if "`ylog'"!="" {local ylog "log"}
		   local Axco=`r7'*`xlog'(`Gxov')+`r8' 
		   local j   =`r5'*`ylog'(`Gymin')+`r6'
		   local Adashl=`r5'*(`ylog'(`Gymax')-`ylog'(`Gymin'))/100
		   local Ayhi=`r5'*`ylog'(`Gymax')+`r6' 
		   while `j'>`Ayhi' { 
		      local Aycol=`j'
		      local Aycoh=`j'+`Adashl'
		      gph line `Aycol' `Axco' `Aycoh' `Axco'
		      local j=`j'+2*`Adashl'
		   }
		}
	}
	gph close
	if `flag1'>0 { di in blue "Error in overall() option. Dashed line not displayed"}
end

*! version 1.2.1 PR 19Nov96.
/* Written by Patrick Royston as part of tgraph (STB34). Modified to have new axis
   label stored in redundant global macro S_13, instead of $S_1 as used by metan.ado
*/
program define axiscale
version 4.0
local varlist "req new max(1)"
local exp "req noprefix"
local if "opt"
local in "opt"
#delimit ;
local options "Labels(string) Function(string) MIN(string) MAX(string)
 Valuelab(string)" ;
#delimit cr
tempvar x labs newlabs new
parse "`*'"
if "`labels'"=="" | "`functio'"=="" {
	di in red "labels() and function() must be supplied"
	exit 198
}
if "`min'"!="" { conf num `min' }
else local min .
if "`max'"!="" { conf num `max' }
else local max .
if "`valuela'"=="" { local valuela _LAB }

* Find min and max of oldvar

quietly {
	gen `x'=`exp' `if' `in'
	sum `x'
	if `min'==. { local min=_result(5) }
	else if `min'>_result(5) {
		noi di in red "invalid min(), `min'> min(`exp')"
		exit 198
	}
	if `max'==. { local max=_result(6) }
	else if `max'<_result(6) {
		noi di in red "invalid max(), `max' < max(`exp')"
		exit 198
	}

* Convert labels to a var, including min and max

	gen `labs'=.
	parse "`labels',`min',`max'", parse(",")
	local nlab 0
	while "`1'"!="" {
		if "`1'"!="," {
			conf num `1'
			local nlab=`nlab'+1
			local lab`nlab' `1'	/* store label as string */
			replace `labs'=`1' in `nlab'
		}
		mac shift
	}

* Update min and max for consistency with labels

	sum `labs'
	if `min'>_result(5) {
		local nlab1=`nlab'-1
		local min=_result(5)
		replace `labs'=`min' in `nlab1'
	}
	if `max'<_result(6) {
		local max=_result(6)
		replace `labs'=`max' in `nlab'
	}

* Transform labels

	parse "`functio'", parse("@[]")
	local f
	while "`1'"!="" {
		if "`1'"=="@" { local 1 `labs' }
		else if "`1'"=="[" { local 1 "(" }
		else if "`1'"=="]" { local 1 ")" }
		local f "`f'`1'"
		mac shift
	}
	cap replace `labs'=`f'
	local rc=_rc
	if `rc' { noisily error `rc' }
	local tmin=`labs'[`nlab'-1]
	local tmax=`labs'[`nlab']
	if `tmin'>`tmax' {
		local temp `tmin'
		local tmin `tmax'
		local tmax `temp'
	}
	
* Transform oldvar

	parse "`functio'", parse("@[]")
	local f
	while "`1'"!="" {
		if "`1'"=="@" { local 1 `x' }
		else if "`1'"=="[" { local 1 "(" }
		else if "`1'"=="]" { local 1 ")" }
		local f "`f'`1'"
		mac shift
	}
	cap replace `x'=`f'
	local rc=_rc
	if `rc' { noisily error `rc' }

* Transform transformed oldvar to integer scale

	gen int `new'=.
	rescale `new' `x' `tmin' `tmax'	/* tmin->0, tmax->1000 */

* Do same to labels

	gen int `newlabs'=.
	rescale `newlabs' `labs' `tmin' `tmax'

* Convert newlabs to string

	local xxl	/* string of new labels */
	cap lab drop `valuela'
	local i 0
	while `i'<`nlab'-2 {
		local i=`i'+1
		local xx=`newlabs'[`i']
		if "`xxl'"=="" { local xxl `xx' }
		else local xxl "`xxl',`xx'"
		lab def `valuela' `xx' "`lab`i''",add
	}
	replace `varlist'=`new'
	lab values `varlist' `valuela'
	lab var `varlist' "`exp', transformed scale"
}

describe `varlist'
global S_13 `xxl'
global S_NJC `xxl'
end

program define rescale /* newintvar oldtsfvar tsfmin tsfmax */
replace `1'=int(1000*(`2'-`3')/(`4'-`3')+.5)
end

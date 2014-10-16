*! version 1.0.6   16 Sep 1997  STB-42 sbe21
* Tony Brady
* Logistic regression attributable fraction, estimates an adjusted measure
* of the population attributable fraction for each term in an unconditional
* logistic or poisson regression model from cross-sectional or case-control
* data. Uses matrix algebra to calculate vx and czx

program define aflogit
	version 5.0
	#delimit ;
	if "$S_E_cmd" != "logistic" & "$S_E_cmd" != "logit" & "$S_E_cmd" != "blogit"
	 & ("$S_E_cmd" != "glm" | "$S_E_fam" != "bin" | "$S_E_link" != "l") 
	 & ("$S_E_cmd" != "glm" | "$S_E_fam" != "poi") 
	 & "$S_E_cmd" != "poisson" {;
		disp in red "Can only be used after unconditional logistic or poisson regression";
		error 301;
	};

	#delimit cr
	tempvar off rx wx
	tempname Cstar names tx AFhat A AFse cilo cihi zval m0
	local varlist "opt ex none"
	local options "REFerence(string) Level(int -1) NOLOG CC"
	local weight "fweight aweight"
	local if "opt"
	local in "opt"
	parse "`*'"
	if ("$S_E_cmd" == "poisson" | "$S_E_fam" == "poi") & "`cc'" == "cc" {
		disp in red "Cannot use case-control option after poisson regression"
		error 499
	}
	local wvar = 1
	local type logistic
	if "$S_E_wgt" != "" {
		local wgt "[${S_E_wgt}${S_E_exp}]"
		local wvar = substr("${S_E_exp}",2,.)
	}
	if "$S_E_m" != "" & "$S_E_m" != "1" {
		local wgt "[fw=${S_E_m}]"		/* Pick up weights from glm command */
		local wvar $S_E_m
	}	
	if "$S_E_cmd" == "poisson" | "$S_E_fam" == "poi" {
		local type poisson
		gen `off' = 1
		local wvar `off'
	}
	if "$S_E_off" != "" {
		if "$S_E_cmd" == "glm" {
			qui replace `off' = round(exp($S_E_off),1)
			local offtype offset
		}
		else {
			qui replace `off' = round($S_E_off,1)
			local offtype exposure
		}
		local wgt "[fw=`off']"		/* Pick up weights from poisson command */
	}
	if "`weight'" != "" {
		local wgt "[`weight' `exp']"
		local wvar = substr("`exp'",2,.)
	}
	if "`if'" == "" {
		local if "$S_E_if"
	}
	if "`in'" == "" {
		local in "$S_E_in"
	}
	if `level' == -1 {
		local level : set level
	}
	matrix `Cstar' = get(VCE)
	local coln = colsof(`Cstar')-1		/* Omit _cons */
	matrix `names' = `Cstar'[1..`coln',1]
	local explvar : rownames(`names')

	* Default terms when none specified by user
	if "`varlist'" == "" {
		* Drop variables with OR < 1
		parse "`explvar'", parse(" ")
		while "`1'" != "" {
			if _b[`1'] < 0 {
				nois disp in bl "Dropping `1' (negative association)"
			}
			else {
				local varlist "`varlist' `1'"
			}
			mac shift
		}
	}
	else {
		parse "`varlist'", parse(" ")
		while "`1'" != "" {
			if "`1'" == "$S_E_depv" {
				disp in red "varlist may not contain the outcome variable"
				error 498
			}
			macro shift
		}
	}

	/* Put reference values into global macros with same name as relevant variable */

	parse "`explvar'", parse(" ")	/* First clear out any old globals */
	while "`1'" != "" {
		macro drop `1'
		macro shift
	}
	parse "`reference'", parse("= ")
	local i = 1
	while "`1'" != "" {
		local reft`i' = "`1'"
		if mod(`i',3)==1 {
			confirm variable `1'
			local lastvar `1'
		}
		else if mod(`i',3)==2 & "`1'" != "=" {
			disp in red "`1' found where = expected"
			error 7
		}
		else if mod(`i',3)==0 {
			confirm number `1'
			global `lastvar' = `1'
		}
		local i = `i' + 1
		macro shift
	}
	local maxref = `i'

	disp in gr _newline(1) "Population attributable fraction from `type' regression"
	quietly {
	if "$S_E_cmd" == "glm" {
		predict `rx' `if' `in', xb
		if "$S_E_fam" == "bin" {
			replace `rx' = exp(`rx') / (1 + exp(`rx'))
		}
		else {
			replace `rx' = exp(`rx')
		}
	}
	else {
		predict `rx' `if' `in'
		if "$S_E_cmd" == "poisson" {
			replace `rx' = exp(`rx')	/* Get predicted rates */
		}
	}
	summ `rx' `wgt', meanonly
	local nobs = _result(1)
	scalar `tx' = _result(18)			/* tx = m1 (no of cases) */
	scalar `m0' = _result(2) - _result(18)	/* m0 = no of controls */
	gen `wx' = `rx'*(1-`rx')
	if "`cc'" == "cc" {
		tempvar px s sx ps zmx sxn
		tempname Dt C DC DCD B
		nois disp in gr "Case-control data (n=`nobs')" _newline(1)
		replace `wx' = `wx' * `wvar'
		gen `px' = `rx'/`tx'
		gen `s' = 1			/* holds product of sx's */
		matrix `C' = `Cstar'
		local c = colsof(`C')
		local r = rowsof(`C')
		matrix `C'[`r',`c'] = `C'[`r',`c'] - 1/`tx' - 1/`m0'
	}
	else {
		tempvar rz wz
		tempname tz vx czx wZ Zw wZC wZCZw vz wX Xw wXC wXCXw wZCXw
		nois disp in gr "Cross-sectional / cohort data (n=`nobs')" _newline(1)
		matrix accum `A' = `wx' `explvar' `wgt' `if' `in'
		matrix `wX' = `A'[1,2...]
		matrix `Xw' = `A'[2...,1]
		matrix `wXC' = `wX' * `Cstar'
		matrix `wXCXw' = `wXC' * `Xw'
		scalar `vx' = `wXCXw'[1,1]
	}
	if "`wgt'" == "" {
		if "$S_E_cmd" == "logit" | "$S_E_cmd" == "blogit" {
			nois disp in bl "No weights assumed"
		}
	}
	else {
		if "`type'" == "poisson" & "`offtype'" !="" {
			nois disp in gr "Using `offtype' $S_E_off"
		}
		else {
			nois disp in gr "Using weights `wgt'"
		}
	}
	if "`nolog'" == "" {
		local star *
	}

	parse "`varlist' *", parse(" ")
	if "`1'" == "*" {
		exit
	}
	nois disp
	nois disp in gr "Term      Ref.     A.F." _col(32) "s.e." _col(42) "[`level'% Conf. Int.]`star'"
	nois disp in gr _dup(58) "-"

	while "`1'" != "" {

		/* Case-control study */

		if "`cc'" == "cc" {
			if "`1'" == "*" {		/* `1' = * on total line */
				gen `ps' = `px' * `s'
				summ `ps' `wgt', meanonly
				scalar `AFhat' = 1 - _result(18)
				preserve
				parse "`explvar'", parse(" ")
				while "`1'" != "" {
					if "$`1'" != "" {
						replace `1' = $`1' - `1'
					}
					else {
						replace `1' = 0
					}
					mac shift
				}
				gen `sxn' = `s' * `wvar'
				matrix accum `A' = `px' `explvar' [pw=`sxn'], nocons
				matrix `B' = (0)
				matrix `A' = `A'[2...,1] 
				matrix `A' = `A' \ `B'
				restore
				matrix accum `Dt' = `s' `explvar' [pw=`wx']
				matrix `Dt' = `Dt'[2...,1]
				local i = 1
				while `i' <= `r' {
					matrix `Dt'[`i',1] = `A'[`i',1] + `Dt'[`i',1]/`tx'	/* Note: tx=m1 */
					local i = `i' + 1
				}
				matrix `DC' = `Dt'' * `C'
				matrix `DCD' = `DC' * `Dt'
				scalar `AFse' = sqrt(`DCD'[1,1])
				local 1 = "TOTAL"
			}
			else {
				if "$`1'" == "" {
					global `1' = 0
				}
				gen `zmx' = $`1' - `1'
				gen `sx' = exp(`zmx' * _b[`1'])
				gen `ps' = `px' * `sx'
				replace `s' = `s' * `sx'
				summ `ps' `wgt', meanonly
				scalar `AFhat' = 1 - _result(18)
				gen `sxn' = `sx' * `wvar'
				matrix accum `A' = `zmx' `px' [pw=`sxn'], nocons
				matrix accum `Dt' = `sx' `explvar' [pw=`wx']
				matrix `Dt' = `Dt'[2...,1]
				local i = 1
				while `i' <= `r' {
					matrix `Dt'[`i',1] = `Dt'[`i',1]/`tx'	/* Note: tx=m1 */
					local i = `i' + 1
				}
				local i = rownumb(`Dt', "`1'")
				matrix `Dt'[`i',1] = `Dt'[`i',1] + `A'[2,1]
				matrix `DC' = `Dt'' * `C'
				matrix `DCD' = `DC' * `Dt'
				scalar `AFse' = sqrt(`DCD'[1,1])
				drop `sx' `sxn' `ps' `zmx'
			}
		}

		/* Cohort or cross-sectional study */

		else {
			preserve
			if "`1'" == "*" {		/* `1' = * on total line */
				parse "`varlist' *", parse(" ")
				while "`1'" != "*" {
					replace `1' = $`1' if `1' != .
					macro shift
				}
				local 1 = "TOTAL"
			}
			else {
				if "$`1'" == "" {
					global `1' = 0
				}
				replace `1' = $`1' if `1' != .	/* reset exposure to reference level */
			}
			if "$S_E_cmd" == "glm" {
				predict `rz' `if' `in', xb
				if "$S_E_fam" == "bin" {
					replace `rz' = exp(`rz') / (1 + exp(`rz'))
				}
				else {
					replace `rz' = exp(`rz')
				}
			}
			else {
				predict `rz' `if' `in'
				if "$S_E_cmd" == "poisson" {
					replace `rz' = exp(`rz')	/* Get predicted rates */
				}
			}
			summ `rz' `wgt', meanonly
			scalar `tz' = _result(18)
			scalar `AFhat' = 1-(`tz'/`tx')
			gen `wz' = `rz'*(1-`rz')
			matrix accum `A' = `wz' `explvar' `wgt' `if' `in'
			matrix `wZ' = `A'[1,2...]
			matrix `Zw' = `A'[2...,1]
			matrix `wZC' = `wZ' * `Cstar'
			matrix `wZCZw' = `wZC' * `Zw'
			scalar `vz' = `wZCZw'[1,1]
			matrix `wZCXw' = `wZC' * `Xw'
			scalar `czx' = `wZCXw'[1,1]
			scalar `AFse' = sqrt((`tz'/`tx')^2*(`vz'/`tz'^2 - 2*`czx'/(`tz'*`tx') + `vx'/`tx'^2))
		}
		scalar `zval' = invnorm((50+`level'/2)/100)
		if "`nolog'" == "nolog" {
			scalar `cilo' = `AFhat'-`zval'*`AFse'
			scalar `cihi' = `AFhat'+`zval'*`AFse'
		}
		else {
			scalar `cilo' = 1-(1-`AFhat')*exp(`zval'*`AFse'/(1-`AFhat'))
			scalar `cihi' = 1-(1-`AFhat')*exp(-`zval'*`AFse'/(1-`AFhat'))
		}
		if `AFhat' < 0 {
			scalar `AFse' = .
			scalar `cilo' = .
			scalar	`cihi' = .
		}
		if "`1'" == "TOTAL" {
			nois disp in gr _dup(58) "-"
		}
		#delimit ;
		nois disp in gr "`1'" in yel _col(12) "$`1'" 
				%9.4f _col(16) `AFhat' 
				%9.4f 	_col(28) `AFse'
				%9.4f _col(40) `cilo'
				%9.4f _col(49) `cihi';
		#delimit cr

*		nois disp in bl "Observed cases, O = " `tx'
*		nois disp in bl "Var(O) = " `vx'
*		nois disp in bl "Expected cases, E = " `tz'
*		nois disp in bl "Var(E) = " `vz'
*		nois disp in bl "Cov(O,E) = " `czx'

		if "`cc'" != "cc" {
			restore
		}
		macro shift
	}
	}
	global S_1 = `AFhat'
	global S_2 = `AFse'
	global S_3 = `cilo'
	global S_4 = `cihi'
	if "`nolog'" == "" {
		disp in gr _newline "* CI calculated on log(1-AF) scale"
	}
end

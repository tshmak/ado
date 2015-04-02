*! version 1.0.2  19jun2014
// see the end of the program for version history
program mibeta, eclass
	version 11
	syntax [anything(everything name=rhs)] [aw fw iw pw]	  ///
				[, 	FISHERZ		 	  ///
					NOCOEF 	  		  ///
					MIOPTS(string asis)	  ///
					*			  /// <regopts>
				]
	if ("`weight'"!="") {
		local rhs `rhs' [`weight'`exp']
	}
	if ("`fisherz'"=="") {
		local original original
	}
	if ("`nocoef'"!="") {
		local nocoef qui
	}
	// check if -saving()- is already specified
	_chk_saving, `miopts'
	local fname    `"`s(filename)'"'
	if (`"`fname'"')=="" {
		tempfile miestfile
		local saving saving(`miestfile')
	}
	else {
		local miestfile `"`fname'"'
	}
	//obtain MI estimates and save indiv. estimation results
	cap `nocoef' noi mi est, `saving' `miopts': regress `rhs', `options'
	if _rc {
		exit _rc
	}
	tempname esthold
	_estimates hold `esthold', copy

	// save completed-data beta and R2 estimates as variables
	local M = e(M_mi)
	mata: st_local("p",strofreal(cols(st_matrix("e(b_mi)"))))
	local cols : colnames e(b_mi)
	local pos : list posof "_cons" in cols
	if `pos'>0 {
		local p = `p'-1
	}
	tempname Beta r2
	mat `Beta' = J(`M',`p',0)
	mat `r2' = J(`M',2,.)
	forvalues i=1/`M' {
		qui estimates use `miestfile', number(`i')
		mat `r2'[`i',1] = e(r2)
		mat `r2'[`i',2] = e(r2_a)
		forvalues j=1/`p' {
			qui _ms_display, el(`j')
			mat `Beta'[`i',`j'] = r(beta)
		}
	}
	preserve
	qui {
		clear
		svmat double `r2', n(r2_)
		svmat double `Beta', n(beta)
	}
	_estimates unhold `esthold'
	// compute and display descriptive stats over imputations
	tempname b_std rsq adjrsq b_std_stats rsq_stats adjrsq_stats
	local coleq : coleq e(b_mi)
	local colnames : colnames e(b_mi)
	mat `b_std'= J(1,`p'+1,.)
	mat coleq `b_std' = `coleq'
	mat colnames `b_std' = `colnames'
	mat `b_std' = `b_std'[1,1..`p']
	di
	di as txt "Standardized coefficients and R-squared"
	di as txt "Summary statistics over `M' imputations"
	di
	if ("`original'"=="") {
		local star *
	}
	di as txt _col(14) "{c |}" _col(22) "mean`star'" 	///
				   _col(33) "min"	///
				   _col(44) "p25"	///
				   _col(52) "median"	///
				   _col(66) "p75"	///
				   _col(76) "max"
	di as txt "{hline 13}{c +}{hline 64}"
	forvalues j=1/`p' {
		_ms_element_info, el(`j') matrix(e(b_mi))
		if ("`r(type)'"!="variable" & r(first)) {
			local first first
		}
		if (`"`r(note)'"'=="(base)") {
			mat `b_std_stats' = nullmat(`b_std_stats'), J(5,1,.)
			continue
		}
		if (`"`r(note)'"'!="") {
			_ms_display, el(`j') matrix(e(b_mi)) `first'
			di as res `"`r(note)'"'
			local first
			mat `b_std_stats' = nullmat(`b_std_stats'), J(5,1,.)
		}
		else {
			_ms_display, el(`j') matrix(e(b_mi)) `first'
			_di_stats beta`j', `original'
			mat `b_std'[1,`j'] = r(mean_mi)
			mat `b_std_stats' = nullmat(`b_std_stats'), r(stats)'
			local first
		}
	}
	mat `b_std_stats' = nullmat(`b_std_stats'), J(5,1,.)
	mat coleq `b_std_stats' = `coleq'
	mat colnames `b_std_stats' = `colnames'
	mat rownames `b_std_stats' = min p25 p50 p75 max
	mat `b_std_stats' = `b_std_stats'[1..5,1..`p']
	di as txt "{hline 13}{c +}{hline 64}"
	di as txt _col(5) "R-square {c |}" _c
	_di_stats r2_1, `original' sqrt
	scalar `rsq' = r(mean_mi)
	mat `rsq_stats' = r(stats)
	di as txt _col(1) "Adj R-square {c |}" _c
	_di_stats r2_2, `original' sqrt
	scalar `adjrsq' = r(mean_mi)
	mat `adjrsq_stats' = r(stats)
	di as txt "{hline 13}{c BT}{hline 64}"
	if ("`original'"=="") {
		di as txt "* based on Fisher's z transformation"
	}
	restore
	//store additional results to e()
	eret scalar r2_mi     = `rsq'
	eret scalar r2_adj_mi = `adjrsq'
	eret matrix b_std_mi  = `b_std'
	eret matrix b_std_stats_mi  = `b_std_stats'
	eret matrix r2_stats_mi  = `rsq_stats'
	eret matrix r2_adj_stats_mi  = `adjrsq_stats'
end

program _chk_saving
	syntax [, SAVing(string asis) * ]
	if (`"`saving'"'!="") {
		// return filename in s(filename)
		_prefix_saving `saving'
	}
end

program _di_stats, rclass
	syntax varname(numeric) [, original SQRT ]
	local var `varlist'

	tempname m
	if ("`original'"!="") {
		qui summ `var', meanonly
		scalar `m' = r(mean)
	}
	else { //compute mean on Fisher's z scale and transform back
		tempvar x
		if ("`sqrt'"!="") {
			qui gen double `x'=atanh(sqrt(`var'))
			qui summ `x', meanonly
			scalar `m' = (tanh(r(mean)))^2
		}
		else {
			qui gen double `x'=atanh(`var')
			qui summ `x', meanonly
			scalar `m' = tanh(r(mean))
		}
	}
	di as res _col(17) %9.0g `m' _c
	qui summ `var', detail
	di as res "  " %8.3g r(min)	///
		  "  " %9.0g r(p25)	///
		  "  " %9.0g r(p50)	///
		  "  " %9.0g r(p75)	///
		  "  " %8.3g r(max)
	tempname stats
	mat `stats' = (r(min), r(p25), r(p50), r(p75), r(max))
	return scalar mean_mi = `m'
	return matrix stats = `stats'
end
/*
Version history:
  *! version 1.0.2  19jun2014 -- fixed a temporary name not found bug (r(111))
  *! version 1.0.1  27may2014 -- MI summaries of standardized coefficients
				 and R-squared measures are now stored in e()
  *! version 1.0.0  07jan2010 -- created

*/

*! version 2.0.0 09oct2014 Daniel Klein

pr mimrgns
	vers 11.2
	
	if ("`e(prefix_mi)'" != "mi estimate") err 301
	
	loc cvers vers `= _caller()' :
	
	sret clear
		
	// mimic margins syntax
	syntax [anything(equalok name = marginlist)] ///
	[if] [in] [fw aw pw iw] [ , ///
	PRedict(passthru) EXPression(passthru) POST ///
	PWCOMPare PWCOMPare_opts(str) ///
	Level(passthru) NOATLEGEND MCOMPare(passthru) ///
	EFORM DIOPTS(str) CMDMARGINS MIOPTS(str asis) * ]
	
	// parse syntax
	loc ifin `if' `in'
	if (`"`weight'"' != "") loc wght [`weight' `exp']
	if mi(`"`predict'`expression'"') {
		loc predict pr(xb)
	}
	if ("`post'" != "") loc not not
	if ("`eform'" != "") loc Eform eform
	loc reporting_opts `level' `noatlegend' `mcompare' `diopts'
	
	if mi("`marginlist'") {
		loc pwcompare
		loc pwcompare_opts
	}
	if ("`pwcompare_opts'" != "") {
		GetTableOpts ,`pwcompare_opts'
		loc cionly `s(cionly)'
		loc pvonly `s(pvonly)'
		loc effects `"`s(effects)'"'
		loc cimargins `s(cimargins)' // returns 'cionly' or empty
		loc reporting_opts `reporting_opts' `s(sort)'
		loc pwcompare pwcompare
	}
	if ("`pwcompare'" != "") {
		if (e(dfadjust_mi) == "Small sample") loc nu_c = e(df_c_mi)
		if mi(`"`cionly'`pvonly'`effects'`cimargins'"') {
			loc cionly cionly
		}
	}
	loc margins_opts `predict' `expression' `options' `reporting_opts'
	
	// get and set cmdlines
	loc cmdline_user mimrgns `0'
	loc cmdline_mi `e(cmdline_mi)'
	gettoken dmp cmdline : cmdline_mi ,p(":") bind
	gettoken col cmdline : cmdline ,p(":")
	
	// rebuild mi est options from last call
	gettoken mi_estimate mi_opts : cmdline_mi ,p(",")
	if ("`mi_estimate'" != "mi estimate ") loc mi_opts
	else {
		gettoken 0 : mi_opts ,p(":")
		syntax [ , POST EFORM HR SHR IRr OR RRr noHEADer noTABle * ]
		loc mi_opts `options'
	}
	loc mi_opts `mi_opts' nohead notab
	
	// back up original mi estimation results
	tempname mi_results
	_est h `mi_results' ,r
	
	// call MiMrgns
	`cvers' mi est ,post `mi_opts' `miopts' : ///
	MiMrgns firstarg `marginlist' `ifin' `wght' ///
	,cmd(`"`cmdline'"') `pwcompare' `margins_opts'
	
	// get r() from MiMrgns
	_ret res _MiMrgns_margins_results
	
	// combine r(_*_vs_mi) matrices and post to e()
	if ("`pwcompare'" != "") m : mCombineVs()
	
	// back up r()
	loc margexpr `r(expression)'
	tempname rres
	_ret hold `rres'
	
	// output
	mi est ,notab	
	if mi("`pwcompare'") | ("`cimargins'" != "") {
		_coef_table ,`cimargins' `reporting_opts' `Eform' `diopts'
		di as txt "Expression: " as res `"`margexpr'"'
	}
	foreach topt in `cionly' `pvonly' `effects' {
		_coef_table ,compare `topt' ///
		bmat(e(b_vs)) vmat(e(V_vs)) dfmat(e(df_vs)) ///
		emat(e(error_vs)) `reoprting_opts' `Eform' `diopts'
		di as txt "Expression: " as res `"`margexpr'"'
	}
	
	// now return r()
	_ret res `rres'
	m : mReturnRes(("`pwcompare'" != ""))
	if mi("`cmdmargins'") m : mSetCmd()
	
	// restore original mi estimation results
	_est u `mi_results' ,`not'
end

pr MiMrgns ,eclass prop(mi swml sw svyb svyj svyr st)
	
	loc cvers vers `= _caller()' :
	
	syntax anything [if] [in] [fw aw pw iw] , CMD(str asis) [ * ]
	if ("`weight'" != "") loc wght [`weight' `exp']
	gettoken firstarg marginslist : anything
	
	// run estimation command
	gettoken cmd : cmd // remove outer double quotes
	`cvers' qui `cmd'
	
	cap _ret res _MiMrgns_margins_results
	
	// copy matrices for additional results
	tempname _b_vs_mi _V_vs_mi _error_vs_mi
	cap conf mat r(_b_vs_mi)
	if !(_rc) {
		mat `_b_vs_mi' = r(_b_vs_mi)
		mat `_V_vs_mi' = r(_V_vs_mi)
		mat `_error_vs_mi' = r(_error_vs_mi)
	}
	
	// run margins
	`cvers' margins `marginslist' `if' `in' `wght' ,post `options'
	
	// pwcompare
	if ("`e(cmd)'" == "pwcompare") {
		cap conf mat `_b_vs_mi'
		if (_rc) {
			mat `_b_vs_mi' = r(b_vs) 
			mat `_V_vs_mi' = r(V_vs)
			mat `_error_vs_mi' = r(error_vs)
		}
		else {
			mat `_b_vs_mi' = `_b_vs_mi'\ r(b_vs)
			mat `_V_vs_mi' = `_V_vs_mi' + r(V_vs)
			mat `_error_vs_mi' = `_error_vs_mi' + r(error_vs)
		}
		m : st_matrix("r(_b_vs_mi)", st_matrix("`_b_vs_mi'"))
		m : st_matrix("r(_V_vs_mi)", st_matrix("`_V_vs_mi'"))
		m : st_matrix("r(_error_vs_mi)", st_matrix("`_error_vs_mi'"))
	}
	
	_ret hold _MiMrgns_margins_results
end

pr GetTableOpts ,sclass
	syntax [ , CIeffects PVeffects EFFects CIMargins GROUPs SORT ]
	
	foreach x in ci pv {
		sret loc `x'only : subinstr loc `x'effects "effects" "only"
	}
	if ("`effects'" != "") sret loc effects `""""'
	
	if ("`cimargins'" != "") sret loc cimargins cionly
	sret loc sort `sort'
end

vers 11.2
m :
void mCombineVs()
{
	real scalar M, nu_c, gamma
	real rowvector q, r, df, nu_obs
	real matrix b, U, B, T
	
	// combine
	b = st_matrix("r(_b_vs_mi)")
	M = rows(b)
	U = st_matrix("r(_V_vs_mi)") / M
	q = mean(b)
	B = ((b :- q)' * (b :- q)) / (M - 1)
	T = U + (1 + 1/M) * B
	
	r = (((1 + 1/M) * diagonal(B)) :/ diagonal(U))'	
	df = (M - 1) * (1 :+ 1:/r) :^ 2
	
	nu_c = strtoreal(st_local("nu_c"))
	if (nu_c != .) {
		gamma = ((1 + 1/M) * (diagonal(B) :/ diagonal(T)))'
		nu_obs = nu_c * (nu_c + 1) * (1 :- gamma) :/ (nu_c + 3)
		df = 1 :/ ((1:/df) :+ (1:/nu_obs))
	}
	
	// post to e()
	if (nu_c != .) st_global("e(dfadjust_mi)", "Small sample")
	st_numscalar("e(N_mi)", min(st_matrix("r(_N)")))
	st_matrix("e(b_vs)", q)
	st_matrixcolstripe("e(b_vs)", st_matrixcolstripe("r(b_vs)"))
	st_matrix("e(V_vs)", T)
	st_matrixcolstripe("e(V_vs)", st_matrixcolstripe("r(V_vs)"))
	st_matrix("e(df_vs)", df)
	st_matrixcolstripe("e(df_vs)", st_matrixcolstripe("r(b_vs)"))
	st_matrix("e(error_vs)", ((st_matrix("r(_error_vs_mi)") :!= 0)*8))
	
	// clean up
	st_matrix("r(_b_vs_mi)", J(0, 0, .))
	st_matrix("r(_V_vs_mi)", J(0, 0, .))
	st_matrix("r(_df_vs_mi)", J(0, 0, .))
	st_matrix("r(_error_vs_mi)", J(0, 0, .))
}

void mReturnRes(real scalar vs)
{
	st_numscalar("r(N)", st_numscalar("e(N_mi)"))
	
	st_global("r(cmdline_user)", st_local("cmdline_user"))
	st_global("r(est_cmdline_mi)", st_local("cmdline_mi"))
	st_global("r(cmdline)", stritrim(st_global("e(cmdline)")))
	
	st_matrix("r(error)", st_matrix("e(error)"))
	st_matrix("r(df)", st_matrix("e(df_mi)"))
	st_matrix("r(V)", st_matrix("e(V_mi)"))
	st_matrixcolstripe("r(V)", st_matrixcolstripe("e(V_mi)"))
	st_matrixrowstripe("r(V)", st_matrixrowstripe("e(V_mi)"))
	st_matrix("r(b)", st_matrix("e(b_mi)"))
	st_matrixcolstripe("r(b)", st_matrixcolstripe("e(b_mi)"))
	
	if (vs) {
		st_matrix("r(error_vs)", st_matrix("e(error_vs)"))
		st_matrix("r(df_vs)", st_matrix("e(df_vs)"))
		st_matrixcolstripe("r(df_vs)", st_matrixcolstripe("e(b_vs)"))
		st_matrix("r(V_vs)", st_matrix("e(V_vs)"))
		st_matrixcolstripe("r(V_vs)", st_matrixcolstripe("e(V_vs)"))
		st_matrixrowstripe("r(V_vs)", st_matrixrowstripe("e(V_vs)"))
		st_matrix("r(b_vs)", st_matrix("e(b_vs)"))
		st_matrixcolstripe("r(b_vs)", st_matrixcolstripe("e(b_vs)"))
	}
	
	// delete
	st_global("r(overall)", "")
	st_matrix("r(table_vs)", J(0, 0, .))
	st_matrix("r(table)", J(0, 0, .))
	st_matrix("r(k_groups)", J(0, 0, .))
	st_matrix("r(chainrule)", J(0, 0, .))
	st_matrix("r(Jacobian)", J(0, 0, .))
	for (i = 1; i <= cols(st_matrix("r(b)")); ++i) {
		st_global("r(groups" + strofreal(i) + ")", "")
	}
	st_matrix("r(chi2)", J(0, 0, .))
	st_matrix("r(p)", J(0, 0, .))
}

void mSetCmd()
{
	st_global("r(cmd)", "mimrgns")
	st_global("e(cmd)", "mimrgns")
	st_global("r(cmd2)", "")
	st_global("e(cmd2)", "")
}
end
e

2.0.0	20jul2014	support -pwcompare- option
					default prediction is xb
					new output replays results
					fix bug get cmd from e(cmdline_mi) not e(cmdline)
					fix bug ignored reporting and display options
					new option -eform-
					new option -diopts-
					new option -cmdmargins-
					new option -miopts- (not documented)
					rewrite code subroutine and Mata functions
1.1.2	18apr2014	fix bug with mixed models syntax ||
					add caller version support
					fix bug with options but no mi options
					fix bug with mi option -noisily-
					code polish remove matrices from results
1.1.1	27mar2014	fix bug ignored weights specified with -mimrgns-
1.1.0	27feb2014	remove potentially missleading/unclear results
					(limited) support for -margins-' -post- option
					Stata version 11.2 declared
					first sent to SSC
1.0.2	24feb2014	global macros mimrgns_* no longer needed
1.0.1	24feb2014	fix problem with -mi-'s -post- and -eform- options
					fix problem with -margins-' -at()- option
1.0.0	21feb2014	initial draft

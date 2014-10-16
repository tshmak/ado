*! version 1.1.2 18apr2014 Daniel Klein

pr mimrgns
	vers 11.2
	
	if ("`e(prefix_mi)'" != "mi estimate") err 301
	
	loc cvers vers `= _caller()' :
	
	// mimic margins syntax
	syntax [anything(everything equalok)] [fw aw pw iw] [ , POST * ]
	if ("`weight'" != "") loc wght [`weight' `exp']
	loc anything mimrgns `anything'
	loc margins_opts `options'
	
	loc mimrgns_post `post'
	loc cmdline_user mimrgns `0'
	
	// get cmdline and mi options from e()
	loc cmdline `e(cmdline)'
	loc cmdline_mi `e(cmdline_mi)'
	gettoken mi_estimate mi_opts : cmdline_mi ,p(",")
	if ("`mi_estimate'" == "mi estimate ") {
		gettoken 0 : mi_opts ,p(":")
		syntax [ , CMDOK POST EFORM HR SHR IRr OR RRr * ]
		loc mi_opts `options'
	}
	else loc mi_opts
	
	// back up original estimation results
	tempname res_mi
	_est h `res_mi' ,r
	
	// get mi estimates for margins
	`cvers' mi est ,cmdok `mi_opts' `mimrgns_post' : ///
	MiMrgns `anything' `wght' ,`margins_opts' cmd(`"`cmdline'"')
	
	// set r() for marginsplot
	_ret res mimrgns_margins_results
	
	m : st_numscalar("r(N)", st_numscalar("e(N_mi)"))
	m : st_global("r(cmdline_user)", "`cmdline_user'")
	m : st_global("r(est_cmdline_mi)", "`cmdline_mi'")
	
	m : st_matrix("r(V)", st_matrix("e(V_mi)"))
	m : st_matrixcolstripe("r(V)", st_matrixcolstripe("e(V_mi)"))
	m : st_matrixrowstripe("r(V)", st_matrixrowstripe("e(V_mi)"))
	m : st_matrix("r(b)", st_matrix("e(b_mi)"))
	m : st_matrixcolstripe("r(b)", st_matrixcolstripe("e(b_mi)"))
	
	// set e() results (post option)
	if ("`mimrgns_post'" != "") {
		m : st_numscalar("e(N)", st_numscalar("e(N_mi)"))
		m : st_global("e(cmdline_user)", "`cmdline_user'")
		m : st_global("e(est_cmdline_mi)", "`cmdline_mi'")
		
		loc not not
	}
	
	// remove potentially missleading results
	foreach c in r e {
		foreach s in N_sub N_clust N_psu N_strata df_r N_poststrata {
			m : st_numscalar("`c'(`s')", J(0, 0, .))
		}
		foreach m in Jacobian _N chainrule error table {
			m : st_matrix("`c'(`m')", J(0, 0, .))
		}
	}	
		
	// restore original results
	_est u `res_mi' ,`not'
end

pr MiMrgns ,eclass prop(mi swml sw svyb svyj svyr st)
	
	syntax anything [if] [in] [fw aw pw iw] [ , cmd(str asis) * ]
	if ("`weight'" != "") loc wght [`weight' `exp']
	gettoken mimrgns anything : anything
	
	gettoken cmd : cmd
	`cvers' qui `cmd'
	
	`cvers' margins `anything' `if' `in' `wght' ,post `options'
	cap _ret drop mimrgns_margins_results
	_ret hold mimrgns_margins_results
end
e

1.1.2	18apr2014	fix bug with multi-level commands using ||
					add caller version support
					fix bug with options but no mi-options
					fix bug with mi-option -noisily-
					code polish remove matrices from results
1.1.1	27mar2014	fix bug ignored weights specified with -mimrgns-
1.1.0	27feb2014	remove potentially missleading/unclear results
					support for -margins-' -post- option (limited)
					Stata version 11.2 declared
					first sent to SSC
1.0.2	24feb2014	global macros mimrgns_* no longer needed
1.0.1	24feb2014	fix problem with -mi-'s -post- and -eform- options
					fix problem with -margins-' -at()- option
1.0.0	21feb2014	initial draft

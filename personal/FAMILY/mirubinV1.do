* Program to apply Rubin's rule to estimation results from multiply-imputed datasets
* Assumes that you have estimations results stored as `stub'1, `stub'2, etc. 
* Version 0.1
capture program drop mirubin
capture mata: mata drop rubin()
program define mirubin, eclass

	version 12
	syntax , stub(name) [Imputations(numlist) force repost noSMALL ] 
	
	if "`imputations'" == "" {
		local i = 0
		while _rc == 0 {
			local i=`i'+1
			capture est dir `stub'`i'
		}
		if `i' == 1 {
			di as err "Cannot find matrix {res:``type'stub'`i'}"
			exit 999
		}
		else local nimp = `i' - 1

		numlist "1/`nimp'"
		local imputations `r(numlist)'
	}
	
	local nlist `imputations'
	local nimp : word count `imputations'
	gettoken firstn otherns : imputations
	
	
	if "`force'" == "" {
		// Check if estimation results have the same e(N) and that e(b) and e(V) have the same colnames.
		qui est restore `stub'`firstn'
		local colnames : colfullnames e(b)
		local n = e(N)
		foreach imp in `nlist' {
			qui est restore `stub'`imp'
			foreach type in e(b) e(V) {
				local testcolnames : colfullnames `type'
				if "`testcolnames'" != "`colnames'" {
					di as err "The column names of `type' in `stub'`firstn' is:"
					di as res "`colnames'"
					di as err "but the column names of `type' in `stub'`imp' is:"
					di as res "`testcolnames'"
					exit 999
				}
			}
			local testn = e(N)
			if `n' != `testn' {
				di as err "e(N) in `stub'`firstn' is: {res:`n'}"
				di as err "but e(N) in `stub'`imp' is:  {res:`testn'}"
				exit 999
			}
		}
	}
	di as txt "Estimations found:"
	local estnames `""`stub'`firstn'""'
	di as res"`stub'`firstn'"
	foreach imp in `otherns' {
		local estnames `"`estnames', "`stub'`imp'""'
		di as res "`stub'`imp'"
	}

	tempname bmat Vmat 
	mata: rubin((`estnames'), "`bmat'", "`Vmat'");
	
	if "`colnames'" == "" local colnames : colfullnames e(b)
	// di "`colnames'"
	foreach mat in bmat Vmat {
		matrix colnames ``mat'' = `colnames'
	}
	foreach mat in Vmat {
		matrix rownames ``mat'' = `colnames'
	}
	
	// Save copy of bmat and Vmat
	tempname bmat2 Vmat2
	matrix `bmat2' = `bmat'
	matrix `Vmat2' = `Vmat'
	
	if "`repost'" == "repost" ereturn repost b = `bmat' V = `Vmat'
	else ereturn post `bmat' `Vmat' 
	ereturn display


end
	
mata: 
void rubin(string rowvector matnames, 
	string scalar bmatname, 
	string scalar Vmatname) {
	
	n = length(matnames);
	for(i=1;i<=n;i++) {
		command = "qui est restore " + matnames[i]
		stata(command);
		b = st_matrix("e(b)"); V = st_matrix("e(V)");
		df_r = st_numscalar("e(df_r)")
		if (i==1) {
			_b = b; _V_within = V; _df_r = df_r;
		}
		else {
			_b = (_b \ b) ; _V_within = _V_within + V; _df_r = _df_r \ df_r;
		}
	}
	 _b_mean = colsum(_b) :/ n ; _V_within = _V_within :/ n
	 _b_centred = _b :- J(n, 1,1) * _b_mean
	 _V_between = _b_centred' * _b_centred :/ (n - 1)
	 VV = _V_within + (1 + 1/n) :* _V_between ; bb = _b_mean ;
	 st_matrix(bmatname, bb) ; st_matrix(Vmatname, VV) ;
	
}
		
		
end

* Program to apply Rubin's rule to estimation matrices from multiply-imputed datasets
* Version 1.0
capture program drop mirubinmat
program define mirubinmat, eclass

	syntax , Bstub(name) Vstub(name) [mata Imputations(numlist) force nopost] 
	
	if "`imputations'" == "" {
		foreach type in b v {
			capture
			local i = 0
			while _rc == 0 {
				local i=`i'+1
				capture confirm matrix ``type'stub'`i'
			}
			if `i' == 1 {
				di as err "Cannot find matrix {res:``type'stub'`i'}"
				exit 999
			}
			else local n`type' = `i' - 1
		}
		if `nb' != `nv' {
			di as err "Number of {res:`bstub'} matrices = `nb', but number of "_c 
			di as err "{res:`vstub'} matrices = `nv'. Perhaps specify the matrices to use by the {res:{cmdab:i:mputations}({it:numlist})} option"
			exit 999
		}
		else {
			numlist "1/`nb'"
			local imputations `r(numlist)'
		}
	}
	
	local nlist `imputations'
	local nimp : word count `imputations'
	gettoken firstn otherns : imputations
	
	
	if "`force'" == "" & "`mata'" != "mata" {
		// Check if matrices have the same col names
		local colnames : colnames `bstub'`firstn'
		foreach imp in `otherns' {
			local testcolnames : colnames `bstub'`imp'
			if "`testcolnames'" != "`colnames'" {
				di as err "The column names of `bstub'`firstn' is:"
				di as res "`colnames'"
				di as err "but the column names of `bstub'`imp' is:"
				di as res "`testcolnames'"
				exit 999
			}
		}
		foreach imp in `nlist' {
			local testcolnames : colnames `vstub'`imp'
			if "`testcolnames'" != "`colnames'" {
				di as err "The column names of `bstub'`firstn' is:"
				di as res "`colnames'"
				di as err "but the column names of `vstub'`imp' is:"
				di as res "`testcolnames'"
				exit 999
			}
		}
	}
	
	if "`mata'" != "mata" {
		foreach imp in `nlist' {
			mata: `bstub'`imp' = st_matrix("`bstub'`imp'") ; `vstub'`imp' = st_matrix("`vstub'`imp'") 
		}
	}
	
	local nlist_mat : subinstr local nlist " " ", " , all
	mata: nlist = (`nlist_mat')
	
	mata: _b = `bstub'`firstn' ; _V_within = `vstub'`firstn'
	mata : st_numscalar("_transform", cols(`bstub'`firstn') == 1) 
	if _transform == 1 local t '

	foreach imp in `otherns' {
		mata: _b = (_b \ `bstub'`imp'`t') ; _V_within = _V_within + `vstub'`imp' 
	}
	mata: _b_mean = colsum(_b) :/ `nimp' ; _V_within = _V_within :/ `nimp'
	mata: _b_centred = _b :- J(`nimp', 1,1) * _b_mean
	mata: _V_between = _b_centred' * _b_centred :/ (`nimp' - 1)
	mata: `vstub' = _V_within + (1 + 1/`nimp') :* _V_between ; `bstub' = _b_mean`t'
	mata: st_matrix("`bstub'", `bstub') ; st_matrix("`vstub'", `vstub') ;
	if "`colnames'" == "" local colnames : colnames `bstub'
	matrix colnames `bstub' = `colnames'
	matrix colnames `vstub' = `colnames'
	matrix rownames `vstub' = `colnames'
	
	

	if "`post'" == "" {
		// ereturn clear
		ereturn post `bstub' `vstub'
		ereturn display
		matrix `bstub' = e(b)
		matrix `vstub' = e(V)
		
	}
end
	
			
		

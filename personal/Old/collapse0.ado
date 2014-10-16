program define collapse0, nclass

	/* An ado-file to do collapse with the zero-count categories */
	version 8
	syntax anything(name=clist id=clist equalok)    ///
                [if] [in] [aw fw iw pw]                 ///
                , BY(varlist) [CW FAST noMISS *]

	tempfile file1 file2 file3
	marksample touse
	tempvar nmiss
	if "`miss'" == "nomiss" {
		qui egen `nmiss' = rowmiss(`by') if `touse'
	}
	else {
		qui gen `nmiss' = 0 if `touse'
	}

	qui save `file1'
	collapse `clist' if `touse' & `nmiss' == 0 [`weight'`exp'], by(`by') `cw' `fast'
	unab varlist : _all
	qui save `file2'
	qui use `file1', clear
	tempname var
	contract `by' if `touse', zero `options' `miss' freq(`var')
	sort `by'
	qui save `file3'
	qui use `file2', clear
	sort `by' 
	qui merge `by' using `file3', uniq
	drop _merge
	sort `by'
end

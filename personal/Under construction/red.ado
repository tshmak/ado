*! Version 1.0.0 4-Nov-2010

program define red, rclass sortpreserve

	*** red - Rounding Error Diagnosis ***
	*** Program to diagnose if data suffer from rounding error ***

	syntax [varlist] [if] [in] [, INTtol(real 1e-5) UNIquevaltol(real 1e-7) fix]

	marksample touse , novarlist
	tempvar id testint testdis testdis2 testdis3 testdis4

	if "`varlist'" == `""' unab varlist : _all

	foreach var in `varlist' {

		local type : type `var' 

		di in ye "`var' " in gr "is of type " in ye "`type'" in gr ". "_c

		if "`type'" == "float" | "`type'" == "double" {

			qui bysort `touse' `var' : gen `id' = _n == 1 & `touse' 

			*** Check if they look like integers ***

			qui gen double `testint' = abs(`var' - round(`var')) if `id' == 1
			qui sum `testint' 
			if `r(N)' > 0 {
				if `r(max)' < `inttol' { 
					di in gr "However, it appears to be " in ye "integer."
					di in gr "Maximum rounding error: " in ye `r(max)' _c
				}
			}

			drop `testint'

			*** Check if variable looks discrete ***

			qui gen double `testdis' = round(`var', `uniquevaltol')
			qui count if `id' == 1
			local n_original = r(N)
			qui bysort `touse' `testdis' : gen `testdis2' = _n == 1 if `id' == 1
			qui count if `testdis2' == 1
			local n_rounded = r(N)

			if `n_original' > `n_rounded' {

				di in gr "The variable may be discrete. "
				qui bysort `id' `testdis' : gen `testdis3' = _N * (`id' == 1)
				local i = `i' + 1
				tempname mat
				mkmat `var' `testdis' if `testdis3' > 1 , mat(`mat')
				di in gr "Type " in ye "matrix list r(`var') " in gr "for details."
				di "Recommend round to nearest " in ye `uniquevaltol'
				return matrix `var' = `mat'

				drop `testdis3' 

			}
			else di
			drop `testdis' `testdis2' `id'
		}
		else di 
	}

end

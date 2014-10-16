*! 1.0.0, John Thompson, 22 May 2006
program wbhull , rclass
    syntax varlist (min=2 max=4) [if] [in] , Peels(numlist) ///
      [ Hull(varlist) Thin(integer 1) Goptions(string) ///
      CGoptions(string) Saving(string) Export(string)]
    version 8.2
    
    * ---------------------------------
    * count number of plots
    * ---------------------------------
    local np = 0
    local vlist ""
    local hlist
    foreach v of varlist `varlist' {
        local np = `np' + 1
        local vlist "`vlist' z`np'"
        local hlist "`hlist' zh`np'"
    }
    tokenize "`varlist'"
    args `vlist'
    
    if "`hull'" ~= "" {
        tokenize "`hull'"
        args `hlist'
        foreach h of varlist `hull' {
            replace `h'=.
        }
    }
    tokenize `"`saving'"',parse(",")
    local saving = trim(`"`1'"')
    local replace `"`3'"'
    
    tokenize `"`export'"',parse(",")
    local export = trim(`"`1'"')
    local ereplace `"`3'"'
    
    tokenize `"`dsaving'"',parse(",")
    local dsaving = trim(`"`1'"')
    local dreplace `"`3'"'
    
    * -------------------------------
    * Select the data
    * -------------------------------
    tempvar h order c
    marksample touse , novarlist
    local np1 = `np'-1
    local pj = 0
    forvalues j1=1/`np1' {
        local jj=`j1'+1
        forvalues j2=`jj'/`np' {
            local pj = `pj' + 1
            local x = "`z`j1''"
            local y = "`z`j2''"
            
            preserve
            qui keep if `touse'
            qui gen `c'= _n
            qui keep if mod(`c',`thin')==0
            
            local last = 0
            foreach k of numlist `peels' {
                local last = max(`k' ,`last')
            }
            * -------------------------------
            * construct the format
            * -------------------------------
            qui count
            local npt = r(N)
            
            qui su `x'
            local mx = r(mean)
            qui su `y'
            local my = r(mean)
            
            quietly gen int `h'=.
            qui wbconhull `x' `y' , hull(`last') coname(`h')
            gen `order' = _n
            di _newline "Peels for `x' vs `y'"
            di %8s "Peel" %12s "% Outside"
            forvalues k=1/`last' {
                qui count if `h' < `k'
                return scalar p`k' = 100*r(N)/`npt'
                di %8.0f `k' %12.2f 100*r(N)/`npt' "%"
            }
            local lines ""
            foreach k of numlist `peels' {
                qui su `order' if `h' == `k'
                if r(N) ~= 0 {
                    local i1 = r(min)
                    local n = _N + 1
                    qui set obs `n'
                    local x1 = `x'[`i1']
                    local y1 = `y'[`i1']
                    qui replace `x' = `x1' in `n'
                    qui replace `y' = `y1' in `n'
                    qui replace `h' = `k' in `n'
                    qui replace `order' = `n' in `n'
                    local lines "`lines' (line `x' `y' if `h'==`k')"
                }
            }
            
            sort `h' `order'
            qui twoway `lines' , legend(off) ///
              text(`mx' `my' "+", place(c)) ///
              `goptions' sav(_h`j1'`j2'.gph,replace)
            if `np' == 2 & "`saving'" ~= "" {
                qui graph save "`saving'", `replace'
            }
            if `np' == 2 & "`export'" ~= "" {
                qui graph export "`export'", `ereplace'
            }
            if "`hull'" ~= "" {
                replace `zh`pj''=`h'
            }
            restore
        }
    }
    if `np' == 2 {
        cap erase _h12.gph
    }
    if `np' == 3 {
        qui graph combine _h12.gph _h13.gph _h23.gph, hole(3) `cgoptions'
        cap erase _h12.gph 
		cap erase _h13.gph 
		cap erase _h23.gph
    }
    if `np' == 4 {
        qui graph combine _h12.gph _h13.gph _h14.gph _h23.gph _h24.gph _h34.gph, hole(4 7 8) `cgoptions'
        cap erase _h12.gph 
		cap erase _h13.gph 
		cap erase _h14.gph 
		cap erase _h23.gph 
		cap erase _h24.gph 
		cap erase _h34.gph
    }
    if `np' > 2 {
        if "`saving'" ~= "" {
            qui graph save "`saving'", `replace'
        }
        if "`export'" ~= "" {
            qui graph export "`export'", `ereplace'
        }
    }
end

program wbconhull
    syntax varlist (min=2 max=2) , coname(varname) hull(integer)
    
    tokenize "`varlist'"
    args x y
    
    tempvar marker fmk theta dx dy test slope
    quietly gen byte `marker'=1
    quietly gen byte `fmk'=`marker'
    quietly gen `theta'=-1e37
    quietly gen `dx'=.
    quietly gen `dy'=.
    quietly gen `test'=.
    quietly gen `slope'=.
    
    local i=1
    local io=`i'
    local chull=1
    while `i'<=_N & `chull' <= `hull' {
        sort `y' `x' in `i'/l
        replace `marker'=2 in `i'
        expand `marker'
        replace `marker'=0 in `i'
        replace `fmk'=`marker' in `i'/l
        local j=`i'+1
        replace `theta'=-1e37 in `i'
        while `marker'[`i'] !=2 {
            replace `marker'=0 in `i'
            replace `fmk'=0 in `i'
            replace `dx'=`x'-`x'[`i'] in `j'/l
            replace `dy'=`y'-`y'[`i'] in `j'/l
            replace `theta'=0 in `j'/l
            replace `theta'=. if `dx'==0 & `dy'==0 in `j'/l
            replace `fmk'=0 if `dx'==0 & `dy'==0 in `j'/l
            replace `theta'=`dy' /(abs(`dx') + abs(`dy')) if `dy'!=0 in `j'/l
            replace `theta'=2-`theta' if `dx'<0 in `j'/l
            replace `theta'=4+`theta' if `dx'>=0 & `dy'<0 in `j'/l
            replace `theta'=`theta'-2 in `j'/l
            replace `theta'=. if `theta'<`theta'[`i'] in `j'/l
            sort `theta' in `j'/l
            local i=`j'
            local j=`j'+1
        }
        local i=`io'
        local j=`i'+1
        while `marker'[`i']!=2{
            replace `slope'=(`x'[`i']-`x'[`j']) / (`y'[`i']-`y'[`j']) in `j'/l
            replace `test'=(`x'[`i']-`1') / (`y'[`i']-`y') in `j'/l
            replace `fmk'=0 if `test'==`slope' in `j'/l
            local i=`j'
            local j=`j'+1
        }
        drop if `marker'==2
        replace `coname'=`chull' if `fmk'==0 & _n>= `io'
        count if `coname'==`chull' in `io'/l
        local i=`io'+r(N)
        sort `coname' in `io'/l
        local chull=`chull'+1
        local io=`i'
    }
    
end

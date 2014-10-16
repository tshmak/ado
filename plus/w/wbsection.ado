*! 1.0.0, John Thompson, 6 May 2006
program wbsection
    syntax varlist [if] [in] , [ m(integer 2) Goptions(string) ///
      BYCHain(varname) CGoptions(string) Saving(string) Export(string) DSaving(string)]
    version 8.2
    quietly {
        marksample touse
        preserve
        keep if `touse'
        
        * ---------------------------------
        * count number of plots
        * ---------------------------------
        local np = 0
        foreach v of varlist `varlist' {
            local np = `np' + 1
        }
        
        tempvar t
        if "`bychain'" ~= "" {
            su `bychain'
            local m = r(max)
        }
        local n = _N
        local size = int(`n'/`m')
        egen `t' = seq() , t(`n')
        tokenize `"`saving'"',parse(",")
        local saving = trim(`"`1'"')
        local replace `"`3'"'
        
        tokenize `"`export'"',parse(",")
        local export = trim(`"`1'"')
        local ereplace `"`3'"'
        
        tokenize `"`dsaving'"',parse(",")
        local dsaving = trim(`"`1'"')
        local dreplace `"`3'"'
        
        forvalues i = 1 / `m' {
            tempvar x`i' f`i'
        }
        local j = 0
        local cs = ""
        tempvar x bigf smallf f plotid
        foreach v of varlist `varlist' {
            {
                local j = `j' + 1
                * -------------------------
                * density for the whole chain
                * -------------------------
                kdensity `v' , gen(`x' `f') n(101) nograph
                * -------------------------
                * density for each part chain
                * -------------------------
                gen `bigf' = 0
                gen `smallf' = 999
                local plot "(line `f' `x', clp(solid) clw(medthick))"
                local vars ""
                local lb = 0
                forvalues i = 1 / `m' {
                    local ub = `lb' + `size'
                    kdensity `v' if `t' > `lb' & `t' <= `ub' , gen(`x`i'' `f`i'') at(`x') nograph
                    local vars "`vars' `f`i''"
                    local plot "`plot' (line `f`i'' `x', clp(dash))"
                    local lb = `ub'
                    replace `bigf' = `f`i'' if `f`i'' > `bigf'
                    replace `smallf' = `f`i'' if `f`i'' < `smallf'
                }
                * -------------------------
                * Measure of difference
                * -------------------------
                summ `f'
                replace `bigf' = (`bigf' - `smallf') / r(max)
                summ `bigf'
                local D = round(r(max) * 100)
            }
            
            * ---------------------------------
            * files to save plots
            * ---------------------------------
            if `np' > 1 {
                local s = "saving(hplot`j'.gph,replace)"
                local cs = "`cs' hplot`j'.gph"
            }
            twoway `plot' , legend(off) ytitle("Density") xtitle("Estimate") ///
              title("`v'") note("D=`D'") `goptions' `s'
            if `np' == 1 & `"`saving'"' ~= "" {
                graph save `"`saving'"' , `replace'
            }
            if `np' == 1 & `"`export'"' ~= "" {
                graph export `"`export'"' , `ereplace'
            }
            if `"`dsaving'"' ~= "" {
                preserve
                keep `x' `f' `vars'
                gen `plotid' = `j'
                if `j' > 1 {
                    append using `"`dsaving'"'
                    save `"`dsaving'"' , replace
                }
                else {
                    save `"`dsaving'"' , `dreplace'
                }
                restore
            }
            drop `x' `bigf' `smallf' `f'
            forvalues i = 1 / `m' {
                drop `x`i'' `f`i''
            }
        }
        * -------------------------
        * combined plot
        * -------------------------
        if `np' > 1 {
            graph combine `cs' , `cgoptions'
            if `"`saving'"' ~= "" {
                graph save `"`saving'"' , `replace'
            }
            if `"`export'"' ~= "" {
                graph export `"`export'"' , `ereplace'
            }
        }
        foreach file of local cs {
            cap erase `file'
        }
        if `"`dsaving'"' ~= "" {
            preserve
            use `"`dsaving'"' , clear
            drop if `f' == .
            rename `f' f
            rename `x' x
            rename `plotid' plot
            forvalues i=1/`m' {
                rename `f`i'' f`i'
            }
            save `"`dsaving'"' , replace
            restore
        }
        restore
    }
end

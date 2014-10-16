*! 1.0.0, John Thompson, 6 May 2006
program wbintervals
    syntax varlist [if] [in] , [ m(integer 10) Goptions(string) Levels(integer 80) ///
      BYCHain(varname) CGoptions(string) Saving(string) Export(string) DSaving(string)]
    version 8.2
    
    quietly {
        marksample touse
        preserve
        keep if `touse'
        local np = 0
        foreach v of varlist `varlist' {
            local np = `np' + 1
        }
        
        if "`bychain'" ~= "" {
            su `bychain'
            local nchain = r(max)
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
        
        tempvar y t x mn lb ub xp
        if "`bychain'" == "" {
            gen `t' = _n
        }
        else {
            count if `bychain' == 1
            local n = r(N)
            egen `t' = seq() , t(`n')
        }
        gen `x' = 1 + int(`m'*(`t'-1)/`n')
        gen `mn' = .
        gen `lb' = .
        gen `ub' = .
        gen `xp' = .
        local lc = (100-`levels')/2
        local uc = 100 - `lc'
        local j = 0
        foreach v of varlist `varlist' {
            local j = `j'+1
            su `v' if `touse', detail
            local ym = r(p50)
            local line = 0
            forvalues k=1/`m' {
                if "`bychain'" == "" {
                    local line = `line'+1
                    centile `v' if `x' == `k' , cent(`lc' 50 `uc')
                    replace `mn' = r(c_2) in `line'
                    replace `lb' = r(c_1) in `line'
                    replace `ub' = r(c_3) in `line'
                    replace `xp' = `k' - 0.5 in `line'
                }
                else {
                    forvalues c=1/`nchain' {
                        local line = `line'+1
                        centile `v' if `x' == `k' & `bychain' == `c' , cent(`lc' 50 `uc')
                        replace `mn' = r(c_2) in `line'
                        replace `lb' = r(c_1) in `line'
                        replace `ub' = r(c_3) in `line'
                        replace `xp' = `k'-0.5*(`c'-`nchain'/2)/`nchain' in `line'
                    }
                }
            }
            * ---------------------------------
            * produce the plot
            * ---------------------------------
            if `np' > 1 {
                local s = "saving(hplot`j'.gph,replace)"
                local cs = "`cs' hplot`j'.gph"
            }
            local mt = `m'+0.6
            twoway (scatter `mn' `xp' if `xp'<`mt') (rcap `lb' `ub' `xp' if `xp'<`mt') , legend(off) ///
              yline(`ym', lpat(dash)) ytitle("`levels'% Interval") xtitle("Ordered sets of simulations") ///
              title("`v'") xscale(range(0.4 `mt')) `goptions' `s'
            if `np' == 1 & `"`saving'"' ~= "" {
                graph save `"`saving'"' , `replace'
            }
            if `np' == 1 & `"`export'"' ~= "" {
                graph export `"`export'"' , `ereplace'
            }
            if `"`dsaving'"' ~= "" {
                if `j' > 1 {
                    append using `"`dsaving'"'
                }
                save `"`dsaving'"' , `dreplace'
            }
        }
        if `"`dsaving'"' ~= "" {
            preserve
            use `"`dsaving'"' , clear
            save `"`dsaving'"' , `dreplace'
            restore
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
        foreach f of local cs {
            cap erase `f'
        }
        restore
    }
end

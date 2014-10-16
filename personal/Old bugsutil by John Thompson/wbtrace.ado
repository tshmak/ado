*! 1.0.0, John Thompson, 6 May 2006
program wbtrace
    syntax varlist [if] [in] , [THin(integer 1) Goptions(string) ///
      CGoptions(string) Saving(string) Export(string) BYCHain(varname) Order(varname) ///
      OVERlay ]
    * ---------------------------------
    * count number of plots
    * ---------------------------------
    local np = 0
    foreach v of varlist `varlist' {
        local np = `np' + 1
    }
    * ---------------------------------
    * count number of chains
    * ---------------------------------
    if "`bychain'" == "" {
        local nc = 1
    }
    else {
        qui su `bychain'
        local nc = r(max)
    }
    if "`overlay'" == "" {
        local np = `np'*`nc'
    }
    * ---------------------------------
    * create order variable
    * ---------------------------------
    tempvar t
    if "`order'" == "" {
        local n = _N / `nc'
        egen `t' = seq() , t(`n')
        local orderlab = "Order"
    }
    else {
        gen `t' = `order'
        local orderlab : var label `order'
        di "TL:`orderlab'"
        if "`orderlab'" == "" {
            local orderlab "`order'"
        }
        di "TL:`orderlab'"
    }
    * ---------------------------------
    * thin if required
    * ---------------------------------
    if `thin' ~= 1 {
        if "`if'" == "" {
            local if "if mod(`t',`thin') == 1"
        }
        else {
            local if "`if' & mod(`t',`thin') == 1"
        }
        local note "thinned by `thin'"
    }
    
    tokenize "`saving'",parse(",")
    local saving "`1'"
    local replace "`3'"
    
    tokenize "`export'",parse(",")
    local export "`1'"
    local ereplace "`3'"
    
    local i = 0
    local cs = ""
    foreach v of varlist `varlist' {
        * ---------------------------------
        * plot each series
        * ---------------------------------
        if "`bychain'" == "" {
            * ---------------------------------
            * Single chain
            * ---------------------------------
            if `np' > 1 {
                local i = `i' + 1
                local s = "saving(_wb`i'.gph,replace)"
                local cs = "`cs' _wb`i'.gph"
            }
            * ---------------------------------
            * find credible intervals
            * ---------------------------------
            qui centile `v' `if' `in'
            local md = r(c_1)
            qui centile `v' `if' `in' , cen(2.5)
            local lb = r(c_1)
            qui centile `v' `if' `in' , cen(97.5)
            local ub = r(c_1)
            qui line `v' `t' `if' `in' , xtitle("`orderlab'") yline(`md' , lp(solid)) ///
              yline(`lb' , lp(dash)) yline(`ub' , lp(dash)) note(`note') `goptions' `s'
            if `np' == 1 & `"`saving'"' ~= "" {
                qui graph save `"`saving'"', `replace'
            }
            if `np' == 1 & `"`export'"' ~= "" {
                qui graph export `"`export'"', `ereplace'
            }
        }
        else {
            if "`overlay'" ~= "" {
                * ---------------------------------
                * Several chains - overlay
                * ---------------------------------
                if `np' > 1 {
                    local i = `i' + 1
                    local s = "saving(_wb`i'.gph,replace)"
                    local cs = "`cs' _wb`i'.gph"
                }
                * ---------------------------------
                * find credible intervals
                * ---------------------------------
                qui centile `v' `if' `in'
                local md = r(c_1)
                qui centile `v' `if' `in' , cen(2.5)
                local lb = r(c_1)
                qui centile `v' `if' `in' , cen(97.5)
                local ub = r(c_1)
                local pc ""
                forvalues c = 1 / `nc' {
                    if "`if'" == "" {
                        local cif "if `bychain' == `c'"
                    }
                    else {
                        local cif "`if' & `bychain' == `c'"
                    }
                    local pc "`pc' (line `v' `t' `cif' `in')"
                }
                qui twoway `pc' , xtitle("`orderlab'") yline(`md' , lp(solid)) ///
                  yline(`lb' , lp(dash)) yline(`ub' , lp(dash)) note(`note') `goptions' legend(off) `s'
                if `np' == 1 & `"`saving'"' ~= "" {
                    qui graph save `"`saving'"', `replace'
                }
                if `np' == 1 & `"`export'"' ~= "" {
                    qui graph export `"`export'"', `ereplace'
                }
            }
            else {
                * ---------------------------------
                * Several chains - not overlayed
                * ---------------------------------
                forvalues c = 1 / `nc' {
                    if "`if'" == "" {
                        local cif "if `bychain' == `c'"
                    }
                    else {
                        local cif "`if' & `bychain' == `c'"
                    }
                    * ---------------------------------
                    * find credible intervals
                    * ---------------------------------
                    qui centile `v' `cif' `in'
                    local md = r(c_1)
                    qui centile `v' `cif' `in' , cen(2.5)
                    local lb = r(c_1)
                    qui centile `v' `cif' `in' , cen(97.5)
                    local ub = r(c_1)
                    local i = `i' + 1
                    local s = "saving(_wb`i'.gph,replace)"
                    local cs = "`cs' _wb`i'.gph"
                    qui line `v' `t' `cif' `in' , xtitle("chain `c':`orderlab'") yline(`md' , lp(solid)) ///
                      yline(`lb' , lp(dash)) yline(`ub' , lp(dash)) note(`note') `goptions' `s'
                }
            }
        }
    }
    * ---------------------------------
    * combine plots if needed
    * ---------------------------------
    if `np' > 1 {
        qui graph combine `cs' , `cgoptions'
        if `"`saving'"' ~= "" {
            qui graph save `"`saving'"', `replace'
        }
        if `"`export'"' ~= "" {
            qui graph export `"`export'"', `ereplace'
        }
    }
    foreach f of local cs {
        cap erase `f'
    }
end

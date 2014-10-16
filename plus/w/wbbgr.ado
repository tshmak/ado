*! 1.0.0, John Thompson, 6 May 2006
program wbbgr
    syntax varlist (max = 1 min = 1) [if] [in] , ///
      Id(varname) [ TIme(varname) Goptions(string) ///
      CGoptions(string) Saving(string) Export(string) Bin(integer 0) ///
      BYChain Variance DSaving(string)]
    version 8.2
    
    quietly {
        * ---------------------------------
        * count number of chains
        * ---------------------------------
        su `id'
        local nc = r(max)
        local length = _N / `nc'
        if `bin' <= 0 {
            local bin = `length'/20
        }
        local nbin = `length'/`bin'
        
        tokenize `"`saving'"',parse(",")
        local saving = trim(`"`1'"')
        local replace `"`3'"'
        
        tokenize `"`export'"',parse(",")
        local export = trim(`"`1'"')
        local ereplace `"`3'"'
        
        tokenize `"`dsaving'"',parse(",")
        local dsaving = trim(`"`1'"')
        local dreplace `"`3'"'
        
        tempvar t
        if "`time'" == "" {
            egen `t' = seq() , t(`length')
            local timelab = "Order"
        }
        else {
            gen `t' = `time'
            local timelab : var label `time'
            if "`timelab'" == "" {
                local timelab "`time'"
            }
        }
        su `t'
        local mint = r(min)
        
        tempvar I80 limit aI80 R dfm dfv df
        gen `I80' = .
        gen `limit' = .
        gen `dfm' = .
        gen `dfv' = .
        gen `df' = .
        
        local list ""
        local plot ""
        forvalues i = 1 / `nc' {
            tempvar I80_`i'
            gen `I80_`i'' = .
            local list "`list' `I80_`i''"
            local plot "`plot' (line `I80_`i'' `limit' , lpat(dash) )"
        }
        forvalues i = 1 / `nbin' {
            local upper = `i'*`bin' + `mint'-1
            local half = `i'*`bin'/2 + `mint'
            replace `limit' = `upper' in `i'
            if "`variance'" == "" {
        * ---------------------------------
        * 80% intervals
        * ---------------------------------
                centile `varlist' if `t' <= `upper' & `t' > `half' , centile(10 90)
                replace `I80' = r(c_2)-r(c_1) in `i'
                forvalues j = 1 / `nc' {
                    centile `varlist' if `t' <= `upper' & `t' > `half' & `id' == `j' , centile(10 90)
                    replace `I80_`j'' = r(c_2)-r(c_1) in `i'
                }
            }
            else {
        * ---------------------------------
        * variance intervals
        * ---------------------------------
                su `varlist' if `t' <= `upper' & `t' > `half'
                local m = r(mean)
                local ss = 0
                local sv = 0
                forvalues j = 1 / `nc' {
                    su `varlist' if `t' <= `upper' & `t' > `half' & `id' == `j'
                    replace `dfm' = r(mean) in `j'
                    replace `dfv' = r(Var) in `j'
                    replace `I80_`j'' = r(Var) in `i'
                    local sv = `sv' + r(Var)
                    local ss = `ss' + (r(mean)-`m')^2
                    local n = r(N)
                }
                local W = `sv'/`nc'
                local B = `n'*`ss'/(`nc'-1)
                local splus = (`n'-1)*`W'/`n' + `B'/`n'
                local V = `splus' + `B'/(`n'*`nc')
                replace `I80' = `V' in `i'
                su `dfv'
                local v1 = r(Var)
                local vv= ((`n'-1)/`n')^2*r(Var)/`nc'+((`nc'+1)/(`nc'*`n'))^2*2*`B'*`B'/(`nc'-1)
                su `dfm'
                local gm = r(mean)
                local v2 = r(Var)
                corr `dfv' `dfm'
                local cv1 = r(rho)*sqrt(`v1'*`v2')
                replace `dfm' = `dfm'*`dfm'
                su `dfm'
                local v3 = r(Var)
                corr `dfv' `dfm'
                local cv2 = r(rho)*sqrt(`v1'*`v3')
                local vv = `vv' + (2*(`nc'+1)*(`n'-1)/(`nc'*`n'*`n'))*(`n'/`nc')*(`cv2'-2*`gm'*`cv1')
                local edf = 2*`V'*`V'/`vv'
                replace `df' = `edf' in `i'
            }
        }
        egen `aI80' = rmean(`list')
        if "`variance'" == "" {
            local Ylabel = "80% Intervals"
            local Rlabel = "R(interval)"
            gen `R' = `I80' / `aI80'
        }
        else {
            local Ylabel = "Variance Estimates"
            local Rlabel = "R(var)"
            gen `R' = ((`df'+3)/(`df'+1))*`I80' / `aI80'
        }
        
        tempfile p1 p2
        line `R' `limit' , yline(1, lpa(dash)) ytitle("`Rlabel'") xtitle("n") ///
          saving(`p1'.gph , replace) `goptions' ylabel(,angle(0))
        if "`bychain'" ~= "" {
            twoway (line `I80' `limit') `plot' , legend(off) ///
              ytitle("`Ylabel'") xtitle("n") ylabel(,angle(0)) ///
              saving(`p2'.gph , replace) `goptions'
        }
        else {
            twoway (line `I80' `limit') (line `aI80' `limit' , lpa(dash)) , legend(off) ///
              ytitle("`Ylabel'") xtitle("n") ylabel(,angle(0)) ///
              saving(`p2'.gph , replace) `goptions'
        }
        graph combine `p1'.gph `p2'.gph , row(2) `cgoptions' title("`varlist'")
        if `"`saving'"' ~= "" {
            graph save `"`saving'"' , `replace'
        }
        if `"`export'"' ~= "" {
            graph export `"`export'"' , `ereplace'
        }
        if `"`dsaving'"' ~= "" {
            preserve
            keep `limit' `R' `df' `I80' `aI80' `list' 
            drop if `I80' == .
            rename `limit' n
            rename `R' R
            rename `I80' pooled
            rename `aI80' average
            rename `df' df
            drop if n == .
            if "`variance'" == "" {
               drop df
               }
            local i = 0
            foreach v of local list {
                local i = `i' + 1
                rename `v' chain`i'
            }
            qui save `"`dsaving'"' , `dreplace'
            restore
        }
    }
end

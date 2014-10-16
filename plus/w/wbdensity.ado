*! 1.0.0, John Thompson, 6 May 2006
program wbdensity
    syntax varlist [if] [in] , [ Low(string) High(string) Koptions(string) Goptions(string) ///
      CGoptions(string) Saving(string) Export(string) DSaving(string)]
    version 8.2
    
    quietly {
        
        marksample touse
        local np = 0
        foreach v of varlist `varlist' {
            local np = `np' + 1
        }
        tokenize "`low'"
        forvalues j=1/`np' {
            local low`j' "``j''"
        }
        tokenize "`high'"
        forvalues j=1/`np' {
            local high`j' "``j''"
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
        
        tempvar y x f id
        local cs ""
        local j = 0
        foreach v of varlist `varlist' {
            local j = `j'+1
            {
                preserve
                gen `y' = `v'
                
                * ---------------------------------
                * if bounded - reflect
                * ---------------------------------
                local set = 1
                if "`low`j''" ~= "" & "`low`j''" ~= "." {
                    tempvar ylow`j'
                    gen `ylow`j'' = `low`j'' - `y'
                    local set = `set' + 1
                }
                if "`high`j''" ~= "" & "`high`j''" ~= "."{
                    tempvar yhigh`j'
                    gen `yhigh`j'' = `high`j'' + (`high`j''-`y')
                    local set = `set' + 1
                }
                if "`ylow`j''`yhigh`j''" ~= "" {
                    stack `y' `ylow`j'' `yhigh`j'' if `touse', into(`y') clear
                }
                local n = min(_N,150)
                kdensity `y' , gen(`x' `f') nograph n(`n') `koptions'
                
                if "`low`j''" ~= "" & "`low`j''" ~= "." {
                    cap drop if `x' < `low`j''
                }
                if "`high`j''" ~= "" & "`high`j''" ~= "."{
                    cap drop if `x' > `high`j''
                }
                replace `f' = `set'*`f'
            }
            * ---------------------------------
            * produce the plot
            * ---------------------------------
            if `np' > 1 {
                local s = "saving(_wb`j'.gph,replace)"
                local cs = "`cs' _wb`j'.gph"
            }
            
            twoway (line `f' `x' ) , legend(off) ///
              ytitle("Density") xtitle("Estimate") ///
              title("`v'") `goptions' `s'
            if `np' == 1 & "`saving'" ~= "" {
                graph save "`saving'" , `replace'
            }
            if `np' == 1 & "`export'" ~= "" {
                graph export "`export'" , `ereplace'
            }
            if "`dsaving'" ~= "" {
                gen `id' = `j'
                keep `id' `x' `f'
                drop if `f' == .
                if `j' > 1 {
                    append using "`dsaving'"
                }
                save "`dsaving'" , `dreplace'
            }
            restore
        }
        if `"`dsaving'"' ~= "" {
            preserve
            use `"`dsaving'"' , clear
            rename `id' plot
            rename `f' f
            rename `x' x
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
    }
end

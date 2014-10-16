*! 1.0.0, John Thompson, 6 June 2006
program wbac
    syntax varlist [if] [in] , [PAC Goptions(string) CGoptions(string) ///
      Saving(string) Export(string) ACoptions(string) DSaving(string)]
    version 8.2
    
    quietly {
        marksample touse , novarlist
        
        local np = 0
        foreach v of varlist `varlist' {
            local np = `np' + 1
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
        
        cap tsset
        local oldt = r(timevar)
        tempvar t plot corr lag
        gen `t' = _n
        tsset `t'
        local plots
        local i = 0
        foreach v of varlist `varlist' {
            local i = `i' + 1
            tempfile t`i'
            local save "saving(`t`i''.gph,replace)"
            local plots "`plots' `t`i''.gph"
            if "`pac'" ~= "" {
                pac `v' if `touse' , `acoptions' `goptions' `save' gen(`corr')
            }
            else {
                ac `v' if `touse' , `acoptions' `goptions' `save' gen(`corr')
            }
            if `np' == 1 & "`saving'" ~= "" {
                graph save "`saving'" , `replace'
            }
            if `np' == 1 & "`export'" ~= "" {
                graph export "`export'" , `ereplace'
            }
            if "`dsaving'" ~= "" {
                preserve
                keep `corr'
                gen `plot' = `i'
                gen `lag' = _n
                if `i' > 1 {
                    append using "`dsaving'"
                    save "`dsaving'" , `replace'
                }
                else {
                    save "`dsaving'" , replace
                }
                restore
            }
            drop `corr'
        }
        cap tsset `oldt'
        if `np' > 1 {
            graph combine `plots' , `cgoptions'
            if "`saving'" ~= "" {
                graph save "`saving'" , `replace'
            }
            if "`export'" ~= "" {
                graph export "`export'" , `ereplace'
            }
        }
        if "`dsaving'" ~= "" {
            preserve
            use "`dsaving'", clear
            rename `plot' plot
            rename `corr' r
            rename `lag' lag
            drop if r == .
            save "`dsaving'", replace
            restore
        }
    }
end

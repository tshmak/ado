*! 1.0.0, John Thompson, 6 May 2006
program wbstructure
    syntax varlist [if] [in] , Name(string) [ Linesize(integer 10) Format(string) ///
      Saving(string) NOLIST NOPRINT]
    version 8.2
    marksample touse , novarlist
    
    tempvar ntouse
    qui gen `ntouse' = _n * `touse'
    qui summ `ntouse'
    local last = r(max)
    qui summ `touse'
    local count = r(sum)
    local n = _N
    
    * --------------------------------
    * organise the formatting
    * --------------------------------
    if "`format'" == "" {
        local f1 = "%8.3f"
        local sf1 = "%8s"
        local nf = 1
    }
    else {
        tokenize "`format'"
        local nf = 1
        while "``nf''" ~= "" {
            local f`nf' = "``nf''"
            local np = index("``nf''" , ".")
            local sp = substr("``nf''" , 2 , `np'-2)
            local sf`nf' = "%`sp's"
            local nf = `nf' + 1
        }
        local nf = `nf' - 1
    }
    
    * --------------------------------
    * count variables
    * --------------------------------
    tokenize "`varlist'"
    local nv = 1
    while "``nv''" ~= "" {
        local nv = `nv' + 1
    }
    local nv = `nv' - 1
    
    * --------------------------------
    * display to screen if required
    * --------------------------------
    if "`noprint'" == "" {
        if "`nolist'" == "" {
            di "list( " _continue
        }
        
        di "`name'=structure(.Data=c("
        local col = 0
        forvalues i = 1 / `n' {
            if `touse'[`i'] == 1 {
                local v = 0
                local k = 1
                foreach x of varlist `varlist' {
                    local v = `v' + 1
                    local y = `x'[`i']
                    local col = `col' + 1
                    if "`y'" == "." {
                        di `sf`k'' "NA" _continue
                    }
                    else {
                        di `f`k'' `y' _continue
                    }
                    if `i' == `last' & `v' == `nv' {
                        di "),.Dim=c(`count',`nv'))" _continue
                        if "`nolist'" == "" {
                            di " )"
                        }
                        else {
                            di " "
                        }
                    }
                    else {
                        di "," _continue
                        if `col' == `linesize' {
                            di " "
                            local col = 0
                        }
                    }
                    local k = `k' + 1
                    if `k' > `nf' {
                        local k = 1
                    }
                }
            }
        }
    }
    * --------------------------------
    * write to file if required
    * --------------------------------
    if `"`saving'"' ~= "" {
        tokenize `"`saving'"' , parse(",")
        local saving `"`1'"'
        local replace "`3'"
        tempname WB
        file open `WB' using `"`saving'"' , write `replace'
        
        if "`nolist'" == "" {
            file write `WB' "list( "
        }
        
        file write `WB' "`name'=structure(.Data=c(" _n
        local col = 0
        forvalues i = 1 / `n' {
            if `touse'[`i'] == 1 {
                local v = 0
                local k = 1
                foreach x of varlist `varlist' {
                    local v = `v' + 1
                    local y = `x'[`i']
                    local col = `col' + 1
                    if "`y'" == "." {
                        file write `WB' `sf`k'' ("NA")
                    }
                    else {
                        file write `WB' `f`k'' (`y')
                    }
                    if `i' == `last' & `v' == `nv' {
                        file write `WB' "),.Dim=c(`count',`nv'))"
                        if "`nolist'" == "" {
                            file write `WB' " )" _n
                        }
                        else {
                            file write `WB' " " _n
                        }
                    }
                    else {
                        file write `WB' ","
                        if `col' == `linesize' {
                            file write `WB' _n
                            local col = 0
                        }
                    }
                    local k = `k' + 1
                    if `k' > `nf' {
                        local k = 1
                    }
                }
            }
        }
        file close `WB'
    }
end

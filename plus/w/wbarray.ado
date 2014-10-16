*! 1.0.0, John Thompson, 22 May 2006
program wbarray
    syntax varlist [if] [in] , [ Saving(string) format(string) NOPrint ]
    version 8.2
    
    marksample touse , novarlist
    
    * -------------------------------
    * construct the format
    * -------------------------------
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
    local n = _N
    * -------------------------------
    * if required write to screen
    * -------------------------------
    if "`noprint'" == "" {
        * -------------------------------
        * data header
        * -------------------------------
        local k = 1
        foreach x of varlist `varlist' {
            di `sf`k'' " `x'[]" _continue
            local k = `k' + 1
            if `k' > `nf' {
                local k = 1
            }
        }
        di " "
        * -------------------------------
        * data .. line by line
        * -------------------------------
        forvalues i = 1 / `n' {
            if `touse'[`i'] == 1 {
                local k = 1
                foreach x of varlist `varlist' {
                    local y = `x'[`i']
                    if `y' == . {
                        di `sf`k'' "NA" _continue
                    }
                    else {
                        di `f`k'' `y' _continue
                    }
                    local k = `k' + 1
                    if `k' > `nf' {
                        local k = 1
                    }
                }
                di " "
            }
        }
        di "END"
    }
    * -------------------------------
    * if required write to file
    * -------------------------------
    if `"`saving'"' ~= "" {
        tokenize `"`saving'"' , parse(",")
        local saving `"`1'"'
        local replace "`3'"
        tempname WB
        file open `WB' using `"`saving'"' , write `replace'
        local k = 1
        foreach x of varlist `varlist' {
            file write `WB' `sf`k'' (" `x'[]")
            local k = `k' + 1
            if `k' > `nf' {
                local k = 1
            }
        }
        file write `WB' _n
        
        forvalues i = 1 / `n' {
            if `touse'[`i'] == 1 {
                local k = 1
                foreach x of varlist `varlist' {
                    local y = `x'[`i']
                    if `y' == . {
                        file write `WB' `sf`k'' ("NA")
                    }
                    else {
                        file write `WB' `f`k'' (`y')
                    }
                    local k = `k' + 1
                    if `k' > `nf' {
                        local k = 1
                    }
                }
                file write `WB' _n
            }
        }
        file write `WB' "END" _n
        file close `WB'
    }
end

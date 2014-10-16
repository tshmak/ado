*! 1.0.0, John Thompson, 6 May 2006
program wbscalar
    syntax , SCalars(string) [ Linesize(integer 5) Format(string) Saving(string) NOLIST NOPRINT]
    version 8.2
    
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
    * count number of scalars
    * --------------------------------
    tokenize "`scalars'"
    local nv = 1
    while "``nv''" ~= "" {
        local nv = `nv' + 1
    }
    local nv = `nv' - 1
    * --------------------------------
    * list to screen if required
    * --------------------------------
    if "`noprint'" == "" {
        if "`nolist'" == "" {
            di "list( " _continue
        }
        local c = 0
        local k = 1
        forvalues c = 1 / `nv' {
            di "``c''=" `f`k'' (``c'') _continue
            if `c' ~= `nv' {
                di ", " _continue
                if mod(`c' , `linesize') == 0 {
                    di " "
                }
            }
            local k = `k' + 1
            if `k' > `nf' {
                local k = 1
            }
        }
        if "`nolist'" == "" {
            di ")"
        }
    }
    * --------------------------------
    * list to file if required
    * --------------------------------
    if `"`saving'"' ~= "" {
        tokenize `"`saving'"' , parse(",")
        local saving "`1'"
        local replace "`3'"
        
        tokenize "`scalars'"
        tempname WB
        file open `WB' using `"`saving'"' , write `replace'
        if "`nolist'" == "" {
            file write `WB' "list( "
        }
        local c = 0
        local k = 1
        forvalues c = 1 / `nv' {
            file write `WB' "``c''=" `f`k'' (``c'')
            if `c' ~= `nv' {
                file write `WB' ", "
                if mod(`c' , `linesize') == 0 {
                    file write `WB' _n
                }
            }
            local k = `k' + 1
            if `k' > `nf' {
                local k = 1
            }
        }
        if "`nolist'" == "" {
            file write `WB' ")" _n
        }
        file close `WB'
    }
end

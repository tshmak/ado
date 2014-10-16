*! 1.0.0, John Thompson, 22 May 2006
program wbdata
    syntax , Contents(string) [ Saving(string) NOPrint]
    version 8.2
    
    * ---------------------------
    * write to screen if required
    * ---------------------------
    if "`noprint'" == "" {
        di "list( "
        tokenize `"`contents'"' , parse("+")
        local p = 1
        while `"``p''"' ! = "" {
            if `p' > 1 {
                di ","
            }
            if strpos(`"``p''"' , ",") == 0 {
                ``p'' , nolist
            }
            else {
                ``p'' nolist
            }
            local p = `p' + 2
        }
        di ")"
    }
    * ---------------------------
    * write to file if required
    * ---------------------------
    if `"`saving'"' ~= "" {
        tokenize `"`saving'"' , parse(",")
        local saving `"`1'"'
        local replace "`3'"
        tempname WB TWB
        tempfile TF
        file open `WB' using `"`saving'"' , write `replace'
        file write `WB' "list( " _n
        
        tokenize `"`contents'"' , parse("+")
        local p = 1
        while `"``p''"' ! = "" {
            if `p' > 1 {
                file write `WB' "," _n
            }
            if strpos(`"``p''"' , ",") == 0 {
                quiet ``p'' , nolist saving(`TF',replace)
            }
            else {
                quiet ``p'' nolist saving(`TF',replace)
            }
            file open `TWB' using `TF' , read
            file read `TWB' line
            while r(eof) == 0 {
                file write `WB' "`line'" _n
                file read `TWB' line
            }
            file close `TWB'
            local p = `p' + 2
        }
        file write `WB' ")" _n
        file close `WB'
    }
end

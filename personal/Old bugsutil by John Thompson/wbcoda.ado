*! 1.0.0, John Thompson, 6 May 2006
program wbcoda
    syntax , Root(string) CLEAR [ CHains(integer 1) Multichain Id(string) ///
      Keep(string) THin(integer 1) NOReshape]
    version 8.2
    
    * ---------------------------------
    * read the index file
    * ---------------------------------
    local filename = `"`root'Index.txt"'
    tempname WB
    cap file open `WB' using `"`filename'"' , read
    if _rc ! = 0 {
        di as err `"Error reading the index file `filename'"'
        exit
    }
    file read `WB' line
    local tab = char(9)
    tokenize "`line'" , parse(" `tab'")
    local var "`1'"
    local n = `5' - `3' + 1
    local npar = 1
    while r(eof) == 0 {
        file read `WB' line
        local npar = `npar' + 1
        tokenize "`line'" , parse(" `tab'")
        if "`1'" ~= "" {
            local var "`var' `1'"
        }
    }
    file close `WB'
    tokenize "`var'"
    local i = 1
    local cvar ""
    while "``i''" ~= "" {
        local pvar = subinstr("``i''" , "[" , "_" , .)
        local pvar = subinstr("`pvar'" , "." , "_" , .)
        local pvar = subinstr("`pvar'" , "]" , "" , .)
        local pvar = subinstr("`pvar'" , "," , "_" , .)
        local cvar "`cvar' `pvar'"
        local i = `i' + 1
    }
    local var "`cvar'"
    local len = length("`var'")
    local npar = `i'-1
    if "`keep'" ~= "" {
        local kstr ""
        foreach v of newlist `keep' {
            local kstr "`kstr' `v'"
        }
    }
    * ---------------------------------
    * read the data file
    * ---------------------------------
    if "`multichain'" == "" {
        * ---------------------------------
        * single chain
        * ---------------------------------
        local filename = `"`root'`chains'.txt"'
        cap infile var1 var2 using `"`filename'"' , clear
        if _rc ! = 0 {
            di as err `"Error reading the data file `filename'"'
            exit
        }
        if `thin' > 1 {
            qui keep if mod(var1,`thin') == 1
            qui sum var1, meanonly
            local n = 1 + (r(max)-r(min))/`thin'
        }
        if "`keep'" ~= "" {
            local is = 1
            local ie = `n'
            local var ""
            foreach v of local cvar {
                local drop = 1
                foreach k of local kstr {
                    if "`k'"== "`v'" {
                        local drop = 0
                    }
                }
                if `drop' == 1 {
                    qui drop in `is'/`ie'
                }
                else {
                    local is = `is'+`n'
                    local ie = `ie'+`n'
                    local var "`var' `v'"
                }
            }
        }
        
        if "`noreshape'" == "" {
            qui wbreshape , p(`var') n(`n')
        }
        else {
            qui egen var3 = seq(), b(`n')
        }
    }
    else {
        * ---------------------------------
        * multiple chains
        * ---------------------------------
        if "`id'" == "" {
            local id "chain"
        }
        tempfile store
        forvalues c = 1 / `chains' {
            local filename = `"`root'`c'.txt"'
            cap infile var1 var2 using `"`filename'"' , clear
            if _rc ! = 0 {
                di as err `"Error reading the data file `filename'"'
                exit
            }
            if `thin' > 1 {
                qui keep if mod(var1,`thin') == 1
                qui sum var1, meanonly
                local n = 1 + (r(max)-r(min))/`thin'
            }
            if "`keep'" ~= "" {
                local is = 1
                local ie = `n'
                local var ""
                foreach v of local cvar {
                    local drop = 1
                    foreach k of local kstr {
                        if "`k'"== "`v'" {
                            local drop = 0
                        }
                    }
                    if `drop' == 1 {
                        qui drop in `is'/`ie'
                    }
                    else {
                        local is = `is'+`n'
                        local ie = `ie'+`n'
                        local var "`var' `v'"
                    }
                }
            }
            if "`noreshape'" == "" {
                qui wbreshape , p(`var') n(`n')
            }
            else {
                qui egen var3 = seq(), b(`n')
            }
            if `c' == 1 {
                gen `id' = 1
                qui save `store'
            }
            else {
                gen `id' = `c'
                append using `store'
                qui save `store' , replace
            }
        }
        use `store' , clear
        order `id' order
        sort `id' order
    }
    if "`noreshape'" ~= "" {
        rename var1 order
        rename var2 value
        rename var3 parameter
        local i = 1
        cap label drop pLab
        foreach v of local var {
            label define pLab `i' "`v'" , modify
            local i = `i' + 1
        }
        label values parameter pLab
    }
end

program wbreshape
    syntax , n(integer) Parameters(string)
    version 8.2
    tempvar par
    egen `par' = seq() , block(`n')
    reshape wide var2 , i(var1) j(`par')
    tokenize "`parameters'"
    local i = 1
    while "``i''" ~= "" {
        rename var2`i' ``i''
        label var ``i'' ``i''
        local i = `i' + 1
    }
    rename var1 order
end

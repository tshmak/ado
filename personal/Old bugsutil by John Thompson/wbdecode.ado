*! 1.0.0, John Thompson, 6 May 2006
program wbdecode
    syntax , Filename(string) clear [array]
    version 8.2
    
    clear
    tempname RF
    file open `RF' using `"`filename'"' , read
    * ---------------------------------
    * read a data array
    * ---------------------------------
    if "`array'" == "array" {
        local nv = 0
        file read `RF' line
        local tab = char(9)
        tokenize "`line'" , parse(" []`tab'")
        local i = 1
        while "``i''" ~= "" {
            if "``i''" ~= "[" & "``i''" ~= "]" {
                local nv = `nv' + 1
                local var`nv' = "``i''"
            }
            local i = `i' + 1
        }
        local n = 0
        local e = 0
        while r(eof) == 0 & `e' == 0 {
            file read `RF' line
            local e = index("`line'" , "END")
            if `e' == 0 {
                local n = `n' + 1
            }
        }
        qui set obs `n'
        forvalues i = 1 / `nv' {
            qui gen `var`i'' = .
        }
        file close `RF'
        tempname RF2
        file open `RF2' using `"`filename'"' , read
        file read `RF2' line
        forvalues i = 1 / `n' {
            file read `RF2' line
            tokenize "`line'" , parse(" `tab'")
            forvalues j = 1 / `nv' {
                if "``j''" ! = "NA" {
                    qui replace `var`j'' = ``j'' in `i'
                }
            }
        }
        file close `RF2'
    }
    else {
        * ---------------------------------
        * read a list structure
        * ---------------------------------
        
        * ---------------------------------
        * Find structure names & sizes
        * ---------------------------------
        local nv = 0
        file read `RF' line
        local tab = char(9)
        tokenize "`line'" , parse(" ,()=`tab'")
        local comma = 0
        
        while r(eof) == 0 {
            tokenize "`line'" , parse(" ,()=`tab'")
            local i = 1
            while "``i''" ~= "" {
                if "``i''" == "," {
                    local comma = `comma' + 1
                }
                else if "``i''" == "=" {
                    local j = `i' - 1
                    if "``j''" == ".Dim" {
                        local j = `i' + 3
                        local row`nv' = "``j''"
                        local j = `i' + 5
                        local col`nv' = "``j''"
                    }
                    else if "``j''" ~= ".Data" & "``j''" ~= ".Dim" {
                        local com`nv' = `comma'
                        local comma = 0
                        local nv = `nv' + 1
                        local varname`nv' = "``j''"
                        local j = `i' + 1
                        if "``j''" == "c" {
                            local type`nv' = "list"
                            local row`nv' = .
                            local col`nv' = 1
                        }
                        else if "``j''" == "structure" {
                            local type`nv' = "structure"
                            local row`nv' = .
                            local col`nv' = .
                        }
                        else {
                            local type`nv' = "constant"
                            local row`nv' = 1
                            local col`nv' = 1
                        }
                    }
                }
                local i = `i' + 1
            }
            file read `RF' line
        }
        local com`nv' = `comma' + 1
        file close `RF'
        
        * ---------------------------------
        * create the variables
        * ---------------------------------
        local maxrow = 0
        forvalues i = 1 / `nv' {
            if `row`i'' == . {
                local row`i' = `com`i''
            }
            local n`i' = `row`i'' * `col`i''
            if `row`i'' > `maxrow' {
                local maxrow = `row`i''
            }
        }
        
        clear
        qui set obs `maxrow'
        forvalues i = 1 / `nv' {
            if "`type`i''" == "list" {
                qui gen `varname`i'' = .
            }
            else if "`type`i''" == "structure" {
                forvalues j = 1 / `col`i'' {
                    qui gen `varname`i''_`j' = .
                }
            }
            else if "`type`i''" == "constant" {
                scalar `varname`i'' = .
            }
        }
        * ---------------------------------
        * read the data
        * ---------------------------------
        file open `RF' using `"`filename'"' , read
        local nv = 0
        local fill = 0
        file read `RF' line
        while r(eof) == 0 {
            tokenize "`line'" , parse(" ,()=`tab'")
            local i = 1
            while "``i''" ~= "" {
                if "``i''" == "=" {
                    local j = `i' - 1
                    if "``j''" ~= ".Data" & "``j''" ~= ".Dim" {
                        local nv = `nv' + 1
                        if "`type`nv''" == "constant" {
                            local j = `i' + 1
                            scalar `varname`nv'' = real("``j''")
                        }
                        if "`type`nv''" == "list" {
                            local row = 1
                            local fill = 1
                        }
                        if "`type`nv''" == "structure" {
                            local row = 1
                            local col = 1
                            local fill = 1
                        }
                    }
                }
                if "``i''" == ")" {
                    local fill = 0
                }
                local y = real("``i''")
                if `fill' == 1 & ( "``i''" == "NA" | `y' ~= . ) {
                    if "`type`nv''" == "list" {
                        qui replace `varname`nv'' = `y' in `row'
                        local row = `row' + 1
                    }
                    if "`type`nv''" == "structure" {
                        qui replace `varname`nv''_`col' = `y' in `row'
                        local col = `col' + 1
                        if `col' > `col`nv'' {
                            local row = `row' + 1
                            local col = 1
                        }
                    }
                }
                local i = `i' + 1
            }
            file read `RF' line
        }
        local com`nv' = `comma' + 1
        file close `RF'
    }
    
end

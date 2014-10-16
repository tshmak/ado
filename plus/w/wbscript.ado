*! 1.0.0, John Thompson, 6 May 2006
program wbscript
    syntax [ , Datafile(string) Initsfile(string) Codafile(string) ///
      Modelfile(string) SET(string) Thin(integer 1) ///
      DIC CHains(integer 1) Burnin(integer 0) Updates(integer 1000) Quit Saving(string) ///
      NOPrint Logfile(string) ]
    version 8.2
    
    local datafile = subinstr(`"`datafile'"',"\","/",.)
    local initsfile = subinstr(`"`initsfile'"',"\","/",.)
    local modelfile = subinstr(`"`modelfile'"',"\","/",.)
    local codafile = subinstr(`"`codafile'"',"\","/",.)
    local logfile = subinstr(`"`logfile'"',"\","/",.)
    local quote = char(39)
    if `chains' > 1 {
        tokenize "`initsfile'" , parse(".")
        local dummy "`1'#.`3'"
    }
    if "`noprint'" == "" {
        * ----------------------------------
        * write to screen
        * ----------------------------------
        di "display(`quote'log`quote')"
        di "check(`quote'`modelfile'`quote')"
        * ----------------------------------
        * several data files
        * ----------------------------------
        tokenize `"`datafile'"' , parse("+")
        local p = 1
        while `"``p''"' ~= "" {
            di "data(`quote'``p''`quote')"
            local p = `p' + 2
        }
        di "compile(`chains')"
        if `chains' > 1 {
            forvalues i = 1 / `chains' {
                local file = subinstr("`dummy'" , "#" , "`i'" , .)
                di "inits(`i',`quote'`file'`quote')"
            }
        }
        else {
            di "inits(1,`quote'`initsfile'`quote')"
        }
        di "gen.inits()"
        if `burnin' > 0 {
            di "update(`burnin')"
        }
        tokenize "`set'"
        local i = 1
        while "``i''" ~= "" {
            di "set(`quote'``i''`quote')"
            local i = `i' + 1
        }
        if `thin' > 1 {
            di "thin.samples(`thin')"
        }
        if "`dic'" ~= "" {
            di "dic.set()"
        }
        di "update(`updates')"
        if "`dic'" ~= "" {
            di "dic.stats()"
        }
        di "coda(*,`quote'`codafile'`quote')"
        if "`logfile'" ~= "" {
            di "save(`quote'`logfile'`quote')"
        }
        if "`quit'" ~= "" {
            di "quit()"
        }
    }
    * ----------------------------------
    * write to file if needed
    * ----------------------------------
    if `"`saving'"' ~= "" {
        tokenize `"`saving'"' , parse(",")
        local saving `"`1'"'
        local replace "`3'"
        tempname WB
        file open `WB' using `"`saving'"' , write `replace'
        
        file write `WB' "display(`quote'log`quote')" _n
        file write `WB' "check(`quote'`modelfile'`quote')" _n
        * ----------------------------------
        * several data files
        * ----------------------------------
        tokenize `"`datafile'"' , parse("+")
        local p = 1
        while `"``p''"' ~= "" {
            file write `WB' "data(`quote'``p''`quote')" _n
            local p = `p' + 2
        }
        file write `WB' "compile(`chains')" _n
        if `chains' > 1 {
            forvalues i = 1 / `chains' {
                local file = subinstr("`dummy'" , "#" , "`i'" , .)
                file write `WB' "inits(`i',`quote'`file'`quote')" _n
            }
        }
        else {
            file write `WB' "inits(1,`quote'`initsfile'`quote')" _n
        }
        file write `WB' "gen.inits()" _n
        if `burnin' > 0 {
            file write `WB' "update(`burnin')" _n
        }
        tokenize "`set'"
        local i = 1
        while "``i''" ~= "" {
            file write `WB' "set(`quote'``i''`quote')" _n
            local i = `i' + 1
        }
        if `thin' > 1 {
            file write `WB' "thin.samples(`thin')" _n
        }
        if "`dic'" ~= "" {
            file write `WB' "dic.set()" _n
        }
        file write `WB' "update(`updates')" _n
        if "`dic'" ~= "" {
            file write `WB' "dic.stats()" _n
        }
        file write `WB' "coda(*,`quote'`codafile'`quote')" _n
        if "`logfile'" ~= "" {
            file write `WB' "save(`quote'`logfile'`quote')" _n
        }
        if "`quit'" ~= "" {
            file write `WB' "quit()" _n
        }
        file close `WB'
    }
end

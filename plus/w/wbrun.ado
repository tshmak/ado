*! 1.0.0, John Thompson, 6 May 2006
program wbrun
    syntax , Script(string) Winbugs(string) [ Batch ]
    version 8.2
    
    local script = subinstr(`"`script'"',"\","/",.)
    
    if "`batch'" == "" {
        shell "`winbugs'" /PAR "`script'"
    }
    else {
        winexec "`winbugs'" /PAR "`script'"
    }
end

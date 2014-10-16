*! 1.0.0, John Thompson, 6 May 2006
program wbstats , rclass byable(recall)
    syntax varlist [if] [in] [ , Hpd Level(real 95) ]
    version 8.2
    marksample touse
    
    tempvar order
    tempname mV
    gen `order' = _n
    qui tsset `order'
    
    * --------------------------------
    * summarize each variable in turn
    * --------------------------------
    if "`hpd'" == "" {
        di %-12s "Parameter" %6s "n" %8s "mean" %8s "sd" %8s "se" %8s "median" %16s "`level'% CrI"
    }
    else {
        di %-12s "Parameter" %6s "n" %8s "mean" %8s "sd" %8s "se" %8s "median" %16s "`level'% HPD"
    }
    local lcen = (100-`level')/2
    local ucen = 100-`lcen'
    local i = 0
    foreach v of varlist `varlist' {
        qui summ `v' if `touse'
        local mn = r(mean)
        local sd = r(sd)
        local n = r(N)
        qui centile `v' if `touse'
        local md = r(c_1)
        if "`hpd'" == "" {
            qui centile `v' if `touse' , cen(`lcen')
            local lb = r(c_1)
            qui centile `v' if `touse' , cen(`ucen')
            local ub = r(c_1)
        }
        else {
            wbhpd `v' if `touse' , alpha(`level')
            local lb = r(low)
            local ub = r(high)
        }
        qui prais `v' if `touse'
        matrix `mV' = e(V)
        local se = sqrt(`mV'[1 , 1])
        di %-12s "`v'" %6.0f `n' %8.3f `mn' %8.3f `sd' %8.4f `se' %8.3f `md' " (" %8.3f `lb' "," %8.3f `ub' " )"
        local i = `i' + 1
        return local par`i' "`v'"
        return scalar n`i' = `n'
        return scalar mn`i' = `mn'
        return scalar sd`i' = `sd'
        return scalar se`i' = `se'
        return scalar md`i' = `md'
        return scalar lb`i' = `lb'
        return scalar ub`i' = `ub'
    }
end

program wbhpd , rclass
    syntax varlist (max = 1 min = 1) [if] [in] [ , alpha(real 95.0) ]
    version 8.2
    
    quietly {
        marksample touse
        local theta = "`varlist'"
        
        * --------------------------------
        * Initial values based on credible interval
        * --------------------------------
        local a = 100 - `alpha'
        local a1 = `a' / 2
        centile `theta' if `touse' , centile(`a1' 50 )
        local theta1 = r(c_1)
        local thetam = r(c_2)
        
        * --------------------------------
        * smoothed density of theta in (x,f)
        * --------------------------------
        
        preserve
        tempvar x f cf tmp
        local n = 1000
        if `n' > _N {
            set obs `n'
        }
        kdensity `theta' if `touse' , gen(`x' `f') nograph n(`n')
        gen `cf' = sum(`f')
        su `cf'
        replace `cf' = `cf' / r(max)
        su `x'
        local step = (r(max)-r(min)) / 200
        
        * --------------------------------
        * Iterate
        * --------------------------------
        
        local xlow = `theta1'
        gen `tmp' = .
        local done = 0
        while `done' == 0 & `step' > 0.0001 {
            * area to left of xlow
            wbinterp `x' `cf' if `touse' , value(`xlow')
            local a1 = r(fvalue)
            * xhigh corresponding to xlow
            wbinterp `x' `f' if `touse' & `x' < `thetam' , value(`xlow')
            local fx = r(fvalue)
            wbinterp `f' `x' if `touse' & `x' > `thetam' , value(`fx') down
            local xhigh = r(fvalue)
            * area to right of xlow
            wbinterp `x' `cf' if `touse' , value(`xhigh')
            local a2 = 1 - r(fvalue)
            local asum = (`a1' + `a2') * 100
            if abs(`asum'-`a') < 0.001 {
                local done = 1
            }
            else if `asum' > `a' {
                local xlow = `xlow' - `step'
            }
            else {
                local xlow = `xlow' + `step'
            }
            local step = `step' * 0.9
        }
        restore
        return scalar low = `xlow'
        return scalar high = `xhigh'
        return scalar larea = `a1' * 100
        return scalar rarea = `a2' * 100
    }
end

program wbinterp , rclass
    syntax varlist (min = 2 max = 2) [if] , value(real) [ down ]
    version 8.2
    marksample touse
    tokenize "`varlist'"
    
    local x = "`1'"
    local f = "`2'"
    tempvar p
    gen `p' = _n
    if "`down'" == "" {
        su `p' if `x' < `value' & `touse'
    }
    else {
        su `p' if `x' > `value' & `touse'
    }
    local p1 = r(max)
    local x1 = `x'[`p1']
    local f1 = `f'[`p1']
    local p1 = `p1' + 1
    local x2 = `x'[`p1']
    local f2 = `f'[`p1']
    return scalar fvalue = `f1' + (`value'-`x1') * (`f2'-`f1') / (`x2'-`x1')
end

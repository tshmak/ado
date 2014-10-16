*! 1.0.0, John Thompson, 6 May 2006
program wbgeweke, rclass byable(recall)
    syntax varlist [if] [in] , [ Percentages(string) ]
    version 8.2
    marksample touse , novarlist
    
    preserve
    qui keep if `touse'
    local np = 0
    foreach v of varlist `varlist' {
        local np = `np' + 1
    }
    if "`percentages'" == "" {
        local p1 = 10
        local p2 = 50
    }
    else {
        tokenize "`percentages'"
        local p1 "`1'"
        local p2 "`2'"
    }
    cap qui tsset
    local oldt = r(timevar)
    tempvar t end
    gen `t' = _n
    local limit1 = _N*`p1'/100
    local limit2 = _N-_N*`p2'/100
    gen `end' = `t' > `limit2'
    tempname b vb
    qui tsset `t'
    local i = 0
    foreach v of varlist `varlist' {
        local i = `i'+1
        qui count if `t' <= `limit1'
        local n1 = r(N)
        qui prais `v' if `t' <= `limit1'
        matrix `b' = e(b)
        matrix `vb' = e(V)
        local m1 = `b'[1,1]
        local s1 = sqrt(`vb'[1,1])
        local rho1 = e(rho)
        qui count if `t' > `limit2'
        local n2 = r(N)
        qui prais `v' if `t' > `limit2'
        matrix `b' = e(b)
        matrix `vb' = e(V)
        local rho2 = e(rho)
        local m2 = `b'[1,1]
        local s2 = sqrt(`vb'[1,1])
        di _newline "Parameter: `v' first " %4.1f `p1' "% (n=`n1') vs last " %4.1f `p2' "% (n=`n2')"
        di "Means (se) " %10.4f `m1' " (" %10.4f `s1' ")" %10.4f `m2' " (" %10.4f `s2' ")"
        di "Autocorrelations " %7.4f `rho1' %9.4f `rho2'
        local z = abs(`m2'-`m1')/sqrt(`s1'^2+`s2'^2)
        local p = 2*(1-norm(`z'))
        di "Mean Difference (se)" %10.4f `m2'-`m1' " (" %10.4f sqrt(`s1'^2+`s2'^2) ")" ///
          " z =" %7.3f `z' " p = " %7.4f `p'
        return scalar m1_`i' = `m1'
        return scalar m2_`i' = `m2'
        return scalar se1_`i' = `s1'
        return scalar se2_`i' = `s2'
        return scalar z_`i' = `z'
        return scalar p_`i' = `p'
    }
    restore
    cap qui tsset `oldt'
end

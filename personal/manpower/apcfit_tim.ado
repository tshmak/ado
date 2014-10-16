/*define program name*/
capture program drop apcfit_tim
program define apcfit_tim, rclass
// Altering SSC's apcfit, to include additional options (*) passed to glm

/*set the syntax for the program*/ 
syntax [varlist(default=none)] [if] [in], Age(varname) ///
Cases(varname) POPrisktime(varname) ///
[Period(varname) AGEFitted(string) PERFitted(string) COHFitted(string) ///
REFCoh(real 0) DRExtr(string) REFPer(real 0) COHort(varname) ///
PARam(string) LEVel(int 95) DFA(int 5) DFP(int 5) DFC(int 5) NPER(int 1) ///
BKNOTSA(numlist max=2 min=2) BKNOTSP(numlist max=2 min=2) BKNOTSC(numlist max=2 min=2) ///
KNOTSA(numlist ascending) KNOTSP(numlist ascending) KNOTSC(numlist ascending) ///
RMATRIXA(name) RMATRIXP(name) RMATRIXC(name) ///
KNOTPLacement(string) ADJust LINK(string) ITERate(int 16000) replace * ]

marksample touse


capture drop _sp* 
capture drop _drift


/*replace option for the fitted value variables. */
if "`param'"!="AC" & "`param'"!="AP" {
if "`replace'"!="" {
capture drop agefitted agefitted_lci agefitted_uci ///
perfitted perfitted_lci perfitted_uci cohfitted ///
cohfitted_lci cohfitted_uci
		if _rc==111 {
			display as error "The replace option is specified but some or all of the variables to be replaced cannot be found."
			exit 198
		}
}
}

if "`param'"=="AC" {
if "`replace'"!="" {
capture drop agefitted agefitted_lci agefitted_uci ///
 cohfitted cohfitted_lci cohfitted_uci
		if _rc==111 {
			display as error "The replace option is specified but some or all of the variables to be replaced cannot be found."
			exit 198
		}
}
}

if "`param'"!=="AP" {
if "`replace'"!="" {
capture drop agefitted agefitted_lci agefitted_uci ///
perfitted perfitted_lci perfitted_uci 
		if _rc==111 {
			display as error "The replace option is specified but some or all of the variables to be replaced cannot be found."
			exit 198
		}
}
}

/*Checks correct variables are specified */
if "`param'"!="AC" & "`period'"=="" {
di as error "Period must be specified for all parameterisations except for AC"
exit 198
}

if "`param'"=="AC" & "`cohort'"=="" {
di as error "Cohort must be specified for the AC parameterisation"
exit 198
}

/*Checks that df and knots aren't both specified*/
 
if "`dfa'"!="5" & "`knotsa'"!="" {
di as error "Degrees of freedom option and knots option for Age cannot be specified simultaneously"
exit 198
}

if "`dfp'"!="5" & "`knotsp'"!="" {
di as error "Degrees of freedom option and knots option for Period cannot be specified simultaneously"
exit 198
}

if "`dfc'"!="5" & "`knotsc'"!="" {
di as error "Degrees of freedom option and knots option for Cohort cannot be specified simultaneously"
exit 198
}



/*Set local macros to make code simpler*/
local A "`age'" 
local D "`cases'"
local Y "`poprisktime'"

if "`param'"!="AC" {
local P "`period'"
}

/*if statements to deal with the case when cohort is/isn't defined */
if "`cohort'"!="" {
     local C "`cohort'"
}

if "`cohort'"=="" & "`param'"!="AP" {
     tempvar C
  quietly   gen `C'=`P'-`A'
}

/*Check if rcsgen is installed or not*/
capture: which rcsgen
if _rc==111 {
          display as error "rcsgen must be installed in order to run apcfit. This can be installed by typing: ssc install rcsgen, in the command window."
          exit 198
 }

if "`agefitted'"=="" {
      local agefitted "agefitted"
}

if "`perfitted'"=="" & "`param'"!="AC" {
      local perfitted "perfitted"
}

if "`cohfitted'"=="" & "`param'"!="AP" {
      local cohfitted "cohfitted"
}


/*Check if agefitted already defined*/
capture: su `agefitted'
if _rc== 0 {
          display as error "The variable being used for the fitted age values is already defined. Either drop the variable, use the replace option, or use the agefitted option to define a different name for the fitted values."
          exit 198
 }

capture: su `agefitted'_lci
if _rc== 0 {
          display as error "The variable being used for the fitted age values LCI is already defined. Either drop the variable, use the replace option, or use the agefitted option to define a different name for the fitted values."
          exit 198
 }

capture: su `agefitted'_uci
if _rc== 0 {
          display as error "The variable being used for the fitted age values UCI is already defined. Either drop the variable, use the replace option, or use the agefitted option to define a different name for the fitted values."
          exit 198
 }

if "`param'"!="AC" {
capture: su `perfitted'
if _rc== 0 {
          display as error "The variable being used for the fitted period values is already defined. Either drop the variable, or use the perfitted option to define a different name for the fitted values."
          exit 198
 }

capture: su `perfitted'_lci
if _rc== 0 {
          display as error "The variable being used for the fitted period values LCI is already defined. Either drop the variable, or use the perfitted option to define a different name for the fitted values."
          exit 198
 }

capture: su `perfitted'_uci
if _rc== 0 {
          display as error "The variable being used for the fitted period values UCI is already defined. Either drop the variable, or use the perfitted option to define a different name for the fitted values."
          exit 198
 }

}

if "`param'"!="AP" {
capture: su `cohfitted'
if _rc== 0 {
          display as error "The variable being used for the fitted cohort values is already defined. Either drop the variable, or use the cohfitted option to define a different name for the fitted values."
          exit 198
 }

capture: su `cohfitted'_lci
if _rc== 0 {
          display as error "The variable being used for the fitted cohort values LCI is already defined. Either drop the variable, or use the cohfitted option to define a different name for the fitted values."
          exit 198
 }

capture: su `cohfitted'_uci
if _rc== 0 {
          display as error "The variable being used for the fitted cohort values UCI is already defined. Either drop the variable, or use the cohfitted option to define a different name for the fitted values."
          exit 198
 }
}

/*Method for extracting the median references if refp and refc are not defined*/

if "`param'"!="AC" {
	quietly summarize `P' [aweight=`D'] if `touse',d 
	quietly gen refdefp0=r(p50) if _n==1
}

if "`param'"!="AP" {
	quietly summarize `C' [aweight=`D'] if `touse',d
	quietly gen refdefc0=r(p50) if _n==1
}

if "`param'"!="AP" {
scalar define defc0=refdefc0
drop refdefc0
}

if "`param'"!="AC" {
scalar define defp0=refdefp0
drop refdefp0
}


/*Sets the median references as default if the user does not specify references*/
if "`refcoh'"=="0" & "`param'"!="AP" {
      local c0=defc0
}

if "`refper'"=="0" & "`param'"!="AC" {
      local p0=defp0
} 

/*Sets the references as those defined by the user if they choose to define them*/
if "`refcoh'"!="0" {
      local c0 "`refcoh'"
}

if "`refper'"!="0" {
      local p0 "`refper'"
}


/*Sets the default drift extraction to be weighted*/
if "`drextr'"=="" {
      local drextr "weighted"
}

/*Displays an error if drextr is incorrectly specified*/
if "`drextr'"!="" & "`drextr'"!="weighted" & "`drextr'"!="holford" {
      display as error "if drextr is specified it must be specified as weighted or holford"
exit
}

/*Sets ACP as the default parameterisation*/
if "`param'"=="" {
     local param "ACP"
}

/*Displays an error if param is incorrectly specified*/
if "`param'"!="" & "`param'"!="ACP" & "`param'"!="APC" & "`param'"!="AdCP" & "`param'"!="AdPC" & "`param'"!="AP" & "`param'"!="AC" {
     display as error "if param is specified it must be specified as one of the given options"
     exit 198
}

/*Sets equal as the default parameterisation*/
if "`knotplacement'"=="" {
     local knotplacement "equal"
}

/*Displays an error if knotplacement is incorrectly specified*/
if "`knotplacement'"!="" & "`knotplacement'"!="equal" & "`knotplacement'"!="weighted" {
     display as error "if knotplacement is specified it must be specified as one of the given options"
     exit 198
}

if "`adjust'"!="" & "`param'"=="AP"  {
 	display as error "Adjust should not be specified with the AP or AC parameterisations"
	exit 198
}

if "`adjust'"!="" & "`param'"=="AC"  {
 	display as error "Adjust should not be specified with the AP or AC parameterisations"
	exit 198
}

/*Checks and sets the default link function*/

if "`link'"!="" & "`link'"!="log" & "`link'"!="power5" {
     display as error "if link is specified it must be specified as one of the given options"
     exit 198
}

if "`link'"=="" {
     local link "log"
}


/*Preserves the dataset whilst the MAs matrix is created in Mata*/
preserve
    quietly keep if `touse'
    gen colA0=1
	
	if "`rmatrixa'"!="" {
	if "`knotsa'"!="" {
		local nk : word count `knotsa' 
		local dfa = `nk' - 1
		
				if "`knotplacement'"=="equal" {
						 quietly rcsgen `A', gen(colA) rmatrix(`rmatrixa') knots(`knotsa') bknots(`bknotsa')
					}
				if "`knotplacement'"=="weighted" { 
							quietly rcsgen `A', gen(colA) rmatrix(`rmatrixa') knots(`knotsa') bknots(`bknotsa') fw(`D')
				   
					}
	}
	
	else {
    if "`knotplacement'"=="equal" {
   		 quietly rcsgen `A', gen(colA) rmatrix(`rmatrixa') df(`dfa') bknots(`bknotsa')
    }
    if "`knotplacement'"=="weighted" { 
    		quietly rcsgen `A', gen(colA) rmatrix(`rmatrixa') df(`dfa') bknots(`bknotsa') fw(`D')
    }
	}
	} 
	
	else {
    if "`knotsa'"!="" {
		local nk : word count `knotsa' 
		local dfa = `nk' - 1
		
				if "`knotplacement'"=="equal" {
						 quietly rcsgen `A', gen(colA) orthog knots(`knotsa') bknots(`bknotsa')
					}
				if "`knotplacement'"=="weighted" { 
							quietly rcsgen `A', gen(colA) orthog knots(`knotsa') bknots(`bknotsa') fw(`D')
				   
					}
	}
	
	else {
    if "`knotplacement'"=="equal" {
   		 quietly rcsgen `A', gen(colA) orthog df(`dfa') bknots(`bknotsa')
    }
    if "`knotplacement'"=="weighted" { 
    		quietly rcsgen `A', gen(colA) orthog df(`dfa') bknots(`bknotsa') fw(`D')
    }
	}
	}
	
    local aknots `r(knots)'
    matrix RmatA=r(R)
	return matrix RmatA=RmatA, copy
    mata: RmatA=st_matrix("r(R)")
    keep colA*
    mata: MAs=st_data(.,(.))
restore
preserve
    quietly keep if `touse'
    keep `A'
    mata: tA=st_data(.,("`A'"))
restore
preserve
   quietly keep if `touse' 
   keep `D'
   mata: DA=st_data(.,("`D'"))
restore

if "`param'"!="AC" {

/*Preserves the dataset whilst the MPs matrix is created in Mata*/
preserve
    quietly keep if `touse'
	if "`rmatrixp'"!="" {
		if "`knotsp'"!="" {
	local nk : word count `knotsp' 
	local dfp = `nk' - 1
	
    if "`knotplacement'"=="equal" {
   		 quietly rcsgen `P', gen(colP) rmatrix(`rmatrixp') knots(`knotsp') bknots(`bknotsp')
    }
    if "`knotplacement'"=="weighted" { 
    		quietly rcsgen `P', gen(colP) rmatrix(`rmatrixp') knots(`knotsp') bknots(`bknotsp') fw(`D')
    }
	}
	
	else {
    if "`knotplacement'"=="equal" {
   		 quietly rcsgen `P', gen(colP) rmatrix(`rmatrixp') df(`dfp') bknots(`bknotsp')
    }
    if "`knotplacement'"=="weighted" { 
    		quietly rcsgen `P', gen(colP) rmatrix(`rmatrixp') df(`dfp') bknots(`bknotsp') fw(`D')
    }
	} 
	}
	
	else {
	if "`knotsp'"!="" {
	local nk : word count `knotsp' 
	local dfp = `nk' - 1
	
    if "`knotplacement'"=="equal" {
   		 quietly rcsgen `P', gen(colP) orthog knots(`knotsp') bknots(`bknotsp')
    }
    if "`knotplacement'"=="weighted" { 
    		quietly rcsgen `P', gen(colP) orthog knots(`knotsp') bknots(`bknotsp') fw(`D')
    }
	}
	
	else {
    if "`knotplacement'"=="equal" {
   		 quietly rcsgen `P', gen(colP) orthog df(`dfp') bknots(`bknotsp')
    }
    if "`knotplacement'"=="weighted" { 
    		quietly rcsgen `P', gen(colP) orthog df(`dfp') bknots(`bknotsp') fw(`D')
    }
	} 
	} 

	if "`rmatrixp'"!="" {
    local pknots `r(knots)'
    matrix RmatP=`rmatrixp'
	return matrix RmatP=RmatP, copy
	}
	else {
	local pknots `r(knots)'
    matrix RmatP=r(R)
	return matrix RmatP=RmatP, copy
	}

    mata: RmatP=st_matrix("r(R)")
   keep colP*
   mata: MPs=st_data(.,(.))
restore
preserve
   quietly keep if `touse' 
   keep `P'
   mata: tP=st_data(.,("`P'"))
restore
preserve
   quietly keep if `touse' 
   keep `D'
   mata: DP=st_data(.,("`D'"))
restore
}


if "`param'"!="AP" {

/*Preserves the dataset whilst the MCs matrix is created in Mata*/
preserve
    quietly keep if `touse' 
	
	if "`rmatrixc'"!="" {
	if "`knotsc'"!="" {
	local nk : word count `knotsc' 
	local dfc = `nk' - 1
	if "`knotplacement'"=="equal" {
   		 quietly rcsgen `C', gen(colC) rmatrix(`rmatrixc') knots(`knotsc') bknots(`bknotsc')
    }
    if "`knotplacement'"=="weighted" { 
    		quietly rcsgen `C', gen(colC) rmatrix(`rmatrixc') knots(`knotsc') bknots(`bknotsc') fw(`D')
    }
	}
	else {
    if "`knotplacement'"=="equal" {
   		 quietly rcsgen `C', gen(colC) rmatrix(`rmatrixc') df(`dfc') bknots(`bknotsc')
    }
    if "`knotplacement'"=="weighted" { 
    		quietly rcsgen `C', gen(colC) rmatrix(`rmatrixc') df(`dfc') bknots(`bknotsc') fw(`D')
    }
	}
	}
	
	
	else {
if "`knotsc'"!="" {
	local nk : word count `knotsc' 
	local dfc = `nk' - 1
	if "`knotplacement'"=="equal" {
   		 quietly rcsgen `C', gen(colC) orthog knots(`knotsc') bknots(`bknotsc')
    }
    if "`knotplacement'"=="weighted" { 
    		quietly rcsgen `C', gen(colC) orthog knots(`knotsc') bknots(`bknotsc') fw(`D')
    }
	}
	else {
    if "`knotplacement'"=="equal" {
   		 quietly rcsgen `C', gen(colC) orthog df(`dfc') bknots(`bknotsc')
    }
    if "`knotplacement'"=="weighted" { 
    		quietly rcsgen `C', gen(colC) orthog df(`dfc') bknots(`bknotsc') fw(`D')
    }
	}
	}
	
	if "`rmatrixc'"!="" {
    local cknots `r(knots)'
    matrix RmatC=`rmatrixc'
	return matrix RmatC=RmatC, copy
	}
	else {
	local cknots `r(knots)'
    matrix RmatC=r(R)
	return matrix RmatC=RmatC, copy
	}

    mata: RmatC=st_matrix("r(R)")
    keep colC*
    mata: MCs=st_data(.,(.))
restore
preserve
   quietly keep if `touse' 
   keep `C'
   mata: tC=st_data(.,("`C'"))
restore
preserve
   quietly keep if `touse' 
   keep `D'
   mata: DC=st_data(.,("`D'"))
restore
}



if "`param'"=="AP" {
tempvar p0col
tempvar dfAcol
tempvar dfPcol
quietly gen `p0col'=`p0' 
quietly gen `dfAcol'=`dfa'  
quietly gen `dfPcol'=`dfp' 

mata: dfa=st_data(1,"`dfAcol'")
mata: dfp=st_data(1,"`dfPcol'")
mata: p0=st_data(1,"`p0col'")




	preserve
	   quietly keep if `touse'
	   quietly rcsgen `p0col', gen(colp0) rmatrix(RmatP) knots(`pknots')
	   keep colp0*
	   mata: RP=st_data(.,(.))
	   mata: RP=RP[1,.]
	restore



mata: P0=progP0matrix(RP,MPs)
mata: MPs0=MPs-P0

/*Generates the correct number of empty Stata variables for the Age coeffs*/
local x=1
while `x'<=`dfa'+1 {
   quietly gen _spA`x'=. 
   local x=`x'+1
}


   local y=1
   while `y'<=`dfp' {
     quietly gen _spP`y'=. 
     local y=`y'+1
}


order _spP*
mata: usedrows=rows(MPs0)

mata: for (j=1;j<=dfp; j++)  st_store(.,(j),"`touse'",MPs0[.,j])

/*Orders the variables to allow easier storage of the columns from Mata*/
order _spA*
/*Stores the results in Stata from Mata*/
mata: for (i=1; i<=dfa+1; i++) st_store(.,(i),"`touse'",MAs[.,i])



/*Generates variables showing the unique groups for the variables*/
tempvar grA
tempvar grP
quietly egen `grA'=group(`A') if `touse'
quietly egen `grP'=group(`P') if `touse'


/*Generates a variable that is 1s and 0s that tag the first element of the unique groups*/
tempvar tagA
tempvar tagP
quietly egen `tagA'=tag(`A') if `touse'
quietly egen `tagP'=tag(`P') if `touse'

 
/*Generates an id variable*/
tempvar _id
quietly egen `_id'=seq() if `touse'

/*Generates a variable that shows the value and position of the unique values of the variables*/
tempvar Apos
tempvar Ppos
quietly gen `Apos'=`tagA'*`grA' if `touse'
quietly gen `Ppos'=`tagP'*`grP' if `touse'


/*Replaces the 0s as missing*/
quietly replace `Apos'=. if `Apos'==0
quietly replace `Ppos'=. if `Ppos'==0

/*Generates unique values of the variables and their position in the matrices*/
tempvar Aposact
quietly gen `Aposact'=`_id' if `Apos'!=.
quietly ta `A' if `touse', matrow(uniqueA)
mata: uniqueA=st_matrix("uniqueA")
mata: rowsUA=rows(uniqueA)
mata: Apos=st_data(.,"`Aposact'")
mata: Apos=editvalue(Apos,.,0)
mata: Apos=select(Apos, Apos[.,1]:>0)


/*Generates unique values of the variables and their position in the matrices*/
tempvar Pposact
quietly gen `Pposact'=`_id' if `Ppos'!=.
quietly ta `P' if `touse', matrow(uniqueP)

mata: uniqueP=st_matrix("uniqueP")
mata: rowsUP=rows(uniqueP)
mata: Ppos=st_data(.,"`Pposact'")
mata: Ppos=editvalue(Ppos,.,0)
mata: Ppos=select(Ppos, Ppos[.,1]:>0)

rename _spA1 _spA1_intct


if "`link'"!="power5" {
if "`iterate'"=="16000" {
glm `D' _sp* if `touse', lnoffset(`Y') f(p) nocons `options'
}
else {
glm `D' _sp* if `touse', lnoffset(`Y') f(p) nocons itetate(`iterate') `options'
}
}
if "`link'"=="power5" {
if "`iterate'"=="16000" {
glm `D' _sp* if `touse', f(p) nocons link(power5 `Y') `options'
}
else {
glm `D' _sp* if `touse', f(p) nocons link(power5 `Y') iterate(`iterate') `options'

}
}

rename _spA1_intct _spA1


   mata: coeffs=st_matrix("e(b)")
   mata: betaA=coeffs'[(1..dfa+1),.]
   mata: betaP=coeffs'[(dfa+2..(dfa+dfp+1)),.]



   mata: varcov=st_matrix("e(V)")
   mata: varcovA=varcov[(1..dfa+1),(1..dfa+1)]
   mata: varcovP=varcov[(dfa+2..(dfa+dfp+1)),(dfa+2..(dfa+dfp+1))]



   mata: cutdownA=MAs[Apos,.]
   mata: cutdownP=MPs0[Ppos,.]



/*Creates matrices containing the fitted values*/
mata: answerA=exp(cutdownA*betaA)
mata: answerP=exp(cutdownP*betaP)

/*Creates matrices containing the fitted cov/vars*/
mata: varianceA=cutdownA*varcovA*transposeonly(cutdownA)
mata: varianceP=cutdownP*varcovP*transposeonly(cutdownP)

/*Creates matrices containing just the vars*/
mata: varianceA=diagonal(varianceA)
mata: varianceP=diagonal(varianceP)



/*Generates the appropriate z value for the normal distribution for the CIs*/
local alpha2 = (100-`level')/200
local zalpha2 = -invnorm(`alpha2')


/*Calculates the 95% (or user defined level) CIs*/
mata: UCIA=exp(ln(answerA)+`zalpha2':*sqrt(varianceA))
mata: LCIA=exp(ln(answerA)-`zalpha2':*sqrt(varianceA))

mata: UCIP=exp(ln(answerP)+`zalpha2':*sqrt(varianceP))
mata: LCIP=exp(ln(answerP)-`zalpha2':*sqrt(varianceP))



/*Generates the variables for the answers to store into*/
quietly gen `agefitted'=.
quietly gen `agefitted'_lci=.
quietly gen `agefitted'_uci=.
quietly gen `perfitted'=.
quietly gen `perfitted'_lci=.
quietly gen `perfitted'_uci=.




/*Stores the answers into Stata variables*/

quietly replace `Aposact'=0 if `Aposact'==.
mata: st_store(.,"`agefitted'","`Aposact'",answerA)
mata: st_store(.,"`agefitted'_lci","`Aposact'",LCIA)
mata: st_store(.,"`agefitted'_uci","`Aposact'",UCIA)



quietly replace `Pposact'=0 if `Pposact'==.
mata: st_store(.,"`perfitted'","`Pposact'",answerP)
mata: st_store(.,"`perfitted'_lci","`Pposact'",LCIP)
mata: st_store(.,"`perfitted'_uci","`Pposact'",UCIP)


quietly replace `agefitted'=`nper'*`agefitted'
quietly replace `agefitted'_lci=`nper'*`agefitted'_lci
quietly replace `agefitted'_uci=`nper'*`agefitted'_uci


scalar define la=`dfa'+1
local la=la


foreach r of numlist `dfp'/1 {
   move _spP`r' `perfitted'_uci
}

foreach t of numlist `la'/1 {
   move _spA`t' `perfitted'_uci
}



return local refper `p0'

return local knotsAge `aknots'
return local boundknotsAge `abknots'

return local knotsPer `pknots'
return local boundknotsPer `pbknots'

rename _spA1 _spA1_intct


}


if "`param'"=="AC" {
tempvar c0col
tempvar dfAcol
tempvar dfCcol
quietly gen `c0col'=`c0'
quietly gen `dfAcol'=`dfa'  
quietly gen `dfCcol'=`dfc' 

mata: dfa=st_data(1,"`dfAcol'")
mata: dfc=st_data(1,"`dfCcol'")
mata: c0=st_data(1,"`c0col'")


	preserve
	   quietly keep if `touse' 
	   quietly rcsgen `c0col', gen(colc0) rmatrix(RmatC) knots(`cknots')
	   keep colc0*
	   mata: RC=st_data(.,(.))
	   mata: RC=RC[1,.]
	restore


mata: C0=progC0matrix(RC,MCs)
mata: MCs0=MCs-C0

/*Generates the correct number of empty Stata variables for the Age coeffs*/
local x=1
while `x'<=`dfa'+1 {
   quietly gen _spA`x'=. 
   local x=`x'+1
}

   local z=1
   while `z'<=`dfc' {
     quietly gen _spC`z'=. 
     local z=`z'+1
}

order _spC*

mata: usedrows=rows(MCs0)

mata: for (j=1;j<=dfc; j++)  st_store(.,(j),"`touse'",MCs0[.,j])

/*Orders the variables to allow easier storage of the columns from Mata*/
order _spA*
/*Stores the results in Stata from Mata*/
mata: for (i=1; i<=dfa+1; i++) st_store(.,(i),"`touse'",MAs[.,i])




/*Generates variables showing the unique groups for the variables*/
tempvar grA
tempvar grC
quietly egen `grA'=group(`A') if `touse'
quietly egen `grC'=group(`C') if `touse'

/*Generates a variable that is 1s and 0s that tag the first element of the unique groups*/
tempvar tagA
tempvar tagC
quietly egen `tagA'=tag(`A') if `touse'
quietly egen `tagC'=tag(`C') if `touse'
 
/*Generates an id variable*/
tempvar _id
quietly egen `_id'=seq() if `touse'

/*Generates a variable that shows the value and position of the unique values of the variables*/
tempvar Apos
tempvar Cpos
quietly gen `Apos'=`tagA'*`grA' if `touse'
quietly gen `Cpos'=`tagC'*`grC' if `touse'

/*Replaces the 0s as missing*/
quietly replace `Apos'=. if `Apos'==0
quietly replace `Cpos'=. if `Cpos'==0


/*Generates unique values of the variables and their position in the matrices*/
tempvar Aposact
quietly gen `Aposact'=`_id' if `Apos'!=.
quietly ta `A' if `touse', matrow(uniqueA)
mata: uniqueA=st_matrix("uniqueA")
mata: rowsUA=rows(uniqueA)
mata: Apos=st_data(.,"`Aposact'")
mata: Apos=editvalue(Apos,.,0)
mata: Apos=select(Apos, Apos[.,1]:>0)


/*Generates unique values of the variables and their position in the matrices*/
tempvar Cposact
quietly gen `Cposact'=`_id' if `Cpos'!=.
quietly ta `C' if `touse', matrow(uniqueC)

mata: uniqueC=st_matrix("uniqueC")
mata: rowsUC=rows(uniqueC)
mata: Cpos=st_data(.,"`Cposact'")
mata: Cpos=editvalue(Cpos,.,0)
mata: Cpos=select(Cpos, Cpos[.,1]:>0)

rename _spA1 _spA1_intct

if "`link'"!="power5" {
if "`iterate'"=="16000" {
glm `D' _sp* if `touse', lnoffset(`Y') f(p) nocons `options'
}
else {
glm `D' _sp* if `touse', lnoffset(`Y') f(p) nocons iterate(`iterate') `options'
}
}
if "`link'"=="power5" {
if "`iterate'"=="16000" {
glm `D' _sp* if `touse', f(p) nocons link(power5 `Y') `options'
}
else {
glm `D' _sp* if `touse', f(p) nocons link(power5 `Y') iterate(`iterate') `options'
}
}


rename _spA1_intct _spA1



   mata: coeffs=st_matrix("e(b)")
   mata: betaA=coeffs'[(1..dfa+1),.]
   mata: betaC=coeffs'[(dfa+2..(dfa+dfc+1)),.]


   mata: varcov=st_matrix("e(V)")
   mata: varcovA=varcov[(1..dfa+1),(1..dfa+1)]
   mata: varcovC=varcov[(dfa+2..(dfa+dfc+1)),(dfa+2..(dfa+dfc+1))]



   mata: cutdownA=MAs[Apos,.]
   mata: cutdownC=MCs0[Cpos,.]


/*Creates matrices containing the fitted values*/
mata: answerA=exp(cutdownA*betaA)
mata: answerC=exp(cutdownC*betaC)

/*Creates matrices containing the fitted cov/vars*/
mata: varianceA=cutdownA*varcovA*transposeonly(cutdownA)
mata: varianceC=cutdownC*varcovC*transposeonly(cutdownC)

/*Creates matrices containing just the vars*/
mata: varianceA=diagonal(varianceA)
mata: varianceC=diagonal(varianceC)


/*Generates the appropriate z value for the normal distribution for the CIs*/
local alpha2 = (100-`level')/200
local zalpha2 = -invnorm(`alpha2')


/*Calculates the 95% (or user defined level) CIs*/
mata: UCIA=exp(ln(answerA)+`zalpha2':*sqrt(varianceA))
mata: LCIA=exp(ln(answerA)-`zalpha2':*sqrt(varianceA))

mata: UCIC=exp(ln(answerC)+`zalpha2':*sqrt(varianceC))
mata: LCIC=exp(ln(answerC)-`zalpha2':*sqrt(varianceC))


/*Generates the variables for the answers to store into*/
quietly gen `agefitted'=.
quietly gen `agefitted'_lci=.
quietly gen `agefitted'_uci=.
quietly gen `cohfitted'=.
quietly gen `cohfitted'_lci=.
quietly gen `cohfitted'_uci=.



/*Stores the answers into Stata variables*/

quietly replace `Aposact'=0 if `Aposact'==.
mata: st_store(.,"`agefitted'","`Aposact'",answerA)
mata: st_store(.,"`agefitted'_lci","`Aposact'",LCIA)
mata: st_store(.,"`agefitted'_uci","`Aposact'",UCIA)



quietly replace `Cposact'=0 if `Cposact'==.
mata: st_store(.,"`cohfitted'","`Cposact'",answerC)
mata: st_store(.,"`cohfitted'_lci","`Cposact'",LCIC)
mata: st_store(.,"`cohfitted'_uci","`Cposact'",UCIC)


quietly replace `agefitted'=`nper'*`agefitted'
quietly replace `agefitted'_lci=`nper'*`agefitted'_lci
quietly replace `agefitted'_uci=`nper'*`agefitted'_uci


foreach r of numlist `dfc'/1 {
   move _spC`r' `cohfitted'_uci
}

scalar define la=`dfa'+1
local la=la

foreach t of numlist `la'/1 {
   move _spA`t' `cohfitted'_uci
}


return local refcoh `c0'
return local knotsAge `aknots'
return local boundknotsAge `abknots'
return local knotsCoh `cknots'
return local boundknotsCoh `cbknots'

rename _spA1 _spA1_intct


}




if "`param'"!="AP" & "`param'"!="AC" {


/*Generates variables that are later dropped*/
tempvar c0col
tempvar p0col
quietly gen `c0col'=`c0'
quietly gen `p0col'=`p0' 

tempvar dfAcol
tempvar dfPcol
tempvar dfCcol
quietly gen `dfAcol'=`dfa'  
quietly gen `dfPcol'=`dfp' 
quietly gen `dfCcol'=`dfc' 

/*Sets the values of c0 and p0 as Mata 1x1 matrices*/
mata: c0=st_data(1,"`c0col'")
mata: p0=st_data(1,"`p0col'")
mata: dfa=st_data(1,"`dfAcol'")
mata: dfp=st_data(1,"`dfPcol'")
mata: dfc=st_data(1,"`dfCcol'")



/*Generates the row required for the reference cohort*/

	preserve
	   quietly keep if `touse' 
	   quietly rcsgen `c0col', gen(colc0) rmatrix(RmatC) knots(`cknots')
	   keep colc0*
	   mata: RC=st_data(.,(.))
	   mata: RC=RC[1,.]
	restore


/*Generates the row required for the reference period*/

	preserve
	   quietly keep if `touse'
	   quietly rcsgen `p0col', gen(colp0) rmatrix(RmatP) knots(`pknots')
	   keep colp0*
	   mata: RP=st_data(.,(.))
	   mata: RP=RP[1,.]
	restore



/*Generates the matrices with the added rows for the references*/
mata: MPsplusrow=(RP\MPs)
mata: MCsplusrow=(RC\MCs)
mata: tPplusrow=(p0\tP)
mata: tCplusrow=(c0\tC)

/*Performs the detrending with a weighted drift extraction*/
if "`drextr'"=="weighted" | "`drextr'"=="" {
mata: detrendMPsplusrow=detrendMfinalweighted(MPsplusrow,tPplusrow,DP)
mata: detrendMCsplusrow=detrendMfinalweighted(MCsplusrow,tCplusrow,DC)
}

/*Performs the detrending with a Holford drift extraction (w=col(1))*/
if "`drextr'"=="holford" {
mata: detrendMPsplusrow=detrendMfinalholford(MPsplusrow,tPplusrow,DP)
mata: detrendMCsplusrow=detrendMfinalholford(MCsplusrow,tCplusrow,DC)
}

/*Performs the manipulations to calculate the adjusted detrended matrices*/
mata: rowC0=detrendMCsplusrow[(1),.]
mata: C0=progC0matrix(rowC0,detrendMCsplusrow)
mata: nrowC0=rows(C0)
mata: C0=C0[2..nrowC0,.]
mata: nrowdMCspr=rows(detrendMCsplusrow)
mata: detrendMC0=detrendMCsplusrow[2..nrowdMCspr,.]-C0
mata detrendMCn=detrendMCsplusrow[2..nrowdMCspr,.]
mata: ColC=tC 
mata: ColCminC0=ColC:-c0
mata: detrendMCfinal=(ColCminC0,detrendMC0)
mata: detrendMCfinalNA=(ColC,detrendMCn)


/*Performs the manipulations to calculate the adjusted detrended matrices*/
mata: rowP0=detrendMPsplusrow[(1),.]
mata: P0=progP0matrix(rowP0,detrendMPsplusrow)
mata: nrowP0=rows(P0)
mata: P0=P0[2..nrowP0,.]
mata: nrowdMPspr=rows(detrendMPsplusrow)
mata: detrendMP0=detrendMPsplusrow[2..nrowdMPspr,.]-P0
mata detrendMPn=detrendMPsplusrow[2..nrowdMPspr,.]
mata: ColP=tP 
mata: ColPminP0=ColP:-p0
mata: detrendMPfinal=(ColPminP0,detrendMP0)
mata: detrendMPfinalNA=(ColP,detrendMPn)





/*Generates the correct number of empty Stata variables for the Age coeffs*/
local x=1
while `x'<=`dfa'+1 {
   quietly gen _spA`x'=. 
   local x=`x'+1
}

/*Generates the correct number of empty Stata variables for the Period coeffs*/
if "`param'"=="ACP" | "`param'"=="AdCP" | "`param'"=="AdPC" {
   local y=1
   while `y'<=`dfp'-1 {
     quietly gen _spP`y'=. 
     local y=`y'+1
}
}

if "`param'"=="APC" {
   local y=1
   while `y'<=`dfp' {
     quietly gen _spP`y'=. 
     local y=`y'+1
}
}

/*Generates the correct number of empty Stata variables for the Cohort coeffs*/
if "`param'"=="ACP"  {
   local z=1
   while `z'<=`dfc' {
     quietly gen _spC`z'=. 
     local z=`z'+1
}
}

if "`param'"=="APC" | "`param'"=="AdPC" | "`param'"=="AdCP" {
   local z=1
   while `z'<=`dfc'-1 {
     quietly gen _spC`z'=. 
     local z=`z'+1
}
}



if "`adjust'"!="" {
/*Orders the variables to allow easier storage of the columns from Mata*/
order _spC*

mata: usedrows=rows(detrendMCfinal)

/*Stores the results in Stata from Mata*/


if "`param'"=="ACP"  {
   mata: for (j=1;j<=dfc; j++)  st_store(.,(j),"`touse'",detrendMCfinal[.,j])
}


if "`param'"=="APC" | "`param'"=="AdPC" | "`param'"=="AdCP" {
   mata: for (j=1; j<=dfc-1; j++)  st_store(.,(j),"`touse'",detrendMC0[.,j])    
}


/*Orders the variables to allow easier storage of the columns from Mata*/
order _spP*
/*Stores the results in Stata from Mata*/
if "`param'"=="ACP" | "`param'"=="AdCP" | "`param'"=="AdPC" {
   mata: for (k=1; k<=dfp-1; k++) st_store(.,(k),"`touse'",detrendMP0[.,k])
}



if "`param'"=="APC"  {
   mata: for (k=1; k<=dfp; k++) st_store(.,(k),"`touse'",detrendMPfinal[.,k])
}
}

if "`adjust'"=="" {

/*Orders the variables to allow easier storage of the columns from Mata*/
order _spC*

mata: usedrows=rows(detrendMCfinal)

/*Stores the results in Stata from Mata*/


if "`param'"=="ACP"  {
   mata: for (j=1;j<=dfc; j++)  st_store(.,(j),"`touse'",detrendMCfinal[.,j])
}

if  "`param'"=="AdCP" {
   mata: for (j=1; j<=dfc-1; j++)  st_store(.,(j),"`touse'",detrendMC0[.,j])    
}


if "`param'"=="APC" | "`param'"=="AdPC" {
   mata: for (j=1; j<=dfc-1; j++)  st_store(.,(j),"`touse'",detrendMCn[.,j])    
}


/*Orders the variables to allow easier storage of the columns from Mata*/
order _spP*
/*Stores the results in Stata from Mata*/
if "`param'"=="ACP" | "`param'"=="AdCP" | "`param'"=="AdPC" {
   mata: for (k=1; k<=dfp-1; k++) st_store(.,(k),"`touse'",detrendMPn[.,k])
}

if "`param'"=="AdPC" {
   mata: for (k=1; k<=dfp-1; k++) st_store(.,(k),"`touse'",detrendMP0[.,k])
}

if "`param'"=="APC"  {
    mata: for (k=1; k<=dfp; k++) st_store(.,(k),"`touse'",detrendMPfinal[.,k])
}
}


/*Orders the variables to allow easier storage of the columns from Mata*/
order _spA*
/*Stores the results in Stata from Mata*/
mata: for (i=1; i<=dfa+1; i++) st_store(.,(i),"`touse'",MAs[.,i])

/*Generates variables showing the unique groups for the variables*/
tempvar grA
tempvar grP
tempvar grC
quietly egen `grA'=group(`A') if `touse'
quietly egen `grP'=group(`P') if `touse'
quietly egen `grC'=group(`C') if `touse'

/*Generates a variable that is 1s and 0s that tag the first element of the unique groups*/
tempvar tagA
tempvar tagP
tempvar tagC
quietly egen `tagA'=tag(`A') if `touse'
quietly egen `tagP'=tag(`P') if `touse'
quietly egen `tagC'=tag(`C') if `touse'
 
/*Generates an id variable*/
tempvar _id
quietly egen `_id'=seq() if `touse'

/*Generates a variable that shows the value and position of the unique values of the variables*/
tempvar Apos
tempvar Ppos
tempvar Cpos
quietly gen `Apos'=`tagA'*`grA' if `touse'
quietly gen `Ppos'=`tagP'*`grP' if `touse'
quietly gen `Cpos'=`tagC'*`grC' if `touse'

/*Replaces the 0s as missing*/
quietly replace `Apos'=. if `Apos'==0
quietly replace `Cpos'=. if `Cpos'==0
quietly replace `Ppos'=. if `Ppos'==0

/*Generates unique values of the variables and their position in the matrices*/

tempvar Aposact
quietly gen `Aposact'=`_id' if `Apos'!=.
quietly ta `A' if `touse', matrow(uniqueA)
mata: uniqueA=st_matrix("uniqueA")
mata: rowsUA=rows(uniqueA)
mata: Apos=st_data(.,"`Aposact'")
mata: Apos=editvalue(Apos,.,0)
mata: Apos=select(Apos, Apos[.,1]:>0)


/*Generates unique values of the variables and their position in the matrices*/

tempvar Pposact
quietly gen `Pposact'=`_id' if `Ppos'!=.
quietly ta `P' if `touse', matrow(uniqueP)

mata: uniqueP=st_matrix("uniqueP")
mata: rowsUP=rows(uniqueP)
mata: Ppos=st_data(.,"`Pposact'")
mata: Ppos=editvalue(Ppos,.,0)
mata: Ppos=select(Ppos, Ppos[.,1]:>0)

/*Generates unique values of the variables and their position in the matrices*/

tempvar Cposact
quietly gen `Cposact'=`_id' if `Cpos'!=.
quietly ta `C' if `touse', matrow(uniqueC)

mata: uniqueC=st_matrix("uniqueC")
mata: rowsUC=rows(uniqueC)
mata: Cpos=st_data(.,"`Cposact'")
mata: Cpos=editvalue(Cpos,.,0)
mata: Cpos=select(Cpos, Cpos[.,1]:>0)


/*Carries out the glm with the appropriate offset, and poisson dist for the detrended splines*/

if "`param'"=="APC" {
   rename _spP1 _spP1_ldrft
}

if "`param'"=="ACP" {
   rename _spC1 _spC1_ldrft
}

rename _spA1 _spA1_intct

if "`param'"!="AdPC" & "`param'"!="AdCP" {
if "`link'"!="power5" {
if "`iterate'"=="16000" {
glm `D' _sp* if `touse', lnoffset(`Y') f(p) nocons `options'
}
else {
glm `D' _sp* if `touse', lnoffset(`Y') f(p) nocons iterate(`iterate') `options'
}
}
if "`link'"=="power5" {
if "`iterate'"=="16000" {
glm `D' _sp* if `touse', f(p) nocons link(power5 `Y') `options'
}
else {
glm `D' _sp* if `touse', f(p) nocons link(power5 `Y') iterate(`iterate') `options'
}
}
}




if "`param'"=="AdPC" {
gen _drift=`P'-`p0'
if "`link'"!="power5" {
if "`iterate'"=="16000" {
glm `D' _sp* _drift if `touse', lnoffset(`Y') f(p) nocons `options'
}
else {
glm `D' _sp* _drift if `touse', lnoffset(`Y') f(p) nocons iterate(`iterate') `options'
}
}
if "`link'"=="power5" {
if "`iterate'"=="16000" {
glm `D' _sp* _drift if `touse', f(p) nocons link(power5 `Y') `options'
} 
else {
glm `D' _sp* _drift if `touse', f(p) nocons link(power5 `Y') iterate(`iterate') `options'
}
}
}

if "`param'"=="AdCP" {
gen _drift=`C'-`c0'
if "`link'"!="power5" {
if "`iterate'"=="16000" {
glm `D' _sp* _drift if `touse', lnoffset(`Y') f(p) nocons `options'
}
else {
glm `D' _sp* _drift if `touse', lnoffset(`Y') f(p) nocons iterate(`iterate') `options'
}
}
if "`link'"=="power5" {
if "`iterate'"=="16000" {
glm `D' _sp* _drift if `touse', f(p) nocons link(power5 `Y') `options'
}
else {
glm `D' _sp* _drift if `touse', f(p) nocons link(power5 `Y') iterate(`iterate') `options'
}
}
}

if "`param'"=="APC" {
   rename _spP1_ldrft _spP1 
}

if "`param'"=="ACP" {
   rename _spC1_ldrft _spC1 
}

rename _spA1_intct _spA1

/*Obtains the coefficients from the glm and sorts them into the appropriate variables*/
if "`param'"=="ACP" {
   mata: coeffs=st_matrix("e(b)")
   mata: betaA=coeffs'[(1..dfa+1),.]
   mata: betaP=coeffs'[(dfa+2..(dfa+dfp)),.]
   mata: betaC=coeffs'[(dfa+dfp+1)..(dfa+dfp+dfc),.]
}

if "`param'"=="AdCP" {
   mata: coeffs=st_matrix("e(b)")
   mata: betaA=coeffs'[(1..dfa+1),.]
   mata: betaP=coeffs'[(dfa+2..(dfa+dfp)),.]
   mata: betaC=coeffs'[(dfa+dfp+1)..(dfa+dfp+dfc-1),.]
}

if "`param'"=="APC" {
   mata: coeffs=st_matrix("e(b)")
   mata: betaA=coeffs'[(1..dfa+1),.]
   mata: betaP=coeffs'[(dfa+2..(dfa+dfp+1)),.]
   mata: betaC=coeffs'[(dfa+dfp+2)..(dfa+dfp+dfc),.]
}

if "`param'"=="AdPC" {
   mata: coeffs=st_matrix("e(b)")
   mata: betaA=coeffs'[(1..dfa+1),.]
   mata: betaP=coeffs'[(dfa+2..(dfa+dfp)),.]
   mata: betaC=coeffs'[(dfa+dfp+1)..(dfa+dfp+dfc-1),.]
}

/*Obtains the vars/covs from the glm and sorts them into the appropriate variables*/

if "`param'"=="ACP" {
   mata: varcov=st_matrix("e(V)")
   mata: varcovA=varcov[(1..dfa+1),(1..dfa+1)]
   mata: varcovP=varcov[(dfa+2..(dfa+dfp)),(dfa+2..(dfa+dfp))]
   mata: varcovC=varcov[((dfa+dfp+1)..(dfa+dfp+dfc)),((dfa+dfp+1)..(dfa+dfp+dfc))]
}

if "`param'"=="AdCP" {
   mata: varcov=st_matrix("e(V)")
   mata: varcovA=varcov[(1..dfa+1),(1..dfa+1)]
   mata: varcovP=varcov[(dfa+2..(dfa+dfp)),(dfa+2..(dfa+dfp))]
   mata: varcovC=varcov[((dfa+dfp+1)..(dfa+dfp+dfc-1)),((dfa+dfp+1)..(dfa+dfp+dfc-1))]
}

if "`param'"=="APC" {
   mata: varcov=st_matrix("e(V)")
   mata: varcovA=varcov[(1..dfa+1),(1..dfa+1)]
   mata: varcovP=varcov[(dfa+2..(dfa+dfp+1)),(dfa+2..(dfa+dfp+1))]
   mata: varcovC=varcov[((dfa+dfp+2)..(dfa+dfp+dfc)),((dfa+dfp+2)..(dfa+dfp+dfc))]
}

if "`param'"=="AdPC" {
   mata: varcov=st_matrix("e(V)")
   mata: varcovA=varcov[(1..dfa+1),(1..dfa+1)]
   mata: varcovP=varcov[(dfa+2..(dfa+dfp)),(dfa+2..(dfa+dfp))]
   mata: varcovC=varcov[((dfa+dfp+1)..(dfa+dfp+dfc-1)),((dfa+dfp+1)..(dfa+dfp+dfc-1))]
}

/*Creates matrices corresponding to the unique values of the variables*/
if "`adjust'"!="" {
if "`param'"=="ACP" {
   mata: cutdownA=MAs[Apos,.]
   mata: cutdownP=detrendMP0[Ppos,.]
   mata: cutdownC=detrendMCfinal[Cpos,.]
}

if "`param'"=="AdCP" | "`param'"=="AdPC" {
   mata: cutdownA=MAs[Apos,.]
   mata: cutdownP=detrendMP0[Ppos,.]
   mata: cutdownC=detrendMC0[Cpos,.]
}

if "`param'"=="APC" {
   mata: cutdownA=MAs[Apos,.]
   mata: cutdownP=detrendMPfinal[Ppos,.]
   mata: cutdownC=detrendMC0[Cpos,.]
}
}

if "`adjust'"=="" {
if "`param'"=="ACP" {
   mata: cutdownA=MAs[Apos,.]
   mata: cutdownP=detrendMPn[Ppos,.]
   mata: cutdownC=detrendMCfinal[Cpos,.]
}

if "`param'"=="AdCP"  {
   mata: cutdownA=MAs[Apos,.]
   mata: cutdownP=detrendMPn[Ppos,.]
   mata: cutdownC=detrendMC0[Cpos,.]
}

if "`param'"=="AdPC" {
   mata: cutdownA=MAs[Apos,.]
   mata: cutdownP=detrendMP0[Ppos,.]
   mata: cutdownC=detrendMCn[Cpos,.]
}

if "`param'"=="APC" {
   mata: cutdownA=MAs[Apos,.]
   mata: cutdownP=detrendMPfinal[Ppos,.]
   mata: cutdownC=detrendMCn[Cpos,.]
}
}

/*Creates matrices containing the fitted values*/
mata: answerA=exp(cutdownA*betaA)
mata: answerP=exp(cutdownP*betaP)
mata: answerC=exp(cutdownC*betaC)

/*Creates matrices containing the fitted cov/vars*/
mata: varianceA=cutdownA*varcovA*transposeonly(cutdownA)
mata: varianceP=cutdownP*varcovP*transposeonly(cutdownP)
mata: varianceC=cutdownC*varcovC*transposeonly(cutdownC)

/*Creates matrices containing just the vars*/
mata: varianceA=diagonal(varianceA)
mata: varianceP=diagonal(varianceP)
mata: varianceC=diagonal(varianceC)


/*Generates the appropriate z value for the normal distribution for the CIs*/
local alpha2 = (100-`level')/200
local zalpha2 = -invnorm(`alpha2')


/*Calculates the 95% (or user defined level) CIs*/
mata: UCIA=exp(ln(answerA)+`zalpha2':*sqrt(varianceA))
mata: LCIA=exp(ln(answerA)-`zalpha2':*sqrt(varianceA))

mata: UCIP=exp(ln(answerP)+`zalpha2':*sqrt(varianceP))
mata: LCIP=exp(ln(answerP)-`zalpha2':*sqrt(varianceP))

mata: UCIC=exp(ln(answerC)+`zalpha2':*sqrt(varianceC))
mata: LCIC=exp(ln(answerC)-`zalpha2':*sqrt(varianceC))


/*Generates the variables for the answers to store into*/
quietly gen `agefitted'=.
quietly gen `agefitted'_lci=.
quietly gen `agefitted'_uci=.
quietly gen `perfitted'=.
quietly gen `perfitted'_lci=.
quietly gen `perfitted'_uci=.
quietly gen `cohfitted'=.
quietly gen `cohfitted'_lci=.
quietly gen `cohfitted'_uci=.



/*Stores the answers into Stata variables*/

quietly replace `Aposact'=0 if `Aposact'==.
mata: st_store(.,"`agefitted'","`Aposact'",answerA)
mata: st_store(.,"`agefitted'_lci","`Aposact'",LCIA)
mata: st_store(.,"`agefitted'_uci","`Aposact'",UCIA)



quietly replace `Pposact'=0 if `Pposact'==.
mata: st_store(.,"`perfitted'","`Pposact'",answerP)
mata: st_store(.,"`perfitted'_lci","`Pposact'",LCIP)
mata: st_store(.,"`perfitted'_uci","`Pposact'",UCIP)


quietly replace `Cposact'=0 if `Cposact'==.
mata: st_store(.,"`cohfitted'","`Cposact'",answerC)
mata: st_store(.,"`cohfitted'_lci","`Cposact'",LCIC)
mata: st_store(.,"`cohfitted'_uci","`Cposact'",UCIC)


quietly replace `agefitted'=`nper'*`agefitted'
quietly replace `agefitted'_lci=`nper'*`agefitted'_lci
quietly replace `agefitted'_uci=`nper'*`agefitted'_uci


/*Drops unwanted variables*/


/*Puts the spline variables to the end of the dataset*/

if "`param'"=="ACP" {
   foreach r of numlist `dfc'/1 {
   move _spC`r' `cohfitted'_uci
}

scalar define lp=`dfp'-1
scalar define la=`dfa'+1
local lp=lp
local la=la

foreach s of numlist `lp'/1 {
    move _spP`s' `cohfitted'_uci
}

foreach t of numlist `la'/1 {
    move _spA`t' `cohfitted'_uci
}
}
  
if "`param'"=="APC" {
   scalar define lc=`dfc'-1
   scalar define la=`dfa'+1
   local lc=lc
   local la=la

foreach s of numlist `lc'/1 {
   move _spC`s' `cohfitted'_uci
}

foreach r of numlist `dfp'/1 {
   move _spP`r' `cohfitted'_uci
}

foreach t of numlist `la'/1 {
   move _spA`t' `cohfitted'_uci
}
}

if "`param'"=="APC" {
   rename _spP1 _spP1_ldrft
}

if "`param'"=="ACP" {
   rename _spC1 _spC1_ldrft
}

rename _spA1 _spA1_intct


return local refcoh `c0'
return local refper `p0'
return local knotsAge `aknots'
return local boundknotsAge `abknots'
return local knotsPer `pknots'
return local boundknotsPer `pbknots'
return local knotsCoh `cknots'
return local boundknotsCoh `cbknots'

}

end

/*MATA PROGRAMS*/

/*Mata program used to generate the pivot vector used later in detrend*/
mata:
real matrix progpivotvector(real matrix userv,userPM) {
v=userv
PM=userPM
rank=rank(PM,tol=-1e-03)
/* if (rank==.) { */
/* exit(_error(3200,"Missing values encountered. Restrict the data using if/in to produce an answer from apcfit.")) */
/* } */

for (j=1; j<=rank; j++) {
                    v[,j]=1
        }
return(v)
}

end

/*Mata program used to detrend the matrix using the weighted method*/
mata:
real matrix detrendMfinalweighted(real matrix userM, usert, userD)
{
/*Sets the matrices to be used during the program*/
D=userD
t=usert
M=userM
numeric matrix w, X, PM, Pp, H, R1, tau, p1, v, detrendM, pivot, pivotedPM
real scalar rank

/*Generates a constant term of the right length and the X matrix*/
cons=J(rows(M),1,1)
X=(cons,t)

/*Generates the weights and sets the first row of the weights to zero*/
w=D
w=(0\D)


/*Performs  the detrending process*/
Pp=svsolve(cross(X:*sqrt(w),X:*sqrt(w)),transposeonly(X:*w))*M
PM=X*Pp
PM=M-PM

/*Generates a blank pivot vector and performs QR decompostion*/
p1=.
H=tau=R1=.
hqrdp(PM,H,tau,R1,p1)

/*Sets the pivot vector equal to that given by the decomposition*/
pivot=p1

/*Generates a vector of zeros with lenth cols(M)*/
v=J(1,cols(M),0)

/*Pivots the detrended matrix according to the defined pivot from QR*/
pivotedPM=PM[.,pivot]
/*Generates a vector that contains 1s according to the rank of PM*/
v=progpivotvector(v,PM)

/*Selects a matrix of full rank using v*/
detrendM=select(pivotedPM,v)
/*Returns the full rank detrended matrix*/
return(detrendM)
}
end

/*Mata program used to detrend the matrix using the weighted method*/
/*Same comments as above*/
mata:

real matrix detrendMfinalholford(real matrix userM, usert, userD)
{

D=userD
t=usert
M=userM
numeric matrix w, X, PM, Pp, H, tau, R1, p1, v, detrendM, pivot, pivotedPM
real scalar rank


w=J(rows(M),1,1)
X=(w,t)
w[1,1]=0


Pp=svsolve(cross(X:*sqrt(w),X:*sqrt(w)),transposeonly(X:*w))*M
PM=X*Pp
PM=M-PM

p1=.
H=tau=R1=.
hqrdp(PM,H,tau,R1,p1)


pivot=p1


v=J(1,cols(M),0)

pivotedPM=PM[.,pivot]
v=progpivotvector(v,PM)


detrendM=select(pivotedPM,v)
return(detrendM)

}

end


/*Mata program used to make C0, a matrix with a repeated row of specified length*/
mata:

real matrix progC0matrix(real matrix userc0,userdetrendMC)
 {    
c0=userc0
detrendMC=userdetrendMC
Jmat=J(rows(detrendMC),cols(detrendMC),0)
for (j=1; j<=cols(detrendMC); j++) {
                for (i=1; i<=rows(detrendMC); i++) {
                    Jmat[i,.]=c0
                }
        }
return(Jmat)
}
end

*/Mata program used to make P0, a matrix with a repeated row of specified length*/
mata:
real matrix progP0matrix(real matrix userp0,userdetrendMP)
 {    
p0=userp0
detrendMP=userdetrendMP
Jmat=J(rows(detrendMP),cols(detrendMP),0)
for (j=1; j<=cols(detrendMP); j++) {
                for (i=1; i<=rows(detrendMP); i++) {
                    Jmat[i,.]=p0
                }
        }
return(Jmat)
}

end

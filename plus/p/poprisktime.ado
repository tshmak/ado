capture program drop poprisktime
program define poprisktime, rclass
syntax [varlist(default=none)] using/, Age(varname) PERiod(varname) COHort(varname) Cases(varname) AGEMAX(int) AGEMIN(int) PERMIN(int) PERMAX(int) [ POP(string) POPRISKtime(string) COVariates(varlist) MISSingreplace]


capture drop _UpperCohort

capture: assert `age'==int(`age')
if _rc==9 {
	di as error "The variable for the Age values must contain only integer values of Age. It may be necessary to round the variable."
	exit 198
}

capture: assert `period'==int(`period')
if _rc==9 {
	di as error "The variable for the Period values must contain only integer values of Period. It may be necessary to round the variable."
	exit 198
}

capture: assert `cohort'==int(`cohort')
if _rc==9 {
	di as error "The variable for the Cohort values must contain only integer values of Cohort. It may be necessary to round the variable."
	exit 198
}

capture: assert `cases'==int(`cases')
if _rc==9 {
	di in green "Warning: The variable for the Cases values contains non-integer values."
}

if "`poprisktime'"=="" {
	local poprisktime "Y"
}

if "`saving'"=="" {
	local saving "APCdata"
}

if "`pop'"=="" {
	local pop pop
}

capture: su `poprisktime'
if _rc!=111 {
	di as error "The variable name that is specified as the population risk-time is already defined."
	exit 198
} 

confirm file `"`using'.dta"'

tempname cohortcheck
quietly gen `cohortcheck'=`period'-`age'
quietly gen _UpperCohort=`cohortcheck'-`cohort'
quietly drop if _UpperCohort<0


preserve
use "`using'", clear

capture: assert `age'==int(`age')
if _rc==9 {
	di as error "The variable for the Age values must contain only integer values of Age. It may be necessary to round the variable."
	exit 198
}

capture: assert `period'==int(`period')
if _rc==9 {
	di as error "The variable for the Period values must contain only integer values of Period. It may be necessary to round the variable."
	exit 198
}

/* capture: assert `pop'==int(`pop')
if _rc==9 {
	di as error "The variable for the Period values must contain only integer values of Period. It may be necessary to round the variable."
	exit 198
}
*/

quietly su
local length=r(N)
quietly append using "`using'"
quietly gen _UpperCohort=0
quietly replace _UpperCohort=1 if _n>`length'
tempfile temppop
quietly sa "`temppop'", replace
restore

* capture: merge `covariates' _UpperCohort `age' `period' using "`temppop'", sort

capture: merge 1:1 `covariates' _UpperCohort `age' `period' using "`temppop'"
if _rc==459 {
quietly drop _UpperCohort
 di as error "variables _UpperCohort A P do not uniquely identify observations in the master data. This is likely to be due to the fact that the dataset is split by a covariate and the covariate option was not specified."
exit 459
}

confirm variable `pop'

quietly sort  `covariates'  _UpperCohort  `age'  `period' 
quietly gen `poprisktime'=0


quietly drop if `age'<`agemin'-1
quietly drop if `age'>`agemax'+1
quietly drop if `period'<`permin'
quietly drop if P>`permax'+1

if "`missingreplace'"!="" {
	quietly replace `cases'=0 if `cases'==.
}


quietly egen max=max(`period') 
quietly egen min=min(`period') 
quietly gen diff=max-min+2 
quietly egen maxdiff=max(diff) 
quietly gen maxdiffminus1=maxdiff-1 
quietly replace `poprisktime'=(1/3)*`pop'[_n]+(1/6)*`pop'[_n+maxdiff] if _UpperCohort==1
quietly replace `poprisktime'=(1/6)*`pop'[_n-maxdiffminus1]+(1/3)*`pop'[_n+1] if  _UpperCohort==0
quietly replace `poprisktime'=. if `period'==max & _UpperCohort==1
quietly drop maxdiff diff min max maxdiffminus1

quietly replace `age'=`age'+0.333 if _UpperCohort==0
quietly replace `period'=`period'+0.667 if _UpperCohort==0
quietly replace `age'=`age'+0.667 if _UpperCohort==1
quietly replace `period'=`period'+0.333 if _UpperCohort==1
quietly replace `cohort'=`period'-`age'
quietly drop _UpperCohort _merge `pop'

quietly drop if `age'<`agemin'
quietly drop if `age'>`agemax'
quietly drop if `period'<`permin'
quietly drop if `period'>`permax'

 if `poprisktime'==. {
       di in green "Warning: variable `poprisktime' contain missing values. The ranges of the age and period values in the population dataset are not appropriate to carry out the formulae for the specified age and period range given in the command. See the help file for a more detailed explanation."
      }

if `cases'==. {
	di in yellow "Warning: The number of cases variable now contains missing values. It is likely that these missing values should be replaced with 0s because there are no cases of the disease in that particular age-period combination. However, if missing data was present before the merge then this may be inappropriate. The missingreplace option can be used to specify a different action."
}

end


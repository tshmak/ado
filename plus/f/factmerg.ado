#delim ;
prog def factmerg,rclass;
version 7.0;
/*
 Merge a list of input factors to create new output string variables
 with value for each observation copied from the first factor in the input list
 with a non-missing value for that observation.
*! Author: Roger Newson
*! Date: 25 February 2004
*/
syntax varlist [if] [in] [, FValue(string) FName(string) FLabel(string)
  MValue(string asis) MName(string asis) MLabel(string asis) FMissing(string) ];
/*
 -varlist- is a list of input factor variables to be merged.
 -fvalue- is an output variable (string or numeric)
  containing, in each observation,
  a value copied from the first variable in the input list
  with a non-missing value for that observation.
 -fname- is a string output variable containing, in each observation,
  the name of the input variable from which the value of -fvalue-
  is copied for that observation.
 -flabel- is a string output variable containing, in each observation,
  the variable label of the input variable
  from which the value of -fvalue- is copied for that observation.
 -mvalue- is a string variable
  from which values will be copied to the -fvalue- variable
  for observations with missing values for the -fvalue- variable.
 -mname- is a string variable
  from which values will be copied to the -fname- variable
  for observations with missing values for the -fvalue- variable.
 -mlabel- is a string variable
  from which values will be copied to the -flabel- variable
  for observations with missing values for the -fvalue- variable.
 -fmissing- is a numeric output variable,
  containing missing values for observations excluded by -if- and -in-,
  1 for other observations in which all the input factors are missing,
  and 0 for other observations in which at least one input factor is nonmissing.
*/

preserve;

marksample touse,novarlist strok;

local nfac:word count `varlist';

* Confirm that output variable names are valid *;
if "`fname'"!="" {;confirm new var `fname';};
if "`flabel'"!="" {;confirm new var `flabel';};
if "`fvalue'"!="" {;confirm new var `fvalue';};

*
Create temporary variables
to contain factor names, labels and values
*;
tempvar fn fl fv fvcur;
qui {;gene str1 `fn'="";gene str1 `fl'="";gene str1 `fv'="";};
forv i1=`nfac'(-1)1 {;local fcur:word `i1' of `varlist';
  local flcur:var lab `fcur';
  local ftype:type `fcur';
  qui replace `fn'="`fcur'" if `touse'&!missing(`fcur');
  qui replace `fl'="`flcur'" if `touse'&!missing(`fcur');
  if index("`ftype'","str")==1 {;
    qui replace `fv'=`fcur' if `touse'&!missing(`fcur');
  };
  else {;
    local fvlcur:value label `fcur';
    local fftcur:format `fcur';
    if "`fvlcur'"=="" {;
      * No labels - use formatted value *;
      qui gene str1 `fvcur'="";
      qui replace `fvcur'=string(`fcur',"`fftcur'") if `touse'&!missing(`fcur');
    };
    else {;
      * Use labels if possible, otherwise use formatted value *;
      qui decode `fcur' if `touse'&!missing(`fcur'),gene(`fvcur');
      qui replace `fvcur'=string(`fcur',"`fftcur'") if `touse'&!missing(`fcur')&missing(`fvcur');
    };
    qui replace `fv'=`fvcur' if `touse'&!missing(`fcur');
    drop `fvcur';
  };
};


*
 Fill in missing values for -fvalue-, -fname- and -flabel-
 from -mvalue-, -mname- and -mlabel- if requested
*;
if `"`mname'"'!="" {;
  qui replace `fn'=(`mname') if `touse' & missing(`fv');
};
if `"`mlabel'"'!="" {;
  qui replace `fl'=(`mlabel') if `touse' & missing(`fv');
};
if `"`mvalue'"'!="" {;
  qui replace `fv'=(`mvalue') if `touse' & missing(`fv');
};

lab var `fn' "Factor name";
lab var `fl' "Factor label";
lab var `fv' "Factor value";

* Rename output variables *;
if "`fname'"!="" {;rename `fn' `fname';};
if "`flabel'"!="" {;rename `fl' `flabel';};
if "`fvalue'"!="" {;rename `fv' `fvalue';};

* Add -fmissing()- variable *;
if `"`fmissing'"'!="" {;
  local nfmissing:word count `fmissing';
  if `nfmissing'!=1 {;
    disp as error "Invalid fmissing()";
    error 198;
  };
  conf new var `fmissing';
  qui gene byte `fmissing'=1 if `touse';
  foreach X of var `varlist' {;
    qui replace `fmissing'=0 if `touse' & !missing(`X');
  };
  lab var `fmissing' "Missing: `varlist'";
};

restore, not;

end;

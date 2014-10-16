#delim ;
prog def descsave;
version 7.0;
syntax [varlist] [, SAving(passthru) DOfile(string asis)
 CHarlist(string asis) IDNum(string) IDStr(string)
 REName(passthru) GSort(passthru) KEep(passthru) *];
/*
 Extension of describe
 creating two output files.
 The saving option specifies a Stata data set,
 with 1 obs per variable in varlist,
 and data on names, types, formats, value labels, variable labels,
 and characteristics specified by the charlist option.
 The dofile option specifies a do-file
 which can reconstruct types, formats, value labels, variable labels,
 and characteristics specified by the charlist option,
 assuming that variables of the specified names exist
 (as they will if the data set has been saved using outsheet
 and re-input using insheet).
 The idnum and idstr options
 specify numeric and string identifiers, respectively,
 which will be stored in variables of the same name
 in the saving data set,
 and can be used as identifiers if the saving data set
 is concatenated with other saving data sets.
 The rename option specifies a list
 of alternating old and new variable names,
 so the user can rename variables in the saving data set.
 The gsort option specifies the sort order of the output data set,
 which defaults to the single variable order.
 The keep option specifies the variables to keep
 in the output data set.
*! Author: Roger Newson
*! Date: 23 April 2004
*/

local nvar:word count `varlist';
local nchar:word count `charlist';

* Call describe *;
describe `varlist',`options';

* Create macro variables containing descriptive features *;
local i1=0;
while(`i1'<`nvar'){;local i1=`i1'+1;
  local varcur:word `i1' of `varlist';
  local name`i1' "`varcur'";
  local type`i1':type `varcur';
  local form`i1':format `varcur';
  local vall`i1':value label `varcur';
  local varl`i1':variable label `varcur';
  local i2=0;
  while(`i2'<`nchar'){;local i2=`i2'+1;
    local charcur:word `i2' of `charlist';
    local char`i2'_`i1' `"``varcur'[`charcur']'"';
  };
};

preserve;
drop _all;

*
 Create file containing label definitions
 if do-file is required
*;
if(`"`dofile'"'!=""){;
  tempfile labdef;
  local vllist "";
  local i1=0;
  while(`i1'<`nvar'){;local i1=`i1'+1;
    * Check that variable label exists *;
    cap lab list `vall`i1'';
    if _rc==0 {;
      if("`vllist'"==""){;local vllist "`vall`i1''";};
      else if("`vall`i1''"!=""){;
        *
         Check that the value label is not in the list
         and add it to the list if it is not already there
        *;
        local newvl=1;
        foreach vallcur in `vllist' {;
          if "`vallcur'" == "`vall`i1''" {; local newvl=0; };
        };
        if `newvl' {;local vllist "`vllist' `vall`i1''";};
      };
    };
  };
  if("`vllist'"!=""){;
   qui label save `vllist' using `"`labdef'"',replace;
   label drop _all;
  };
  else{;
    label drop _all;
    qui label save using `"`labdef'"',replace;
  };
};

* Create new data set with 1 obs per variable in varlist *;
qui set obs `nvar';
qui gene long order=_n;
qui compress order;
foreach X of new name type format vallab varlab{;qui gene str1 `X'="";};
local i2=0;
while(`i2'<`nchar'){;local i2=`i2'+1;
  qui gene str1 char`i2'="";
};
local i1=0;
while(`i1'<`nvar'){;local i1=`i1'+1;
  qui{;
    replace name=`"`name`i1''"' in `i1';
    replace type=`"`type`i1''"' in `i1';
    replace format=`"`form`i1''"' in `i1';
    replace vallab=`"`vall`i1''"' in `i1';
    replace varlab=`"`varl`i1''"' in `i1';
    local i2=0;
    while(`i2'<`nchar'){;local i2=`i2'+1;
      replace char`i2'=`"`char`i2'_`i1''"' in `i1';
    };
  };
};
lab var order "Variable order";
lab var name "Variable name";
lab var type "Storage type";
lab var format "Display format";
lab var vallab "Value label";
lab var varlab "Variable label";
local i2=0;
while(`i2'<`nchar'){;local i2=`i2'+1;
  local charcur:word `i2' of `charlist';
  lab var char`i2' `"char[`charcur']"';
};

*
 Left-justify formats for all character variables
 in the base output variable set
*;
unab outvars: *;
foreach X of var `outvars' {;
    local typecur: type `X';
    if index("`typecur'","str")==1 {;
        local formcur: format `X';
        local formcur=subinstr("`formcur'","%","%-",1);
        format `X' `formcur';
    };
};

*
 Create numeric and/or string ID variables if requested
 and move them to the beginning of the variable order
*;
if("`idstr'"!=""){;
    qui gene str1 idstr=" ";
    qui replace idstr="`idstr'";
    qui compress idstr;
    qui order idstr;
    lab var idstr "String id";
};
if("`idnum'"!=""){;
    qui gene double idnum=real("`idnum'");
    qui compress idnum;
    qui order idnum;
    lab var idnum "Numeric id";
};


* Save Stata output if required *;
rensave, `rename' `saving' `gsort' `keep';

*
 Create output do-file if required
*;
if(`"`dofile'"'!=""){;
  *
   Create variable dquote containing a single double quote
   (this is a workaround for an obscure Stata bug
   encountered on 18 April 2001. - RBN)
  *;
  gene str1 dquote=`""""';
  * Create file containing storage types *;
  tempfile type_f;
  qui{;
    gene str1 line1="";gene str1 line2="";gene str1 line3="";
    replace line1="cap recast "+type+" "+name if(type!="");
    linesave `"`type_f'"';
    drop line1 line2 line3;
  };
  * Create file containing formats *;
  tempfile format_f;
  qui{;
    gene str1 line1="";gene str1 line2="";gene str1 line3="";
    replace line1="cap form "+name+" "+format if(format!="");
    linesave `"`format_f'"';
    drop line1 line2 line3;
  };
  * Create file containing value labels *;
  tempfile vallab_f;
  qui{;
    gene str1 line1="";gene str1 line2="";gene str1 line3="";
    replace line1="cap la val "+name+" "+vallab if(vallab!="");
    linesave `"`vallab_f'"';
    drop line1 line2 line3;
  };
  * Create file containing variable labels *;
  tempfile varlab_f;
  qui{;
    gene str1 line1="";gene str1 line2="";gene str1 line3="";
    disp "Line variables initialized to missing...";
    replace line1="cap la var "+name+" `"+dquote if(varlab!="");
    replace line2=varlab if(varlab!="");
    replace line3=dquote+"'" if(varlab!="");
    linesave `"`varlab_f'"';
    drop line1 line2 line3;
  };
  * Create files containing characteristics *;
  local i2=0;
  while(`i2'<`nchar'){;local i2=`i2'+1;
    local charcur:word `i2' of `charlist';
    tempfile char`i2'_f;
    qui{;
    gene str1 line1="";gene str1 line2="";gene str1 line3="";
      replace line1="cap char "+name+"[`charcur'] "+" `"+dquote if(char`i2'!="");
      replace line2=char`i2' if(char`i2'!="");
      replace line3=dquote+"'" if(char`i2'!="");
      linesave `"`char`i2'_f'"';
    drop line1 line2 line3;
    };
  };
  *
   Concatenate all files into memory
   and write to output file
  *;
  drop _all;
  qui{;
    infix str line1 1-80 str line2 81-160 str line3 161-240 using `"`labdef'"';
    replace line1=subinstr(line1,"label define ","cap la de ",1);
    append using `"`type_f'"';
    append using `"`format_f'"';
    append using `"`vallab_f'"';
    append using `"`varlab_f'"';
    local i2=0;
    while(`i2'<`nchar'){;local i2=`i2'+1;
      append using `"`char`i2'_f'"';
    };
  };
  dosave using `dofile';
};

restore;

end;

prog def linesave;
args file;
* Save variables line1, line2 and line3 to data set file *;

preserve;
keep line1 line2 line3;
keep if((!missing(line1))|(!missing(line2))|(!missing(line3)));
save `"`file'"',replace;
restore;

end;

prog def dosave;
syntax using/ [,REPLACE];
* Save the do-file *;

outfile line1 line2 line3 using `"`using'"',runtogether `replace';

end;

prog def rensave;
syntax [,  REName(string) SAving(string asis) GSort(string) KEep(string) ];
* Save file, renaming variables as specified in -rename- *;

preserve;

*
 Rename variables if requested
*;
if "`rename'"!="" {;
    local nrename:word count `rename';
    if mod(`nrename',2) {;
        disp in green 
          "Warning: odd number of variable names in rename list - last one ignored";
        local nrename=`nrename'-1;
    };
    local nrenp=`nrename'/2;
    local i1=0;
    while `i1'<`nrenp' {;
        local i1=`i1'+1;
        local i3=`i1'+`i1';
        local i2=`i3'-1;
        local oldname:word `i2' of `rename';
        local newname:word `i3' of `rename';
        cap{;
            confirm var `oldname';
            confirm new var `newname';
        };
        if _rc!=0 {;
            disp in green
             "Warning: it is not possible to rename `oldname' to `newname'";
        };
        else {;
            rename `oldname' `newname';
        };
    };
};

* Sort if requested *;
if "`gsort'"=="" {;local gsort "order";};
tempvar tiebreak;
qui gene long `tiebreak'=_n;
qui compress `tiebreak';
gsort `gsort' + `tiebreak';
drop `tiebreak';

* Keep only selected variables if requested *;
if "`keep'"!="" {;
    confirm variable `keep';
    keep `keep';
};

* Save file if requested *;
if(`"`saving'"'!=""){;
  save `saving';
};

restore;

end;

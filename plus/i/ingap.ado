#delim ;
prog def ingap, rclass byable(onecall);
version 7.0;
/*
  Insert gap observations next to observations specified by a numlist
  giving positions of the observations
  within the data set or within the by-groups.
  A gap observation has values of the by-variables as in its by-group,
  a special gap row label in the row label variable if one is specified,
  and missing values for all other variables.
  Gap observations are used in a Stata set that represents a table,
  with one observation per row of the table,
  and possibly by-variables specifying pages of a multi-page table
  and a row label variable specifying table row labels.
  Such a table can be output using the -listtex- package
  for input into a TeX, LaTeX, HTML or Microsoft Word table,
  or plotted on a Stata graph with the row labels on the Y-axis,
  after the row labels have been encoded to a numeric variable using -sencode-.
*! Author: Roger Newson
*! Date: 11 February 2004
*/

syntax [ anything(name=gaplist id="gap list") ] [if] [in] [ , AFter
  ROwlabel(varlist string) GRowlabels(string asis) RString(string) GRExpression(string asis)
  Gapindicator(string) NEWOrder(string) ];
if `"`gaplist'"'=="" {;
  local gaplist=1;
};
else {;
  numlist `"`gaplist'"',integer;
  local gaplist `"`r(numlist)'"';
};
/*
  -after- indicates that the gap observations must be inserted
    after the observations specified in the input numlist,
    instead of before these observations (the default).
  -rowlabel- is an existing string variable used as row labels,
    to be filled in from the -growlabel- option in the gap observations.
  -growlabels- is a list of string row labels for the gap observations.
  -rstring- specifies a rule for replacing string variables in gap observations
    (labels, names, or labels if present and names otherwise).
  -grexpression- is a string expression defining gap row labels,
    and is executed after setting gap row labels to -growlabels-,
    and therefore can contain the -rowlabel- variable and/or the by-variables,
    although other variables will usually be set to missing in the gap observations
    and can be read from adjacent observations by subscripting.
  -gapindicator- is a generated gap indicator variable,
    equal to 1 if the observation is a gap and 0 otherwise.
  -neworder- specifies a generated variable
    containing the new order of an observation within the data set
    (within by-group if necessary).
*/

* Preserve old data in case user presses -Break- *;
preserve;

*
 Create macro -bybyvars- to prefix commands done by by-vars
 if by-vars are present
*;
if _by() {;
  local bybyvars `"by `_byvars':"';
};

*
 Create local macro -gindlab-
 (containing label for variable -gapindicator-)
*;
local gindlab "Gap indicator";

* Create list of existing variables *;
unab existvar: *;

* Check that row label variables are not by-variables *;
if (`"`rowlabel'"'!="") & _by() {;
  foreach X of var `rowlabel' {;
    foreach Y of var `_byvars' {;
      if "`X'"=="`Y'" {;
        disp as error "Error: row label variable `X' is a by-variable";
        error 498;
      };
    };
  };
};

* Mark sample for use *;
marksample touse;

*
 Create temporary variable -seqord- containing original order,
 temporary variable -wbseqord- containing order within by-groups,
 temporary variable -wbtotal- containing number in current by-group,
 temporary variable -ntodup- to contain number of duplicates to -expand- by,
 and temporary variable -gapseq- to contain gap sequence order for gap observations,
*;
tempvar seqord wbseqord wbtotal ntodup gapseq;
qui {;
  gene long `seqord'=_n;
  `bybyvars' gene long `wbseqord'=_n;
  `bybyvars' gene long `wbtotal'=_N;
  gene long `ntodup'=.;
  gene long `gapseq'=.;
};

* Initialise -gapindicator- variable *;
if `"`gapindicator'"'=="" {;tempvar gapindicator;};
else {;
  confirm new var `gapindicator';
  local ngapi:word count `gapindicator';
  if `ngapi'>1 {;
    disp as error "Invalid multiple gap indicator variables: `gapindicator'";
    error 498;
  };
};
qui gene byte `gapindicator'=0;

*
 Add gap observations for each gap
*;
local ngap:word count `gaplist';
local Norig=_N;
forv i1=1(1)`ngap' {;
  local gapcur:word `i1' of `gaplist';
  local growlcur:word `i1' of `growlabels';
  local Noldcur=_N;
  qui {;
    replace `ntodup'=1;
    if `gapcur'>=0 {;
      * Count gap position from beginning of data set or by-group *;
      replace `ntodup'=`ntodup'+1
        if `touse' & (_n<=`Norig') & (`wbseqord'==`gapcur');
    };
    else {;
      * count gap position from end of data set or by-group *;
      replace `ntodup'=`ntodup'+1
        if `touse' & (_n<=`Norig') & (`wbseqord'==`wbtotal'+`gapcur'+1);
    };
    expand `ntodup';
    * Replace gap indicator and row labels in new observations *;
    replace `gapindicator'=1 if _n>`Noldcur';
    replace `gapseq'=`i1' if _n>`Noldcur';
    if `"`rowlabel'"'!="" {;
      foreach L of var `rowlabel' {;
        replace `L'=`"`growlcur'"' if _n>`Noldcur';
      };
    };
  };
};

*
 Check that -rstring- is valid
 and reset it to missing otherwise
*;
if !inlist(`"`rstring'"',"name","label","labname","") {;
  disp as text `"Note: invalid rstring(`rstring') ignored"';
  local rstring "";
};

* Set non-by, non-rowlabel variables in gap observations *;
if `"`existvar'"'!="" {;
  foreach X of var `existvar' {;
    local nonbyrovar=1;
    if (`"`rowlabel'"'!="")|_by() {;
      foreach Y of var `_byvars' `rowlabel' {;
        if "`X'"=="`Y'" {;local nonbyrovar=0;};
      };
    };
    if `nonbyrovar' {;
      cap confirm string variable `X';
      if _rc==0 {;
        * String variable *;
        if `"`rstring'"'=="name" {;
          qui replace `X'=`"`X'"' if `gapindicator'==1;
        };
        else if `"`rstring'"'=="label" {;
          local Xlab:var lab `X';
          qui replace `X'=`"`Xlab'"' if `gapindicator'==1;
        };
        else if `"`rstring'"'=="labname" {;
          local Xlab:var lab `X';
          if `"`Xlab'"'!="" {;qui replace `X'=`"`Xlab'"' if `gapindicator'==1;};
          else {;qui replace `X'=`"`X'"' if `gapindicator'==1;};
        };
        else {;
          qui replace `X'="" if `gapindicator'==1;
        };
      };
      else {;
        * Numeric variable *;
        qui replace `X'=. if `gapindicator'==1;
      };
    };
  };
};

*
 Sort to original order
 (with gap observations placed according to -after- option)
 and add -neworder()- variable if requested
*;
if "`after'"=="" {;gsort `_byvars' `seqord' -`gapindicator' `gapseq';};
else {;gsort `_byvars' `seqord' `gapindicator' `gapseq';};
if "`neworder'"=="" {;
  tempvar neworder;
};
else {;
  confirm new var `neworder';
};
qui `bybyvars' gene long `neworder'=_n;
qui compress `neworder';
if "`_byvars'"=="" {;lab var `neworder' "Observation order";};
else {;lab var `neworder' "Observation order (within `_byvars')";};
sort `_byvars' `neworder';

*
 Set row labels to value of -grexpression- in gap observations
*;
if `"`grexpression'"'!="" & "`rowlabel'"!="" {;
  qui `bybyvars' replace `rowlabel'=(`grexpression') if `gapindicator'==1;
};

* Restore old data only if error happens or user presses -Break- *;
restore,not;

end;

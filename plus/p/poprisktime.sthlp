{smcl}
{* *! version 1.0  15dec2008}{...}
{cmd:help poprisktime}{right: ({browse "http://www.stata-journal.com/article.html?article=st0211":SJ10-4: st0211})}
{hline}

{title:Title}

{p2colset 5 20 22 2}{...}
{p2col :{hi: poprisktime} {hline 2}}Calculates population risk-time {p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 16 2}{cmd:poprisktime} {cmd:using} {it:filename}{cmd:,} 
{opth a:ge(varname)} {opt per:iod(varname)} {opt coh:ort(varname)} 
{opt c:ases(varname)} {opt agemin(#)} {opt agemax(#)} {opt permin(#)} 
{opt permax(#)} [{it:options}]

{marker options}{...}
{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{p2coldent :* {opt age(varname)}}specify age variable{p_end}
{p2coldent :* {opt period(varname)}}define period values{p_end}
{p2coldent :* {opt cohort(varname)}}define the variable that refers to the cohort values{p_end}
{p2coldent :* {opt cases(varname)}}specify number of cases{p_end}
{p2coldent :* {opt agemin(#)}}specify minimum age{p_end}
{p2coldent :* {opt agemax(#)}}specify maximum age {p_end}
{p2coldent :* {opt permin(#)}}specify minimum period{p_end}
{p2coldent :* {opt permax(#)}}specify maximum period{p_end}
{synopt :{opth pop(string)}}name the population variable in the using dataset; default assumes the variable is called {cmd:pop}{p_end}
{synopt :{opth poprisk:time(newvar)}}name the new variable created for the population risk-time; default is {cmd:poprisktime(Y)}{p_end}
{synopt :{opth cov:ariates(varlist)}}specify any covariates by which the data are split so they can be included in the merge{p_end}
{synopt :{opt miss:ingreplace}}specify whether the missing values for the {cmd:cases()} variable should be replaced with a zero 
in the merging process. This should be an appropriate assumption, unless missing data were present beforehand{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}* {opt age(varname)}, {opt period(varname)}, {opt coh:ort(varname)},
{opt cases(varname)}, {opt agemin(#)}, {opt agemax(#)}, {opt permin(#)}, and
{opt permax(#)} are required.{p_end}


{title:Description}

{pstd} {cmd:poprisktime} combines collapsed data from cancer registries and
disease registries with population data to specify the appropriate values of
population risk-time.  The master dataset must, therefore, contain data on
incidence and deaths that are split by age, period, and cohort in yearly intervals.

{pstd} Note: It is vital that the data are also split by cohort by using the patients'
date of birth information.  The master dataset can also be split by
covariates,
providing that they are specified in the {cmd:covariates()} option and that the using dataset is split by the same covariates.

{pstd} {cmd:using} {it:filename} is used to specify a file that contains the
relevant population data that are split into yearly intervals of age and
period.  This file should contain a variable for age, period, and population
figures.  It can also be split by a covariate, providing that the master
dataset is also split by the same covariate.  The variables used in this
dataset to refer to age and period must have the same names that are used in the
master dataset.

{pstd} The desired age and period ranges must be specified as part of the
{cmd:poprisktime} command using the max and min options.  Population figures
in the using dataset must be at least one year wider than these for both age
and period so the calculations will be carried out
without missing values.  It is possible to use population figures that have
much wider ranges than those specified in the command options.

{pstd} {cmd:poprisktime} uses formulas that are defined by an appropriate
weighting of the surrounding population figures to give a calculation
of the population risk-time in the triangular subsets of a Lexis diagram
(splitting by cohort).  Population figures split by age and calendar time (in
yearly intervals) are available for the majority of countries and regions of
countries.

{pstd} {cmd:poprisktime} calculates the population risk-time for data that are
split by age, period, and cohort.  The command also adjusts the values of age,
period, and cohort so that they are ready for an analysis via an
age-period-cohort model.  {cmd:poprisktime} returns the adjusted values of age,
period, and cohort, the calculated population risk-time and the number of
cases (incidence or deaths).  These new data are then in an appropriate form for the
{cmd:apcfit} command, which fits age-period-cohort models using restricted
cubic splines.


{title:Options}

{phang} {opth age(varname)} specifies the age variable that must have
the same name in both datasets.  In the population dataset (the using
dataset),
age values one less and one greater than those specified by {cmd:agemax()} and
{cmd:agemin()} are required to avoid missing values.

{phang} {opt period(varname)} specifies the period variable that
must have the same name in both datasets.  In the population dataset (the using
dataset), period values one greater than that specified by {cmd:permax()} are
required.  Population data are also necessary for at least as low at the
{cmd:permin()} value.  Missing values will be generated for the population
risk-time variable if the population data do not at least satisfy these
requirements.

{phang} {opt cohort(varname)} specifies the cohort variable in the master
dataset.

{phang} {opt cases(varname)} specifies the variable in the master dataset
that contains the number of cases.

{phang} {opt agemin(#)} specifies the minimum age in the output dataset.  In
the population dataset (the using dataset), an age that is less than this is
required.

{phang} {opt agemax(#)} specifies the maximum age in the output dataset.  In
the population dataset (the using dataset), an age that is greater than this
is required.

{phang} {opt permin(#)} specifies the minimum period in the output dataset.  In
the
population dataset (the using dataset), a period that is equal to or less
than this is required.

{phang} {opt permax(#)} specifies the maximum period in the output dataset.
In the population dataset (the using dataset), a period that is greater than
this is required.

{phang} {opth pop(string)} specifies the name of the variable in the using
dataset that refers to the population figures.  If this option is not
specified, it is assumed that the variable is called {cmd:pop}.

{phang} {opth poprisktime(newvar)} specifies the name of the new variable
that is added to the file to specify the population risk-time.  The default is
to name the variable {cmd:Y}.

{phang} {opth covariates(varlist)} can specify any covariates, such as a sex
variable, by which the two datasets are split.  If this option is specified,
the covariates are included in the {cmd:merge} statement.  If the dataset is
split by covariates, this option must be specified so that the variables by
which the data are merged uniquely identify the observations in the datasets.
Both datasets must be split by the same covariates.

{phang} {opt missingreplace} specifies whether the missing values for the
cases variable should be replaced with a zero in the merging process.  This
should be an appropriate assumption, unless missing data were present in the
data beforehand.  If {cmd:missingreplace} is not specified, the {cmd:cases()}
variable is likely to contain missing values.  A warning is given to indicate the presence of missing
values that most probably should be replaced with values of 0.


{title:Examples}

{pstd} The basic specification of the data that are ready for merging: {p_end}
{phang2} {cmd:. poprisktime using popdata, age(A) period(P) cohort(C) agemin(20) agemax(80) permin(1980) permax(2003) cases(D) missingreplace} {p_end}
 
{pstd} Used to generate a final dataset that is split by sex: {p_end}
{phang2} {cmd:. poprisktime using popdatawithsex, age(A) period(P) cohort(C) agemin(20) agemax(80) permin(1980) permax(2003) cases(D) covariates(sex) missingreplace} {p_end}


{title:Authors}

{pstd}Mark J. Rutherford{p_end}
{pstd}Department of Health Sciences{p_end}
{pstd}University of Leicester, UK {p_end}
{pstd}mjr40@le.ac.uk{p_end}
  
{pstd}Paul C. Lambert{p_end}
{pstd}Department of Health Sciences{p_end}
{pstd}University of Leicester, UK{p_end}
{pstd}paul.lambert@le.ac.uk{p_end}

{pstd}John R. Thompson{p_end}
{pstd}Department of Health Sciences{p_end}
{pstd}University of Leicester, UK {p_end}
{pstd}john.thompson@le.ac.uk{p_end}


{title:Also see}

{p 4 14 2}Article:  {it:Stata Journal}, volume 10, number 4: {browse "http://www.stata-journal.com/article.html?article=st0211":st0211}

{p 4 14 2}{space 3}Help:  {helpb apcfit} (if installed){p_end}

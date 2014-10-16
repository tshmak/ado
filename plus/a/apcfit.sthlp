{smcl}
{* *! version 1.0  19nov2008}{...}
{cmd:help apcfit}{right: ({browse "http://www.stata-journal.com/article.html?article=st0211":SJ10-4: st0211})}
{hline}

{title:Title}

{p2colset 8 18 20 2}{...}
{p2col :{hi: apcfit} {hline 2}}Fit age-period-cohort models using restricted cubic splines{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 16 2}{cmd:apcfit} {ifin}{cmd:,} {opth a:ge(varname)} {opth c:ases(varname)} {opth pop:risktime(varname)} [{it:options}]

{marker options}{...}
{synoptset 32 tabbed}{...}
{synopthdr}
{synoptline}
{p2coldent :* {opt age(varname)}}specify age variable{p_end}
{p2coldent :* {opt cases(varname)}}specify number of cases{p_end}
{p2coldent :* {opt poprisktime(varname)}}specify population risk-time (person-years){p_end}
{synopt :{opt p:eriod(varname)}}define period values{p_end}
{synopt :{opth coh:ort(varname)}}define the variable that refers to the cohort values {p_end}
{synopt :{opth agef:itted(newvar)}}define the new variable names for the fitted age values {p_end}
{synopt :{opt perf:itted(newvar)}}define the new variable names for the fitted period values {p_end}
{synopt :{opt cohf:itted(newvar)}}define the new variable names for the fitted cohort values {p_end}
{synopt :{opt refp:er(#)}}define the reference period{p_end}
{synopt :{opt refc:oh(#)}}define the reference cohort{p_end}
{synopt :{cmdab:dre:xtr(}{cmd:weighted}|{cmd:holford)}}specify method of drift extraction; default is {cmd:drextr(weighted)}{p_end}
{synopt :{cmdab:par:am(}{cmd:ACP}|{cmd:APC}|{cmd:AdCP}|{cmd:AdPC}|{cmd:AP}|{cmd:AC)}}specify parameterization of the age-period-cohort model; default is {cmd:param(ACP)} {p_end}
{synopt :{opt lev:el(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synopt :{opt dfa(#)}}set degrees of freedom for the splines for the age variable.{p_end}
{synopt :{opt dfp(#)}}set degrees of freedom for the splines for the period variable{p_end}
{synopt :{opt dfc(#)}}set degrees of freedom for the splines for the cohort variable{p_end}
{synopt :{opt nper(#)}}set units to be used in reported rates{p_end}
{synopt :{opth bknotsa:(numlist)}}define the lower and upper boundary knots for the age variable; default is the upper and lower values {p_end}
{synopt :{opth bknotsp:(numlist)}}define the lower and upper boundary knots for the period variable; default is the upper and lower values{p_end}
{synopt :{opth bknotsc:(numlist)}}define the lower and upper boundary knots for the cohort variable; default is the upper and lower values{p_end}
{synopt :{opth knotsa:(numlist)}}define the knots for the age variable if the {cmd:dfa()} option is not used{p_end}
{synopt :{opth knotsp:(numlist)}}define the knots for the period variable if the {cmd:dfp()} option is not used{p_end}
{synopt :{opth knotsc:(numlist)}}define the knots for the cohort variable if the {cmd:dfc()} option is not used{p_end}
{synopt :{cmdab:knotpl:acement(}{cmd:equal}|{cmd:weighted)}}specify method of knot placement; default is {cmd:knotplacement(equal)}{p_end}
{synopt :{opt adj:ust}}specify that the constrained variable is given relative to a reference point rather than averaging to zero on the log scale{p_end}
{synopt :{opt replace}}specify that the default fitted value variables should be overwritten{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}* {opt age(varname)}, {opt cases(varname)}, and {opt poprisktime(varname)} are required.{p_end}


{title:Description}

{pstd}
{cmd:apcfit} fits age-period-cohort models using spline functions to model the
variables as continuous variables, rather than the traditional method of
fitting them as factors. It uses matrix transformations of the spline basis
functions to give interpretable results in the output.

{pstd}
Having obtained the transformed spline basis functions for each of the
variables, {cmd:apcfit} uses a generalized linear model with a Poisson family
error structure and an offset of {cmdab:ln(}{cmdab:poprisktime)}.  On the
basis that the command calls upon the {helpb glm} command, the commands listed
in {manhelp glm_postestimation R:glm postestimation} can be used.


{title:Options}

{phang} {opth age(varname)} specifies the variable that refers to the
age values.  {cmd:age()} is required.

{phang}
{opt cases(varname)} specifies the variable that refers to the number of cases
or deaths for a given age and period.  {cmd:cases()} is required.

{phang}
{opt poprisktime(varname)} specifies the variable that refers to the
population risk-time (person-years) for a given age and period.  The
population risk-time can be calculated using the {cmd:poprisktime} command.
This is a required option.  {cmd:poprisktime()} is required.

{phang}
{opt period(varname)} specifies the variable that refers to the
period values.  This variable must be specified in all cases except when
the age-cohort parameterization option is specified.

{phang} {opth cohort(varname)} specifies the variable that refers to the
cohort values.  If this variable is not given, the cohort values are
calculated from the period and age variables according to the equality
{cmd:cohort} = {cmd:period} - {cmd:age}.

{phang}
{opth agefitted(newvar)} can specify the name of the fitted rate values
given for age in the output.  The default is {cmd:agefitted(agefitted)}.  This
can be useful when the user wants to compare the results of more than one
parameterization.

{phang}
{opt perfitted(newvar)} can specify the name of the fitted
relative risk (RR) values given for period in the output.  The default is
{cmd:perfitted(perfitted)}.  This can be useful when the user wants to compare the
results of more than one parameterization.

{phang}
{opt cohfitted(newvar)} can specify the name of the fitted RR
values given for cohort in the output.  The default is
{cmd:cohfitted(cohfitted)}.  This can be useful when the user wants to compare
the results of more than one parameterization.

{phang}
{opt refper(#)} can specify the reference period for the model.
The default is to take the reference period to be the median date of diagnosis
among the cases.

{phang}
{opt refcoh(#)} can specify the reference cohort for the model.
The default is to take the reference cohort to be the median date of birth
among the cases.

{phang} {opth drextr(string)} specifies the method of drift extraction for the
model.

{pmore}
{cmdab:drextr(}{cmdab:weighted)} lets the drift extraction depend on the
weighted average (by number of cases) of the period and cohort effects.  The
default is {cmd:drextr(weighted)}.

{pmore}
{cmdab:drextr(}{cmdab:holford)} uses a na{c i:}ve average over all the values of
the estimated effects, disregarding the number of cases.

{phang}
{cmd:param(ACP}|{cmd:APC}|{cmd:AdCP}|{cmd:AdPC}|{cmd:AP}|{cmd:AC)} specifies
the parameterization of the age-period-cohort model.

{pmore}
{cmdab:param(}{cmdab:ACP)} dictates that the age effects should be rates for
the reference cohort, the cohort effects should be RRs relative to the
reference cohort, and the period effects should be RR constrained to be 0 on
average (on the log scale) with 0 slope.  The default is {cmd:param(ACP)}.

{pmore}
{cmdab:param(}{cmdab:APC)} dictates that the age effects should be rates
relative to the reference period, the period effects should be RR relative to
the reference period, and the cohort effects should be RR constrained to be 0
on average (on the log scale) with 0 slope.

{pmore}
{cmdab:param(}{cmdab:AdCP)} dictates that the age effects should be rates for
the reference cohort, and the cohort and period effects should be RR
constrained to be 0 on average (on the log scale) with 0 slope.  The drift term
is missing from this model, and so the fitted values do not multiply to the
fitted rates.

{pmore}
{cmdab:param(}{cmdab:AdPC)} dictates that the age effects should be rates for
the reference period, and the cohort and period effects should be RR
constrained to be 0 on average (on the log scale) with 0 slope.  The drift term
is missing from this model, and so the fitted values do not multiply to the
fitted rates.

{pmore}
{cmdab:param(}{cmdab:AP)} dictates that the age effects should be rates for the reference period, and the period effects should be RR relative
to the reference period.  The cohort effects are not included in this model.  Therefore, there is no identifiability issue.

{pmore}
{cmdab:param(}{cmdab:AC)} dictates that the age effects should be rates for
the reference cohort, and the cohort effects should be RR relative to the
reference cohort.  The period effects are not included in this model.
Therefore, there is no identifiability issue.

{phang}
{opt level(#)} specifies the confidence level, as a percentage, for confidence
intervals.  The default is {cmd:level(95)}.

{phang}
{opt dfa(#)}, {opt dfp(#)}, {opt dfc(#)} specify the degrees of freedom used for
the natural (restricted) cubic spline function used for the variables (age, period, and
cohort).  {it:#} can take any value within reason, but the default value is
set to 5 for all 3 of the variables.  The knots are placed at the following
centiles of the distributions for the variables (for df<=10):

        {hline 62}
        df  Knots        Centile positions
        {hline 62}
         1    0    (no knots)
         2    1    50
         3    2    33    67
         4    3    25    50    75
         5    4    20    40    60    80
         6    5    17    33    50    67    83
         7    6    14    29    43    57    71    86
         8    7    12.5  25    37.5  50    62.5  75    87.5
         9    8    11.1  22.2  33.3  44.4  55.6  66.7  77.8  88.9
        10    9    10    20    30    40    50    60    70    80    90     
        {hline 62}

{pmore} Note: These are internal knots, and there are also boundary
knots placed at the minimum and maximum of the relevant variables (unless the
boundary knot specification is also used).  The user can also specify 
knots using the {cmd:knotsa()}, {cmd:knotsp()}, and {cmd:knotsc()} options.

{phang}
{opt nper(#)} specifies the units to be used in reported rates.  For example,
if the analysis time is in years, specifying {cmd:nper(1000)} results in rates
per 1000 person-years.  The default is {cmd:nper(1)}.

{phang}
{opth bknotsa(numlist)}, {opt bknotsp(numlist)}, and {opt bknotsc(numlist)}
specify the boundary knots for the relevant variables (age, period, and
cohort) if a {cmd:df}*{cmd:()} option is used.  The default is to take the
minimum and maximum of the variables.  However, it may be necessary to use
boundary knots within the range of the data and to force the splines to be
linear beyond those points.  The option requires the specification of the
lower and upper boundary knots in the form of a numlist and maps onto the
option to specify boundary knots in {helpb rcsgen}.

{phang}
{opt knotsa(numlist)}, {opt knotsp(numlist)}, and {opt knotsc(numlist)}
specify the knots for the relevant variables (age, period, and cohort).  The
default is to use the {cmd:df(5)} option for each variable.  However, it is
possible with a {cmd:bknots}*{cmd:()} option for the user to specify all the
knots to be used, including the boundary knots.  The option requires the
specification of all the knots in the form of a numlist and maps onto the
option to specify the knots in {cmd:rcsgen}.

{phang} {cmd:knotplacement(equal}|{cmd:weighted)} specifies the method of knot
placement for the spline terms.

{pmore}
{cmdab:knotplacement(}{cmdab:equal)} means that the knots are placed at
equally spaced centiles of the respective variables, depending on the number of
knots that are used.  This is the default.

{pmore}
{cmdab:knotplacement(}{cmdab:weighted)} means that the knots are placed at
centiles of the variables that are dependent on the number of cases.  For
example, if there are more cases in the higher ages, the knots would be
concentrated at the higher ages.

{phang}
{opt adjust} specifies that the constrained variable be given
relative to a reference point rather than averaging to zero on the log scale.
This option cannot be applied to the age-period and age-cohort
parameterization.  This option alters the variable that is constrained to be
0 on average (on the log scale) with 0 slope to still have 0 slope but to make
the RRs relative to the reference point that is specified (or the median, if
not specified).  Adjusting the third variable to be relative to a reference
point alters the interpretation of the age effects.

{phang}
{opt replace} specifies that the default fitted value variables for
age, period, and cohort should be replaced by the new run of the command.  This
will work only if the default names are used for the original model and if
all the variables are still in the dataset.


{title:Examples}

{pstd} Simply defining the data: {p_end}
{phang2} {cmd:. apcfit, age(A) period(P) cases(D) poprisktime(Y)} {p_end}
 
{pstd} Using the {cmd:if} qualifier to fit different models for covariates: {p_end}
{phang2} {cmd:. apcfit if sex==1, age(A) period(P) cases(D) poprisktime(Y)} {p_end}

{pstd} Altering the degrees of freedom used for the spline functions: {p_end}
{phang2} {cmd:. apcfit, age(A) period(P) cases(D) poprisktime(Y) dfa(6) dfp(6) dfc(8)} {p_end}

{pstd} Using a different parameterization for the model: {p_end}
{phang2} {cmd:. apcfit, age(A) period(P) cases(D) poprisktime(Y) param(APC)} {p_end}

{pstd} Using a weighted placement for the knots for the model: {p_end}
{phang2} {cmd:. apcfit, age(A) period(P) cases(D) poprisktime(Y) knotplacement(weighted)} {p_end}


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

{p 4 14 2}{space 3}Help:  {manhelp glm_postestimation R:glm postestimation}, {helpb poprisktime} (if installed){p_end}

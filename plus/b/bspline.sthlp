{smcl}
{cmd:help bspline}, {cmd:help frencurv}, {cmd:help flexcurv}{right: ({browse "http://www.stata-journal.com/article.html?article=sg151_2":SJ12-3: sg151_2})}
{hline}

{title:Title}

{p2colset 5 16 18 2}{...}
{p2col :{hi:bspline} {hline 2}}B-splines and splines parameterized by their values at reference points{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 21 2}
{cmd:bspline} [{help newvarlist:{it:newvarlist}}] {ifin}{cmd:,} {cmdab:x:var(}{varname}{cmd:)}
  [{opt p:ower(#)}
    {cmdab:k:nots}{cmd:(}{help numlist:{it:numlist}}{cmd:)} {cmdab:noexk:not}
    {opt g:enerate(prefix)} {cmdab:t:ype}{cmd:(}{help datatype:{it:type}}{cmd:)}
    {cmdab:lab:fmt}{cmd:(}{help format:{it:format}}{cmd:)}
    {cmdab:labp:refix}{cmd:(}{it:string}{cmd:)}]

{p 8 21 2}
{cmd:frencurv} [{it:newvarlist}] {ifin}{cmd:,}
 {cmdab:x:var(}{it:varname}{cmd:)}
  [{opt p:ower(#)}
    {cmdab:r:efpts}{cmd:(}{it:numlist}{cmd:)} {cmdab:noexr:ef} {opt om:it(#)} {opt ba:se(#)}
    {cmdab:k:nots}{cmd:(}{it:numlist}{cmd:)} {cmdab:noexk:not}
    {opt g:enerate(prefix)} {cmdab:t:ype}{cmd:(}{it:type}{cmd:)}
    {cmdab:lab:fmt}{cmd:(}{it:format}{cmd:)}
    {cmdab:labp:refix}{cmd:(}{it:string}{cmd:)}]

{p 8 21 2}
{cmd:flexcurv} [{it:newvarlist}] {ifin}{cmd:,} 
 {cmdab:x:var(}{it:varname}{cmd:)}
  [{opt p:ower(#)}
    {cmdab:r:efpts}{cmd:(}{it:numlist}{cmd:)} {opt om:it(#)} {opt ba:se(#)}
    {cmdab:inc:lude}{cmd:(}{it:numlist}{cmd:)} {cmdab:kru:le}{cmd:(}{cmdab:r:egular}|{cmdab:i:nterpolate}{cmd:)}
    {opt g:enerate(prefix)} {cmdab:t:ype}{cmd:(}{it:type}{cmd:)}
    {cmdab:lab:fmt}{cmd:(}{it:format}{cmd:)}
    {cmdab:labp:refix}{cmd:(}{it:string}{cmd:)}]


{title:Description}

{pstd}The {cmd:bspline} package contains three commands: {cmd:bspline},
{cmd:frencurv}, and {cmd:flexcurv}.  {cmd:bspline} generates a basis of
B-splines in the X variate based on a list of knots for use in the
design matrix of a regression model.  {cmd:frencurv} generates a basis
of reference splines for use in the design matrix of a regression model,
with the property that the parameters estimated will be values of the
spline at a list of reference points.  {cmd:flexcurv} is an easy-to-use
version of {cmd:frencurv} that generates reference splines with
regularly spaced knots or with knots interpolated between the reference
points.  {cmd:frencurv} and {cmd:flexcurv} have the additional option of
generating an incomplete basis of reference splines, which can be
completed by the addition of the standard constant variable used in
regression models.  The splines are either given the names in the 
{help newvarlist:{it:newvarlist}} (if present) or (more usually)
generated as a list of numbered variables, prefixed by the
{cmd:generate()} option.  Usually (but not always), the regression
command is called using the {cmd:noconstant} option.


{title:Options for use with bspline and frencurv}

{phang}{cmd:xvar(}{varname}{cmd:)} specifies the X variable on which the
splines are to be based.  {cmd:xvar()} is required.

{phang}{opt power(#)} (a nonnegative integer) specifies the power (or
degree) of the splines.  Examples are 0 for constant, 1 for linear, 2
for quadratic, 3 for cubic, 4 for quartic, or 5 for quintic.  The
default is {cmd:power(0)}.

{phang}{cmd:knots(}{help numlist:{it:numlist}}{cmd:)} specifies a list of at
least two knots on which the splines are to be based.  If {cmd:knots()} is not
specified, then {cmd:bspline} will initialize the list to the minimum and
maximum of the {cmd:xvar()} variable, and {cmd:frencurv} will create a list of
knots equal to the reference points (in the case of odd-degree splines such as
linear, cubic, or quintic) or midpoints between reference points (in the case
of even-degree splines such as constant, quadratic, or quartic).
{cmd:flexcurv} does not have the {cmd:knots()} option, because it automatically
generates a list of knots containing the required number of knots "sensibly"
spaced on the {cmd:xvar()} scale.

{phang}{cmd:noexknot} specifies that the original knot list not be
extended.  If {cmd:noexknot} is not specified, then the knot list is
extended on the left and right by a number of extra knots on each side
specified by {cmd:power()}, spaced by the distance between the first and
last two original knots, respectively.  {cmd:flexcurv} does not have the
{cmd:noexknot} option, because it specifies the knots automatically.

{phang}{opt generate(prefix)} specifies a prefix for the names of the
generated splines, which (if there is no 
{help newvarlist:{it:newvarlist}}) will be named as {it:prefix}{hi:1},
..., {it:prefixN}, where {it:N} is the number of splines.

{phang}{cmd:type(}{help datatype:{it:type}}{cmd:)} specifies the storage
type of the splines generated ({cmd:float} or {cmd:double}).  If
{it:type} is specified as anything else (or if {cmd:type()} is not specified),
then {it:type} is set to {cmd:float}.

{phang}{cmd:labfmt(}{help format:{it:format}}{cmd:)} specifies the
format used in the variable labels for the generated splines.  If
{cmd:labfmt()} is not specified, then the format is set to the format of the
{cmd:xvar()} variable.

{phang}{cmd:labprefix(}{it:string}{cmd:)} specifies the prefix used in the
variable labels for the generated splines.  If {cmd:labprefix()} is not
specified, then the prefix is set to {cmd:"Spline at "} for {cmd:flexcurv} and
{cmd:frencurv} and to {cmd:"B-spline on "} for {cmd:bspline}.


{title:Options for use with frencurv}

{phang}{cmd:refpts(}{it:numlist}{cmd:)} specifies a list of at least two
reference points, with the property that if the splines are used in a
regression model, then the estimated parameters will be values of the spline at
those points.  If {cmd:refpts()} is not specified, then the list is initialized
to a list of two points equal to the minimum and maximum of the {cmd:xvar()}
variable.  If the {cmd:omit()} option is specified with {cmd:flexcurv} or
{cmd:frencurv}, and the spline corresponding to the omitted reference point is
replaced with a standard constant term in the regression model, then the
estimated parameters will be relative values of the spline (differences or
ratios) compared with the value of the spline at the omitted reference point.

{phang}{cmd:noexref} specifies that the original reference list not be
extended.  If {cmd:noexref} is not specified, then the reference list is
extended on the left and right by a number of extra reference points on
each side equal to {cmd:int(}{it:power}{cmd:/2)}, where {it:power} is
the value of the {cmd:power()} option, spaced by the distance between
the first and last two original reference points, respectively.  If
{cmd:noexref} and {cmd:noexknot} are both specified, then the number of
knots must equal the number of reference points plus {it:power}{cmd:+1}.
{cmd:flexcurv} does not have the {cmd:noexref} option, because it
automatically chooses the knots and does not extend the reference
points.

{phang}{opt omit(#)} specifies a reference point that must be present in
the {cmd:refpts()} list (after any extension requested by
{cmd:frencurv}) and whose corresponding reference spline will be omitted
from the set of generated splines.  If the user specifies {cmd:omit()},
then the set of generated splines will not be a complete basis of the
set of splines with the specified power and knots, but can be completed
by the addition of a constant variable equal to 1 in all observations.
If the user then uses the generated splines as predictor variables for a
regression command such as {helpb regress} or {helpb glm}, then the
{cmd:noconstant} option should usually not be used.  And if the omitted
reference point is in the completeness region of the basis, then the
intercept parameter {cmd:_cons} will be the value of the spline at the
omitted reference point, and the model parameters corresponding to the
generated reference splines will be differences between the values of
the spline at the corresponding reference points and the value of the
spline at the omitted reference point.  If {cmd:omit()} is not
specified, then the generated reference splines form a complete basis of
the set of splines with the specified power and knots.  If the user then
uses the generated splines as predictor variables for a regression
command such as {cmd:regress} or {cmd:glm}, then the {cmd:noconstant}
option should be used, and the fitted model parameters corresponding to
the generated splines will be the values of the spline at the
corresponding reference points.

{phang}{opt base(#)} is an alternative to {cmd:omit()} for use in Stata
11 or higher.  It specifies a reference point that must be present in
the {cmd:refpts()} list (after any extension requested by
{cmd:frencurv}) and whose corresponding reference spline will be set to
0.  If the user specifies {cmd:base()}, then the set of generated
splines will not be a complete basis of the set of splines with the
specified power and knots, but can be completed by the addition of a
constant variable equal to 1 in all observations.  The generated splines
can then be used in the design matrix by a Stata 11 (or higher)
estimation command.


{title:Options for use with flexcurv only}

{pstd}Note that {cmd:flexcurv} uses all the options available to
{cmd:frencurv} except for {cmd:knots()}, {cmd:noexknot}, and
{cmd:noexref}.

{phang}{cmd:include(}{it:numlist}{cmd:)} specifies a list of additional
numbers to be included within the boundaries of the completeness region
of the spline basis, as well as the available values of the {cmd:xvar()}
variable and the {cmd:refpts()} values (if provided).  This allows the
user to specify a nondefault infimum or supremum for the completeness
region of the spline basis.  If {cmd:include()} is not provided, then
the completeness region will extend from the minimum to the maximum of
the values available either in the {cmd:xvar()} variable or in the
{cmd:refpts()} list.

{phang}{cmd:krule(}{cmd:regular}|{cmd:interpolate}{cmd:)} specifies a
rule for generating knots based on the reference points, which may be
{cmd:regular} (the default) or {cmd:interpolate}.  If {cmd:regular} is
specified, then the knots are spaced regularly over the completeness
region of the spline.  If {cmd:interpolate} is specified, then the knots
are interpolated between the reference points in a way that produces the
same knots as {cmd:krule(regular)} if the reference points are regularly
spaced.  Whichever {cmd:krule()} option is specified, any extra knots to
the left of the completeness region are regularly spaced with a spacing
equal to that between the first two knots of the completeness region,
and any extra knots to the right of the completeness region are
regularly spaced with a spacing equal to that between the last two knots
of the completeness region.  Therefore, {cmd:krule(regular)} specifies
that all knots be regularly spaced whether or not the reference points
are regularly spaced, whereas {cmd:krule(interpolate)} specifies that
the knots be interpolated between the reference points in a way that
will cause reference splines to be definable, even if the reference
points are not regularly spaced.


{title:Remarks}

{pstd}The splines generated are intended for use in the {it:varlist} of
an estimation command (for example, {helpb regress} or {helpb glm}),
typically with a {cmd:noconstant} option (except if the {cmd:omit()} or
{cmd:base()} option is specified with {cmd:frencurv} or {cmd:flexcurv}).
The rules look complicated, but they are designed to give simple
defaults for most users (especially if {cmd:flexcurv} is used) and also
a powerful choice of options for programmers and advanced users.  The
principles and definitions of B-splines are given in de Boor (1978) and
Ziegler (1969).  {cmd:frencurv} and {cmd:flexcurv} calculate the
reference splines by calling {cmd:bspline} to calculate B-splines based
on the reference points, the {cmd:xvar()} variable, and the
{cmd:include()} option (if supplied to {cmd:flexcurv}).  They then
invert the matrix of the B-splines for the reference points to generate
a transformation matrix, which is used to transform the B-splines to
reference splines.  The principles and definitions of reference splines
are given in detail by Newson (2000).

{pstd}Full documentation of the {cmd:bspline} package (including Methods
and Formulas) is provided in the file {cmd:bspline.pdf}, which is
distributed with the {cmd:bspline} package as an ancillary file (see
{helpb help net}).  It can be viewed using the Adobe Acrobat Reader,
which can be downloaded from 
{browse "http://www.adobe.com/products/acrobat/readermain.html"}.


{title:Examples}

{pstd}These examples demonstrate the fitting of a spline model of
{cmd:mpg} with respect to {cmd:weight} in {cmd:auto.dta} shipped with
official Stata.

{pstd}Setup

{phang2}{cmd:. sysuse auto}{p_end}
{phang2}{cmd:. describe}{p_end}

{pstd}The following example demonstrates the use of {cmd:flexcurv} to
define a basis of cubic reference splines in {cmd:weight}, with
regularly spaced knots and regularly spaced reference points.  We then
use {cmd:regress} with the {cmd:noconstant} option to fit a spline
regression model whose parameters ({cmd:cs1} to {cmd:cs5}) are the
values of the spline at the reference points, each equal to the fitted
conditional mean of {cmd:mpg} for cars with {cmd:weight} equal to the
corresponding reference point.  Differences between conditional means
can then be fit (with confidence limits) using {helpb lincom}.  Finally,
we use {helpb predict} to compute the predicted values of {cmd:mpg} for
all cars, and we plot the observed and fitted values of {cmd:mpg}
against {cmd:weight}.

{phang2}{cmd:. flexcurv, xvar(weight) refpts(1760(770)4840) generate(cs) power(3)}{p_end}
{phang2}{cmd:. describe cs*}{p_end}
{phang2}{cmd:. regress mpg cs*, vce(robust) noconstant}{p_end}
{phang2}{cmd:. lincom cs3-cs5}{p_end}
{phang2}{cmd:. predict mpghat3}{p_end}
{phang2}{cmd:. scatter mpg weight, msym(circle_hollow) || line mpghat3 weight, sort ||, xlab(1760(770)4840) ylab(0(5)45) legend(row(1))}{p_end}

{pstd}The following example demonstrates the use of {cmd:flexcurv} with
the {cmd:omit()} option to fit the same model as the previous example,
generating an incomplete basis of reference splines by omitting the
reference spline for a {cmd:weight} of 1,760 U.S. pounds.  We then use
{cmd:regress} without the {cmd:noconstant} option to fit the spline
model.  The parameters in this case are the constant term {cmd:_cons},
equal to the conditional mean {cmd:mpg} for cars with the omitted
{cmd:weight} of 1,760 U.S. pounds, and the cubic spline parameters
{cmd:cs2} to {cmd:cs5}, equal to the difference in conditional means of
{cmd:mpg} between cars with a {cmd:weight} equal to the corresponding
reference point and cars with a {cmd:weight} equal to the omitted
reference point of 1,760 U.S. pounds.  Again we can use {cmd:lincom} to
estimate differences between means for nonomitted reference points, and
we can use {cmd:predict} to compute the fitted values of {cmd:weight},
which are the same as in the previous example.

{phang2}{cmd:. flexcurv, xvar(weight) refpts(1760(770)4840) omit(1760) generate(ics) power(3)}{p_end}
{phang2}{cmd:. describe ics*}{p_end}
{phang2}{cmd:. regress mpg ics*, vce(robust)}{p_end}
{phang2}{cmd:. lincom ics3-ics5}{p_end}
{phang2}{cmd:. predict mpghat3a}{p_end}
{phang2}{cmd:. scatter mpg weight, msym(circle_hollow) || line mpghat3a weight, sort ||, xlab(1760(770)4840) ylab(0(5)45) legend(row(1))}{p_end}

{pstd}The following example demonstrates the use of {cmd:frencurv} to
fit the same model again, this time with reference points equal to the
knots in and around the completeness region of the spline.  This results
in the list of reference points being extended on the left and on the
right by two reference points outside the completeness region, whose
corresponding spline parameters represent the behavior of the spline as
it converges back to 0 outside its completeness region.  These two extra
parameters are not easy to explain to nonmathematicians.

{phang2}{cmd:. frencurv, xvar(weight) refpts(1760 3300 4840) generate(kcs) power(3)}{p_end}
{phang2}{cmd:. describe kcs*}{p_end}
{phang2}{cmd:. regress mpg kcs*, vce(robust) noconstant}{p_end}
{phang2}{cmd:. predict mpghat3b}{p_end}
{phang2}{cmd:. scatter mpg weight, msym(circle_hollow) || line mpghat3b weight, sort ||, xlab(1760 3300 4840) ylab(0(5)45) legend(row(1))}{p_end}

{pstd}The following example uses {cmd:frencurv} to fit the same model as
the previous example, using the {cmd:omit()} option to omit the
reference spline corresponding to the reference point (and knot) at
1,760 U.S. pounds.  This time, the parameter {cmd:_cons} represents the
mileage at 1,760 U.S. pounds; the parameters {cmd:ikcs2} and {cmd:ikcs3}
represent the differences between the mileages at 3,300 and 4,840 U.S.
pounds (respectively) and the mileage at 1,760 pounds; and the
parameters {cmd:ikcs1} and {cmd:ikcs5} represent the behavior of the
spline as it converges back to 0 outside its completeness region.

{phang2}{cmd:. frencurv, xvar(weight) refpts(1760 3300 4840) omit(1760) generate(ikcs) power(3)}{p_end}
{phang2}{cmd:. describe ikcs*}{p_end}
{phang2}{cmd:. regress mpg ikcs*, vce(robust)}{p_end}
{phang2}{cmd:. predict mpghat3c}{p_end}
{phang2}{cmd:. scatter mpg weight, msym(circle_hollow) || line mpghat3c weight, sort ||, xlab(1760 3300 4840) ylab(0(5)45) legend(row(1))}{p_end}

{pstd}
The following example demonstrates the use of {cmd:bspline} to fit the
same model as the previous examples, generating a basis of Schoenberg
B-splines.  We then use {helpb regress} with the {cmd:noconstant} option
to fit the spline model.  The parameters in this case correspond to the
B-splines and are again expressed in units of the Y variable {cmd:mpg}.
They are not easy to interpret in a way that nonmathematicians will
understand, nor are the differences between parameters that might be
estimated using {cmd:lincom}.  However, we can still use {helpb predict}
to compute fitted values for {cmd:mpg}, which (together with the
observed values) can be plotted against {cmd:weight} exactly as before.

{phang2}{cmd:. bspline, xvar(weight) knots(1760 3300 4840) generate(bs) power(3)}{p_end}
{phang2}{cmd:. describe bs*}{p_end}
{phang2}{cmd:. regress mpg bs*, vce(robust) noconstant}{p_end}
{phang2}{cmd:. predict mpghat3d}{p_end}
{phang2}{cmd:. scatter mpg weight, msym(circle_hollow) || line mpghat3d weight, sort ||, xlab(1760 3300 4840) ylab(0(5)45) legend(row(1))}{p_end}


{title:Saved results}

{pstd}
{cmd:bspline}, {cmd:frencurv}, and {cmd:flexcurv} save the following results in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(xsup)}}upper bound of completeness region{p_end}
{synopt:{cmd:r(xinf)}}lower bound of completeness region{p_end}
{synopt:{cmd:r(nincomp)}}number of X values out of completeness region{p_end}
{synopt:{cmd:r(nknot)}}number of knots{p_end}
{synopt:{cmd:r(nspline)}}number of splines{p_end}
{synopt:{cmd:r(power)}}power (or degree) of splines{p_end}

{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(knots)}}final list of knots{p_end}
{synopt:{cmd:r(splist)}}{it:varlist} of generated splines{p_end}
{synopt:{cmd:r(labfmt)}}format used in spline variable labels{p_end}
{synopt:{cmd:r(labprefix)}}prefix used in spline variable labels{p_end}
{synopt:{cmd:r(type)}}storage type of splines ({cmd:float} or {cmd:double}){p_end}
{synopt:{cmd:r(xvar)}}X variable specified by {cmd:xvar()} option{p_end}

{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(knotv)}}row vector of knots{p_end}
{p2colreset}{...}

{pstd}{cmd:frencurv} and {cmd:flexcurv} save all the above results in
{cmd:r()} and also save the following:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(omit)}}omitted reference point specified by {cmd:omit()}{p_end}
{synopt:{cmd:r(base)}}base reference point specified by {cmd:base()}{p_end}

{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(refpts)}}final list of reference points{p_end}

{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(refv)}}row vector of reference points{p_end}
{p2colreset}{...}

{pstd}The result {cmd:r(nincomp)} is the number of values of the
{cmd:xvar()} variable outside the completeness region of the space of
splines defined by the reference splines or B-splines.  The number lists
{cmd:r(knots)} and {cmd:r(refpts)} are the final lists after any left
and right extensions carried out by {cmd:bspline}, {cmd:frencurv}, or
{cmd:flexcurv}; the vectors {cmd:r(knotv)} and {cmd:r(refv)} contain the
same values in double precision (mainly for programmers).  The scalars
{cmd:r(xinf)} and {cmd:r(xsup)} are knots, such that the completeness
region is {cmd:r(xinf)} <= x <= {cmd:r(xsup)} for positive-degree
splines and {cmd:r(xinf)} <= x < {cmd:r(xsup)} for zero-degree splines.

{pstd}In addition, {cmd:bspline}, {cmd:frencurv}, and {cmd:flexcurv}
save {help char:variable characteristics} for the output spline basis
variables.  The characteristic {it:varname}{cmd:[xvar]} is set by
{cmd:bspline}, {cmd:frencurv}, and {cmd:flexcurv} to be equal to the
input X variable name set by {cmd:xvar()}.  The characteristics
{it:varname}{cmd:[xinf]} and {it:varname}{cmd:[xsup]} are set by
{cmd:bspline} to be equal to the infimum and supremum, respectively, of
the interval of X values for which the B-spline is nonzero.  The
characteristic {it:varname}{cmd:[xvalue]} is set by {cmd:frencurv} and
{cmd:flexcurv} to be equal to the reference point on the X axis
corresponding to the reference spline.


{title:References}

{phang}de Boor, C.  1978.  {it:A Practical Guide to Splines}. 
New York: Springer.

{phang}Newson, R.  2000.  sg151: B-splines and splines parameterized by their
values at reference points on the x-axis.  
{browse "http://www.stata.com/products/stb/journals/stb57.pdf":{it:Stata Technical Bulletin} 57}: 20-27.  Reprinted in {it:Stata Technical Bulletin Reprints}, 
vol. 10, pp. 221-230.  College Station, TX: Stata Press.{p_end}

{phang}Ziegler, Z.  1969.  One-sided L_1-approximation by splines of an
arbitrary degree.  In
{it:Approximations with Special Emphasis on Spline Functions}, ed. I. J. Schoenberg, 405-413.  New York: Academic Press.


{title:Author}

{pstd}Roger Newson{p_end}
{pstd}National Heart and Lung Institute{p_end}
{pstd}Imperial College London{p_end}
{pstd}London, UK{p_end}
{pstd}{browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}{p_end}


{title:Also see}

{p 4 14 2}Article:  {it:Stata Journal}, volume 12, number 3: {browse "http://www.stata-journal.com/article.html?article=sg151_2":sg151_2},{break}
                    {it:Stata Journal}, volume 3, number 3: {browse "http://www.stata-journal.com/article.html?article=sg151_1":sg151_1},{break}
                    {it:Stata Technical Bulletin} 57: {browse "http://www.stata.com/products/stb/journals/stb57.pdf":sg152}

{p 5 14 2}Manual:  {manlink R mkspline}

{p 7 14 2}Help:  {helpb mkspline}, {helpb spline}, {helpb spbase}, {helpb sp_adj} (if installed)
{p_end}

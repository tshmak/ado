{smcl}
{* version 2.0.0}{...}
{cmd:help mimrgns}
{hline}

{title:Title}

{p 5}
{cmd:mimrgns} {hline 2} {helpb margins} after {helpb mi estimate}


{title:Syntax}

{p 8}
{cmd:mimrgns} [{help fvvarlist:{it:marginlist}}] {ifin} {weight} 
[{cmd:,} {it:options} ]


{title:Description}

{pstd}
{cmd:mimrgns} runs {helpb margins} after {helpb mi estimate}.

{pstd}
{cmd:mimrgns} generalizes the approach suggest by the 
{browse "http://www.ats.ucla.edu/stat/stata/faq/ologit_mi_marginsplot.htm":UCLA Statistical Consulting Group.} It 
runs whichever 
{help mi_estimation##estimation_command:{it:estimation command}} was 
specified with the last call to {cmd:mi estimate} together with 
{cmd:margins} on the imputed datasets combining the results. See 
{help mimrgns##remarks:remarks below}.


{marker remarks}{...}
{title:Remarks}

{pstd}
There might be good reasons why {cmd:margins} does not work after 
{cmd:mi estimate}. Rather than merely applying {cmd:margins} to the 
(final) MI estimates, {cmd:mimrgns} treats {cmd:margins} itself as an 
estimation command, applying Rubin's rules to its results. 
Nonetheless, please read 
{mansection MI miestimatepostestimationRemarksUsingthecommand-specificpostestimationtools:{it:Using the command-specific postestimation tools}}
in {manhelp mi_estimate_postestimation MI:mi estimate postestimation} 
before using the command. 

{pstd}
Applying Rubin's rules to the results obtained from {cmd:margins} 
assumes asymptotic normality. This might well be appropriate for 
linear predictions (although White, Royston and Wood (2011) argue 
that predicted values should be obtained at the observational level), 
but might not be otherwise. By default {cmd:mimrgns} uses linear 
predictions regardless of the default prediction for the estimation 
command specified with the last {cmd:mi estimate} call.

{pstd}
Note that while in principle {helpb marginsplot} works after 
{cmd:mimrgns}, the plotted confidence intervals are based on 
inappropiate degrees of freedom ({help mimrgns##df:more}). The 
appropriate degrees of freedom are saved in {cmd:r(df)} 
(or {cmd:r(df_vs)} if option {opt pwcompare} is specified) by 
{cmd:mimrgns}. With the {opt post} option the degrees of freedom 
are also saved in {cmd:e(df_mi)} (or {cmd:e(df_vs)}). Although the 
differences will typically be too small to notice in a graph, you 
may want to use an alternative to {cmd:marginsplot} that allows 
specifying the degrees of freedom used to calculate confidence 
intervals (e.g. Jann's (2013) {stata findit coefplot:{bf:coefplot}}).

{pstd}
Also note that {cmd:mimrgns} does neither fully support {cmd:margins}' 
{help margins_contrast:{bf:contrast}} option nor does it save all 
results that {cmd:margins} saves. This might lead to error messages 
when running post estimation commands, e.g. {helpb mi test}. Even if 
no error messages appear these results might not be appropriate.


{title:Options}

{phang}
{it:{help margins##options:margins_options}} are options allowed with 
the {cmd:margins} command.

{phang}
{opt eform} displays coefficients in exponentiated form.

{phang}
{cmd:diopts(}{it:{help margins##display_options:display_options}}{cmd:)}
are display options allowed with the {cmd:margins} command (Stata 12 
or higher).

{phang}
{opt post} leaves behind estimation results from {cmd:mimrgns} in 
{cmd:e()}. Default is to hold estimation results from the last call 
to {cmd:mi estimate}.

{phang}
{opt cmdmargins} sets {cmd:r(cmd)} (or {cmd:e(cmd)} respectively) 
to {cmd:margins} ({cmd:pwcompare} or {cmd:contrast}). This option is 
required if {cmd:marginsplot} (Stata 12 or higher) is to be used 
subsequently - but see the discussion under 
{help mimrgns##remarks:remarks} above.


{title:Example}

{phang2}{cmd:. webuse mheart1s20}{p_end}
{phang2}{cmd:. mi estimate, dots : logit attack smokes age bmi hsgrad female}{p_end}
{phang2}{cmd:. mimrgns ,dydx(*)}{p_end}

{phang2}{cmd:. generate ageg = irecode(age, 20, 40 ,60, 80)}{p_end}
{phang2}{cmd:. mi estimate, dots : logit attack smokes i.ageg bmi hsgrad female}{p_end}
{phang2}{cmd:. mimrgns ageg ,pwcompare}{p_end}


{title:Saved results}

{pstd}
{cmd:mimrgns} saves in {cmd:r()} some of the results that  
{help margins##saved_results:{bf:margins}} saves without the 
{cmd:post} option.

{pstd}
{cmd:mimrgns} additionally saves the following in {cmd:r()}:

{pstd}
Macros{p_end}
{synoptset 21 tabbed}{...}
{synopt:{cmd:r(cmd)}}{cmd:mimrgns} (not with {opt cmdmargins}){p_end}
{synopt:{cmd:r(est_cmdline_mi)}}{cmd:e(cmdline_mi)} from {cmd:mi estimate}{p_end}
{synopt:{cmd:r(cmdline_user)}}command line as typed{p_end}


{marker df}
{title:marginsplot after mimrgns}

{pstd}
The confidence intervals reported by {cmd:mimrgns} are based on the 
degrees of freedom calculated by Stata's {cmd:mi} suit. 
{cmd:marginsplot} recalculates the confidence intervals by replaying 
{cmd:margins}' results internally, obtaining coefficients and standard 
errors from {cmd:r(table)}. The problem is that in doing so 
{cmd:marginsplot} does not rely on the (appropriate) degrees of 
freedom calculated by {cmd:mi}, but rather uses the default degrees 
of freedom. Therefore the confidence intervals plotted by 
{cmd:marginsplot} are wrong. 


{title:References}

{pstd}
Jann, B. 2013. Plotting regression coefficients and other estimates 
in Stata. {it:University of Bern Social Sciences Working Papers Nr. 1}.  
Available from {browse "http://ideas.repec.org/p/bss/wpaper/1.html"}

{pstd}
White, I. R., Royston, P., Wood, M. A. 2011. Multiple imputation 
using chained equations: Issues and guidance for practice. 
{it:Statistics in Medicine} 30:377-399.

{pstd}
Stata FAQ. How can I get margins and marginsplot with multiply 
imputated data? UCLA: Statistical Consulting Group. from 
{browse "http://www.ats.ucla.edu/stat/stata/faq/ologit_mi_marginsplot.htm"}


{title:Acknowledgments}

{pstd}
Timothy Mak identified a bug with mixed models.

	
{title:Author}

{pstd}Daniel Klein, University of Kassel, klein.daniel.81@gmail.com


{title:Also see}

{psee}
Online: {helpb mi}, {helpb margins}{p_end}

{psee}
if installed: {help coefplot}{p_end}

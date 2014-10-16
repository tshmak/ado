{smcl}
{* version 1.1.2}{...}
{cmd:help mimrgns}
{hline}

{title:Title}

{p 5}
{cmd:mimrgns} {hline 2} {help margins} after {help mi estimate}


{title:Syntax}

{p 8}
{cmd:mimrgns} [{help fvvarlist:{it:marginlist}}] {ifin} {weight} 
[{cmd:,} {help margins##options:{it:margins_options}}]


{title:Description}

{pstd}
{cmd:mimrgns} runs {help margins} after {help mi estimate} and leaves 
results for {help marginsplot} (Stata 12 or higher).

{pstd}
{cmd:mimrgns} generalizes the approach suggest by the 
{browse "http://www.ats.ucla.edu/stat/stata/faq/ologit_mi_marginsplot.htm":UCLA Statistical Consulting Group.} It 
runs whichever 
{help mi_estimation##estimation_command:{it:estimation command}} was 
specified with the last call to {cmd:mi estimate} together with 
{cmd:margins} on the imputed datasets combining the results.


{title:Remarks}

{pstd}
There might be good reasons why {cmd:margins} does not work after 
{cmd:mi estimate}. Rather than merely applying {cmd:margins} to the 
last mi estimates, {cmd:mimrgns} treats {cmd:margins} itself as an 
estimation command applying Rubin's rules to its results. Nontheless, 
please read 
{mansection MI miestimatepostestimationRemarksUsingthecommand-specificpostestimationtools:{it:Using the command-specific postestimation tools}}
in {manhelp mi_estimate_postestimation MI:mi estimate postestimation}.

{pstd}
{cmd:mimrgns} does not save all results that {cmd:margins} saves 
(see {help mimrgns##saved_results:saved results}). This might lead 
to error messages when running {help mi test} or {help marginsplot}.


{title:Options}

{phang}
{it:{help margins##options:margins_options}} options allowed with 
{help margins}.


{title:Example}

{phang2}{cmd:. webuse mheart1s20}{p_end}
{phang2}{cmd:. mi estimate, dots: logit attack smokes age bmi hsgrad female}{p_end}
{phang2}{cmd:. mimrgns ,dydx(*)}{p_end}
{phang2}{cmd:. marginsplot}{p_end}


{marker saved_results}{...}
{title:Saved results}

{pstd}
{cmd:mimrgns} saves in {cmd:r()} some of the results that  
{help margins##saved_results:{bf:margins}} saves without the 
{cmd:post} option. Results that might differ accross imputed datasets 
are not returned.

{pstd}
{cmd:mimrgns} additionally saves the following in {cmd:r()}:

{pstd}
Macros{p_end}
{synoptset 21 tabbed}{...}
{synopt:{cmd:r(est_cmdline_mi)}}{cmd:e(cmdline_mi)} from {cmd:mi estimate}{p_end}
{synopt:{cmd:r(cmdline_user)}}command line as typed{p_end}


{title:References}

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
Online: {helpb mi}, {help margins}, {help marginsplot}{p_end}

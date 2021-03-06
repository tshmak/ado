{smcl}
{* *! version 3.0.0  Apr2013}{...}
{viewerjumpto "Syntax" "lgraph##syntax"}{...}
{viewerjumpto "Description" "lgraph##description"}{...}
{viewerjumpto "Options" "lgraph##options"}{...}
{viewerjumpto "Examples" "lgraph##examples"}{...}
{viewerjumpto "Saved results" "lgraph##saved_results"}{...}
{vieweralsosee "[XT] xtline" "help xtline"}{...}
{hline}
help for {hi:lgraph} -- Tool for drawing line graphs (and more) (Requires Version 9) {right:(Version 3.0.0)}
{hline}

{marker syntax}{...}
{title:Syntax}

{p 8 14 2}
{cmd:lgraph}
{it:varlist}
{ifin}
{weight}
[{cmd:,} 
{opt s:tatistic(stat)}
{opt err:ortype(errortype)}{break}
{cmd:fit}({cmd:lfit}|{cmd:qfit}|{cmd:fpfit} [, {opt now:eight}])
{cmdab:colorg:radient}({cmd:on}|{cmd:by}|{help colorstyle} [{it:start_num end_num}])
{opt sep:arate(#)}
{opt by(groupvar2)}{break}
{opt lop:tions(line_options)}
{opt eop:tions(errorbar_options)}
{opt fop:tions(fit_options)}
{opt leop:tions(omnibus_options)}{break}
{opt bw}
{opt nom:arker}
{opt nol:egend}
{opt wide}
{opt swap}
{opt plot:orderoptions}
{help twoway_options}{break}
{opt nopreserve}
{opt also:collapse(clist)}
{opt addplot(plot)}
]

{phang2}
where {it:varlist} can be either 

{phang3}
Syntax 1: {it:yvar} {it:xvar} [{it:groupvar1}]
 
{phang3}
or 

{phang3}
Syntax 2: {it:yvar1} {it:yvar2} [...] {it:xvar}

{phang2}
For Syntax 2, the option {cmd:wide} must be specified. 

{phang2}
Weights supported are the same as those supported by {helpb collapse}. 

{marker description}{...}
{title:Description}

{p 4 4 2}
{cmd:lgraph} is a tool for drawing line graphs with optional error bars optionally stratified by one or two variables. 
{cmd:lgraph} {helpb collapse}s {it:yvar} by {it:xvar} and optionally {it:groupvar1} and {it:groupvar2}. It then
plots a {helpb twoway_connected} graph of {it:yvar} against {it:xvar}, stratified by {it:groupvar1} and {it:groupvar2} with optional 
error bars. The advantage of using {cmd:lgraph} is that the data is automatically {helpb preserve}d. Moreover, 
{cmd:lgraph} automatically takes care of the coloring of the lines and the error bars, and produces meaningful legends. 
It is most useful for graphical exploration of longitudinal and/or multilevel data. 

{p 4 4 2}
Although the syntax of {cmd:lgraph} has changed since 2.0.0, the old syntax will continue to work.

{marker options}{...}
{title:Options}

{p 4 8 2}{opt statistic(stat)} specifies the summary statistic which we plot. It can be any of the {it:stat} in {helpb collapse}. 
The default summary statistic is {it:mean}. 

{p 4 8 2}{opt errortype(errortype)} specifies the type of error bar to be plotted. {p_end} 
{synoptset 23 tabbed}
{synopthdr:errortype}
{synoptline}
{synopt:{opt ci(#)}}{it:#}% Confidence Interval{p_end}
{synopt:{opt q:uantile(# #)}}Quantiles. e.g. {cmd:quantile(25 75)}{p_end}
{synopt:{opt minmax}}Minimum and maximum{p_end}
{synopt:{opt sd}}Standard Deviation{p_end}
{synopt:{opt iqr}}Inter-quartile Range{p_end}
{synopt:{opt se:mean} [{opt ci(#)}]}Standard error of the mean. If {opt ci(#)} is specified, then it is the {it:#}% confidence interval{p_end}
{synopt:{opt seb:inomial} [{opt ci(#)}]}Standard error of the mean, binomial. If {opt ci(#)} is specified, then it is the {it:#}% confidence interval based on the Binomial standard error {p_end}
{synopt:{opt sep:oisson} [{opt ci(#)}]}Standard error of the mean, Poisson. If {opt ci(#)} is specified, then it is the {it:#}% confidence interval based on the Poisson standard error {p_end}
{synopt:{opt c:ollapse}({it:var1} {it:var2})}User-defined error bars. Generally, {it:var1} and {it:var2} should not differ between levels of {it:groupvar1} and {it:groupvar2}, 
	because it is {helpb collapse}d over using ({it:mean}) as the option. {it:var1} gives the lower bound and {it:var2} the upper bound of the error bars.{p_end}
{synoptline}
{p2colreset}{...}

{p 4 8 2}{cmd:fit}({cmd:lfit}|{cmd:qfit}|{cmd:fpfit} [, {opt now:eight}]) specifies that a linear/quadratic/fractional polynomial fit should be plotted instead of a line graph. 
	See {helpb twoway_lfit}, {helpb twoway_qfit}, {helpb twoway_fpfit} for details. By default, if {cmd:mean} (the default) is specified as the summary statistic, 
	the fit of the lines is weighted by the number of observations that go into each plotted mean, corresponding to using the {it: aweight} option in {helpb regress}. 
	Use the {opt now:eight} option to override this. 

{p 4 8 2}{cmdab:colorg:radient}({cmd:on}|{cmd:by}|{help colorstyle} [{it:start_num end_num}]) By default each level in {it:groupvar1} will have a different color line. 
	The color given to each line follows the loop implied by the particular {help scheme}, e.g.: navy, maroon, forest_green, dkorange, etc. 
	Specifying {cmdab:colorg:radient}({cmd:on}|{cmd:by}|{help colorstyle} [{it:start_num end_num}]) causes the color scheme to follow a gradient, e.g. navy*0.1, navy*0.2, ..., navy*1. 
	This is particularly useful if {it:groupvar1} has an ordinal scale. Specifying {cmdab:colorg:radient}({cmd:on}) plots the gradient in the default color. Otherwise, the color
	can be specified by typing {cmdab:colorg:radient}({help colorstyle}). {cmdab:colorg:radient}({cmd:by}) is useful when combined with {opt by(groupvar2)}. It causes a different color gradient to be 
	used for each different level of {it:groupvar2}. This is useful if the lines are, e.g., stratified by {it:groupvar1}=age and {it:groupvar2}=sex. Specifying {it:startnum} and {it:endnum} gives the starting and ending 
	multiplying factor for the color gradient. For example, specifying {cmd:colorgradient(blue 0.3 1.2)} when {it:groupvar1} has 4 levels will cause the colors for the four levels 
	to be blue*0.3, blue*0.6, blue*0.9, blue*1.2, respectively. The default {it:startnum} and {it:endnum} are 0.1 and 1. 

{p 4 8 2}{opt sep:arate(#)} causes the points that are plotted to be slightly shifted 
so that the error bars do not overlap. {it:#} will usually be in the range of 0.001 to 0.05. By default, points are not shifted.

{p 4 8 2}{opt by(groupvar2)} specifies a second-level group variable. When {opt by(groupvar2)} is specified, the color scheme of {cmd:lgraph} now loops over {it:groupvar2} instead of {it:groupvar1},
	although lines are still drawn for each {it:groupvar1}, albeit using the same color. 

{p 4 8 2}{opt lop:tions(line_options)} passes extra options to {helpb twoway_connected}. {cmd:lgraph} works by generating a {helpb twoway} command with multiple {helpb twoway_connected} plots. 
	The syntax for {it:line_options} is:
	
{phang3} [{help numlist}] {it:twoway_connected_options} [; [{help numlist}] {it:twoway_connected_options} ... ]
 
{pin} {help numlist}, if specified, indicates which lines the {it:twoway_connected_options} apply to. {help numlist} would be the levels of {it:groupvar1}, or if {opt by(groupvar2)} is specified, 
	{it:groupvar2}. (However, see {opt plot:orderoptions} below.) If {help numlist} is not specified, then the options apply to all levels. 
	Options given to different lines should be separated by a {cmd:;}. For example, {cmd: loptions(lpat(dot) ; 1/3 color(green))} 
	causes all lines to be dotted and the line whose {it:groupvar1} == 1 or 2 or 3 to be plotted in green.

{p 4 8 2}{opt eop:tions(errorbar_options)} is the same as {opt lop:tions(line_options)} except that options are passed to {helpb twoway_rcap} for the drawing of the error bars. 

{p 4 8 2}{opt fop:tions(fit_options)} is the same as {opt lop:tions(line_options)} except that options are passed to {helpb twoway_lfit} | {helpb twoway_qfit} | {helpb twoway_fpfit} for the drawing of the 
	fitted lines. Use this option to control, e.g., the fitting of the fractional polynomial curve. 
	
{p 4 8 2}{opt leop:tions(omnibus_options)} applies the {it:omnibus_options} to all of {opt lop:tions(line_options)}, {opt eop:tions(errorbar_options)}, and {opt fop:tions(fit_options)}. 

{p 4 8 2}{opt bw} draws the graph in black and white instead of color. (It applies {cmd:scheme(s2mono)}.)

{p 4 8 2}{opt nom:arker} suppresses the drawing of markers.

{p 4 8 2}{opt nol:egend} suppresses the legend.
	
{p 4 8 2}{opt wide} specifies that {help lgraph##syntax:Syntax} 2 be used when parsing {varlist}. {cmd:lgraph} was written to work with data in the {cmd:long} format. This means that different lines on the graph, 
	rather than representing different dependent variables, represent the plotting of {it:yvar} against {it:xvar} for different levels of {it:groupvar1}. However, it may sometimes be useful to plot {it:xvar} against different
	dependent variables. The {opt wide} option enables this. 

{p 4 8 2}{opt swap} specifies that {it:groupvar1} and {it:groupvar2} be swapped. It is useful mainly when using {opt wide}. 

{p 4 8 2}{opt plot:orderoptions} By default the {help numlist}s to be used with {opt lop:tions},  {opt eop:tions}, {opt fop:tions}, and {opt leop:tions} refer to the levels of {it:groupvar1} or {it:groupvar2}. Specifying 
	{opt plot:orderoptions} causes the {help numlist}s to refer instead to the order by which the lines are plotted. This is especially useful when the {opt by(groupvar2)} option is used, since it is not
	otherwise possible to specifying options for levels of {it:groupvar1} and {it:groupvar2} jointly. 
	
{p 4 8 2}{help twoway_options} Most options available to {helpb twoway} can be used. 

    {hline}
{p 8 8 2}{it:(Advanced options)}

{p 4 8 2}{opt nopreserve} requests that {cmd:lgraph} does not {helpb preserve} the data first before {helpb collapse}-ing and drawing the graph. This is useful if one desires to draw a graph that 
	is more complicated than is possible with {cmd:lgraph}. {cmd:lgraph} saves the command that is used to generate the graph in {cmd:r(command)} and {cmd:r(options)}. 
	Therefore, one can use {cmd:lgraph, nopreserve} to generate {cmd:r(command)} and {cmd:r(options)}, edits the data or {cmd:`r(command)'} or {cmd:`r(options)'}, before drawing the graph by calling 
	{cmd:twoway `r(command)', `r(options)'}.

{p 4 8 2}{opt also:collapse(clist)} requests {cmd:lgraph} to perform additional {helpb collapse} tasks. It is only useful when combined with the {opt nopreserve} or the {opt addplot(plot)} option, to facilitate 
	manipulation of the {helpb collapse}d data in plotting the graph. The syntax for {it:clist} is given in {helpb collapse}. Care should be taken so that names such as {cmd:statistic}, {cmd:scaleparam}, {cmd:count}, 
	{cmd:lbound} and {cmd:ubound} are not given, as these may conflict with names generated by {cmd:lgraph}. 

{p 4 8 2}{opt addplot(plot)} This allows additional {helpb twoway} plots to be plotted. See {help addplot_option}. Note that because {cmd:lgraph} {helpb collapse}s the data before plotting in {helpb twoway}, 
	plots given in {opt addplot(plot)} should also refer to the {helpb collapse}d data. Specify in {opt also:collapse(clist)}
	any additional data that need to be {helpb collapse}d.  

    {hline}

{marker examples}{...}
{title:Examples}

{p 4 8 2}Simple line graph with error bars plotting the mean price against 1978 repair record, stratified by origin

{p 8 8 2}{stata sysuse auto, clear}{break}
		{stata lgraph price rep78 foreign, errortype(sd) separate(0.01) }

{p 4 8 2}Plotting unemployment rates by states (using the {opt wide} option)

{p 8 8 2}{stata "use http://www.stata-press.com/data/r9/urates.dta, clear"}{break}
		{stata lgraph tenn missouri kentucky indiana illinois arkansas t, wide nom}

{p 4 8 2}Comparing college and non-college graduates on work experience gained (using the {opt by(groupvar2)} option)

{p 8 8 2}{stata "use http://www.stata-press.com/data/r9/nlswork.dta, clear"}{break}
		{stata lgraph ttl_exp age idcode if idcode < 100, by(collgrad)}

{p 4 8 2}Examining relationship between weight and height

{p 8 8 2}{stata "use http://www.stata-press.com/data/r9/nhanes2f.dta, clear"}{break}
		{stata lgraph weight height agegrp, fit(lfit) lopt(msize(tiny))} // Fitting a straight line {break}
		{stata lgraph weight height agegrp, fit(lfit) lopt(msize(tiny)) colorg(on)} // Using a color gradient

{p 4 8 2}Examining mortality rate (with user-given error bars)

{p 8 8 2}{stata "use http://www.stata-press.com/data/r9/mortality.dta, clear"}{break}
		{stata gen mortality = deaths / population}{break}
		{stata gen se = sqrt(deaths) / population}{break}
		{stata gen lb = mortality - invnormal(0.975) * se}{break}
		{stata gen ub = mortality + invnormal(0.975) * se}{break}
		{stata encode nation, gen(nation2)}{break}
		{stata lgraph mortality age_category nation2, err(collapse(lb ub)) nom ytitle(Mortality rate) xlabel(1 2 3,valuel)}

{marker saved_results}{...}
{title:Saved results}

{p 4 8 2}{cmd:twoway `r(command)', `r(options)'} gives the entire command used to generate the graph. 

{p 4 8 2}{cmd:r(command)} gives the {it:plot} part of the command.

{p 4 8 2}{cmd:r(options)} gives the {help twoway_options} part of the command.
	
{title:Also see}

{p 4 8 2}{helpb xtline}, {net "describe xtgraph, from(http://fmwww.bc.edu/RePEc/bocode/x)":xtgraph}
		
{title:Author}

{p 4 4 2}Timothy Mak{break}
		School of Public Health, University of Hong Kong{break}
		tshmak@hku.hk{break}
		April 2013

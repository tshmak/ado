*! Date    : 31 Jul 2013
*! Version : 1.06
*! Author  : Adrian Mander
*! Email   : adrian.mander@mrc-bsu.cam.ac.uk

/*
14 Jul 08 v1.01 Sort out the rounding issues around axes labels
 7 Jan 11 v1.02 Sort out some of the help file/code anomalies
16 Nov 11 v1.03 Sort out saving bug
30 May 12 v1.04	Added in the xtra option just in case
12 Jun 12 v1.05	Tiny datasets of obs <16 need sorting to have more observations need at least 16 obs to construct the axes
31 Jul 13 v1.06 Sort out the issues around looping x and y over all values and the storing floats problem, really just made strings instead
*/

program define surface
preserve
version 10.0
syntax varlist(min=3 max=3) [, SAVING(string) Box(string) EYE(string) ROUND(int 5) LABELround(int 2) NLINES(int 40) /*
*/ NOBOX ORIENT(string) XLABel(numlist) YLABel(numlist) ZLABel(numlist) NOWIRE XTITLE(string) YTITLE(string) ZTITLE(string) *]
/**********************************************************
 * I am allowing any extra options that the user specifies 
 * but I am not checking this
 **********************************************************/
local xopt "`options'"

/**********************************************************
 * First set up which variables are x, y and z
 **********************************************************/
local i 1
foreach v of local varlist {
  if `i'==1 local x "`v'"
  if `i'==2 local y "`v'"
  if `i++'==3 local z "`v'"
}

/**********************************************************
 * Set up Axis labels 
 **********************************************************/
local xtit:variable label `x'
local ytit:variable label `y'
local ztit:variable label `z'
if "`xtitle'"=="" {
  if "`xtit'"=="" local xtitle "`x'"
  else local xtitle "`xtit'"
}
if "`ytitle'"=="" {
  if "`ytit'"=="" local ytitle "`y'"
  else local ytitle "`ytit'"
}
if "`ztitle'"=="" {
  if "`ztit'"=="" local ztitle "`z'"
  else local ztitle "`ztit'"
}

/**********************************************************
 * Find out the limits of the data
 **********************************************************/
qui su `x', de
local xmin = `r(min)'
local xmax = `r(max)'
local xmed = `r(p50)'
qui su `y', de
local ymin = `r(min)'
local ymax = `r(max)'
local ymed = `r(p50)'
qui su `z', de
local zmin = `r(min)'
local zmax = `r(max)'
local zmed = `r(p50)'

/**********************************************************
 * Set up the axis labels 
 * this is the rounding bit of the labels
 **********************************************************/

if "`xlabel'"=="" {
  local acc `labelround'
  local stem = `acc'+4
  local l1:di %`stem'.`acc'f `xmin'
  local l2:di %`stem'.`acc'f `=`xmin'+(`xmax'-`xmin')/2 '
  local l3:di %`stem'.`acc'f `xmax'
  local xlabel "`l1' `l2' `l3'"
}
else {
  foreach xx of local xlabel {
    if `xx' > `xmax' local xmax "`xx'"
    if `xx' < `xmin' local xmin "`xx'"
  }
}
if "`ylabel'"=="" {
  local acc `labelround'
  local stem = `acc'+4
  local l1:di %`stem'.`acc'f `ymin'
  local l2:di %`stem'.`acc'f `=`ymin'+(`ymax'-`ymin')/2 '
  local l3:di %`stem'.`acc'f `ymax'
  local ylabel "`l1' `l2' `l3'"
}
else {
  foreach xx of local ylabel {
    if `xx' > `ymax' local ymax "`xx'"
    if `xx' < `ymin' local ymin "`xx'"
  }
}
if "`zlabel'"=="" {
  local acc `labelround'
  local stem = `acc'+4
  local l1:di %`stem'.`acc'f `zmin'
  local l2:di %`stem'.`acc'f `=`zmin'+(`zmax'-`zmin')/2 '
  local l3:di %`stem'.`acc'f `zmax'
  local zlabel "`l1' `l2' `l3'"
}
else {
  foreach xx of local zlabel {
    if `xx' > `zmax' local zmax "`xx'"
    if `xx' < `zmin' local zmin "`xx'"
  }
}

/**********************************************************
 * Set up the vectors defining the axes and scale 
 * according to these vectors 
 **********************************************************/
/* X is horizontal */
global xdirx = 1/(`xmax'-`xmin')
global xdiry = 0/(`xmax'-`xmin')

/* Z by default goes up */
global zdirx = 0/(`zmax'-`zmin')
global zdiry = 1/(`zmax'-`zmin')

/* Y goes into the page*/
global ydirx = 1/(sqrt(2)*(`ymax'-`ymin'))
global ydiry = 1/(sqrt(2)*(`ymax'-`ymin'))


/**********************************************************
 * Draw the box axes 
 **********************************************************/
qui draw_axes `x' `y' `z', `nobox' zh(`zmax') zl(`zmin') yh(`ymax') yl(`ymin') xh(`xmax') xl(`xmin') 

/**********************************************************
 * Draw the ticks with the xlabel/ylabel stuff this time
 **********************************************************/
qui draw_ticks `x' `y' `z', zh(`zmax') zl(`zmin') yh(`ymax') yl(`ymin') xh(`xmax') xl(`xmin') xlab("`xlabel'") /*
*/ ylab("`ylabel'") zlab("`zlabel'")
local ticks `"`r(gxlab)'`r(gylab)'`r(gzlab)'"'
local tickst `"`r(gxlabt)'`r(gylabt)'`r(gzlabt)'"'

/**********************************************************
 * Draw the Titles
 **********************************************************/
qui _drawtitles  `x' `y' `z', zh(`zmax') zl(`zmin') yh(`ymax') yl(`ymin') xh(`xmax') xl(`xmin') xtitle("`xtitle'") /*
*/ ytitle("`ytitle'") ztitle("`ztitle'")
local ti `"`r(xti)' `r(yti)' `r(zti)'"'

/**********************************************************
 * Draw a 3D scatter plot
 **********************************************************/
qui _project3d `x' `y' `z', zh(`zmax') zl(`zmin') yh(`ymax') yl(`ymin') xh(`xmax') xl(`xmin')

/**********************************************************
 * Create the wireframe although really it doesn't do 
 *  anything... in the new code
 **********************************************************/
_createwire `x' `y' `z', zh(`zmax') zl(`zmin') yh(`ymax') yl(`ymin') xh(`xmax') xl(`xmin') 

/**********************************************************
 * Sort out the twoway options add the saving option
 **********************************************************/
if "`nowire'"~="" local scatter "scatter"
else local wire "wire"

local opt `"legend(off) ylab(,nogrid) ysca(off r(-0.1 1.4)) xsca(off r(-0.3 1.2)) `ti' `ticks'"'
if "`saving'"~="" local opt `"`opt' saving(`saving')"'

/**********************************************************
 * This is the drawing bit
 **********************************************************/
if "`scatter'"~="" twoway (line axesy axesx, lc(edkblue))(scatter newy newx)`tickst', `opt' `xopt'
if "`dropline'"~="" twoway (line axesy axesx, lc(edkblue))(scatter newy newx)(pcspike newy newx newbasey newbasex)`tickst', `opt' `xopt'

/* Unfortunately need to loop through every line */
if "`wire'"~="" {
  local g ""
  tempvar xstr
  gen `xstr' = string(`x')
  qui levelsof `xstr', local(levels)
  foreach l of local levels {
    local g "`g' (line newy newx if `xstr'=="`l'", lc(gs1) sort)"
  } 
  local g2 ""
  tempvar ystr
  gen `ystr'=string(`y')
  qui levelsof `ystr', local(levels)
  foreach l of local levels {
    local g2 "`g2' (line newy newx if `ystr'=="`l'", lc(gs0) sort)"
  } 
/* This is the old way of handling real values in x and y
  qui levelsof `x', local(levels)
  foreach l of local levels {
    local g "`g' (line newy newx if `x'==`l', lc(gs1) sort)"
  } 
  local g2 ""
  qui levelsof `y', local(levels)
  foreach l of local levels {
    local g2 "`g2' (line newy newx if `y'==`l', lc(gs0) sort)"
 }
*/ 
 twoway (line axesy axesx, lc(edkblue)) `g' `g2' `tickst', legend(off) `opt' `xopt'
}



restore
end

/******************************************************************************
 * ALL the stuff about axes 
 * Make a continuous line loop round a cube 
 * 1)  start at origin
 * 2) head along X
 * 3) head along Y
 ******************************************************************************/

pr draw_axes
syntax varlist(max=3 min=3) , zh(real) zl(real) yh(real) yl(real) xh(real) xl(real) [ Nobox ]

if "`nobox'"=="" {
  if `c(N)'<16 qui set obs 16
  gen axesy = 0 in 1
  gen axesx = 0 in 1
  replace axesy = axesy[1]+(`xh'-`xl')*$xdiry in 2
  replace axesx = axesx[1]+(`xh'-`xl')*$xdirx in 2
  replace axesy = axesy[2]+(`yh'-`yl')*$ydiry in 3
  replace axesx = axesx[2]+(`yh'-`yl')*$ydirx in 3
  replace axesy = axesy[3]-(`xh'-`xl')*$xdiry in 4
  replace axesx = axesx[3]-(`xh'-`xl')*$xdirx in 4
  replace axesy = axesy[4]-(`yh'-`yl')*$ydiry in 5
  replace axesx = axesx[4]-(`yh'-`yl')*$ydirx in 5
  replace axesy = axesy[5]+(`zh'-`zl')*$zdiry in 6
  replace axesx = axesx[5]+(`zh'-`zl')*$zdirx in 6
  replace axesy = axesy[6]+(`xh'-`xl')*$xdiry in 7
  replace axesx = axesx[6]+(`xh'-`xl')*$xdirx in 7
  replace axesy = axesy[7]+(`yh'-`yl')*$ydiry in 8
  replace axesx = axesx[7]+(`yh'-`yl')*$ydirx in 8
  replace axesy = axesy[8]-(`xh'-`xl')*$xdiry in 9
  replace axesx = axesx[8]-(`xh'-`xl')*$xdirx in 9
  replace axesy = axesy[9]-(`yh'-`yl')*$ydiry in 10
  replace axesx = axesx[9]-(`yh'-`yl')*$ydirx in 10
  replace axesy = axesy[10]+(`yh'-`yl')*$ydiry in 11
  replace axesx = axesx[10]+(`yh'-`yl')*$ydirx in 11
  replace axesy = axesy[11]-(`zh'-`zl')*$zdiry in 12
  replace axesx = axesx[11]-(`zh'-`zl')*$zdirx in 12
  replace axesy = axesy[12]+(`xh'-`xl')*$xdiry in 13
  replace axesx = axesx[12]+(`xh'-`xl')*$xdirx in 13
  replace axesy = axesy[13]+(`zh'-`zl')*$zdiry in 14
  replace axesx = axesx[13]+(`zh'-`zl')*$zdirx in 14
  replace axesy = axesy[14]-(`yh'-`yl')*$ydiry in 15
  replace axesx = axesx[14]-(`yh'-`yl')*$ydirx in 15
  replace axesy = axesy[15]-(`zh'-`zl')*$zdiry in 16
  replace axesx = axesx[15]-(`zh'-`zl')*$zdirx in 16
}
else {
  if `c(N)'<11 qui set obs 11
  gen axesy = 0 in 1
  gen axesx = 0 in 1
  replace axesy = axesy[1]+(`xh'-`xl')*$xdiry in 2
  replace axesx = axesx[1]+(`xh'-`xl')*$xdirx in 2
  replace axesy = axesy[2]+(`yh'-`yl')*$ydiry in 3
  replace axesx = axesx[2]+(`yh'-`yl')*$ydirx in 3
  replace axesy = axesy[3]-(`xh'-`xl')*$xdiry in 4
  replace axesx = axesx[3]-(`xh'-`xl')*$xdirx in 4
  replace axesy = axesy[4]-(`yh'-`yl')*$ydiry in 5
  replace axesx = axesx[4]-(`yh'-`yl')*$ydirx in 5
  replace axesy = axesy[5]+(`zh'-`zl')*$zdiry in 6
  replace axesx = axesx[5]+(`zh'-`zl')*$zdirx in 6
  replace axesy = axesy[6]+(`yh'-`yl')*$ydiry in 7
  replace axesx = axesx[6]+(`yh'-`yl')*$ydirx in 7
  replace axesy = axesy[7]+(`xh'-`xl')*$xdiry in 8
  replace axesx = axesx[7]+(`xh'-`xl')*$xdirx in 8
  replace axesy = axesy[8]-(`zh'-`zl')*$zdiry in 9
  replace axesx = axesx[8]-(`zh'-`zl')*$zdirx in 9
  replace axesy = axesy[9]-(`xh'-`xl')*$xdiry in 10
  replace axesx = axesx[9]-(`xh'-`xl')*$xdirx in 10
  replace axesy = axesy[10]+(`zh'-`zl')*$zdiry in 11
  replace axesx = axesx[10]+(`zh'-`zl')*$zdirx in 11
}

end

/********************************************************************
 *                           DRAW TICKS
 * The ticks are drawn as pci calls and the text is ttext options
 ********************************************************************/
pr draw_ticks, rclass
syntax varlist(max=3 min=3) , zh(real) zl(real) yh(real) yl(real) xh(real) xl(real) xlab(string) ylab(string) zlab(string)

/* 
 *WARNING : all the tick lengths are fixed... and will break at some stage!!!
 */
local ticklen 0.025

local i 1
foreach v of local varlist {
  if `i'==1 local x "`v'"
  if `i'==2 local y "`v'"
  if `i++'==3 local z "`v'"
}

local gxlab ""

foreach x of local xlab {
  local yy: di %5.2f (`x'-`xl')*$xdiry+(`yl'-`yl')*$ydiry  + (`zl'-`zl')*$zdiry -0.1
  local xx: di %5.2f (`x'-`xl')*$xdirx+(`yl'-`yl')*$ydirx + (`zl'-`zl')*$zdirx
  local lab:di `x'
  local gxlab `"`gxlab' ttext(`yy' `xx' "`x'")"'
  local gxlabt `"`gxlabt' (pci `=`yy'+0.1' `xx' `=`yy'+0.1-`ticklen'' `xx', lc(edkblue))"'
}
foreach y of local ylab {
  local yy: di %5.2f (`xh'-`xl')*$xdiry+(`y'-`yl')*$ydiry  + (`zl'-`zl')*$zdiry
  local xx: di %5.2f (`xh'-`xl')*$xdirx+(`y'-`yl')*$ydirx + (`zl'-`zl')*$zdirx+0.1
  local lab: di `y'
  local gylab `"`gylab' ttext(`yy' `xx' "`y'", place(e))"'
  local gylabt `"`gylabt' (pci `yy' `=`xx'-0.1' `yy' `=`xx'-0.1+`ticklen'', lc(edkblue))"'
}
foreach z of local zlab {
  local yy: di %5.2f (`xl'-`xl')*$xdiry+(`yl'-`yl')*$ydiry  + (`z'-`zl')*$zdiry
  local xx: di %5.2f (`xl'-`xl')*$xdirx+(`yl'-`yl')*$ydirx + (`z'-`zl')*$zdirx-`ticklen'
  local gzlab `"`gzlab' ttext(`yy' `=`xx'-`ticklen'' "`z'", place(w))"'
  local gzlabt `"`gzlabt' (pci `yy' `=`xx'+`ticklen'' `yy' `=`xx'-`ticklen'/2', lc(edkblue))"'
}

return local gxlab  `"`gxlab'"'
return local gxlabt `"`gxlabt'"'
return local gylab  `"`gylab'"'
return local gylabt `"`gylabt'"'
return local gzlab  `"`gzlab'"'
return local gzlabt `"`gzlabt'"'

end

/***********************************************************************
 * ALL the stuff for a 3D scatter plot 
 ***********************************************************************/
pr _project3d
syntax varlist(max=3 min=3) , zh(real) zl(real) yh(real) yl(real) xh(real) xl(real)

local i 1
foreach v of local varlist {
  if `i'==1 local x "`v'"
  if `i'==2 local y "`v'"
  if `i++'==3 local z "`v'"
}

gen newy = (`x'-`xl')*$xdiry+(`y'-`yl')*$ydiry  + (`z'-`zl')*$zdiry
gen newx = (`x'-`xl')*$xdirx+(`y'-`yl')*$ydirx + (`z'-`zl')*$zdirx

gen newbasey = (`x'-`xl')*$xdiry+(`y'-`yl')*$ydiry 
gen newbasex = (`x'-`xl')*$xdirx+(`y'-`yl')*$ydirx 

end

/*********************************************************************
 *  DRAW TITLES
 *********************************************************************/

pr _drawtitles, rclass
syntax varlist(max=3 min=3) , zh(real) zl(real) yh(real) yl(real) xh(real) xl(real) xtitle(string) ytitle(string) ztitle(string)

local i 1
foreach v of local varlist {
  if `i'==1 local x "`v'"
  if `i'==2 local y "`v'"
  if `i++'==3 local z "`v'"
}
local midx = (`xh'+`xl')/2
local midy = (`yh'+`yl')/2.5
local midz = (`zh'+`zl')/2

local xtitx = (`midx'-`xl')*$xdirx 
local xtity = (`midx'-`xl')*$xdiry-0.15
return local xti = `"text(`xtity' `xtitx' "`xtitle'", place(s))"'

local ytitx = (`midy'-`yl')*$ydirx + (`xh'-`xl')*$xdirx+0.25
local ytity = (`midy'-`yl')*$ydiry + (`xh'-`xl')*$xdiry
return local yti = `"text(`ytity' `ytitx' "`ytitle'", place(e))"'

local ztitx = (`midz'-`zl')*$zdirx -0.25
local ztity = (`midz'-`zl')*$zdiry
return local zti = `"text(`ztity' `ztitx' "`ztitle'", place(w) orient(vertical))"'

end

/*********************************************
 * draw the wireframe 
 *********************************************/

pr _createwire
syntax varlist(max=3 min=3) , zh(real) zl(real) yh(real) yl(real) xh(real) xl(real)

local i 1
foreach v of local varlist {
  if `i'==1 local x "`v'"
  if `i'==2 local y "`v'"
  if `i++'==3 local z "`v'"
}

/* Check the Grid lines  BUT what are these used for???*/

qui inspect `x'
if `r(N_unique)'<40 local xok 1
else local xok 0

qui inspect `y'
if `r(N_unique)'<40 local yok 1
else local yok 0

end


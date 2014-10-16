*! 2.4.0 NJC 21 April 2009 
*! 2.3.3 NJC 8 November 2007 
* 2.3.2 NJC 2 November 2007 
* 2.3.1 NJC 17 July 2007 
* 2.3.0 NJC 21 June 2007 
* 2.2.0 NJC 28 November 2005
* onewayplot 2.1.3 NJC 27 October 2004
* 2.1.2 NJC 11 August 2004
* 2.1.1 NJC 21 July 2004
* 2.1.0 NJC 13 February 2004
* 2.0.3 NJC 17 July 2003 
* 2.0.2 NJC 7 July 2003 
* 2.0.1 NJC 6 July 2003 
* 2.0.0 NJC 3 July 2003 
* 1.2.1 NJC 18 October 1999 
* 1.1.0 NJC 27 April 1999 
* 1.0.0 NJC 23 April 1999 
program stripplot, sort  
	version 8.2
	syntax varlist(numeric) [if] [in]                                ///
	[, CEnter CEntre VERTical Height(real 0.8) Fraction(str) STack   ///
	over(varname) by(str asis) Width(numlist max=1 >0)               ///
	floor CEILing box BOX2(str asis) bar BAR2(str asis) boffset(str) /// 
	medianbar(str asis) PLOT(str asis) ADDPLOT(str asis) variablelabels SEParate(varname) * ] 

	if "`fraction'" != "" {
		di as inp "fraction()" as txt ": please use " as inp "height()"
		capture confirm num `fraction' 
		if _rc { 
			di as err "fraction() invalid {c -} invalid number"
			exit 198 
		}
		local height = `fraction' 
	} 	
	
	if "`floor'" != "" & "`ceiling'" != "" { 
		di as err "must choose between floor and ceiling"
		exit 198 
	}	

	if `"`box'`box2'"' != "" & `"`bar'`bar2'"' != "" { 
		di as err "may not combine bar and box"
		exit 198 
	}	

	if `"`bar2'"' != "" { 
		local 0 , `bar2' 
		local opts `options'
		local vars `varlist' 
		syntax [ , Level(int `c(level)') Poisson Binomial    ///
		EXAct WAld Agresti Wilson Jeffreys Exposure(varname) ///
		mean(str asis) * ]
		local ciopts level(`level') `poisson' `binomial' `exact' ///
		`wald' `agresti' `wilson' `jeffreys' 
		local baropts `options' 
		local meanopts `mean' 
		local options `opts'
		local varlist `vars' 
	}

	tokenize `varlist' 
	local nvars : word count `varlist' 

	if `"`by'"' != "" { 
		gettoken by opts : by, parse(",") 
		gettoken comma opts : opts, parse(",") 

		local total "total" 
		if `: list total in opts' & `"`bar'`bar2'`box'`box2'"' != "" { 
			di as err "by(, total) not supported with box or bar" 
			exit 198 
		}	


	}	
	
	marksample touse, novarlist 
	if "`by'`over'`separate'" != "" markout `touse' `by' `over' `separate', strok 
	qui count if `touse' 
	if r(N) == 0 error 2000 

	local noover = "`over'" == ""
		
	// variables for plot 
	qui if `nvars' > 1 { 
		if "`over'" != "" { 
			di as err ///
			"over() may not be combined with more than one variable"
			exit 198
		}	
		else {
			// several variables are stacked into one
			// x axis shows `data' 
			// y axis shows _stack 
			preserve
			if "`variablelabels'" != "" { 
				forval i = 1/`nvars' { 
					local l : variable label ``i''
					local labels `"`labels' `i' `"`l'"'"'
				}
			} 	
			else forval i = 1/`nvars' {
                		local labels "`labels'`i' ``i'' "
		        }
			
			if "`by'" != "" { 
				local bylbl : value label `by' 
				if "`bylbl'" != "" { 
					tempfile bylabel 
					label save `bylbl' using `bylabel' 
				}
			}	

			if "`separate'" != "" { 
				local seplbl : value label `separate' 
				if "`seplbl'" != "" { 
					tempfile seplabel 
					label save `seplbl' using `seplabel'
				}
			}
		
			tempvar data copystack  
			foreach v of local varlist { 
				local stacklist "`stacklist' `v' `by' `exposure' `separate'" 
			}	
			stack `stacklist' if `touse', into(`data' `by' `exposure' `separate') clear
			drop if missing(`data')
			gen `copystack' = _stack  

			qui if `"`box'`box2'"' != "" { 
				tempvar median loq upq yshow2 
				egen `median' = median(`data'), by(`by' _stack) 
				egen `loq' = pctile(`data'), p(25) by(`by' _stack) 
				egen `upq' = pctile(`data'), p(75) by(`by' _stack) 
			} 

			qui if `"`bar'`bar2'"' != "" { 
				tempvar mean group ul ll yshow2 
				gen `mean' = . 
				gen `ul'   = . 
				gen `ll'   = . 
				egen `group' = group(`by' _stack) 
				su `group', meanonly
				forval i = 1/`r(max)' { 
					ci `data' if `group' == `i', `ciopts' 
					replace `mean' = r(mean) if `group' == `i' 
					replace `ul' = r(ub) if `group' == `i' 
					replace `ll' = r(lb) if `group' == `i' 
				}
			}
				
			if "`width'" != "" {
				if "`floor'" != "" {
					replace `data' = `width' * floor(`data'/`width')
				}
				else if "`ceiling'" != "" { 
					replace `data' = `width' * ceil(`data'/`width')
				}	
				else replace `data' = round(`data', `width') 
			}	
			
			label var `data' "`varlist'"
			label var _stack `" "' 

			if "`bylbl'" != "" { 
				do `bylabel' 
				label val `by' `bylbl' 
			}	

			if "`seplbl'" != "" { 
				do `seplabel' 
				label val `separate' `seplbl' 
			}	

			tempname stlbl
			label def `stlbl' `labels' 
		        label val _stack `stlbl'
			su _stack, meanonly 
			local range "`r(min)'/`r(max)'" 
			if "`stack'" != "" { 
				tempvar count
				sort `by' _stack `data' `separate', stable 
				by `by' _stack `data' : gen `count' = _n - 1  
				su `count', meanonly
				if "`centre'`center'" != "" { 
					by `by' _stack `data' : ///
					replace `count' = _n - (_N + 1)/2
				} 
				if r(max) > 0 { 
					replace _stack = /// 
					_stack + `height' * `count' / r(max) 
				} 	
			}	
		}
	}	
	else {
		local gif "if `touse'" 

		qui if "`over'" == "" {
			// a single variable, no over()
			// x axis shows `varlist' 
			// y axis shows `over' = 1  
			tempvar over
			gen byte `over' = 1 if `touse'
			tempname overlbl 
			label def `overlbl' 1 "`varlist'"
			label val `over' `overlbl' 
		}
		else qui {
			// a single variable with over()
			// x axis shows `varlist' 
			// y axis shows `over' (or `overcount' if stack option)
			tempvar over2
			capture confirm numeric variable `over'
			if _rc == 7 { 
				encode `over' if `touse', gen(`over2')
			}	
			else { 
				gen `over2' = `over' if `touse'
				label val `over2' `: value label `over'' 
			} 	
			_crcslbl `over2' `over' 
			local over "`over2'"

			capture levelsof `over' 
			if _rc { 
				su `over', meanonly 
				local range "`r(min)'/`r(max)'" 
			} 
			else local range "`r(levels)'" 
		}

		qui if `"`box'`box2'"' != "" { 
			tempvar median loq upq yshow2 
			egen `median' = median(`varlist') `gif', by(`by' `over') 
			egen `loq' = pctile(`varlist') `gif', p(25) by(`by' `over') 
			egen `upq' = pctile(`varlist') `gif', p(75) by(`by' `over') 
		} 

		qui if `"`bar'`bar2'"' != "" { 
			tempvar mean group ul ll yshow2
			gen `mean' = . 
			gen `ul'   = . 
			gen `ll'   = . 
			egen `group' = group(`by' `over') 
			su `group', meanonly
			forval i = 1/`r(max)' { 
				ci `varlist' if `group' == `i', `ciopts' 
				replace `mean' = r(mean) if `group' == `i' 
				replace `ul' = r(ub) if `group' == `i' 
				replace `ll' = r(lb) if `group' == `i' 
			}
		}
	
		qui if "`width'" != "" { 
			tempvar rounded
			if "`floor'" != "" {
				gen `rounded' = `width' * floor(`varlist'/`width')
			}
			else if "`ceiling'" != "" { 
				gen `rounded' = `width' * ceil(`varlist'/`width')
			}	
			else gen `rounded' = round(`varlist', `width') 

			_crcslbl `rounded' `varlist' 
			local varlist "`rounded'" 
		} 	
	
		qui if "`stack'" != "" { 
			tempvar count overcount 
			sort `touse' `by' `over' `varlist' `separate', stable 
			by `touse' `by' `over' `varlist': gen `count' = _n - 1 
			su `count' if `touse', meanonly
			if "`centre'`center'" != "" { 
				by `touse' `by' `over' `varlist' : ///
				replace `count' = _n - (_N + 1)/2 
			} 
			gen `overcount' = `over' if `touse' 
			if r(max) > 0 { 
				replace `overcount' = /// 
				`overcount' + `height' * `count' / r(max) 
			} 	
			_crcslbl `overcount' `over'
			label val `overcount' `: value label `over'' 
		} 
		
	}	

	if "`boffset'" == "" { 
		if `"`bar'`bar2'"' != "" local boffset = -0.2 
		else                     local boffset = 0 
	}	

	// plot details 
	if `noover' local axtitle `" "' 
	else { 
		local axtitle : variable label `over' 
		if `"`axtitle'"' == "" local axtitle "`over'" 
	} 	

	if `nvars' > 1 local axtitle2 "`varlist'"
	else { 
		local axtitle2 `"`: var label `varlist''"' 
		if `"`axtitle2'"' == "" local axtitle2 "`varlist'" 
	}	

	if "`over'" != "" { 
		if "`stack'" != "" { 
			local yshow "`overcount'" 
			local xshow "`varlist'" 
		} 	
		else { 
			local yshow "`over'" 
			local xshow "`varlist'" 
		} 	
	}
	else {
		local yshow "_stack" 
		local xshow "`data'" 
	}

	local y = cond("`over'" != "", "`over'", "_stack") 
	local Y = cond("`over'" != "", "`over'", "`copystack'") 

	if `noover' & `nvars' == 1 local axlabel ", nolabels noticks nogrid" 
	else { 
		foreach r of num `range' { 
			local axlabel `axlabel' `r' `"`: label (`y') `r''"'  
		}	
		local axlabel `axlabel', ang(h) 
	}	
	
	su `yshow', meanonly
	local margin = cond(r(max) == r(min), 0.1, 0.05 * (r(max) - r(min)))
	local stretch "r(`= r(min) - `margin'' `= r(max) + `margin'')" 
	if "`vertical'" != "" local stretch "xsc(`stretch')" 
	else local stretch "ysc(`stretch')" 

	local nprev = 0 

	if "`vertical'" != "" { 
		qui if `"`box'`box2'"' != "" { 
			gen `yshow2' = `Y' + `boffset' 
			if "`medianbar'" != "" { 
				local medianbar ///
		rbar `median' `median' `yshow2', barw(0.4) bcolor(none) `medianbar' 
				local nprev = `nprev' + 1 
			}
			local boxbar ///
		rbar `median' `loq' `yshow2', bcolor(none) barw(0.4) `box2' ///
		|| rbar `median' `upq' `yshow2', bcolor(none) barw(0.4) `box2' ///
		|| `medianbar' 
			local nprev = `nprev' + 2 
		}

		qui if `"`bar'`bar2'"' != "" { 
			gen `yshow2' = `Y' + `boffset' 
			local boxbar ///
			rcap `ul' `ll' `yshow2', `baropts' || ///
			scatter `mean' `yshow2', `meanopts'   
			local nprev = `nprev' + 2 
		}

		qui if "`separate'" != "" { 
			tempname stub 
			separate `xshow', by(`separate') gen(`stub') veryshortlabel 
			local xshow "`r(varlist)'" 
			local first = `nprev' + 1 
			local last = `first' + `: word count `xshow'' - 1 
			numlist "`first'/`last'" 
			local separate legend(order(`r(numlist)')) 
		}
		else local separate "legend(off)" 

		if "`by'" != "" { 
			if "`separate'" == "" local separate "legend(off)" 

			if `noover' & `nvars' == 1 { 
				local byby ///
				"by(`by', noixla noixtic `separate' `opts') xla(none)" 
			}
			else local byby ///
				"by(`by', noixtic `separate' `opts')" 

			local separate 
		} 
	
		twoway `boxbar' || ///     
		scatter `xshow' `yshow' `gif',     ///
		ms(Oh) xti(`"`axtitle'"') yti(`"`axtitle2'"')              /// 
		xla(`axlabel') `stretch' `byby' `separate' `options'      ///
		|| `plot' || `addplot' 
		// blank 
	} 	
	else { 
		qui if `"`box'`box2'"' != "" { 
			gen `yshow2' = `Y' + `boffset' 
			if "`medianbar'" != "" { 
				local medianbar ///
		rbar `median' `median' `yshow2', barw(0.4) bcolor(none) hor `medianbar' 
				local nprev = `nprev' + 1 
			}
			local boxbar ///
			rbar `median' `upq' `yshow2', bcolor(none) barw(0.4) hor `box2' ///
			|| rbar `median' `loq' `yshow2', bcolor(none) barw(0.4) hor `box2' ///
			|| `medianbar' 
			local nprev = `nprev' + 2 
		} 	

		qui if `"`bar'`bar2'"' != "" { 
			gen `yshow2' = `Y' + `boffset' 
			local boxbar ///
			rcap `ul' `ll' `yshow2', hor `baropts' ///
			|| scatter `yshow2' `mean', `meanopts'
			local nprev = `nprev' + 2 
		}

		qui if "`separate'" != "" { 
			tempname stub 
			separate `yshow', by(`separate') gen(`stub') veryshortlabel 
			local yshow "`r(varlist)'" 
			local first = `nprev' + 1 
			local last = `first' + `: word count `yshow'' - 1 
			numlist "`first'/`last'" 
			local separate legend(order(`r(numlist)')) 
		}
		else local separate "legend(off)"

		if "`by'" != "" {
			if "`separate'" == "" local separate "legend(off)"   

			if `noover' & `nvars' == 1 { 
				local byby ///
				"by(`by', noiyla noiytic `separate' `opts') yla(none)"
			} 
			else local byby "by(`by', noiytic `separate' `opts')" 

			local separate 
		} 

		twoway `boxbar' ||  ///
		scatter `yshow' `xshow' `gif',    ///
		ms(Oh) yti(`"`axtitle'"') xti(`"`axtitle2'"')             /// 
		yla(`axlabel') `stretch' `byby' `separate' `options'     /// 
		|| `plot' || `addplot'  
		// blank 
	} 	
end 	

/* 

	2.1.3 The -sort-s were all made -, stable-. This is important  
	when you want to add -mlabel()- and -mlabel()- contains 
	order-sensitive information e.g. on time of observation. 

*/ 


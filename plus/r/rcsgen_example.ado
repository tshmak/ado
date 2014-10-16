program define rcsgen_example
	version 10.1
	preserve
	sysuse auto, clear
	rcsgen weight, gen(rcs) df(3)
	regress mpg rcs1-rcs3
	predictnl pred = xb(), ci(lci uci)
	twoway (rarea lci uci weight, sort) (scatter mpg weight, sort) (line pred weight, sort lcolor(black)), legend(off)
	restore
end

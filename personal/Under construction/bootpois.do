* Program to do Poisson regression with bootstrapping
* Created July 2010 by Timothy Mak

capture program drop bootpois
program define bootpois, eclass sortpreserve

	version 10

	syntax varlist [if] [in] [fweight] [, Offset(varname) Exposure(varname)]



	
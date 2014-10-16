* Program to get CI's and p-values from -lincom-
capture program drop lincomci
program define lincomci, rclass 

	version 8
	syntax anything [, Level(numlist max=1 >0 <100) EForm DF(numlist max=1 >0)]
	if "`level'" == "" local level = c(level)
	
	lincom `anything', `eform' level(`level') df(`df')

	if "`eform'" == "eform" {
		qui lincom `anything'
	}
	
	tempname z lci uci p t DF
	if r(df) == . & "`df'" == "" {
		local plevel = 1 - (1 - `level'/100)/2
		scalar `z' = r(estimate) / r(se)
		scalar `lci' = r(estimate) - invnormal(`plevel') * r(se)
		scalar `uci' = r(estimate) + invnormal(`plevel') * r(se)
		scalar `p' = (1 - normal(abs(`z'))) * 2
		return scalar z = `z'
	}
	else {
		if "`df'" != "" scalar `DF' = `df'
		else scalar `DF' = r(df)
		
		local plevel = (1 - `level'/100)/2
		scalar `t' = r(estimate) / r(se)
		scalar `lci' = r(estimate) - invttail(`DF', `plevel') * r(se)
		scalar `uci' = r(estimate) + invttail(`DF', `plevel') * r(se)
		scalar `p' = ttail(`DF', abs(`t')) * 2
		return scalar t = `t'
		return scalar df = `DF'
	}
	
	return scalar p = `p'
	if "`eform'" == "eform" {
		return scalar lci = exp(`lci')
		return scalar uci = exp(`uci')
		return scalar b = exp(r(estimate))
		return scalar se = r(se) * exp(r(estimate))
	}
	else {
		return scalar lci = `lci'
		return scalar uci = `uci'
		return scalar b = r(estimate)
		return scalar se = r(se)
	}
	
end

* Program to integrate an arbitrary function in mata by interpolating with a cubic spline

mata: 

real scalar integratespline(pointer scalar f, real scalar lower, real scalar upper, real vector aux, 
	real scalar posvar, real scalar numpoints) {

	delta = (upper - lower) / (numpoints -1)	
	x = (0::(numpoints-1)) :* delta :+ lower

	aux = colshape(aux, 1)
	if (posvar == 1) {
		beforeaux = J(0,1,.)
	}
	else {
		beforeaux = aux[1::(posvar-1)]
	}
	if (rows(aux) == rows(beforeaux)) {
		afteraux = J(0,1,.)
	}
	else {
		afteraux = aux[posvar::rows(aux)]
	}

	y = J(numpoints, 1,.)

	for(i=1; i<=numpoints; i++) {
		par = (beforeaux \ x[i] \ afteraux)
		y[i] = (*f)(par)
	}

	splinefit = spline3(x, y)

	area = ( ( (splinefit[.,3] :/ 4) :* delta + splinefit[.,2] :/3) :* delta + splinefit[.,1] :/2) :* delta + y

	integral = sum(area) * delta
	return(integral)
}


end


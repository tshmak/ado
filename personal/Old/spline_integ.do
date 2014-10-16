capture  mata : mata drop spline_integ()

mata:

real scalar spline_integ(real colvector x, real colvector y, real scalar equal_spaced) {

	spline_result = spline3(x,y)
	npoints = rows(x)
	nparts = npoints - 1
	integral_diff = 0

	if(equal_spaced == 1) {
		dx = J(nparts, 1, (x[npoints] - x[1])/nparts)
		block_integral = sum(y[1::nparts]) * dx[1]
	}
	else {
		dx = x[2::npoints] - x[1::nparts]
		block_integral = y[1::nparts]' * dx
	}

	for(i=1;i<=nparts;i++) {
		integral_diff = integral_diff + 
			polyeval(polyinteg((0,spline_result[i,1..3]),1), dx[i])
	}
	return(block_integral + integral_diff)
}

end

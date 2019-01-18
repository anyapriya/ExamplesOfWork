*Problem 1

set matsize 4000
cd "/Users/Anya/Documents/Senior Year/Labor Econ/Stata"



cap program drop mySim
program mySim, rclass
	syntax [if] [in], q(integer) n(integer)
	
	clear
	
	local Q = `q'
	local N = `n'
	
		
	matrix covmat = (1,0.8\ 0.8,1)
	set obs `N'
	
	forval i = 1/`Q'{
		cap drop z`i'
		gen z`i' = runiform()
	}

		
	cap drop eta 
	cap drop merp
	drawnorm eta merp, n(`=N') cov(covmat)
	
	cap drop x
	gen x = 0.1*z1 + (`Q'-1)*eta
	
	
	cap drop y
	gen y = x + merp
	

	
	
end








*Part a

cap mata mata drop mata_myiv1()
mata

	function mata_myiv1(){
		xmat=zmat=ymat=.
		st_view(xmat, .,("x"),0)
		st_view(zmat, .,("z*"), 0)
		st_view(ymat, .,("y"), 0)
		
		projmat = zmat*invsym(cross(zmat, zmat))*zmat'
		
		b = invsym((xmat' * projmat * xmat))*xmat'*projmat*ymat
		
		ypredvals = xmat*b
		e = ymat - ypredvals
		V = e'e/(rows(xmat))*invsym(xmat'*projmat*xmat)
		
		st_matrix( "b" , b)
		st_matrix( "V" , V)
	}
	
end
	
cap program drop myiv1
program myiv1, rclass
syntax [if] [in], q(integer) n(integer)
	set seed 12345
	mySim, q(`q') n(`n')
	mata: mata_myiv1()
	mat list b
	mat list V

end


myiv1, q(2) n(1000)

outtable using myiv1beta, mat(b) replace
outtable using myiv1varcov, mat(V) replace

ivregress 2sls y (x = z* ), noconstant

eststo clear
eststo: quietly ivregress 2sls y (x = z* ), noconstant
esttab using my2slsreg.tex















*Part B

cap mata mata drop mata_myiv2()
mata

	function mata_myiv2(){
		xmat=zmat=ymat=.
		st_view(xmat, .,("x"),0)
		st_view(zmat, .,("z*"), 0)
		st_view(ymat, .,("y"), 0)
		
		projmat = zmat*invsym(cross(zmat, zmat))*zmat'


		zz = cross(zmat , zmat)
		zx = cross(zmat , xmat)
		b_s1=invsym(zz)*zx
		xpredvals = zmat*b_s1
		
		xx = cross(xpredvals, xpredvals)
		xy = cross(xpredvals, ymat)
		b_s2 = invsym(xx)*xy
		
		ypredvals = xmat*b_s2
		e = ymat - ypredvals
		V = e'e/(rows(xmat))*invsym(xmat'*projmat*xmat)
		
		st_matrix( "b" , b_s2)
		st_matrix( "V" , V)
	}
	
end



cap program drop myiv2
program myiv2, rclass
syntax [if] [in], q(integer) n(integer)
	set seed 12345
	mySim, q(`q') n(`n')
	mata: mata_myiv2()
	mat list b
	mat list V

end


myiv2, q(2) n(1000)

outtable using myiv2beta,mat(b) replace
outtable using myiv2varcov,mat(V) replace

ivregress 2sls y (x = z* ), noconstant











*Problem 2

foreach i of numlist 2 10 20 {
	set seed 12345

	forval j = 1/1000 {
		mySim, q(`i') n(1000)
		
		
		*a - OLS
		reg y x, robust noconstant
		
		matrix b = e(b)
		matrix V = e(V)
		scalar OLSbias = b[1,1] - 1
		di OLSbias
					
		scalar OLSFTR = ttail(999,(OLSbias/sqrt(V[1,1]))) > 0.025 & ttail(999,(OLSbias/sqrt(V[1,1]))) < 0.975
		di OLSFTR
		
		
		
		
		*b - 2SLS (conventional confidence interval)
		ivregress 2sls y (x = z* ), robust noconstant
		
		matrix b = e(b)
		matrix V = e(V)
		scalar TSLS1bias = b[1,1] - 1
		di TSLS1bias
					
		scalar TSLS1FTR = ttail(999,(TSLS1bias/sqrt(V[1,1]))) > 0.025 & ttail(999,(TSLS1bias/sqrt(V[1,1]))) < 0.975
		di TSLS1FTR
		
		
		
		
		
		
		*c - 2SLS (CLR confidence interval using “rivtest.ado)
		rivtest, null(1)
		scalar pval = r(clr_p)
		scalar TSLS2bias = TSLS1bias
		di TSLS2bias
		
		scalar TSLS2FTR = pval > 0.05
		di TSLS2FTR
		
		
		
		
		*d - LIML
		ivregress liml y (x = z1* ), noconstant robust
		
		matrix b = e(b)
		matrix V = e(V)
		scalar LIMLbias = b[1,1] - 1
		di LIMLbias
					
		scalar LIMLFTR = ttail(999,(LIMLbias/sqrt(V[1,1]))) > 0.025 & ttail(999,(LIMLbias/sqrt(V[1,1]))) < 0.975
		di LIMLFTR
		
		
		
		
		
		*e - LASSO
		lassoShooting y z* , het(1) verbose(0) lasiter(5)
		local ysel `r(selected)'

		lassoShooting x z*, het(1) verbose(0) lasiter(5)
		local xsel `r(selected)'

		local xuse : list ysel | xsel

		reg y x `xuse' , noconstant robust
		
		matrix b = e(b)
		matrix V = e(V)
		scalar LASSObias = b[1,1] - 1
		di LASSObias
		
					
		scalar LASSOFTR = ttail(999,(LASSObias/sqrt(V[1,1]))) > 0.025 & ttail(999,(LASSObias/sqrt(V[1,1]))) < 0.975
		di LASSOFTR
		
		
		
		
		
		
		if `j' == 1 {
			matrix Q`i' = [`i', OLSbias, OLSFTR, TSLS1bias, TSLS1FTR, TSLS2bias, TSLS2FTR, LIMLbias, LIMLFTR, LASSObias, LASSOFTR]
		} 
		else {
			matrix Q`i' = Q`i'\[`i', OLSbias, OLSFTR, TSLS1bias, TSLS1FTR, TSLS2bias, TSLS2FTR, LIMLbias, LIMLFTR, LASSObias, LASSOFTR]
		}
	}
			
}




matrix allQ = Q2\Q10\Q20
mat list allQ

mat colnames allQ = Q OLSbias OLSFTR TSLS1bias TSLS1FTR TSLS2bias TSLS2FTR LIMLbias LIMLFTR LASSObias LASSOFTR

clear
svmat allQ

export delimited using "/Users/Anya/Documents/Senior Year/Labor Econ/Pset3ResultsMatrix.csv", replace

*Note: I imported the data into R and calculated the medians of biases and probability of Type 1 error there, and then turned it into a table















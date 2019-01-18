global filepath "/Users/Anya/Documents/Senior Year/Labor Econ/Stata"
cd "$filepath"


//Problem 1:
use "$filepath/census_sample_30_50.dta", clear

//Part 1:
//local varlist "lnwage exp exp2 hieduc"


cap program drop myreg1
program myreg1, eclass
	syntax varlist [if] [in]
	
	
	//local varlist "lnwage exp exp2 hieduc"

	
	marksample touse

	tokenize `varlist'
	
	local ymat `1'
	macro shift 1
	local Xmat `*'
	
	
	
		
		mata: y=X=V=.
		
		mata: st_view(y=., ., "`ymat'", "`touse'")
		mata: st_view(X=., ., "`Xmat'", "`touse'")
		
		
		mata: b = invsym(cross(X,1  ,X,1))*cross(X,1  , y,0) 
		
		mata: cons = J(rows(X),1,1)
		
		mata: e = y - (X , cons)*b

		mata: V = e'e/(rows(X)-rows(b))*invsym(cross(X,1  ,X,1))
		mata: b = b'
		mata: st_matrix( "bmat" , b)
		mata: st_matrix(  "Vmat" , V)

	

	

	
	matrix rownames bmat=`ymat'
	matrix colnames bmat=`Xmat' _cons
	matrix rownames Vmat=`Xmat' _cons
	matrix colnames Vmat=`Xmat' _cons
	
	matrix list bmat
	matrix list Vmat
	
	
	ereturn clear
	ereturn post bmat Vmat
	
	ereturn list

	
end



local varlist "lnwage exp exp2 hieduc"

myreg1 `varlist'




regress lnwage exp exp2 hieduc












//Part 2:


	local varlist "lnwage exp exp2 hieduc"

	marksample touse

	tokenize `varlist'
	
	local y `1'
	macro shift 1
	local X `*'

mata
mata clear
void myols(y,X){
  st_view(y=.,.,st_local("y"),0)
  st_view(X=.,.,st_local("X"),0)
  
  
  

  
  cons=J(rows(X),1,1)
  X=(X,cons)
  k=cols(X)
  temp1=J(k,k,0)
  temp2=J(k,1,0)
  N = cols(X)



  for (i=1;i<=N;i++){
    temp1=temp1 + X[i,.]'*X[i,.]
    temp2=temp2+X[i,.]'*y[i,.]
  }

  
  st_matrix("temp1",temp1)
  st_matrix("temp2",temp2)
  

  

  
  b=invsym(temp1)*temp2


  
  
  E=J(k,k,0)
  
  for (i=1;i<=N;i++){
    E=E+(y[i,.]-X[i,.]*b)^2*X[i,.]*X[i,.]'
  }
  V=invsym(X'X)*(E*(N/(N-k)))*invsym(X'X)
  b=b'
  st_matrix("b",b)
  st_matrix("V",V)
 }
end


	matrix list b
	matrix list V



capture program drop myreg2
program myreg2,eclass
syntax varlist

	local varlist "lnwage exp exp2 hieduc"

	marksample touse

	tokenize `varlist'
	
	local y `1'
	macro shift 1
	local X `*'
	
	
	
	mata: myols("y","X")
	matrix rownames b=`y'
	matrix colnames b=`X' _cons
	matrix rownames V=`X' _cons
	matrix colnames V=`X' _cons

	matrix list b
	matrix list V
	

	ereturn post `b' 
	ereturn post `V'


end

local varlist "lnwage exp exp2 hieduc"
myreg2 `varlist'

reg lnwage exp exp2 hieduc, robust


















**Problem 1.2 OLS in MATA**
 clear
 clear results

**Create a mata function called myols()
mata
mata clear
void myols(y,X){
  st_view(y=.,.,st_local("y"),0)
  st_view(X=.,.,st_local("X"),0)
  N=rows(X)
  cons=J(N,1,1)
  X=(X,cons)
  k=cols(X)
  A=J(k,k,0)
  B=J(k,1,0)
  for (i=1;i<=N;i++){
    A=A+X[i,.]'*X[i,.]
    B=B+X[i,.]'*y[i,.]
  }
  b=invsym(A)*B
  E=J(k,k,0)
  for (i=1;i<=N;i++){
    E=E+(y[i,.]-X[i,.]*b)^2*X[i,.]'X[i,.]
  }
  V=invsym(X'X)*(E*(N/(N-k)))*invsym(X'X)
  b=b'
  st_matrix("b",b)
  st_matrix("V",V)
 }
end
**Create a stata program called myreg2
capture program drop myreg2
program myreg2,eclass
syntax varlist
tokenize `varlist'
local i=1
  while "`1'"!="" {
    drop if `1'==.
    if `i'==1 {
          local y "`1'"
          }
        else{
          if `i'==2 {
          local X "`1'"
          }
          else{
          local X "`X' `1'"
          }
        }
        local i=`i'+1
        macro shift
  }
mata: myols("y","X")
matrix rownames b=`y'
matrix colnames b=`X' _cons
matrix rownames V=`X' _cons
matrix colnames V=`X' _cons
ereturn post b V
matrix list e(b)
matrix list e(V)
end
**Run program myreg2
use "$filepath/census_sample_30_50.dta", clear
myreg2 lnwage exp exp2 hieduc
































//Problem 2:



use "https://stats.idre.ucla.edu/stat/stata/dae/poisson_sim", clear

histogram num_awards
sum num_awards

local varlist = "num_awards i.prog math"
fvrevar `varlist'
mypois `r(varlist)'
poisson num_awards i.prog math



//Problem 3:

//Part 1:

cap program drop OLSPOIS
program OLSPOIS, rclass
	syntax [if] [in], sigma(real) n(integer)
	
	scalar sigma = 0.5
	scalar N = `n'
	scalar temp = sigma / 2
	matrix covmat = (sigma,temp\ temp,sigma)
	drawnorm X1 X2, n(`=N') cov(covmat)
	gen y = rpoisson(exp(2*X1-X2))
	gen truepred = exp(2*X1-X2)
	
	//estimates store b
	
	
	reg y X1 X2
	matrix b_OLS = e(b)
	scalar MSE_OLS = 0.5*(b_OLS[1,1]-2)^2 + 0.5*(b_OLS[1,2]+1)^2
	
	poisson y X1 X2
	matrix b_pois = e(b)
	scalar MSE_pois = 0.5*(b_pois[1,1]-2)^2 + 0.5*(b_pois[1,2]+1)^2

	return scalar OLSMSE = MSE_OLS
	return scalar PoisMSE = MSE_pois
	
	drop y X1 X2 truepred
end

//Part 2

foreach i of numlist 50 1000 {
	foreach j of numlist 0.01 0.1 1{
		set seed 5555
			local s = 1/`j'
			//scalar i = 50
			//scalar j = 0.01
			scalar l = 0
			forval k = 1/1000 {
				OLSPOIS, sigma(`j') n(`i')
				  
				if `k' == 1 {
					matrix MSEn`i'`s' = [r(OLSMSE), r(PoisMSE)]
				} 
				else {
					matrix MSEn`i'`s' = MSEn`i'`s'\[r(OLSMSE), r(PoisMSE)]
				}
			}
			scalar l = l + 1
			mata : st_matrix("sumMSE`i'`s'", colsum(st_matrix("MSEn`i'`s'")))
			mat colnames sumMSE`i'`s' = OLSMSE POISMSE
			mat list sumMSE`i'`s'
			
	}
}

matrix OLSmat = [sumMSE501[1,1], sumMSE5010[1,1], sumMSE50100[1,1]] \ [sumMSE10001[1,1], sumMSE100010[1,1], sumMSE1000100[1,1]]

mat colnames OLSmat = 0.01 0.1 1
mat rownames OLSmat = 50 1000




matrix POISmat = [sumMSE501[1,2], sumMSE5010[1,2], sumMSE50100[1,2]] \ [sumMSE10001[1,2], sumMSE100010[1,2], sumMSE1000100[1,2]]

mat colnames POISmat = 0.01 0.1 1
mat rownames POISmat = 50 1000

mat list OLSmat
mat list POISmat









//Problem 4: 
use "$filepath/25_MSA_panel.dta", clear


//Part 1:
drop if naics != 10
gen treated = .
gen lnemp2 = .
egen cbsanames = group(cbsa)


cap program drop randsim
program randsim, rclass
	
	
	replace treated = 0
	levels cbsa, local(uniqlist)
	forvalues i=1/25 {
		scalar treatment = rbinomial(1,0.25)
		if treatment == 1{
			scalar treatdt = floor(1 + uniform()*81)
			replace treated = treatment if cbsanames == `i' & time >= treatdt
		}
	}

	replace lnemp2 = lnemp + 0.5*treated
	
	
	
	
	
	
	reg lnemp treated cbsa time, vce(cluster cbsa)
	
	mat bmat = e(b)
	mat vmat = e(V)
	scalar degf = e(df_m)
	
	local tval1 = bmat[1,1]/sqrt(vmat[1,1])
	
	display ttail(degf,`tval1')
	
	
	if ttail(degf,`tval1') < 0.05 {
		scalar mod1_mysim = 1
	}
	else {
		scalar mod1_mysim = 0
	}
	

	
	
	
	reg lnemp2 treated cbsa time, vce(cluster cbsa)
	scalar degf = e(df_m)
	
	mat bmat = e(b)
	mat vmat = e(V)
	
	local tval2 = bmat[1,1]/sqrt(vmat[1,1])

	
	if ttail(degf,`tval2') < 0.05 {
		scalar mod2_mysim = 1
	}
	else {
		scalar mod2_mysim = 0
	}

	
	
	
	
	wildbs lnemp treated cbsa time, reps(1) cmd("reg") cluster(cbsa) hypothesis(0) alpha(0.05)
	return list
	local mytstat1 = scalar(r(tstat))
	di `mytstat1'
	//scalar mod1_wildbs = (ttail(degf,r(tstat)) < 0.05)
	if ttail(degf,r(tstat)) < 0.05 {
		scalar mod1_wildbs = 1
	}
	else {
		scalar mod1_wildbs = 0
	}
	
	
	
	
	wildbs lnemp2 treated cbsa time, reps(1) cmd("reg") cluster(cbsa) hypothesis(0) alpha(0.05)
	return list
	local mytstat2 = scalar(r(tstat))
	//scalar mod2_wildbs = (ttail(degf,r(tstat)) < 0.05)

	if ttail(degf,r(tstat)) < 0.05 {
		scalar mod2_wildbs = 1
	}
	else {
		scalar mod2_wildbs = 0
	}
	
	
	
	return scalar beta1_mysim = mod1_mysim
	return scalar beta2_mysim = mod2_mysim
	return scalar beta1_wildbs = mod1_wildbs
	return scalar beta2_wildbs = mod2_wildbs
	
	

	
end



//Part 2:
scalar mysim_beta1_count = 0
scalar mysim_beta2_count = 0
scalar wildbs_beta1_count = 0
scalar wildbs_beta2_count = 0

forval j = 1/1000 {
  randsim
  return list
  scalar mysim_beta1_count = mysim_beta1_count + scalar(r(beta1_mysim))
  scalar mysim_beta2_count = mysim_beta2_count + scalar(r(beta2_mysim))
  scalar wildbs_beta1_count = wildbs_beta1_count + scalar(r(beta1_wildbs))
  scalar wildbs_beta2_count = wildbs_beta2_count + scalar(r(beta2_wildbs))
}

di mysim_beta1_count
di mysim_beta2_count
di wildbs_beta1_count
di wildbs_beta2_count


//Part 3:
drop if cbsa != 14460 & cbsa != 16980 & cbsa != 19100 & cbsa != 31100 & cbsa != 33100 & cbsa != 35620 & cbsa != 37980 & cbsa != 38300



scalar mysim_beta1_count = 0
scalar mysim_beta2_count = 0
scalar wildbs_beta1_count = 0
scalar wildbs_beta2_count = 0

forval j = 1/1000 {
  randsim
  return list
  scalar mysim_beta1_count = mysim_beta1_count + scalar(r(beta1_mysim))
  scalar mysim_beta2_count = mysim_beta2_count + scalar(r(beta2_mysim))
  scalar wildbs_beta1_count = wildbs_beta1_count + scalar(r(beta1_wildbs))
  scalar wildbs_beta2_count = wildbs_beta2_count + scalar(r(beta2_wildbs))
}

di mysim_beta1_count
di mysim_beta2_count
di wildbs_beta1_count
di wildbs_beta2_count
















//Problem 5: 
use "$filepath/census_sample_30_50.dta", clear

gen FB = (bpld>15000)
gen english = (speakeng == 3 | speakeng == 4)

//Part 1:
reg lnwage FB, robust

//Part2:
reg lnwage FB married exp exp2 i.racesing hisp i.educ99 english gender, robust

//Part 3:
local varlist = "married exp exp2 i.racesing hisp i.educ99 english gender"
fvrevar `varlist'
egen gp = group(`r(varlist)')
areg lnwage FB, robust absorb(gp)
//reg lnwage FB i.gp, robust


//Part 4:
local varlist = "married exp exp2 i.racesing hisp i.educ99 english gender"
fvrevar `varlist'
cem lnwage `r(varlist)', treatment(FB)
//cem lnwage married exp exp2 racesing hisp educ99 english gender, treatment(FB)


//Part 5:
cap drop FBprop
probit FB married exp exp2 racesing hisp educ99 english gender     
predict FBprop 


xtile FBprop_n = FBprop, nq(10)
table FBprop_n FB, c(mean married mean exp mean exp2 mean gender) row  
table FBprop_n FB, c(mean black mean hisp mean hieduc) row  


foreach j of numlist 0 1 {
	cap drop ed`j'
	cap drop lnwage_e`j'
	gen ed`j' = 1 if FB==`j'
	egen lnwage_e`j' = mean (lnwage*ed`j'), by(FBprop_n)	
}

cap drop lnwdif
gen lnwdif = (lnwage_e1-lnwage_e0) if FB==1


cap drop FBtot 
cap drop FBtot
cap drop FBq
cap drop all

egen FBq = sum(FB), by(FBprop_n)
egen FBtot = sum(FB)

cap drop wt1  
gen wt1 = FBq/FBtot
 

cap drop first 
egen first = tag(FBprop_n) if FB==1 



table FBprop_n if FB==1 & first==1 [aw=wt1] , c(mean lnwdif) row  
  
   
 cap drop FBpropsq
 gen FBpropsq = marprop^2
 
 reg lnwage FB FBprop, robust  
 reg lnwage FB FBprop FBpropsq, robust  
 


//Part 6:
psmatch2 FB married exp exp2 racesing hisp educ99 english gender, neighbor(10)


//Part 7:
 
 qui sum FB
 local p = r(mean)
 
 cap drop w3
 gen w3 = cond(FB, `p'/(1-`p'), FBprop/(1-FBprop))

  twoway (kdensity FBprop if FB==1 ) (kdensity FBprop if FB==0 )
 
  twoway (kdensity FBprop if FB==1 [aw=w3] ) (kdensity FBprop if FB==0 [aw=w3])

 reg lnwage FB [aw=w3]
 
 
 
 
//Part 8:
teffects ipw (lnwage) (FB married exp exp2 racesing hisp educ99 english gender)

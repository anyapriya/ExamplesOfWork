*Problem 1

use "/Users/Anya/Documents/Senior Year/Labor Econ/Stata/pointonepctsampleE.dta", clear

foreach i of numlist 50 75 100 125 150 {
	cap drop I`i'
	gen I`i' = poverty<`i'
}

gen lnminwage = log(minwage)


*Part A.i.

reg I50 lnminwage i.year i.division, cluster(division)
reg I75 lnminwage i.year i.division, cluster(division)
reg I100 lnminwage i.year i.division, cluster(division)
reg I125 lnminwage i.year i.division, cluster(division)
reg I150 lnminwage i.year i.division, cluster(division)


*Part A.ii.

reg I50 lnminwage i.empstatd age i.sex i.married i.racesingd hieduc uhrswork i.year i.division, cluster(division)
reg I75 lnminwage i.empstatd age i.sex i.married i.racesingd hieduc uhrswork i.year i.division, cluster(division)
reg I100 lnminwage i.empstatd age i.sex i.married i.racesingd hieduc uhrswork i.year i.division, cluster(division)
reg I125 lnminwage i.empstatd age i.sex i.married i.racesingd hieduc uhrswork i.year i.division, cluster(division)
reg I150 lnminwage i.empstatd age i.sex i.married i.racesingd hieduc uhrswork i.year i.division, cluster(division)


*Not including:
	*incwelfr - would only be on welfare if the person is in poverty
	*statefips - minimum wage would be by state, so we can use division to account for place effects instead
	*citizen - 89.11961% of data for this variable is N/A
	*inctot - the poverty variable is derived from the total family income, so should not include
	
	
*Part A.iii. 


*Part A.iii.

reg I50 lnminwage i.division i.division##year, robust
reg I75 lnminwage i.division i.division##year, robust
reg I100 lnminwage i.division i.division##year, robust
reg I125 lnminwage i.division i.division##year, robust
reg I150 lnminwage i.division i.division##year, robust


reg I50 lnminwage i.empstatd age i.sex i.married i.racesingd hieduc uhrswork i.division i.division##year, cluster(division)
reg I75 lnminwage i.empstatd age i.sex i.married i.racesingd hieduc uhrswork i.division i.division##year, cluster(division)
reg I100 lnminwage i.empstatd age i.sex i.married i.racesingd hieduc uhrswork i.division i.division##year, cluster(division)
reg I125 lnminwage i.empstatd age i.sex i.married i.racesingd hieduc uhrswork i.division i.division##year, cluster(division)
reg I150 lnminwage i.empstatd age i.sex i.married i.racesingd hieduc uhrswork i.division i.division##year, cluster(division)




*Table of all of this together


foreach j of numlist 50 75 100 125 150 {

	

	reg I`j' lnminwage i.year i.division, cluster(division)
	matrix tempmat = [_b[lnminwage]\ _se[lnminwage]]

	
	reg I`j' lnminwage i.empstatd age i.sex i.married i.racesingd hieduc uhrswork i.year i.division, cluster(division)
	matrix tempmat = [tempmat, [_b[lnminwage]\ _se[lnminwage]]]

	reg I`j' lnminwage i.division i.division##year, robust
	matrix tempmat = [tempmat, [_b[lnminwage]\ _se[lnminwage]]]

	
	reg I`j' lnminwage i.empstatd age i.sex i.married i.racesingd hieduc uhrswork i.division i.division##year, cluster(division)
	matrix tempmat = [tempmat, [_b[lnminwage]\ _se[lnminwage]]]

	
	if(`j' == 50){
		matrix fullmat = tempmat
	}
	else{
		matrix fullmat = [fullmat \ tempmat]
	}

}

matlist fullmat





*Part B.i.


foreach i of numlist   25(25)250 {
	cap drop I`i'
	gen I`i' = poverty<`i'
}

foreach j of numlist   25(25)250 {
	reg I`j' lnminwage i.empstatd age i.sex i.married i.racesingd hieduc uhrswork i.division i.division##year, cluster(division)
	lincom lnminwage
	matrix tempmat = [`j', _b[lnminwage], _se[lnminwage], _b[lnminwage] + _se[lnminwage]* 2.306004, _b[lnminwage] - _se[lnminwage]* 2.306004]

	if(`j' == 25){
		matrix fullmat2 = tempmat
	}
	else{
		matrix fullmat2 = [fullmat2 \ tempmat]
	}
}

matlist fullmat2

svmat fullmat2

twoway (rarea fullmat24 fullmat25 fullmat21, color(gs14)) (line fullmat22 fullmat21), xscale(noextend) legend(cols(3) lab(1 "Confidence Int") lab(2 "Treatment"))





*Part B.ii. 

matrix A = .
count
local total = r(N)

foreach j of numlist  25(25)250 {

	*reg I`j' lnminwage i.empstatd age i.sex i.married i.racesingd hieduc uhrswork i.division i.division##year, cluster(division)
	reg I`j' lnminwage age hieduc uhrswork 

	matrix b = e(b)
	

	count if poverty==`j'
	scalar pdf`j' = r(N)/`total'
	scalar A`j' = b[1,1]/(-1 * pdf`j')
	matrix A = [A \ A`j']

}
matrix list A

count
local total = r(N)
foreach j of numlist  25 50   {
	count if poverty <= `j'
	scalar percentile = `j' / `total'
	di percentile
 	rifreg I`j' lnminwage age hieduc uhrswork, quantile(percentile)
	di `j'
	 
}

*lnminwage i.empstatd age i.sex i.married i.racesingd hieduc uhrswork i.division i.division##year




*Problem 2


use "/Users/Anya/Documents/Senior Year/Labor Econ/Stata/emp_wage_data.dta", clear

drop if quarterdate > 120 | quarterdate < 88

gen treat = (stateabb == "CA" && quarterdate > 113)
gen treatsample = (stateabb == "CA")


forval i=1/51 {
	local startminwg = MW[`i'*33 - 32]
	local endminwg = MW[`i'*33]

	
	
	if(`startminwg' != `endminwg'  & stateabb[`i'*33] != "CA"){
		drop if stateabb == stateabb[`i'*33]
	}
}
drop if stateabb == "PA"



*Part A.i. 

cap drop teen_logemp
gen teen_logemp = ln(teen_emp)
cap drop overall_logemp
gen overall_logemp = ln(overall_emp)


local outcomes = "teen_logwage teen_logemp overall_logemp overall_logwage"

foreach i of local outcomes{
	reg `i' treat *_share* *_ind* i.statenum i.quarterdate, cluster(statenum)
}


local outcomes = "teen_logwage teen_logemp overall_logemp overall_logwage"

foreach i of local outcomes{
	preserve

	collapse (mean) meantempval=`i' (sd) sdwage=`i' (count) n=`i', by(treatsample quarterdate)

	twoway (line  meantempval quarterdate if treatsample==1) || ///
	(line  meantempval quarterdate if treatsample==0), ///
	xtitle("Quarter") ytitle("") title("Problem 2 `i'") ///
	plotregion(fcolor(white)) graphregion(fcolor(white)) legend(cols(3) lab(1 "Treated") lab(2 "Controls"))  
	
	graph export CA_DiD_`i'.png, replace 
	
	
	restore
}



*Part A.ii.

local outcomes = "teen_logwage teen_logemp overall_logemp overall_logwage"

cap drop MWsq
gen MWsq = MW^2

foreach i of local outcomes{
	reg `i' treat L.treat MW L.MW MWsq *_share* *_ind* i.statenum i.quarterdate, cluster(statenum)

}



*Part A.iii.

local outcomes = "teen_logwage teen_logemp overall_logemp overall_logwage"

foreach i of local outcomes{
	//teffects ipw (`i') (treat *_share* *_ind* )




cap drop treatprop
logit treat *_share* *_ind*      
predict treatprop 

cap drop treatprop_n

xtile treatprop_n = treatprop, nq(10)
 


foreach j of numlist 0 1 {
	cap drop ed`j'
	cap drop `i'_e`j'
	gen ed`j' = 1 if treat==`j'
	egen `i'_e`j' = mean (`i'*ed`j'), by(treatprop_n)	
}

cap drop `i'dif
gen `i'dif = (`i'_e1-`i'_e0) if treat==1


cap drop treattot 
cap drop treattot
cap drop treatq
cap drop all

egen treatq = sum(treat), by(treatprop_n)
egen treattot = sum(treat)

cap drop wt1  
gen wt1 = treatq/treattot
 

cap drop first 
egen first = tag(treatprop_n) if treat==1 



table treatprop_n if treat==1 & first==1 [aw=wt1] , c(mean `i'dif) row  
  
   
 cap drop treatpropsq
 gen treatpropsq = treatprop^2
 
 reg `i' treat treatprop, robust  
 reg `i' treat treatprop treatpropsq, robust  

}













*Part A.iv.
set matsize 800


use "/Users/Anya/Documents/Senior Year/Labor Econ/Stata/emp_wage_data.dta", clear

drop if quarterdate > 120 | quarterdate < 88

gen treat = (stateabb == "CA" && quarterdate > 113)
gen treatsample = (stateabb == "CA")


forval i=1/51 {
	local startminwg = MW[`i'*33 - 32]
	local endminwg = MW[`i'*33]

	
	
	if(`startminwg' != `endminwg'  & stateabb[`i'*33] != "CA"){
		drop if stateabb == stateabb[`i'*33]
	}
}
drop if stateabb == "PA"

cap drop teen_logemp
gen teen_logemp = ln(teen_emp)
cap drop overall_logemp
gen overall_logemp = ln(overall_emp)



local outcomes = "teen_logwage teen_logemp overall_logemp overall_logwage"

foreach i of local outcomes{

	local i = "teen_logwage"
	*infile `i' treat *_share* *_ind* i.statenum i.quarterdate using reg.raw

	/* Create iteraction terms for years and states*/
	gen stqd=1000*statenum+quarterdate
	sum statenum 
	g stmin=r(min)
	g stmax=r(max)
	sum quarterdate 
	g qdmin=r(min)
	g qdmax=r(max)

	/* Create dummies for state+year interactions*/
	g qd=qdmin
	quietly {
	foreach st of numlist 1 2 4 5 6 8 10 12 13 16 17 18 20 21 22 24 26 28 29 30 31 32 34 35 36 37 39 40 45 46 47 48 49 51 54 56 {
		while qd<=qdmax {
			local ind=`st'*1000+qd
			g byte Dstqd_`ind'=stqd==`ind' 
			replace qd=qd+1
			}		
		replace qd=qdmin
	} 
	}

	reg `i' *_share* *_ind* Dstqd*, noc r clust(stqd)
	predict `i'hat, xb
	gen beta=`i'hat- race_share1*_b[race_share1]- race_share2*_b[race_share2]- race_share3*_b[race_share3]- /// 
	hispanic_share*_b[hispanic_share1]- married_share*_b[married_share1]- gender_share*_b[gender_share1]- ///
	emp_sh_ind1*_b[emp_sh_ind1]- emp_sh_ind2*_b[emp_sh_ind2]- emp_sh_ind3*_b[emp_sh_ind3]- emp_sh_ind4*_b[emp_sh_ind4]-/// 
	emp_sh_ind5*_b[emp_sh_ind5]- emp_sh_ind6*_b[emp_sh_ind6]- emp_sh_ind7*_b[emp_sh_ind7]- emp_sh_ind8*_b[emp_sh_ind8]- emp_sh_ind9*_b[emp_sh_ind9]
	
	

	/* Keep only beta coefficients for state*year terms */
	collapse (mean) beta statenum quarterdate qdmin qdmax treat, by(stqd)

	xi: reg beta treat i.quarterdate i.statenum, robust
	xi: reg beta treat i.quarterdate i.statenum, r cluster(state)

	/* Create state and year dummies*/
	g qd=qdmin
	quietly {
		while qd<=qdmax {
		local k=qd
			g byte Dquarterdate_`k'=quarterdate==`k' 
			replace qd=qd+1
			}		
	}

	quietly {
		foreach st of numlist 1 2 4 5 6 8 10 12 13 16 17 18 20 21 22 24 26 28 29 30 31 32 34 35 36 37 39 40 45 46 47 48 49 51 54 56 {
			g byte Dstate_`st'=statenum==`st' 
		}
	}

	/* Now regress the coefficients (beta) obtained from the previous regression 
	on state and year dummies and treat variable*/
	reg beta treat Dstat* Dquarterdate*, noc

	/* Create an indicator for the state where policy changed (Georgia==1)*/
	g byte CA=state==6

	/* Predict residuals from regression */
	predict eta, res 
	replace eta=eta+_b[treat]*treat
	drop D*

	/* Create d tilde variable*/
	bysort quarterdate: egen djtga=mean(treat) if CA==1
	bysort quarterdate: egen djt=sum(djtCA) 
	bysort state: egen meandjt=mean(djt)
	g dtil=djt-meandjt

	/* Obtain difference in differences coefficient*/
	reg eta dtil if CA==1,noc
	matrix alpha=e(b)
		
	/* Simulations*/
	quietly {
		foreach st of numlist 1 2 4 5 6 8 10 12 13 16 17 18 20 21 22 24 26 28 29 30 31 32 34 35 36 37 39 40 45 46 47 48 49 51 54 56 {
			capture {
			reg eta dtil if state==`st'&CA!=1, noc
			matrix alpha=alpha\e(b)
		}
		}
	} 
	matrix asim=alpha[2...,1]
	matrix alpha=alpha[1,1]

	/* Confidence intervals */
	svmat alpha 
	svmat asim

	sum alpha
	gen alpha=r(mean)
	g ci=alpha-asim

	/* form confidence intervals */
	local numst=42
	local i025=floor(0.025*(`numst'-1))
	local i975=ceil(0.975*(`numst'-1))
	local i05=floor(0.050*(`numst'-1))
	local i95=ceil(0.950*(`numst'-1))

	quietly sum alpha
	display as text "Difference in Differences coefficient=" as result _newline(2) r(mean)

	sort asim
	quietly sum ci if _n==`i025'|_n==`i975'
	display as text "95% Confidence interval=" as result _newline(2) r(min) _col(15) r(max)
	quietly sum ci if _n==`i05'|_n==`i95' 
	display as text "90% Confidence interval=" as result _newline(2) r(min) _col(15) r(max)
	local i025=floor(0.025*(`numst'-1))
	local i975=ceil(0.975*(`numst'-1))
	local i05=floor(0.050*(`numst'-1))
	local i95=ceil(0.950*(`numst'-1))

}
















*Part B.i.

local outcomes = "teen_logwage teen_logemp overall_logemp overall_logwage"

foreach i of local outcomes{

	synth `i' race_share1 race_share2 race_share3 hispanic_share married_share gender_share ///
	emp_sh_ind1 emp_sh_ind2 emp_sh_ind3 emp_sh_ind4 emp_sh_ind5 emp_sh_ind6 emp_sh_ind7 emp_sh_ind8 emp_sh_ind9 ///
	 `i'(92(1)113), trunit(6) trperiod(114) unitnames(stateabb) keep(synthCA88_w_`i', replace) 
}





*Part B.ii. 
local outcomes = "teen_logwage teen_logemp overall_logemp overall_logwage"

mat esteffect = .

foreach i of local outcomes{

	use synthCA88_w_`i', clear

	cap drop period_4q
	g time = floor((_time-114)/4)

	* ii

	collapse (mean) _Y_treated _Y_synthetic , by(time)
	twoway scatter _Y_syn _Y_treated  time, mcolor(red green) || ///
	 line  _Y_syn _Y_treated  time, lcolor(red green) lpat(solid solid) scheme(plotplain) ///
	 legend(order(1 "Synthetic CA `i'" 2 "CA")) xtitle(Event time) xline(0, lcolor(gs7)) ///
	 ytitle(log "`i'")

	graph export CA_Synth_`i'.png, replace 
	
	mat esteffect = [esteffect\ (sum(_Y_treated)/9 - sum(_Y_synthetic)/9)]
}
							 
matlist esteeffect









*Part B.iii.


*start of teen_logwage
		use "/Users/Anya/Documents/Senior Year/Labor Econ/Stata/emp_wage_data.dta", clear

		drop if quarterdate > 120 | quarterdate < 88

		gen treat = (stateabb == "CA" && quarterdate > 113)
		gen treatsample = (stateabb == "CA")


		forval j=1/51 {
			local startminwg = MW[`j'*33 - 32]
			local endminwg = MW[`j'*33]

			
			
			if(`startminwg' != `endminwg'  & stateabb[`j'*33] != "CA"){
				drop if stateabb == stateabb[`j'*33]
			}
		}
		drop if stateabb == "PA"


		cap drop teen_logemp
		gen teen_logemp = ln(teen_emp)
		cap drop overall_logemp
		gen overall_logemp = ln(overall_emp)



		synth teen_logwage race_share1 race_share2 race_share3 hispanic_share married_share gender_share ///
		emp_sh_ind1 emp_sh_ind2 emp_sh_ind3 emp_sh_ind4 emp_sh_ind5 emp_sh_ind6 emp_sh_ind7 emp_sh_ind8 emp_sh_ind9 ///
		 teen_logwage(92(1)113), trunit(6) trperiod(114) unitnames(stateabb) keep(synthCA88_w_teen_logwage, replace) 

		preserve

		drop if statenum==6

		local placebolist "1 2 4 5 8 10 12 13 16 17 18 20 21 22 24 26 28 29 30 31 32 34 35 36 37 39 40 45 46 47 48 49 51 54 56" 

		foreach x in `placebolist' {

		  di "`x'"

			synth teen_logwage race_share1 race_share2 race_share3 hispanic_share married_share gender_share ///
			emp_sh_ind1 emp_sh_ind2 emp_sh_ind3 emp_sh_ind4 emp_sh_ind5 emp_sh_ind6 emp_sh_ind7 emp_sh_ind8 emp_sh_ind9 ///
			 teen_logwage(92(1)113), trunit(`x') trperiod(114) unitnames(stateabb) keep("synth/synth_teen_logwage_`x'.dta", replace) 

		}



		restore



		preserve



		use "/Users/Anya/Documents/Senior Year/Labor Econ/Stata/synthCA88_w_teen_logwage.dta" , clear

		g statenum = 6




		local placebolist "1 2 4 5 8 10 12 13 16 17 18 20 21 22 24 26 28 29 30 31 32 34 35 36 37 39 40 45 46 47 48 49 51 54 56" 



		foreach x in `placebolist' {

			append using "/Users/Anya/Documents/Senior Year/Labor Econ/Stata/synth/synth_teen_logwage_`x'.dta"
			replace statenum =`x' if statenum==.

		}



		g dif = _Y_treated - _Y_synthetic
		g time = floor((_time-114)/4)
		collapse (mean) dif , by(time statenum)





		local placebolist "1 2 4 5 8 10 12 13 16 17 18 20 21 22 24 26 28 29 30 31 32 34 35 36 37 39 40 45 46 47 48 49 51 54 56" 

		foreach x in `placebolist' { 
			local fig  "`fig' || line dif time if statenum==`x', lcolor(gs10) lpat(solid)"

		}





		twoway line dif  time if statenum==1, lcolor(blue) scheme(plotplain) legend(off) ///
		xtitle(Event time) ///
		xline(0, lcolor(black)) ///
		 ytitle(log teen wage) ylabel(-0.05(.05)0.1) ///

		 || `fig' ///

		 || line dif time if statenum==6, lcolor(blue) lwidth(thick)





		graph export CA_synth_teen_logwage_dif.pnf, replace  

		 

		restore



		twoway line dif  time if statenum==1, lcolor(blue) scheme(plotplain) legend(off) ///
		xtitle(Event time) ///
		xline(0, lcolor(black)) ///
		 ytitle(log teen wage) ylabel(-0.05(.05)0.1) ///

		 || `fig' ///

		 || line dif time if statenum==6, lcolor(blue) lwidth(thick)





		graph export CA_teen_logwage_dif.png, replace  

		 

		restore

*end of teen_logwage






















*start of teen_logemp
		use "/Users/Anya/Documents/Senior Year/Labor Econ/Stata/emp_wage_data.dta", clear

		drop if quarterdate > 120 | quarterdate < 88

		gen treat = (stateabb == "CA" && quarterdate > 113)
		gen treatsample = (stateabb == "CA")


		forval j=1/51 {
			local startminwg = MW[`j'*33 - 32]
			local endminwg = MW[`j'*33]

			
			
			if(`startminwg' != `endminwg'  & stateabb[`j'*33] != "CA"){
				drop if stateabb == stateabb[`j'*33]
			}
		}
		drop if stateabb == "PA"


		cap drop teen_logemp
		gen teen_logemp = ln(teen_emp)
		cap drop overall_logemp
		gen overall_logemp = ln(overall_emp)



		synth teen_logemp race_share1 race_share2 race_share3 hispanic_share married_share gender_share ///
		emp_sh_ind1 emp_sh_ind2 emp_sh_ind3 emp_sh_ind4 emp_sh_ind5 emp_sh_ind6 emp_sh_ind7 emp_sh_ind8 emp_sh_ind9 ///
		 teen_logemp(92(1)113), trunit(6) trperiod(114) unitnames(stateabb) keep(synthCA88_w_teen_logemp, replace) 

		preserve

		drop if statenum==6

		local placebolist "1 2 4 5 8 10 12 13 16 17 18 20 21 22 24 26 28 29 30 31 32 34 35 36 37 39 40 45 46 47 48 49 51 54 56" 

		foreach x in `placebolist' {

		  di "`x'"

			synth teen_logemp race_share1 race_share2 race_share3 hispanic_share married_share gender_share ///
			emp_sh_ind1 emp_sh_ind2 emp_sh_ind3 emp_sh_ind4 emp_sh_ind5 emp_sh_ind6 emp_sh_ind7 emp_sh_ind8 emp_sh_ind9 ///
			 teen_logemp(92(1)113), trunit(`x') trperiod(114) unitnames(stateabb) keep("synth/synth_teen_logemp_`x'.dta", replace) 

		}



		restore



		preserve



		use "/Users/Anya/Documents/Senior Year/Labor Econ/Stata/synthCA88_w_teen_logemp.dta" , clear

		g statenum = 6




		local placebolist "1 2 4 5 8 10 12 13 16 17 18 20 21 22 24 26 28 29 30 31 32 34 35 36 37 39 40 45 46 47 48 49 51 54 56" 



		foreach x in `placebolist' {

			append using "/Users/Anya/Documents/Senior Year/Labor Econ/Stata/synth/synth_teen_logemp_`x'.dta"
			replace statenum =`x' if statenum==.

		}



		g dif = _Y_treated - _Y_synthetic
		g time = floor((_time-114)/4)
		collapse (mean) dif , by(time statenum)





		local placebolist "1 2 4 5 8 10 12 13 16 17 18 20 21 22 24 26 28 29 30 31 32 34 35 36 37 39 40 45 46 47 48 49 51 54 56" 

		foreach x in `placebolist' { 
			local fig  "`fig' || line dif time if statenum==`x', lcolor(gs10) lpat(solid)"

		}





		twoway line dif  time if statenum==1, lcolor(blue) scheme(plotplain) legend(off) ///
		xtitle(Event time) ///
		xline(0, lcolor(black)) ///
		 ytitle(log teen wage) ylabel(-0.05(.05)0.1) ///

		 || `fig' ///

		 || line dif time if statenum==6, lcolor(blue) lwidth(thick)





		graph export CA_synth_teen_logemp_dif.pnf, replace  

		 

		restore



		twoway line dif  time if statenum==1, lcolor(blue) scheme(plotplain) legend(off) ///
		xtitle(Event time) ///
		xline(0, lcolor(black)) ///
		 ytitle(log teen wage) ylabel(-0.05(.05)0.1) ///

		 || `fig' ///

		 || line dif time if statenum==6, lcolor(blue) lwidth(thick)





		graph export CA_teen_logemp_dif.png, replace  

		 

		restore

*end of teen_logemp





















*start of overall_logwage
		use "/Users/Anya/Documents/Senior Year/Labor Econ/Stata/emp_wage_data.dta", clear

		drop if quarterdate > 120 | quarterdate < 88

		gen treat = (stateabb == "CA" && quarterdate > 113)
		gen treatsample = (stateabb == "CA")


		forval j=1/51 {
			local startminwg = MW[`j'*33 - 32]
			local endminwg = MW[`j'*33]

			
			
			if(`startminwg' != `endminwg'  & stateabb[`j'*33] != "CA"){
				drop if stateabb == stateabb[`j'*33]
			}
		}
		drop if stateabb == "PA"


		cap drop teen_logemp
		gen teen_logemp = ln(teen_emp)
		cap drop overall_logemp
		gen overall_logemp = ln(overall_emp)



		synth overall_logwage race_share1 race_share2 race_share3 hispanic_share married_share gender_share ///
		emp_sh_ind1 emp_sh_ind2 emp_sh_ind3 emp_sh_ind4 emp_sh_ind5 emp_sh_ind6 emp_sh_ind7 emp_sh_ind8 emp_sh_ind9 ///
		 overall_logwage(92(1)113), trunit(6) trperiod(114) unitnames(stateabb) keep(synthCA88_w_overall_logwage, replace) 

		preserve

		drop if statenum==6

		local placebolist "1 2 4 5 8 10 12 13 16 17 18 20 21 22 24 26 28 29 30 31 32 34 35 36 37 39 40 45 46 47 48 49 51 54 56" 

		foreach x in `placebolist' {

		  di "`x'"

			synth overall_logwage race_share1 race_share2 race_share3 hispanic_share married_share gender_share ///
			emp_sh_ind1 emp_sh_ind2 emp_sh_ind3 emp_sh_ind4 emp_sh_ind5 emp_sh_ind6 emp_sh_ind7 emp_sh_ind8 emp_sh_ind9 ///
			 overall_logwage(92(1)113), trunit(`x') trperiod(114) unitnames(stateabb) keep("synth/synth_overall_logwage_`x'.dta", replace) 

		}



		restore



		preserve



		use "/Users/Anya/Documents/Senior Year/Labor Econ/Stata/synthCA88_w_overall_logwage.dta" , clear

		g statenum = 6




		local placebolist "1 2 4 5 8 10 12 13 16 17 18 20 21 22 24 26 28 29 30 31 32 34 35 36 37 39 40 45 46 47 48 49 51 54 56" 



		foreach x in `placebolist' {

			append using "/Users/Anya/Documents/Senior Year/Labor Econ/Stata/synth/synth_overall_logwage_`x'.dta"
			replace statenum =`x' if statenum==.

		}



		g dif = _Y_treated - _Y_synthetic
		g time = floor((_time-114)/4)
		collapse (mean) dif , by(time statenum)





		local placebolist "1 2 4 5 8 10 12 13 16 17 18 20 21 22 24 26 28 29 30 31 32 34 35 36 37 39 40 45 46 47 48 49 51 54 56" 

		foreach x in `placebolist' { 
			local fig  "`fig' || line dif time if statenum==`x', lcolor(gs10) lpat(solid)"

		}





		twoway line dif  time if statenum==1, lcolor(blue) scheme(plotplain) legend(off) ///

		xtitle(Event time) xline(0, lcolor(black)) ///

		 ytitle(log teen wage) ylabel(-0.05(.05)0.1) ///

		 || `fig' ///

		 || line dif time if statenum==6, lcolor(blue) lwidth(thick)





		graph export CA_synth_overall_logwage_dif.pnf, replace  

		 

		restore



		twoway line dif  time if statenum==1, lcolor(blue) scheme(plotplain) legend(off) ///

		xtitle(Event time) xline(0, lcolor(black)) ///

		 ytitle(log teen wage) ylabel(-0.05(.05)0.1) ///

		 || `fig' ///

		 || line dif time if statenum==6, lcolor(blue) lwidth(thick)





		graph export CA_overall_logwage_dif.png, replace  

		 

		restore

*end of overall_logwage





















*start of overall_logemp
		use "/Users/Anya/Documents/Senior Year/Labor Econ/Stata/emp_wage_data.dta", clear

		drop if quarterdate > 120 | quarterdate < 88

		gen treat = (stateabb == "CA" && quarterdate > 113)
		gen treatsample = (stateabb == "CA")


		forval j=1/51 {
			local startminwg = MW[`j'*33 - 32]
			local endminwg = MW[`j'*33]

			
			
			if(`startminwg' != `endminwg'  & stateabb[`j'*33] != "CA"){
				drop if stateabb == stateabb[`j'*33]
			}
		}
		drop if stateabb == "PA"


		cap drop teen_logemp
		gen teen_logemp = ln(teen_emp)
		cap drop overall_logemp
		gen overall_logemp = ln(overall_emp)



		synth overall_logemp race_share1 race_share2 race_share3 hispanic_share married_share gender_share ///
		emp_sh_ind1 emp_sh_ind2 emp_sh_ind3 emp_sh_ind4 emp_sh_ind5 emp_sh_ind6 emp_sh_ind7 emp_sh_ind8 emp_sh_ind9 ///
		 overall_logemp(92(1)113), trunit(6) trperiod(114) unitnames(stateabb) keep(synthCA88_w_overall_logemp, replace) 

		preserve

		drop if statenum==6

		local placebolist "1 2 4 5 8 10 12 13 16 17 18 20 21 22 24 26 28 29 30 31 32 34 35 36 37 39 40 45 46 47 48 49 51 54 56" 

		foreach x in `placebolist' {

		  di "`x'"

			synth overall_logemp race_share1 race_share2 race_share3 hispanic_share married_share gender_share ///
			emp_sh_ind1 emp_sh_ind2 emp_sh_ind3 emp_sh_ind4 emp_sh_ind5 emp_sh_ind6 emp_sh_ind7 emp_sh_ind8 emp_sh_ind9 ///
			 overall_logemp(92(1)113), trunit(`x') trperiod(114) unitnames(stateabb) keep("synth/synth_overall_logemp_`x'.dta", replace) 

		}



		restore



		preserve



		use "/Users/Anya/Documents/Senior Year/Labor Econ/Stata/synthCA88_w_overall_logemp.dta" , clear

		g statenum = 6




		local placebolist "1 2 4 5 8 10 12 13 16 17 18 20 21 22 24 26 28 29 30 31 32 34 35 36 37 39 40 45 46 47 48 49 51 54 56" 



		foreach x in `placebolist' {

			append using "/Users/Anya/Documents/Senior Year/Labor Econ/Stata/synth/synth_overall_logemp_`x'.dta"
			replace statenum =`x' if statenum==.

		}



		g dif = _Y_treated - _Y_synthetic
		g time = floor((_time-114)/4)
		collapse (mean) dif , by(time statenum)





		local placebolist "1 2 4 5 8 10 12 13 16 17 18 20 21 22 24 26 28 29 30 31 32 34 35 36 37 39 40 45 46 47 48 49 51 54 56" 

		foreach x in `placebolist' { 
			local fig  "`fig' || line dif time if statenum==`x', lcolor(gs10) lpat(solid)"

		}





		twoway line dif  time if statenum==1, lcolor(blue) scheme(plotplain) legend(off) ///

		xtitle(Event time) xline(0, lcolor(black)) ///

		 ytitle(log teen wage) ylabel(-0.05(.05)0.1) ///

		 || `fig' ///

		 || line dif time if statenum==6, lcolor(blue) lwidth(thick)





		graph export CA_synth_overall_logemp_dif.pnf, replace  

		 

		restore



		twoway line dif  time if statenum==1, lcolor(blue) scheme(plotplain) legend(off) ///

		xtitle(Event time) xline(0, lcolor(black)) ///

		 ytitle(log teen wage) ylabel(-0.05(.05)0.1) ///

		 || `fig' ///

		 || line dif time if statenum==6, lcolor(blue) lwidth(thick)





		graph export CA_overall_logemp_dif.png, replace  

		 

		restore

*end of overall_logemp










*B.iv.

use "/Users/Anya/Documents/Senior Year/Labor Econ/Stata/emp_wage_data.dta", clear

drop if quarterdate > 120 | quarterdate < 88

gen treat = (stateabb == "CA" && quarterdate > 113)
gen treatsample = (stateabb == "CA")


forval i=1/51 {
	local startminwg = MW[`i'*33 - 32]
	local endminwg = MW[`i'*33]

	
	
	if(`startminwg' != `endminwg'  & stateabb[`i'*33] != "CA"){
		drop if stateabb == stateabb[`i'*33]
	}
}
drop if stateabb == "PA"


cap drop teen_logemp
gen teen_logemp = ln(teen_emp)
cap drop overall_logemp
gen overall_logemp = ln(overall_emp)


local outcomes = "teen_logwage teen_logemp overall_logemp overall_logwage"

foreach i of local outcomes{

	synth `i' race_share1 race_share2 race_share3 hispanic_share married_share gender_share ///
	emp_sh_ind1 emp_sh_ind2 emp_sh_ind3 emp_sh_ind4 emp_sh_ind5 emp_sh_ind6 emp_sh_ind7 emp_sh_ind8 emp_sh_ind9 ///
	 `i'(92(1)105), trunit(6) trperiod(114) unitnames(stateabb) keep(synth_val_w_`i', replace) 
}





/* note: some commands require the cibar package; if not installed, run 'ssc install cibar' */


/* header */
version 14
set more off


/* graph options */
set scheme s2mono


/* figure 1 */
use "data_1.dta", clear

cibar justice, over2(units) over1(treatment) ///
   graphopts( ///
      xtitle("Units of Living Space") ///
      xlabel(, angle(forty_five)) ///
      ytitle("Evaluation of Justice") ///
      ylabel(0 "0" 0.2 "0.2" 0.4 "0.4" 0.6 "0.6" 0.8 "0.8" 1 "1", angle(horizontal))) ///
   baropts( ///
      lcolor(black) ///
      lpattern(solid) ///
      lwidth(medium) ///
      graphregion(color(white)) ///
      legend(cols(1)))
graph export "figure_1.pdf", as(pdf) replace


/* figure 2 */
use "data_2.dta", clear

preserve
   la var need_a "Need of Person A"
   la var need_b "Need of Person B"
   la var productivity_a "Productivity of Person A"
   la var productivity_b "Productivity of Person B"
   la var equal_split "Equal Split"

   line need_a need_b productivity_a productivity_b equal_split case, by(scenario, ///
      note("") ///
      graphregion(fcolor(white))) ///
      ytitle("Units of Wood") ///
      ylabel(, angle(horizontal)) ///
      xtitle("Case")
   graph export "figure_2.pdf", as(pdf) replace
restore


/* figure 3 */
use "data_3.dta", clear

preserve
   rename accountability_need judgment0
   rename accountability_productivity judgment1

   reshape long judgment, i(subject) j(frame)

   collapse ///
      (mean) meanj=judgment ///
      (sd) sdj=judgment ///
      (count) n=judgment, ///
      by(frame treatment)

   generate ci_high=meanj+invttail(n/2-1,0.05)*(sdj/sqrt(n/2))
   generate ci_low=meanj-invttail(n/2-1,0.05)*(sdj/sqrt(n/2))

   generate tnr=.
      replace tnr=0 if frame==0 & treatment==0
      replace tnr=1 if frame==0 & treatment==1
      replace tnr=2.25 if frame==1 & treatment==0
      replace tnr=3.25 if frame==1 & treatment==1

   local pposition=6.5
   local pposition1=`pposition'-0.5
   local ylim=`pposition'+0.25

   twoway (bar meanj tnr if treatment==0, fcolor(gs10) lcolor(black) lwidth(medium) barwidth(0.5)) ///
      (bar meanj tnr if treatment==1, fcolor(white) lcolor(black) lwidth(medium) barwidth(0.5)) ///
      (rcap ci_high ci_low tnr, lcolor(black)), ///
      title("") ///
      ytitle("Evaluation of Accountability") ///
      yscale(range(1 `ylim')) ///
      ylabel(1 (1) `pposition', angle(horizontal)) ///
      xtitle("") ///
      xlabel(0 `" "Need and" "Low Account." "' 1 `" "Need and" "High Account." "' 2.25 `" "Productivity and" "Low Account." "' 3.25 `" "Productivity and" "High Account." "') ///
      graphregion(color(white)) ///
      legend(off) ///
   saving(figure_3, replace)
   graph export "figure_3.pdf", as(pdf) replace
restore


/* figure 4 (a) */
use "data_4.dta", clear

preserve
   collapse ///
      (mean) meanj=share_a ///
      (sd) sdj=share_a ///
      (count) n=share_a, ///
      by(scenario treatment)

   generate ci_high=meanj+invttail(n-1,0.05)*(sdj/sqrt(n))
   generate ci_low=meanj-invttail(n-1,0.05)*(sdj/sqrt(n))

   generate tnr=.
      replace tnr=0 if scenario==0 & treatment==0
      replace tnr=1 if scenario==0 & treatment==1
      replace tnr=2.25 if scenario==1 & treatment==0
      replace tnr=3.25 if scenario==1 & treatment==1

   twoway (bar meanj tnr if treatment==0, fcolor(gs10) lcolor(black) lwidth(medium) barwidth(0.5)) ///
      (bar meanj tnr if treatment==1, fcolor(white) lcolor(black) lwidth(medium) barwidth(0.5)) ///
      (rcap ci_high ci_low tnr, lcolor(black)) ///
      (pci 0.717 -0.250 0.717 1.250, lpattern(shortdash) lcolor(black)) ///
      (pci 0.500  2.000 0.500 3.500, lpattern(shortdash) lcolor(black)) ///
      (pci 0.500 -0.250 0.500 1.250, lpattern(dash) lcolor(black)) ///
      (pci 0.283  2.000 0.283 3.500, lpattern(dash) lcolor(black)), ///
      title("") ///
      ytitle("Share") ///
      yscale(range(0 (0.1) 0.7)) ///
      ylabel(0 "0" 0.1 "0.1" 0.2 "0.2" 0.3 "0.3" 0.4 "0.4" 0.5 "0.5" 0.6 "0.6" 0.7 "0.7", angle(horizontal)) ///
      xtitle("") ///
      xlabel(0 `" "Need and" "Low Account." "' 1 `" "Need and" "High Account." "' 2.25 `" "Productivity and" "Low Account." "' 3.25 `" "Productivity and" "High Account." "') ///
      legend(off) ///
      graphregion(color(white)) ///
      saving(accountability_dist_a, replace)
   graph export "figure_4_a.pdf", as(pdf) replace
restore


/* figure 4 (b) */
preserve
   gen deviation_a=.
      replace deviation_a=(share_a-0.5)/(share_need_a-0.5) if scenario==0
      replace deviation_a=(0.5-share_a)/(0.5-share_productivity_a) if scenario==1

   collapse ///
      (mean) meanj=deviation_a ///
      (sd) sdj=deviation_a ///
      (count) n=deviation_a, ///
      by(scenario treatment)

   generate ci_high=meanj+invttail(n-1,0.05)*(sdj/sqrt(n))
   generate ci_low=meanj-invttail(n-1,0.05)*(sdj/sqrt(n))

   generate tnr=.
      replace tnr=0 if scenario==0 & treatment==0
      replace tnr=1 if scenario==0 & treatment==1
      replace tnr=2.25 if scenario==1 & treatment==0
      replace tnr=3.25 if scenario==1 & treatment==1

   twoway (rcap ci_high ci_low tnr, lcolor(black)) ///
      (scatter meanj tnr if treatment==0, msymbol(square) mfcolor(gs10) mlcolor(black) msize(large)) ///
      (scatter meanj tnr if treatment==1, msymbol(square) mfcolor(white) mlcolor(black) msize(large)), ///
      title("") ///
      ytitle("Deviation") ///
      yscale(range(0 (0.1) 0.7)) ///
      ylabel(0 "0" 0.1 "0.1" 0.2 "0.2" 0.3 "0.3" 0.4 "0.4" 0.5 "0.5" 0.6 "0.6" 0.7 "0.7", angle(horizontal)) ///
      xtitle("") ///
      xscale(range(-0.5 3.75)) ///
      xlabel(0 `" "Need and" "Low Account." "' 1 `" "Need and" "High Account." "' 2.25 `" "Productivity and" "Low Account." "' 3.25 `" "Productivity and" "High Account." "') ///
      legend(off) ///
      graphregion(color(white)) ///
      saving(figure_4_b, replace)
   graph export "figure_4_b.pdf", as(pdf) replace
restore


/* figure 6 */
use "data_5.dta", clear

cibar eval, over1(kind_of_need) ///
   graphopts( ///
      ytitle("Evaluation of Importance") ///
      ylabel(, angle(horizontal)) ///
      xtitle("Kind of Need") ///
      xlabel(1 "Survival" 2 "Decency" 3 "Belonging" 4 "Autonomy", angle(forty_five)) ///
      legend(off)) ///
   baropts( ///
      lcolor(black) ///
      lpattern(solid) ///
      lwidth(medium) ///
      barwidth(0.5) ///
      graphregion(color(white)))
graph export "figure_6.pdf", as(pdf) replace


/* figure 7 */
use "data_6.dta", clear

cibar allocation_diff, over2(kind_of_need) over1(productivity) ///
   graphopts( ///
      ytitle("Differences") ///
      ylabel(-300 "–300" -200 "–200" -100 "–100" 0 "0" 100 "100", angle(horizontal)) ///
      xtitle("Kind of Need") ///
      xlabel(, angle(forty_five))) ///
   baropts( ///
      lcolor(black) ///
      lpattern(solid) ///
      lwidth(medium) ///
      graphregion(color(white)) ///
      legend(cols(1)))
graph export "figure_7.pdf", as(pdf) replace


/* figure 8 */
use "data_7", clear

cibar allocation_diff, over2(case) over1(productivity) ///
   graphopts( ///
      ytitle("Differences") ///
      ylabel(-200 "–200" 0 "0" 200 "200" 400 "400" 600 "600", angle(horizontal)) ///
      xtitle("Combination") ///
      xlabel(, angle(forty_five))) ///
   baropts( ///
      lcolor(black) ///
      lpattern(solid) ///
      lwidth(medium) ///
      graphregion(color(white)) ///
      legend(cols(1)))
graph export "figure_8.pdf", as(pdf) replace


exit

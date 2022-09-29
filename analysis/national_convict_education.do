********************************************************************************
* Title: Imprisonment in Turkey by Education Status                            *
* Author: Lutfi Sun                                                            *
* Date: Saturday, April 3, 2021                                                *
********************************************************************************

*-------------------------------------------------------------------------------
* Housekeeping
*-------------------------------------------------------------------------------

clear all
drop _all

cd "/Users/lutfisun/Desktop/turkey_convicts/analysis"

macro drop _all 
capture log close 
clear all

*-------------------------------------------------------------------------------
* Data Exploration
*-------------------------------------------------------------------------------

import delimited "../data/convicts_by_education.csv"

drop regioncode regionname

twoway (line total year) (line illiterate year) (line literate_noschool year) ///
	   (line primary year) (line primary_jun year) (line junior_high year) ///
	   (line highschool year)  (line university year) (line unknown year)

* Combining vars into two broader categories: 8+ years of education vs 8-
gen below_eight = illiterate + literate_noschool + primary
gen eight_plus = primary_jun + junior_high + highschool + university
replace eight_plus =  junior_high + highschool + university if eight_plus == .

twoway (line total year) (line eight_plus year) (line below_eight year)
* a significant rise in the imprisonment of educated population
* possibly due to a shift in overall population to more educated
* or a rise in politically driven criminalization and incarceration

tset year
gen trend = year - 2000
gen trend2 = trend * trend

gen election_year = 0
replace election_year = 1 if (year == 2002) | (year == 2007) /// 
						   | (year == 2011) | (year == 2015) | (year == 2018)

reg total trend trend2 election_year
reg total trend trend2 l.election_year
* a quadratic trend fits well
* we see no seasonality with respect to election period (neither with its lag)

reg total trend trend2
predict total_trend2
label variable total_trend2 "quadratic trend for #imprisonments"

predict total_dtd2, residuals
label variable total_dtd2 "detrended #imprisonments"

twoway (scatter total year) (line total_trend2 year)

gen tot_diff = total - total[_n-1]
label variable tot_diff "first difference #imprisonments"

twoway (line total_dtd2 year)
twoway (line tot_diff year)

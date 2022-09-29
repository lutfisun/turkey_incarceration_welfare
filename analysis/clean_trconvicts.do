********************************************************************************
* Title: Clean Turkey Convicts Dataset and Save	                               *
* Author: Lutfi Sun                                                            *
* Date: Friday, April 2, 2021                                                  *
********************************************************************************

*-------------------------------------------------------------------------------
* Housekeeping
*-------------------------------------------------------------------------------


capture log close
clear all
drop _all
macro drop _all 

cd "/Users/lutfisun/Desktop/turkey_convicts/analysis"

log using "../temp/cleaning.log", replace

*-------------------------------------------------------------------------------
* clean turkey convicts
*-------------------------------------------------------------------------------

import delimited "../data/turkey_convicts_mid.csv"
destring *, ignore("NA") replace

drop region_code registered* particip* akp* chp* mhp* hdp* ref_*

replace vs_akp = . if year < 2002
replace vs_chp = . if year < 2002
replace vs_mhp = . if year < 2002
replace vs_hdp = . if year < 2002
replace ms_akp = . if year < 2004
replace ms_chp = . if year < 2004
replace ms_mhp = . if year < 2004

*
sort province year
gen popi_ipo = population
replace popi_ipo = . if year<2008 & year>2000
bysort province: ipolate popi_ipo year, g(popi)
*
bysort province: ipolate educ_hs year, g(educ_hsch)
bysort province: ipolate educ_col year, g(educ_coll)

order year province region population popi_ipo popi gdpk educ_hs* educ_col*

drop population popi_ipo educ_hs educ_col

sort province year

save "../data/turkey_convicts_clean.dta", replace
export delimited using "../data/turkey_convicts_clean.csv", replace

log close

* editted on May 11, 2021

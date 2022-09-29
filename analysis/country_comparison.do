********************************************************************************
* Title: Incarceration Comparison Among OECD Countries                         *
* Author: Lutfi Sun                                                            *
* Date: Saturday, April 3, 2021                                                *
********************************************************************************

*-------------------------------------------------------------------------------
* Housekeeping
*-------------------------------------------------------------------------------

clear all
drop _all

cd "/Users/lutfisun/Desktop/turkey_convicts/analysis"

* country comparison

import delimited "../data/country_comparison.csv"

destring prison_total, replace ignore(",") force
encode country, gen(enc_country)
xtset enc_country year

tsfill
list, clean noobs

xtline prison_rate, overlay
gen ln_prison_rate = log(prison_rate)
xtline ln_prison_rate, overlay

bysort enc_country: ipolate prison_total year, g(prison_tot_ipo)
bysort enc_country: ipolate prison_rate year, g(prison_rate_ipo)

gen ln_prison_rate_ipo = log(prison_rate_ipo)
xtline ln_prison_rate_ipo, overlay

sort enc_country year

gen ln_prison_ipo = log(prison_tot_ipo)
gen prison_gr = D.ln_prison_ipo
xtline prison_gr

gen prison_rate_gr = D.ln_prison_rate_ipo
xtline prison_rate_gr

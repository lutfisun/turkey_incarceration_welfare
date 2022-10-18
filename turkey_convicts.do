********************************************************************************
* Title: Difference in Differences Analysis 	                               *
* Author: Lutfi Sun                                                            *
* Date: Friday, April 2, 2021                                                  *
********************************************************************************

*-------------------------------------------------------------------------------
* Housekeeping
*-------------------------------------------------------------------------------

clear all
drop _all
capture log close 
macro drop _all 

cd "/Users/lutfisun/Desktop/turkey_convicts/analysis"

log using "../temp/lutfi_diff.log", replace text

*-------------------------------------------------------------------------------
* Mutate Data
*-------------------------------------------------------------------------------

use "../data/turkey_convicts_clean.dta"

encode province, gen(enc_province)
encode region,   gen(enc_region)
xtset enc_province year

gen period00 = (year < 2011)
gen period11 = (year > 2010) * (year < 2016)
gen period16 = (year > 2015)

gen con1000 = 1000 * cr_educ_total / popi
gen cr_educ_hsplus = cr_educ_hs + cr_educ_uni
gen conhs1000 =  1000 * cr_educ_hsplus / popi

gen conprim_1000 = con1000 - conhs1000

gen educ_hs100 = 100*(educ_hsch)/popi 
gen ln_gdpk = log(gdpk)

gen divorce_y = 100*(divorce_byd_1 + divorce_byd_below1 + divorce_byd_1_10)
gen divorce_yrt = 100*(divorce_byd_1 + divorce_byd_below1 + divorce_byd_1_10) /popi
gen suicide_y = (suicides_male_15 + suicides_male_25 + suicides_male_35) + (suicides_female_15 + suicides_female_25 + suicides_female_35)
gen suicide_yrt = 100 * suicide_y / popi

*-------------------------------------------------------------------------------
* Descriptive Statistics
*-------------------------------------------------------------------------------

* table 1
eststo clear
estpost tabstat gdpk educ_hs100 conprim_1000 conhs1000 crude_divorce_rate100 crude_suicide_rate1000, by(region ) statistics(mean sd) columns(statistics) listwise


* Welfare ~ Incarceration Association

* table 2
eststo clear

gen cpk_perd11 = con1000 * period11
gen cpk_perd16 = con1000 * period16


reg L.ln_gdpk popi  educ_hsch con1000 period11 period16 cpk_perd11 cpk_perd16 i.year##i.enc_region
estimates store m1, title(yo2)

reg L.crude_divorce_rate100 popi  educ_hsch con1000 period11 period16 cpk_perd11 cpk_perd16 i.year##i.enc_region
estimates store m2, title(yo2)

reg L.divorce_yrt popi  educ_hsch con1000 period11 period16 cpk_perd11 cpk_perd16 i.year##i.enc_region
estimates store m3, title(yo2)

reg L.divorce_y popi  educ_hsch con1000 period11 period16 cpk_perd11 cpk_perd16 i.year##i.enc_region
estimates store m4, title(yo2)

reg L.crude_suicide_rate1000 popi  educ_hsch con1000 period11 period16 cpk_perd11 cpk_perd16 i.year##i.enc_region
estimates store m5, title(yo2)

reg L.suicide_yrt popi  educ_hsch con1000 period11 period16 cpk_perd11 cpk_perd16 i.year##i.enc_region
estimates store m6, title(yo2)

reg L.suicide_y popi  educ_hsch con1000 period11 period16 cpk_perd11 cpk_perd16 i.year##i.enc_region
estimates store m7, title(yo2)


esttab m1 m2 m3 m4 m5 m6 m7 using welfare1.tex, cells(b(star fmt(3)) se(par fmt(2))) legend label varlabels(_cons constant) stats(r2 df_r bic, fmt(3 0 1) label(R-sqr dfres BIC)) replace
esttab m1 m2 m3 m4 m5 m6 m7 using welfare1.csv, cells(b(star fmt(3)) se(par fmt(2))) legend label varlabels(_cons constant) stats(r2 df_r bic, fmt(3 0 1) label(R-sqr dfres BIC)) replace

* table 3
eststo clear

gen cpk_hsp_perd16 = conhs1000 * period16
gen cpk_hsp_perd11 = conhs1000 * period11

reg L.ln_gdpk popi  educ_hsch conprim_1000 conhs1000 period11 period16 cpk_hsp_perd11 cpk_hsp_perd16 i.year##i.enc_region
estimates store m1, title(yo2)

reg L.crude_divorce_rate100 popi  educ_hsch conprim_1000 conhs1000 period11 period16 cpk_hsp_perd11 cpk_hsp_perd16 i.year##i.enc_region
estimates store m2, title(yo2)

reg L.divorce_yrt popi  educ_hsch conprim_1000 conhs1000 period11 period16 cpk_hsp_perd11 cpk_hsp_perd16 i.year##i.enc_region
estimates store m3, title(yo2)

reg L.divorce_y popi  educ_hsch conprim_1000 conhs1000 period11 period16 cpk_hsp_perd11 cpk_hsp_perd16 i.year##i.enc_region
estimates store m4, title(yo2)

reg L.crude_suicide_rate1000 popi  educ_hsch conprim_1000 conhs1000 period11 period16 cpk_hsp_perd11 cpk_hsp_perd16 i.year##i.enc_region
estimates store m5, title(yo2)

reg L.suicide_yrt popi  educ_hsch conprim_1000 conhs1000 period11 period16 cpk_hsp_perd11 cpk_hsp_perd16 i.year##i.enc_region
estimates store m6, title(yo2)

reg L.suicide_y popi  educ_hsch conprim_1000 conhs1000 period11 period16 cpk_hsp_perd11 cpk_hsp_perd16 i.year##i.enc_region
estimates store m7, title(yo2)


esttab m1 m2 m3 m4 m5 m6 m7 using welfare2.tex, cells(b(star fmt(3)) se(par fmt(2))) legend label varlabels(_cons constant) stats(r2 df_r bic, fmt(3 0 1) label(R-sqr dfres BIC)) replace
esttab m1 m2 m3 m4 m5 m6 m7 using welfare2.csv, cells(b(star fmt(3)) se(par fmt(2))) legend label varlabels(_cons constant) stats(r2 df_r bic, fmt(3 0 1) label(R-sqr dfres BIC)) replace

*-------------------------------------------------------------------------------
* Categorization 1: Rise in Educated Convicts Received per 1000
*-------------------------------------------------------------------------------

egen avgconpk_00 = mean(conhs1000), by(enc_province period00)
egen avgconpk_11 = mean(conhs1000), by(enc_province period11)
egen avgconpk_16 = mean(conhs1000), by(enc_province period16)

replace avgconpk_00  = . if  !period00
replace avgconpk_11  = . if  !period11
replace avgconpk_16  = . if  !period16

egen aconpk_00 = mean(avgconpk_00), by(enc_province)
egen aconpk_11 = mean(avgconpk_11), by(enc_province)
egen aconpk_16 = mean(avgconpk_16), by(enc_province)

gen conpk_rise11 = aconpk_11 - aconpk_00
gen conpk_rise16 = aconpk_16 - aconpk_11

egen p75_rise11 = pctile(conpk_rise11), p(75)
egen p90_rise11 = pctile(conpk_rise11), p(90)
egen p75_rise16 = pctile(conpk_rise16), p(75)
egen p90_rise16 = pctile(conpk_rise16), p(90)

gen cat_rise11_75 = 0
gen cat_rise11_90 = 0
gen cat_rise16_75 = 0
gen cat_rise16_90 = 0

replace cat_rise11_75 = 1 if (conpk_rise11 >= p75_rise11)
replace cat_rise11_90 = 1 if (conpk_rise11 >= p90_rise11)
replace cat_rise16_75 = 1 if (conpk_rise16 >= p75_rise16)
replace cat_rise16_90 = 1 if (conpk_rise16 >= p90_rise16)

list province if cat_rise11_75 * year == 2019
list province if cat_rise16_75 * year == 2019

* table 4: cutoff 75th

eststo clear

reg L.ln_gdpk popi educ_hsch conprim_1000 conhs1000 period11##cat_rise11_75 period16##cat_rise16_75 i.year##i.enc_region
estimates store m1, title(yo2)

reg L.suicide_yrt popi educ_hsch conprim_1000 conhs1000 period11##cat_rise11_75 period16##cat_rise16_75 i.year##i.enc_region 
estimates store m2, title(yo2)

reg L.divorce_yrt popi educ_hsch conprim_1000 conhs1000 period11##cat_rise11_75 period16##cat_rise16_75 i.year##i.enc_region 
estimates store m3, title(yo2)

esttab m1 m2 m3 using convict_rise75.tex, cells(b(star fmt(3)) se(par fmt(2))) legend label varlabels(_cons constant) stats(r2 df_r bic, fmt(3 0 1) label(R-sqr dfres BIC)) replace
esttab m1 m2 m3 using convict_rise75.csv, cells(b(star fmt(3)) se(par fmt(2))) legend label varlabels(_cons constant) stats(r2 df_r bic, fmt(3 0 1) label(R-sqr dfres BIC)) replace

*-------------------------------------------------------------------------------
* Figures
*-------------------------------------------------------------------------------

egen cpk_other = mean(conhs1000), by(year cat_rise16_75) 
egen cpk_p75   = mean(conhs1000), by(year cat_rise16_75) 
egen cpk_p90   = mean(conhs1000), by(year cat_rise16_90) 

replace cpk_other = . if cat_rise16_75 | cat_rise16_75
replace cpk_p75   = . if !cat_rise16_75 | cat_rise16_90
replace cpk_p90   = . if !cat_rise16_90

set scheme cleanplots, perm
  
label variable cpk_other "low convict growth"
label variable cpk_p90   "high convict growth"

scatter cpk_other cpk_p90 year, ///
	title("New Highschool Graduate Prisoner per 1000") xline(2016) xline(2011) name(cpk_graph)
graph export cpk_graph.pdf, name(cpk_graph) replace


egen gdpk_other = mean(gdpk), by(year cat_rise16_75) 
egen gdpk_p75   = mean(gdpk), by(year cat_rise16_75) 
egen gdpk_p90   = mean(gdpk), by(year cat_rise16_90) 

replace gdpk_other = . if cat_rise16_75
replace gdpk_p75   = . if !cat_rise16_75
replace gdpk_p90   = . if !cat_rise16_90

label variable gdpk_other "low convict growth"
label variable gdpk_p90   "high convict growth"

scatter gdpk_other gdpk_p90 year, ///
	title("GDP per capita") xline(2016) xline(2011) name(gdpk_graph)
graph export gdpk_graph.pdf, name(gdpk_graph) replace

reg ln_gdpk i.year
predict lngdpk_gap, resid

egen lngap_other = mean(lngdpk_gap), by(year cat_rise16_75) 
egen lngap_p90   = mean(lngdpk_gap), by(year cat_rise16_90) 

replace lngap_other = . if cat_rise16_75
replace lngap_p90   = . if !cat_rise16_90

label variable lngap_other "low convict growth"
label variable lngap_p90   "high convict growth"

scatter lngap_other lngap_p90 year, ///
	title("Percent Deviation from National GDPK") xline(2016) xline(2011) name(lngap_graph)
graph export lngap_graph.pdf, name(lngap_graph) replace

scatter D.lngap_other D.lngap_p90 year, ///
	title("Growth in Percent Deviation") xline(2016) xline(2011) name(Dlngap_graph)
graph export Dlngap_graph.pdf, name(Dlngap_graph) replace

*-------------------------------------------------------------------------------
* Robustness Check 1: table 5: cutoff 90th
*-------------------------------------------------------------------------------

eststo clear

reg L.ln_gdpk popi educ_hsch conprim_1000 conhs1000 period11##cat_rise11_90 period16##cat_rise16_90 i.year##i.enc_region
estimates store m1, title(yo2)

reg L.suicide_yrt popi educ_hsch conprim_1000 conhs1000 period11##cat_rise11_90 period16##cat_rise16_90 i.year##i.enc_region 
estimates store m2, title(yo2)

reg L.divorce_yrt popi educ_hsch conprim_1000 conhs1000 period11##cat_rise11_90 period16##cat_rise16_90 i.year##i.enc_region 
estimates store m3, title(yo2)

esttab m1 m2 m3 using convict_rise90.tex, cells(b(star fmt(3)) se(par fmt(2))) legend label varlabels(_cons constant) stats(r2 df_r bic, fmt(3 0 1) label(R-sqr dfres BIC)) replace
esttab m1 m2 m3 using convict_rise90.csv, cells(b(star fmt(3)) se(par fmt(2))) legend label varlabels(_cons constant) stats(r2 df_r bic, fmt(3 0 1) label(R-sqr dfres BIC)) replace


*-------------------------------------------------------------------------------
* Robustness Check 2: table 6: manual did / disparity
*-------------------------------------------------------------------------------

list province if cat_rise11_90 * year == 2019
list province if cat_rise16_90 * year == 2019
list province if cat_rise11_90 * cat_rise16_90 * year == 2019

gen cat_rise1116 =  cat_rise11_90 * cat_rise16_90

*
egen gdpk_00 = mean(gdpk), by(enc_province period00)
egen gdpk_11 = mean(gdpk), by(enc_province period11)
egen gdpk_16 = mean(gdpk), by(enc_province period16)

replace gdpk_00  = . if  !period00
replace gdpk_11  = . if  !period11
replace gdpk_16  = . if  !period16

egen agdpk_00 = mean(gdpk_00), by(enc_province)
egen agdpk_11 = mean(gdpk_11), by(enc_province)
egen agdpk_16 = mean(gdpk_16), by(enc_province)

gen gdpk_rise11 = agdpk_11 - agdpk_00
gen gdpk_rise16 = agdpk_16 - agdpk_11

* 
estpost tabstat aconpk_00 aconpk_11 aconpk_16 conpk_rise11 conpk_rise16 agdpk_00 agdpk_11 agdpk_16 gdpk_rise11 gdpk_rise16, by(enc_province) statistics(mean)

*-------------------------------------------------------------------------------
* Robustness Check 3: Classify by PostCoup Levels of Educated Incarceration 
*-------------------------------------------------------------------------------

egen avgconpk_post16 = mean(conhs1000), by(enc_province period16)
replace avgconpk_post16 = . if !period16

egen aconpk_post16 = mean(avgconpk_post16), by(enc_province)

egen p75_post16 = pctile(aconpk_post16), p(75)
egen p90_post16 = pctile(aconpk_post16), p(90)

gen cat_cpk16_p75 = 0
gen cat_cpk16_p90 = 0

replace cat_cpk16_p75 = 1 if (aconpk_post16 >= p75_post16)
replace cat_cpk16_p90 = 1 if (aconpk_post16 >= p90_post16)

list province if cat_cpk16_p75 * year == 2019
list province if cat_cpk16_p90 * year == 2019

* table 7 level categorization
eststo clear

reg L.ln_gdpk popi  educ_hsch conprim_1000 conhs1000  period16##cat_cpk16_p75 i.year##i.enc_region
estimates store m1, title(yo2)

reg L.ln_gdpk popi  educ_hsch conprim_1000 conhs1000  period16##cat_cpk16_p90 i.year##i.enc_region
estimates store m2, title(yo2)

reg L.suicide_yrt popi  educ_hsch conprim_1000 conhs1000  period16##cat_cpk16_p75 i.year##i.enc_region
estimates store m3, title(yo2)

reg L.suicide_yrt popi  educ_hsch conprim_1000 conhs1000  period16##cat_cpk16_p90 i.year##i.enc_region
estimates store m4, title(yo2)

reg L.divorce_yrt popi  educ_hsch conprim_1000 conhs1000  period16##cat_cpk16_p75 i.year##i.enc_region
estimates store m5, title(yo2)

reg L.divorce_yrt popi  educ_hsch conprim_1000 conhs1000  period16##cat_cpk16_p90 i.year##i.enc_region
estimates store m6, title(yo2)

esttab m1 m2 m3 m4 m5 m6 using convict_level.tex, cells(b(star fmt(3)) se(par fmt(2))) legend label varlabels(_cons constant) stats(r2 df_r bic, fmt(3 0 1) label(R-sqr dfres BIC)) replace
esttab m1 m2 m3 m4 m5 m6 using convict_level.csv, cells(b(star fmt(3)) se(par fmt(2))) legend label varlabels(_cons constant) stats(r2 df_r bic, fmt(3 0 1) label(R-sqr dfres BIC)) replace


***
/*

	
/*
scatter cons_low cons_mid cons_hig year, ///
	title("Convicts Received per 1000") xline(2016) name(cons_graph2)

scatter gdpk_low gdpk_mid gdpk_hig year, ///
	title("Convicts Received per 1000") xline(2016) name(gdpk_graph2)

graph twoway ///
line yvar xvar if group == 1 || ///
line yvar xvar if group == 2 || ///
line yvar xvar if group == n ||
*/

/*
reg gdpk cr_educ_total postcoup_convicts postcoup  popi
reg gdpk cr_educ_total postcoup_convicts postcoup  popi i.enc_province
twoway (line cr_educ_total year) (line cr_type_homicide year) (line cr_type_assault year) (line cr_type_sexual year) (line cr_type_kidnapping year) (line cr_type_defamation year)
twoway (line convicts_turkey  year)
twoway (scatter convicts_turkey  year) name(turk_graph)
*/



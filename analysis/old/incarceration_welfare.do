********************************************************************************
* Title: Imprisonment~Welfare in Turkish Provinces                             *
* Author: Lutfi Sun                                                            *
* Date: Saturday, April 3, 2021                                                *
********************************************************************************

*-------------------------------------------------------------------------------
* Housekeeping
*-------------------------------------------------------------------------------

clear all
drop _all

cd "/Users/lutfisun/Desktop/turkey_convicts/analysis"

* turkey convicts analysis

import delimited "../data/turkey_convicts_clean.csv"

* convicts on welfare
gen postcoup = (year > 2015)
gen postcoup_convicts = postcoup * cr_educ_total
reg gdpk cr_educ_total postcoup_convicts postcoup  population
encode province, gen(enc_province)
reg gdpk cr_educ_total postcoup_convicts postcoup  population i.enc_province

gen post11 = (year > 2011)
gen post11_convicts = post11 * cr_educ_total
reg gdpk cr_educ_total post11_convicts postcoup_convicts post11 postcoup population
reg gdpk cr_educ_total post11_convicts postcoup_convicts post11 postcoup population i.year 

* politics on convicts
reg postcoup_convicts vs_akp vs_chp vs_mhp cr_educ_total  postcoup  population i.enc_province


twoway (line cr_educ_total year) (line cr_type_homicide year) (line cr_type_assault year) (line cr_type_sexual year) (line cr_type_kidnapping year) (line cr_type_defamation year)

egen convicts_turkey = total(cr_educ_total), by(year) 
twoway (line convicts_turkey  year)
twoway (scatter convicts_turkey  year)

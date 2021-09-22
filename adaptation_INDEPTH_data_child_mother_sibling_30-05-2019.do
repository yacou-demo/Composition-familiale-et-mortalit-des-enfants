cd "C:\Users\bocquier\Documents\INDEPTH\MADIMAH\MADIMAH 3 Child Mig\2018 analysis\"

* Methodology updates discussed in Jo’burg in January 2019:
* DONE 3.	Account for twin death and migration

*** Step 1: define sibling true rank
* The child_mother is merged with the Mother_Children file to identify the rank of Ego among siblings:
use child_mother, clear
bysort concat_IndividualId (EventDate): gen byte last_obs=(_N==_n)
keep if last_obs==1
keep concat_IndividualId MotherId last_record_date
duplicates drop
rename concat_IndividualId EgoId
rename MotherId concat_IndividualId
merge m:1 concat_IndividualId using Mother_Children.dta
drop _merge 

*The file is reshaped into long format (one sibling per record identified by ChildId):
rename concat_IndividualId MotherId 
reshape long concat_ChildId DoB, i(EgoId MotherId) j(child_rank)
drop if concat_ChildId ==""
drop if concat_ChildId ==" "

*The Ego child is identified among the siblings by the individual identifier using an indicator variable:
gen Ego= EgoId==concat_ChildId
sort EgoId DoB

*To determine the birth order of children born of the same mother:
gen true_child_rank=1
bysort EgoId (DoB) : replace true_child_rank = ///
		cond(DoB>DoB[_n-1],true_child_rank[_n-1]+1,true_child_rank[_n-1]) ///
		if _n!=1

*The rank of the Ego child is identified using the indicator variable for Ego:
bysort EgoId (DoB) : egen Ego_rank = max(cond(Ego==1,true_child_rank,0))
save child_mother_Ego, replace

**** Step 2: create files for the twin sibling, and the younger and older siblings
*Select the twin siblings:
use child_mother_Ego, clear 
bysort EgoId (child_rank) : keep if true_child_rank==Ego_rank & concat_ChildId!=EgoId
keep EgoId concat_ChildId last_record_date
sort concat_ChildId EgoId
bysort concat_ChildId (EgoId): gen sibling=_n
reshape wide EgoId, i(concat_ChildId) j(sibling)
duplicates drop
rename concat_ChildId concat_IndividualId
sort concat_IndividualId
save twin, replace

*Select the non-twin siblings:
use child_mother_Ego, clear 
bysort EgoId (child_rank) : gen twin= true_child_rank==true_child_rank[_n+1] | true_child_rank==true_child_rank[_n-1]   
bysort EgoId (child_rank) : drop if twin==1
keep concat_ChildId last_record_date
duplicates drop
rename concat_ChildId concat_IndividualId
sort concat_IndividualId
save non_twin, replace

*Merge the file for twin with the core residency file to get their event history:
*use residency_pregnancy, clear
use child_mother, clear
sort concat_IndividualId
merge m:1 concat_IndividualId using twin.dta
keep if _merge==3
drop _merge
* drop CountryId SubContinent CentreId CentreLab LocationId IndividualId MotherId 
* drop sibling
keep concat_IndividualId EventDate EventCode Sex DoB residence DTH_TVC EgoId*
rename concat_IndividualId TwinId
rename EventDate EventDateTwin
rename EventCode EventCodeTwin
rename Sex SexTwin
rename DoB DoBTwin
rename residence residenceTwin
rename DTH_TVC Twin_DTH_TVC 
duplicates drop
* 1 case only with event same date as last record date
drop if TwinId=="12TZ01258308" & EventCodeTwin==9 // delete last record with OBE 
reshape long EgoId, i(TwinId EventDateTwin) j(sibling)
drop if EgoId==""
drop if EgoId==" "
rename EgoId concat_IndividualId
sort concat_IndividualId TwinId EventDateTwin
order concat_IndividualId
append using non_twin

* Recode OBE for non-twin
recode EventCodeTwin .=9
replace EventDateTwin=last_record_date if EventDateTwin==.
sort concat_IndividualId EventDateTwin
bysort concat_IndividualId : gen chck_OBEt = cond(_n==_N,EventCodeTwin[_N],0)
bysort concat_IndividualId : gen chck_dateOBEt = cond(_n==_N,EventDateTwin[_N],0)
tab1 EventCode chck_OBEt chck_dateOBEt
drop chck_OBEt chck_dateOBEt
compress
save twin, replace
erase non_twin.dta

*Select the younger siblings (including younger twin siblings):
use child_mother_Ego, clear 
bysort EgoId (child_rank) : keep if true_child_rank==Ego_rank+1
keep EgoId concat_ChildId last_record_date
bysort concat_ChildId (EgoId): gen sibling=_n
reshape wide EgoId, i(concat_ChildId) j(sibling)
duplicates drop
rename concat_ChildId concat_IndividualId
sort concat_IndividualId
save ysibling, replace

* Children with no younger sibling (last rank)
use child_mother_Ego, clear 
bysort EgoId (child_rank) : egen max_child_rank=max(true_child_rank)
bysort EgoId (child_rank) : keep if true_child_rank==max_child_rank
keep concat_ChildId last_record_date
duplicates drop
rename concat_ChildId concat_IndividualId
sort concat_IndividualId
save non_ysibling, replace

*Merge the file of younger siblings with the core residency file to get their event history:
*use residency_pregnancy, clear
use child_mother, clear
sort concat_IndividualId
merge m:1 concat_IndividualId using ysibling.dta
keep if _merge==3
drop _merge
keep concat_IndividualId EventDate EventCode Sex DoB residence DTH_TVC EgoId*
rename concat_IndividualId YsiblingId
rename EventDate EventDateYsibling
rename EventCode EventCodeYsibling
rename Sex SexYsibling
rename DoB DoBYsibling
rename residence residenceYsibling
rename DTH_TVC Y_DTH_TVC 
sort YsiblingId EventDateYsibling EventCodeYsibling
duplicates drop
* 2 cases only with event same date as last record date
drop if YsiblingId=="1BF041142522" & EventCodeYsibling==9 // delete last record with OBE 
drop if YsiblingId=="4GH02188438" & EventCodeYsibling==9 // delete last record with OBE 
reshape long EgoId, i(YsiblingId EventDateYsibling) j(sibling)
drop if EgoId==""
drop if EgoId==" "
drop sibling
rename EgoId concat_IndividualId
sort concat_IndividualId YsiblingId EventDateYsibling
order concat_IndividualId
append using non_ysibling

* Recode OBE for non-younger siblings
recode EventCodeYsibling .=9
replace EventDateYsibling=last_record_date if EventDateYsibling==.
sort concat_IndividualId EventDateYsibling

capture drop datebeg
sort YsiblingId EventDateYsibling EventCodeYsibling
qui by YsiblingId: gen double datebeg=cond(_n==1, DoBYsibling, EventDateYsibling[_n-1])
format datebeg %tC

capture drop censor_BTH
gen censor_BTH = (EventCodeYsibling==2)

stset EventDate, id(YsiblingId) failure(censor_BTH==1) time0(datebeg) ///
				origin(time DoBYsibling-15778800000) scale(31557600000) 

display %20.0f  (365.25*0.5) * 24 * 60 * 60 * 1000
* 15778800000  
display %20.0f  365.25 * 24 * 60 * 60 * 1000 
* 31557600000
display %20.0f  (365.25*1.5) * 24 * 60 * 60 * 1000
* 47336400000

gen YsiblingId_EgoId = YsiblingId + concat_IndividualId
capture drop datebeg
sort YsiblingId_EgoId EventDateYsibling EventCodeYsibling
qui by YsiblingId_EgoId: gen double datebeg=cond(_n==1, DoBYsibling, EventDateYsibling[_n-1])
format datebeg %tC

sort YsiblingId_EgoId EventDateYsibling EventCodeYsibling
cap drop lastrecord
qui by YsiblingId_EgoId: gen lastrecord=_n==_N
stset EventDateYsibling, id(YsiblingId_EgoId) failure(lastrecord==1) ///
		time0(datebeg) origin(time DoBYsibling-15778800000)

capture drop birth_int
stsplit birth_int, at(0 15778800000 31557600000 47336400000)

recode birth_int (0=1 "pregnant_YS") (15778800000=2 "0-6m") ///
			(31557600000=3 "6-12m") (47336400000=4 "12m&+"), ///
			gen(birth_int_YS) label(lbirth_int_YS)

sort YsiblingId EventDateYsibling EventCodeYsibling
drop lastrecord
drop birth_int
drop _*

capture drop datebeg
sort YsiblingId EventDateYsibling EventCodeYsibling
qui by YsiblingId: gen double datebeg=cond(_n==1, DoBYsibling, EventDateYsibling[_n-1])
format datebeg %tC
****

sort concat_IndividualId EventDateYsibling
bysort concat_IndividualId : gen chck_OBE = cond(_n==_N,EventCode[_N],0)
bysort concat_IndividualId : gen chck_dateOBE = cond(_n==_N,EventDate[_N],0)
tab1 EventCode chck_OBE chck_dateOBE
*replace EventDateYsibling =1704153600000 if chck_dateOBE!=0
drop chck_*
compress
save ysibling, replace
erase non_ysibling.dta

*The same is done for the older siblings. Select the older siblings (including twin older siblings):
use child_mother_Ego, clear 
bysort EgoId (child_rank) : keep if true_child_rank==Ego_rank-1
keep EgoId concat_ChildId last_record_date
bysort concat_ChildId (EgoId): gen sibling=_n
reshape wide EgoId, i(concat_ChildId) j(sibling)
duplicates drop
rename concat_ChildId concat_IndividualId
sort concat_IndividualId
save osibling, replace

* Children with no older sibling (first rank)
use child_mother_Ego, clear 
bysort EgoId (child_rank) : egen min_child_rank=min(true_child_rank)
bysort EgoId (child_rank) : keep if true_child_rank==min_child_rank
keep concat_ChildId last_record_date
duplicates drop
rename concat_ChildId concat_IndividualId
sort concat_IndividualId
save non_osibling, replace

*Merge the file of older siblings with the core residency file to get their event history:
*use residency_pregnancy, clear
use child_mother, clear
sort concat_IndividualId
merge m:1 concat_IndividualId using osibling.dta
keep if _merge==3
drop _merge
keep concat_IndividualId EventDate EventCode Sex DoB residence DTH_TVC EgoId*
rename concat_IndividualId OsiblingId
rename EventDate EventDateOsibling
rename EventCode EventCodeOsibling
rename Sex SexOsibling
rename DoB DoBOsibling
rename residence residenceOsibling
rename DTH_TVC O_DTH_TVC 
duplicates drop
* 4 cases only with event same date as last record date
drop if OsiblingId=="1BF03127743" & EventCodeOsibling==9 // delete last record with OBE 
drop if OsiblingId=="3ET06112459" & EventCodeOsibling==9 // delete last record with OBE 
drop if OsiblingId=="4GH021121634" & EventCodeOsibling==9 // delete last record with OBE 
* 1 case where BTH wrongly coded and same date as DTH: add 12 hours in milliseconds
replace EventCodeOsibling=2 if OsiblingId=="4GH01113468" & EventCodeOsibling==7 & residenceOsibling==0  
replace EventDateOsibling=EventDateOsibling+ 12*60*60*1000 if OsiblingId=="4GH01113468" & EventCodeOsibling==7
reshape long EgoId, i(OsiblingId EventDateOsibling) j(sibling)
drop if EgoId==""
drop if EgoId==" "
drop sibling
rename EgoId concat_IndividualId
sort concat_IndividualId OsiblingId EventDateOsibling
order concat_IndividualId
append using non_osibling

* Recode OBE for non-older siblings
recode EventCodeOsibling .=9
replace EventDateOsibling=last_record_date if EventDateOsibling==.
sort concat_IndividualId EventDateOsibling
save osibling, replace
erase non_osibling.dta

*** Step 3: merge the younger and older sibling files with children file
*Merge the file of twin with the child file that already includes parents’ history:
clear
capture erase child_mother_twin.dta
tmerge concat_IndividualId child_mother(EventDate) twin(EventDateTwin) ///
		child_mother_twin(EventDate_final)

format EventDate_final %tC
drop EventDate 
rename EventDate_final EventDate
replace EventCode = 18 if _File==2
replace EventCodeTwin = 18 if _File==1
drop _File
order concat_IndividualId EventDate EventCode
sort concat_IndividualId EventDate EventCode
save child_mother_twin, replace

*Merge the file of younger siblings with the children file that already includes parents’ and twin’s history:
clear
capture erase child_mother_t_y.dta
tmerge concat_IndividualId child_mother_twin(EventDate) ysibling(EventDateY) ///
		child_mother_t_y(EventDate_final)

format EventDate_final %tC
drop EventDate 
rename EventDate_final EventDate
replace EventCode = 18 if _File==2
replace EventCodeY = 18 if _File==1
drop _File
order concat_IndividualId EventDate EventCode
sort concat_IndividualId EventDate EventCode
save child_mother_t_y, replace

use osibling

*Merge the file of older siblings with the children file that includes parents’ and younger siblings’ histories:
clear
capture erase child_mother_sibling.dta
tmerge concat_IndividualId child_mother_t_y(EventDate) osibling(EventDateO) ///
		child_mother_sibling(EventDate_final)

format EventDate_final %tC
drop EventDate 
rename EventDate_final EventDate
replace EventCode = 18 if _File==2
replace EventCodeO = 18 if _File==1
order concat_IndividualId EventDate EventCode
sort concat_IndividualId EventDate EventCode

/*br concat_IndividualId EventDate EventCode residence residenceYsibling EventCodeYsibling ///
	EventDateYsibling DoBYsibling residenceOsibling EventCodeOsibling ///
	EventDateOsibling DoBOsibling   
*/
**Correction residenceYsibling residenceOsibling
replace residenceYsibling=. if EventDate<=DoBYsibling & residenceYsibling!=.
replace residenceOsibling=. if EventDate<=DoBOsibling & residenceOsibling!=.
replace DoBYsibling=. if residenceYsibling==.
replace DoBOsibling=. if residenceOsibling==.

drop mdth6m_3m_15j_15j_3m_6m EventDateMO deadMO DoDMO inmig6m2_5_10y censor_deathMO child_mother_file 
drop EventDateTwin DoBTwin
drop EventDateYsibling  YsiblingId_EgoId 
drop EventDateOsibling  
drop censor_BTH datebeg _File 

order CountryId SubContinent CentreId CentreLab LocationId concat_IndividualId EventDate EventCode
compress
save child_mother_sibling, replace

***	Step 4: Restricting observation to under-5 year old
*			This consists in creating an extra record corresponding to the 5th birthday:
use child_mother_sibling, clear
capture drop censor_death 
gen censor_death=(EventCode==7) if residence==1
capture drop datebeg
bysort concat_IndividualId (EventDate): gen double datebeg=cond(_n==1,DoB,EventDate[_n-1])
format datebeg %tC

stset EventDate if residence==1, id(concat_IndividualId) failure(censor_death==1) ///
		time0(datebeg) origin(time DoB) exit(time .)  
capture drop fifthbirthday
display %20.0f (5*365.25*24*60*60*1000)+212000000 /* adding 2 days */
* 158000000000
stsplit fifthbirthday, at(158000000000) trim
drop if fifthbirthday!=0
compress
save child_mother_sibling, replace

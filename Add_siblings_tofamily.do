use final_dataset_analysis_des_p3,clear

capture drop last_record_date
gen double last_record_date = cofd(date("19apr 2019","DMY",2020)) if hdss=="GM011"
replace last_record_date=cofd(date("01Jan 2018","DMY",2020)) if hdss=="BF041"
replace last_record_date=cofd(date("29aug 2018","DMY",2020))  if hdss=="BF021"
replace last_record_date=cofd(date("01Jan 2016","DMY",2020))  if hdss=="SN011"
replace last_record_date=cofd(date("01Jan 2018","DMY",2020))  if hdss=="SN012"
format last_record_date %tc


*1672617600000
sort hdss concat_IndividualId EventDate EventCode
expand=2 if concat_IndividualId!=concat_IndividualId[_n+1] & EventDate<last_record_date, gen(duplicate)
sort concat_IndividualId EventDate EventCode duplicate
by concat_IndividualId : replace EventDate=last_record_date  if duplicate==1
drop duplicate

* Need recoding for these individuals
sort hdss concat_IndividualId EventDate EventCode
bys hdss concat_IndividualId : replace EventCode=9 if _n==_N


capture drop maxEventDate
bysort hdss concat_IndividualId (EventDate) : egen double maxEventDate=max(EventDate)
format %tc maxEventDate
tab maxEventDate, miss

save final_dataset_analysis_des_p3_bis,replace


use final_dataset_analysis_des_p3_bis,clear


*** Step 1: define sibling true rank
* The child_mother is merged with the mother_children file to identify the rank of Ego among siblings:
keep concat_IndividualId MotherId last_record_date hdss

duplicates drop
rename concat_IndividualId EgoId
rename MotherId concat_IndividualId
merge m:1 concat_IndividualId using mother_children_sahel_bis.dta
keep if _merge==3
drop _merge 
*The file is reshaped into long format (one sibling per record identified by ChildId):
rename concat_IndividualId MotherId 
reshape long ChildId DoB, i(EgoId MotherId) j(child_rank)
drop if ChildId ==""
drop if ChildId ==" "

*The Ego child is identified among the siblings by the individual identifier using an indicator variable:
gen Ego= EgoId==ChildId
sort EgoId DoB

*To determine the birth order of children born of the same mother:
gen true_child_rank=1
bysort EgoId (DoB) : replace true_child_rank = ///
		cond(DoB>DoB[_n-1],true_child_rank[_n-1]+1,true_child_rank[_n-1]) ///
		if _n!=1

*The rank of the Ego child is identified using the indicator variable for Ego:
bysort EgoId (DoB) : egen Ego_rank = max(cond(Ego==1,true_child_rank,0))
save child_mother_Ego_sahel, replace

**** Step 2: create files for the twin sibling, and the younger and older siblings
*Select the twin siblings:
use child_mother_Ego_sahel, clear 
bysort EgoId (child_rank) : keep if true_child_rank==Ego_rank & ChildId!=EgoId
keep EgoId ChildId last_record_date hdss
sort ChildId EgoId
bysort ChildId (EgoId): gen sibling=_n
reshape wide EgoId, i(ChildId) j(sibling)
duplicates drop
rename ChildId concat_IndividualId
sort concat_IndividualId
save twin_sahel, replace

*Select the non-twin siblings:
use child_mother_Ego_sahel, clear 
bysort EgoId (child_rank) : gen twin= true_child_rank==true_child_rank[_n+1] | true_child_rank==true_child_rank[_n-1]   
bysort EgoId (child_rank) : drop if twin==1
keep ChildId last_record_date hdss
duplicates drop
rename ChildId concat_IndividualId
sort concat_IndividualId
save non_twin_sahel, replace

*Merge the file for twin with the core residency file to get their event history:
use residency_sahel, clear
sort concat_IndividualId
merge m:1 concat_IndividualId using twin_sahel.dta
keep if _merge==3
drop _merge
* drop CountryId SubContinent CentreId CentreLab LocationId IndividualId MotherId 
* drop sibling
keep concat_IndividualId EventDate EventCode gender DoB residence  EgoId* hdss socialgpid 
rename concat_IndividualId TwinId
rename EventDate EventDateTwin
rename EventCode EventCodeTwin
rename gender SexTwin
rename DoB DoBTwin
rename residence residenceTwin
rename socialgpid socialgpidTwin
duplicates drop TwinId EventDateTwin EventCodeTwin,force
*drop Edu4 
*rename Death_Cause Death_CauseTwin
*rename Cause_Category Cause_CategoryTwin
*drop datebeg

*XX

reshape long EgoId, i(TwinId EventDateTwin EventCodeTwin) j(sibling)
drop if EgoId==""
drop if EgoId==" "

drop sibling
rename EgoId concat_IndividualId
sort concat_IndividualId TwinId EventDateTwin
order concat_IndividualId
append using non_twin_sahel
*save twin_verif, replace

gsort  EventDate
bys hdss : replace last_record_date = last_record_date[_n-1] if missing(last_record_date) & _n > 1 
bys hdss : replace last_record_date = last_record_date[_n+1] if missing(last_record_date) & _n > 1 
bys hdss : replace last_record_date = last_record_date[_N]

recode EventCodeTwin .=9
replace EventDateTwin=last_record_date if EventDateTwin==.
sort concat_IndividualId EventDateTwin
bysort concat_IndividualId : gen chck_OBEt = cond(_n==_N,EventCodeTwin[_N],0)
bysort concat_IndividualId : gen double chck_dateOBEt = cond(_n==_N,EventDateTwin[_N],0)
tab1 EventCode chck_OBEt chck_dateOBEt

* Recode OBE for non-twin
display %20.0f clock("19apr 2019","DMY")
* 1871251200000

display %20.0f clock("01jan 2016","DMY")
*1767225600000

display %20.0f clock("01jan 2018","DMY")
* 1830384000000

display %20.0f clock("29aug 2018","DMY")
*1851120000000


bys concat_IndividualId : replace last_record_date=cofd(date("19apr 2019","DMY",2020))  if hdss=="GM011"
bys concat_IndividualId : replace last_record_date=cofd(date("01Jan 2018","DMY",2020)) if hdss=="BF041"
bys concat_IndividualId : replace last_record_date=cofd(date("29aug 2018","DMY",2020))  if hdss=="BF021"
bys concat_IndividualId : replace last_record_date=cofd(date("01Jan 2016","DMY",2020))  if hdss=="SN011"
bys concat_IndividualId : replace last_record_date=cofd(date("01Jan 2018","DMY",2020))  if hdss=="SN012"

capture drop last_obs last_record_date
by hdss (EventDate), sort: gen double last_obs = (_n == _N)
capture drop last_record_date
gen double last_record_date = EventDate if last_obs==1
format last_record_date %tc
bys hdss (EventDate): replace last_record_date = last_record_date[_N]

recode EventCodeTwin .=9
replace EventDateTwin=last_record_date if EventDateTwin==.
sort concat_IndividualId EventDateTwin
capture drop chck_OBEt chck_dateOBEt
bysort concat_IndividualId : gen chck_OBEt = cond(_n==_N,EventCodeTwin[_N],0)
bysort concat_IndividualId : gen double chck_dateOBEt = cond(_n==_N,EventDateTwin[_N],0)
tab1 EventCode chck_OBEt chck_dateOBEt

drop chck_OBEt chck_dateOBEt
compress


save twin_sahel_bis, replace
erase non_twin_sahel.dta


*Select the younger siblings (including younger twin siblings):
use child_mother_Ego_sahel, clear 
bysort EgoId (child_rank) : keep if true_child_rank==Ego_rank+1
keep EgoId ChildId last_record_date hdss 
bysort ChildId (EgoId): gen sibling=_n
reshape wide EgoId, i(ChildId) j(sibling)
duplicates drop
rename ChildId concat_IndividualId
sort concat_IndividualId
save ysibling_sahel, replace

* Children with no younger sibling (last rank)
use child_mother_Ego_sahel, clear 
bysort EgoId (child_rank) : egen max_child_rank=max(true_child_rank)
bysort EgoId (child_rank) : keep if true_child_rank==max_child_rank
keep ChildId last_record_date hdss 
duplicates drop
rename ChildId concat_IndividualId
sort concat_IndividualId
save non_ysibling_sahel, replace

*Merge the file of younger siblings with the core residency file to get their event history:
use residency_sahel, clear

sort concat_IndividualId
merge m:1 concat_IndividualId using ysibling_sahel.dta
keep if _merge==3
drop _merge
rename concat_IndividualId YsiblingId
rename EventDate EventDateYsibling
rename EventCode EventCodeYsibling
rename gender SexYsibling
rename DoB DoBYsibling
rename residence residenceYsibling
rename socialgpid socialgpidYsibling
sort YsiblingId EventDateYsibling EventCodeYsibling
br YsiblingId EventDateYsibling EventCodeYsibling
*drop Edu4 
*rename Death_Cause Death_CauseYsibling
*rename Cause_Category Cause_CategoryYsibling
*drop datebeg

sort YsiblingId EventDate EventCode
capture drop dup_a
quietly by YsiblingId EventDateYsibling EventCodeYsibling: gen dup_a = cond(_N==1,0,_n)
drop if dup_a>1


duplicates drop
reshape long EgoId, i(YsiblingId EventDateYsibling EventCodeYsibling) j(sibling)
drop if EgoId==""
drop if EgoId==" "

drop sibling
rename EgoId concat_IndividualId
sort concat_IndividualId YsiblingId EventDateYsibling
order concat_IndividualId
append using non_ysibling_sahel


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
format datebeg %tc





gsort  EventDate
bys hdss : replace last_record_date = last_record_date[_n-1] if missing(last_record_date) & _n > 1 
bys hdss : replace last_record_date = last_record_date[_n+1] if missing(last_record_date) & _n > 1 
bys hdss : replace last_record_date = last_record_date[_N]

recode EventCodeYsibling .=9
replace EventDateYsibling=last_record_date if EventDateYsibling==.
sort concat_IndividualId EventDateYsibling
bysort concat_IndividualId : gen chck_OBEt = cond(_n==_N,EventCodeYsibling[_N],0)
bysort concat_IndividualId : gen double chck_dateOBEt = cond(_n==_N,EventDateYsibling[_N],0)
tab1 EventCode chck_OBEt chck_dateOBEt


* Recode OBE for non-twin
display %20.0f clock("19apr 2019","DMY")
* 1871251200000

display %20.0f clock("01jan 2016","DMY")
*1767225600000

display %20.0f clock("01jan 2018","DMY")
* 1830384000000

display %20.0f clock("29aug 2018","DMY")
*1851120000000

bys concat_IndividualId : replace last_record_date=1871251200000  if EventDate==. & hdss=="GM011"
bys concat_IndividualId : replace last_record_date=1830384000000  if EventDate==. & hdss=="BF041"
bys concat_IndividualId : replace last_record_date=1851120000000  if EventDate==. & hdss=="BF021"
bys concat_IndividualId : replace last_record_date=1767225600000  if EventDate==. & hdss=="SN011"
bys concat_IndividualId : replace last_record_date=1830384000000  if EventDate==. & hdss=="SN012"

capture drop last_obs last_record_date
by hdss (EventDate), sort: gen double last_obs = (_n == _N)
gen double last_record_date = EventDate if last_obs==1
format last_record_date %tc
bys hdss (EventDate): replace last_record_date = last_record_date[_N]


* Recode OBE for non-twin
recode EventCodeYsibling .=9
replace EventDateYsibling=last_record_date if EventDateYsibling==.
sort concat_IndividualId EventDateYsibling
capture drop chck_OBEt
bysort concat_IndividualId : gen chck_OBEt = cond(_n==_N,EventCodeYsibling[_N],0)
capture drop chck_dateOBEt
bysort concat_IndividualId : gen chck_dateOBEt = cond(_n==_N,EventDateYsibling[_N],0)
tab1 EventCode chck_OBEt chck_dateOBEt
drop chck_OBEt chck_dateOBEt
compress



*Modification 30012019


/*YaC 14-07-2018 
* PhB 05-07-2018: to create a 3-month pregnancy event (6 months before delivery)
expand =2 if EventCodeYsibling==11, gen(preg3month)
* preg3month = 3-month pregnancy event
replace EventCodeYsibling=18 if preg3month==1 /* observation */
replace EventDateYsibling=EventDateYsibling-((365.25/2)*24*60*60*1000) if preg3month==1
gen byte pregnant_YS=(EventCodeYsibling==11) 
label var pregnant_YS "6-month period before delivery"
*drop preg3month
*/

*YaC 14-07-2018
* PhB 27072018
capture drop datebeg
sort YsiblingId EventDateYsibling EventCodeYsibling
qui by YsiblingId: gen double datebeg=cond(_n==1, DoBYsibling, EventDateYsibling[_n-1])
format datebeg %tc


*Yac 13082018
gen YsiblingId_EgoId = YsiblingId + concat_IndividualId
capture drop datebeg
sort YsiblingId_EgoId EventDateYsibling EventCodeYsibling
qui by YsiblingId_EgoId: gen double datebeg=cond(_n==1, DoBYsibling, EventDateYsibling[_n-1])
format datebeg %tc

sort YsiblingId_EgoId EventDateYsibling EventCodeYsibling
cap drop lastrecord
qui by YsiblingId_EgoId: gen lastrecord=_n==_N


*Yac 13082018
capture drop datebeg
sort YsiblingId EventDateYsibling EventCodeYsibling
qui by YsiblingId: gen double datebeg=cond(_n==1, DoBYsibling, EventDateYsibling[_n-1])
format datebeg %tc
****

sort concat_IndividualId EventDateYsibling
bysort concat_IndividualId : gen chck_OBE = cond(_n==_N,EventCode[_N],0)
bysort concat_IndividualId : gen chck_dateOBE = cond(_n==_N,EventDate[_N],0)
tab1 EventCode chck_OBE chck_dateOBE
*replace EventDateYsibling =1704153600000 if chck_dateOBE!=0
bysort concat_IndividualId : gen chck_OBE1 = cond(_n==_N,EventCode[_N],0)
bysort concat_IndividualId : gen chck_dateOBE1 = cond(_n==_N,EventDate[_N],0)
tab1 EventCode chck_OBE1 chck_dateOBE1

 
save ysibling_sahel, replace
erase non_ysibling_sahel.dta


*XX
*The same is done for the older siblings. Select the older siblings (including twin older siblings):
use child_mother_Ego_sahel, clear 
bysort EgoId (child_rank) : keep if true_child_rank==Ego_rank-1
keep EgoId ChildId last_record_date hdss 
bysort ChildId (EgoId): gen sibling=_n
reshape wide EgoId, i(ChildId) j(sibling)
duplicates drop
rename ChildId concat_IndividualId
sort concat_IndividualId
save osibling_sahel, replace

* Children with no older sibling (first rank)
use child_mother_Ego_sahel, clear 
bysort EgoId (child_rank) : egen min_child_rank=min(true_child_rank)
bysort EgoId (child_rank) : keep if true_child_rank==min_child_rank
keep ChildId last_record_date hdss 
duplicates drop
rename ChildId concat_IndividualId
sort concat_IndividualId
save non_osibling_sahel, replace

*Merge the file of older siblings with the core residency file to get their event history:
use residency_sahel, clear

sort concat_IndividualId
merge m:1 concat_IndividualId using osibling_sahel.dta
keep if _merge==3
drop _merge
rename concat_IndividualId OsiblingId
rename EventDate EventDateOsibling
rename EventCode EventCodeOsibling
rename gender SexOsibling
rename DoB DoBOsibling
rename residence residenceOsibling
rename socialgpid socialgpidOsibling
*drop Edu4 
*rename Death_Cause Death_CauseOsibling
*rename Cause_Category Cause_CategoryOsibling
*drop datebeg


sort OsiblingId  EventDateOsibling EventCodeOsibling
capture drop dup_a
quietly by OsiblingId  EventDateOsibling EventCodeOsibling: gen dup_a = cond(_N==1,0,_n)
drop if dup_a>1

duplicates drop
reshape long EgoId, i(OsiblingId EventDateOsibling EventCodeOsibling) j(sibling)
drop if EgoId==""
drop if EgoId==" "

drop sibling
rename EgoId concat_IndividualId
sort concat_IndividualId OsiblingId EventDateOsibling
order concat_IndividualId
append using non_osibling_sahel

gsort  EventDate
bys hdss : replace last_record_date = last_record_date[_n-1] if missing(last_record_date) & _n > 1 
bys hdss : replace last_record_date = last_record_date[_n+1] if missing(last_record_date) & _n > 1 
bys hdss : replace last_record_date = last_record_date[_N]

recode EventCodeOsibling .=9
replace EventDateOsibling=last_record_date if EventDateOsibling==.
sort concat_IndividualId EventDateOsibling
bysort concat_IndividualId : gen chck_OBEt = cond(_n==_N,EventCodeOsibling[_N],0)
bysort concat_IndividualId : gen double chck_dateOBEt = cond(_n==_N,EventDateOsibling[_N],0)
tab1 EventCode chck_OBEt chck_dateOBEt

* Recode OBE for non-twin
display %20.0f clock("19apr 2019","DMY")
* 1871251200000

display %20.0f clock("01jan 2016","DMY")
*1767225600000

display %20.0f clock("01jan 2018","DMY")
* 1830384000000

display %20.0f clock("29aug 2018","DMY")
*1851120000000

bys concat_IndividualId : replace last_record_date=1871251200000  if EventDate==. & hdss=="GM011"
bys concat_IndividualId : replace last_record_date=1830384000000  if EventDate==. & hdss=="BF041"
bys concat_IndividualId : replace last_record_date=1851120000000  if EventDate==. & hdss=="BF021"
bys concat_IndividualId : replace last_record_date=1767225600000  if EventDate==. & hdss=="SN011"
bys concat_IndividualId : replace last_record_date=1830384000000  if EventDate==. & hdss=="SN012"




capture drop last_obs last_record_date
by hdss (EventDate), sort: gen double last_obs = (_n == _N)
gen double last_record_date = EventDate if last_obs==1
format last_record_date %tc
bys hdss (EventDate): replace last_record_date = last_record_date[_N]


* Recode OBE for non-twin
recode EventCodeOsibling .=9
replace EventDateOsibling=last_record_date if EventDateOsibling==.
sort concat_IndividualId EventDateOsibling
capture drop chck_OBEt
bysort concat_IndividualId : gen chck_OBEt = cond(_n==_N,EventCodeOsibling[_N],0)
capture drop chck_dateOBEt
bysort concat_IndividualId : gen chck_dateOBEt = cond(_n==_N,EventDateOsibling[_N],0)
tab1 EventCode chck_OBEt chck_dateOBEt
drop chck_OBEt chck_dateOBEt
compress

save osibling_sahel,replace
erase non_osibling_sahel.dta
*** Step 3: merge the younger and older sibling files with children file
*Merge the file of twin with the child file that already includes parents’ history:
clear
capture erase child_network_twin_sahel.dta
tmerge concat_IndividualId final_dataset_analysis_des_p3_bis(EventDate) twin_sahel_bis(EventDateTwin) ///
		child_network_twin_sahel(EventDate_final)


format EventDate_final %tc
drop EventDate 
rename EventDate_final EventDate
replace EventCode = 18 if _File==2
replace EventCodeTwin = 18 if _File==1
drop _File
order concat_IndividualId EventDate EventCode
sort concat_IndividualId EventDate EventCode
save child_network_twin_sahel, replace

*Merge the file of younger siblings with the children file that already includes parents’ and twin’s history:
clear
capture erase child_network_t_y_sahel.dta
tmerge concat_IndividualId child_network_twin_sahel(EventDate) ysibling_sahel(EventDateY) ///
child_network_t_y_sahel(EventDate_final)

format EventDate_final %tc
drop EventDate 
rename EventDate_final EventDate
replace EventCode = 18 if _File==2
replace EventCodeY = 18 if _File==1
drop _File
order concat_IndividualId EventDate EventCode
sort concat_IndividualId EventDate EventCode
save child_network_t_y_sahel, replace

*Merge the file of older siblings with the children file that includes parents’ and younger siblings’ histories:
clear
capture erase child_network_sibling_sahel.dta
tmerge concat_IndividualId child_network_t_y_sahel (EventDate) osibling_sahel(EventDateO) ///
child_network_sibling_sahel(EventDate_final)

format EventDate_final %tc
drop EventDate 
rename EventDate_final EventDate
replace EventCode = 18 if _File==2
replace EventCodeO = 18 if _File==1
order concat_IndividualId EventDate EventCode
sort concat_IndividualId EventDate EventCode

save child_network_sibling_sahel,replace
XX


***	Step 4: restricting observation to under-5 year old
*This consists in creating an extra record corresponding to the 5th birthday:
use child_mother_sibling_sahel, clear
capture drop censor_death 
gen censor_death=(EventCode==7) if residence==1
capture drop datebeg
bysort concat_IndividualId (EventDate): gen double datebeg=cond(_n==1,DoB,EventDate[_n-1])

stset EventDate if residence==1, id(concat_IndividualId) failure(censor_death==1) ///
		time0(datebeg) origin(time DoB) exit(time .)  
capture drop fifthbirthday
display %20.0f (5*365.25*24*60*60*1000)+212000000 /*why 212000000? */ /*(2 days)*/
* 158000000000
stsplit fifthbirthday, at(158000000000) trim
drop if fifthbirthday!=0

*display %20.0f clock("01Jan 1998","DMY")

display %20.0f clock("01Jan 1983","DMY")

save child_mother_sibling_sahel_final, replace


 




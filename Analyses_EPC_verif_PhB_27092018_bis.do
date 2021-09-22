cd "C:\Users\bocquier\Documents\INDEPTH\MADIMAH\MADIMAH 3 Child Mig\2018 analysis\"

* Methodology updates discussed in Jo’burg in January 2019:
* 1.	Include in model some form of controlling for clustering within families (number children in HH or HH size)- using LocationID
* 	NOT DONE: cannot use both MotherId and LocationId to control for clustering.

*log using Analyses_30-05-2019, replace
use child_mother_sibling, clear

* Correction 
bysort concat_IndividualId (DoBOsibling): replace DoBOsibling = DoBOsibling[1]
bysort concat_IndividualId (DoBYsibling): replace DoBYsibling = DoBYsibling[1]
format DoBYsibling %tC
format DoBOsibling %tC
sort concat_IndividualId EventDate EventCode

* Correction: Residence of the mother should be 0 after her death
replace residenceMO=0 if MO_DTH_TVC==4 | MO_DTH_TVC==5 | MO_DTH_TVC==6

* Generate indicator variables for death of mother and siblings:
capture drop Dead*
bysort concat_IndividualId (EventDate): gen byte DeadMO=sum(EventCodeMO[_n-1]==7) 
bysort concat_IndividualId (EventDate): gen byte DeadY =sum(EventCodeY[_n-1]==7) 
bysort concat_IndividualId (EventDate): gen byte DeadO =sum(EventCodeO[_n-1]==7) 
bysort concat_IndividualId (EventDate): gen byte DeadTwin =sum(EventCodeTwin[_n-1]==7) 
replace DeadMO= 1 if DeadMO>1 & DeadMO!=. 
replace DeadY = 1 if DeadY >1 & DeadY !=. 
replace DeadO = 1 if DeadO >1 & DeadO !=. 

* New variable for residence accounting for death: 
capture drop MigDead*
gen byte MigDeadMO=(1+residenceMO+2*DeadMO)
recode MigDeadMO (4 = 3)
lab def MigDeadMO 1"mother non resident" 2 "mother res" 3 "mother dead" 4 "mother res dead",  modify
lab val MigDeadMO MigDeadMO
replace MigDeadMO=3 if MO_DTH_TVC==4 | MO_DTH_TVC==5

gen byte MigDeadY=cond(residenceY==., 0, 1 + (residenceY==1) + 2*(DeadY==1)) 
recode MigDeadY(4=3) 
lab def MigDeadY 0 "no young sib" 1 "y sib non-res" 2 "y sib resident" 3 "y sib dead" 4 "y sib res dead",  modify
lab val MigDeadY MigDeadY
replace MigDeadY=2 if MigDeadY==3 & Y_DTH_TVC<3
replace MigDeadY=3 if MigDeadY!=3 & (Y_DTH_TVC==4 | Y_DTH_TVC==5)

gen byte MigDeadTwin=cond(residenceTwin==., 0, 1 + (residenceTwin==1) + 2*(DeadTwin==1)) 
recode MigDeadTwin(4=3) 
lab def MigDeadTwin 0 "no twin" 1 "twin non-res" 2 "twin resident" 3 "twin dead" 4 "twin res dead",  modify
lab val MigDeadTwin MigDeadTwin
replace MigDeadTwin=2 if MigDeadTwin==3 & Twin_DTH_TVC<3
replace MigDeadTwin=3 if MigDeadTwin!=3 & (Twin_DTH_TVC==4 | Twin_DTH_TVC==5)

gen byte MigDeadO=cond(residenceO==., 0, 1 + (residenceO==1) + 2*(DeadO==1))
recode MigDeadO(4=3) 
lab def MigDeadO 0 "no older sib" 1 "o sib non-res" 2 "o sib resident" 3 "o sib dead" 4 "o sib res dead",  modify
lab val MigDeadO MigDeadO
replace MigDeadO=2 if MigDeadO==3 & O_DTH_TVC<3
replace MigDeadO=3 if MigDeadO!=3 & (O_DTH_TVC==4 | O_DTH_TVC==5)

** Generate calendar periods
cap drop lastrecord
qui bys concat_IndividualId (EventDate): gen byte lastrecord=(_n==_N) 
tab lastrecord

format datebeg %tC
sort concat_IndividualId datebeg
*bysort CentreId (concat_IndividualId datebeg): summarize datebeg if concat_IndividualId!=concat_IndividualId[_n-1], format detail
summarize datebeg if concat_IndividualId!=concat_IndividualId[_n-1] & CentreId=="BF021" ///
	& datebeg<clock("01jan2010","DMY"), format detail
drop if CentreId=="BF021" & datebeg<clock("21mar2009","DMY")
summarize datebeg if concat_IndividualId!=concat_IndividualId[_n-1] & CentreId=="BF031" ///
	& datebeg<clock("01jul1999","DMY"), format detail
drop if CentreId=="BF031" & datebeg<clock("01jan1998","DMY")
summarize datebeg if concat_IndividualId!=concat_IndividualId[_n-1] & CentreId=="BF041" ///
	& datebeg<clock("01jul2009","DMY"), format detail
drop if CentreId=="BF041" & datebeg<clock("01jan2009","DMY")
summarize datebeg if concat_IndividualId!=concat_IndividualId[_n-1] & CentreId=="CI011" ///
	& datebeg<clock("01jul2009","DMY"), format detail
drop if CentreId=="CI011" & datebeg<clock("01jan2009","DMY")
summarize datebeg if concat_IndividualId!=concat_IndividualId[_n-1] & CentreId=="ET021" ///
	& datebeg<clock("01jul2006","DMY"), format detail
drop if CentreId=="ET021" & datebeg<clock("01jan2006","DMY")
summarize datebeg if concat_IndividualId!=concat_IndividualId[_n-1] & CentreId=="ET031" ///
	& datebeg<clock("01jul2010","DMY"), format detail
drop if CentreId=="ET031" & datebeg<clock("01jan2010","DMY")
summarize datebeg if concat_IndividualId!=concat_IndividualId[_n-1] & CentreId=="ET041" ///
	& datebeg<clock("01jul2008","DMY"), format detail
drop if CentreId=="ET041" & datebeg<clock("01jan2008","DMY")
summarize datebeg if concat_IndividualId!=concat_IndividualId[_n-1] & CentreId=="ET042" ///
	& datebeg<clock("01jan2013","DMY"), format detail
drop if CentreId=="ET042" & datebeg<clock("01jan2012","DMY")
summarize datebeg if concat_IndividualId!=concat_IndividualId[_n-1] & CentreId=="ET051" ///
	& datebeg<clock("01jul2009","DMY"), format detail
drop if CentreId=="ET051" & datebeg<clock("01jan2009","DMY")
summarize datebeg if concat_IndividualId!=concat_IndividualId[_n-1] & CentreId=="ET061" ///
	& datebeg<clock("01jul2010","DMY"), format detail
drop if CentreId=="ET061" & datebeg<clock("01jan2010","DMY")
summarize datebeg if concat_IndividualId!=concat_IndividualId[_n-1] & CentreId=="GH011" ///
	& datebeg<clock("01jan1994","DMY"), format detail
drop if CentreId=="GH011" & datebeg<clock("01jul1993","DMY")
summarize datebeg if concat_IndividualId!=concat_IndividualId[_n-1] & CentreId=="GH021" ///
	& datebeg<clock("01jul2006","DMY"), format detail
drop if CentreId=="GH021" & datebeg<clock("01jan2006","DMY")
summarize datebeg if concat_IndividualId!=concat_IndividualId[_n-1] & CentreId=="GM011" ///
	& datebeg<clock("01jan1990","DMY"), format detail
drop if CentreId=="GM011" & datebeg<clock("11mar1989","DMY")
summarize datebeg if concat_IndividualId!=concat_IndividualId[_n-1] & CentreId=="KE031" ///
	& datebeg<clock("01jul2003","DMY"), format detail
drop if CentreId=="KE031" & datebeg<clock("01jan2003","DMY")
summarize datebeg if concat_IndividualId!=concat_IndividualId[_n-1] & CentreId=="KE051" ///
	& datebeg<clock("01jul2011","DMY"), format detail
drop if CentreId=="KE051" & datebeg<clock("01jan2011","DMY")
summarize datebeg if concat_IndividualId!=concat_IndividualId[_n-1] & CentreId=="MW011" ///
	, format detail
drop if CentreId=="MW011" & datebeg<clock("01jan2003","DMY")
summarize datebeg if concat_IndividualId!=concat_IndividualId[_n-1] & CentreId=="MZ021" ///
	& datebeg<clock("01jan2011","DMY"), format detail
drop if CentreId=="MZ021" & datebeg<clock("14jun2010","DMY")
summarize datebeg if concat_IndividualId!=concat_IndividualId[_n-1] & CentreId=="NG011" ///
	& datebeg<clock("01jul2011","DMY"), format detail
drop if CentreId=="NG011" & datebeg<clock("01jan2011","DMY")
summarize datebeg if concat_IndividualId!=concat_IndividualId[_n-1] & CentreId=="SN011" ///
	& datebeg<clock("01jul1989","DMY"), format detail
drop if CentreId=="SN011" & datebeg<clock("01jan1990","DMY")
summarize datebeg if concat_IndividualId!=concat_IndividualId[_n-1] & CentreId=="SN012" ///
	& datebeg<clock("01jul1989","DMY"), format detail
drop if CentreId=="SN012" & datebeg<clock("01jan1990","DMY")
summarize datebeg if concat_IndividualId!=concat_IndividualId[_n-1] & CentreId=="SN013" ///
	& datebeg<clock("01jul1989","DMY"), format detail
drop if CentreId=="SN013" & datebeg<clock("01jan1990","DMY")
summarize datebeg if concat_IndividualId!=concat_IndividualId[_n-1] & CentreId=="TZ011" ///
	& datebeg<clock("01jul1998","DMY"), format detail
drop if CentreId=="TZ011" & datebeg<clock("01jan1997","DMY")
summarize datebeg if concat_IndividualId!=concat_IndividualId[_n-1] & CentreId=="TZ021" ///
	& datebeg<clock("01jan1995","DMY"), format detail
drop if CentreId=="TZ021" & datebeg<clock("15may1994","DMY")
summarize datebeg if concat_IndividualId!=concat_IndividualId[_n-1] & CentreId=="UG011" ///
	& datebeg<clock("01may2005","DMY"), format detail
histogram datebeg if concat_IndividualId!=concat_IndividualId[_n-1] & CentreId=="UG011" ///
	& datebeg<clock("01may2005","DMY") & datebeg>clock("01jan2005","DMY"), xlabel(,angle(45)) bin(50)
drop if CentreId=="UG011" & datebeg<clock("01apr2005","DMY")
summarize datebeg if concat_IndividualId!=concat_IndividualId[_n-1] & CentreId=="ZA011" ///
	& datebeg<clock("01jul1993","DMY"), format detail
drop if CentreId=="ZA011" & datebeg<clock("01jan1993","DMY")
summarize datebeg if concat_IndividualId!=concat_IndividualId[_n-1] & CentreId=="ZA021" ///
	& datebeg<clock("01jul1996","DMY"), format detail
drop if CentreId=="ZA021" & datebeg<clock("01jan1996","DMY")

stset EventDate if residence==1, id(concat_IndividualId) failure(lastrecord==1) ///
		time0(datebeg)  
/* To get values of 01Jan for each year
foreach num in 1990 1995 2000 2005 2010 2015 {
	display %20.0f clock("01Jan`num'","DMY")
}
*/
capture drop period 
stsplit period, at(946771200000 1104537600000 1262304000000 ///
			1420156800000 1577923200000 1735689600000)
recode period (946771200000=1990) (1104537600000=1995) (1262304000000=2000) ///
			(1420156800000=2005) (1577923200000=2010) (1735689600000=2015)
label variable period period

sort concat_IndividualId EventDate
by concat_IndividualId: replace EventCode=30 if EventCode==EventCode[_n+1] ///
		& period!=. & period!=period[_n+1] & concat_IndividualId==concat_IndividualId[_n+1]
label define eventlab 30 "Period", modify
lab val EventCode eventlab

sort concat_IndividualId EventDate EventCode
cap drop censor_death
gen byte censor_death=(EventCode==7) if residence==1
stset EventDate if residence==1, id(concat_IndividualId) failure(censor_death==1) ///
			time0(datebeg) origin(time DoB) exit(time .) scale(31557600000)

* clean some inconsistent out-of-period data for some sites
tab CentreId period [iw=_t-_t0],  missing
format datebeg %tC

drop if period==0 | period==.

**Groupe d'âge de la mère
capture drop mother_age_birth
gen mother_age_birth = (DoB - DoB_mother)/31557600000

**Erreurs (âge de la mère à la naissance inférieur à 13 ans ou supérieur à 52 ans)
capture drop error_m_age
gen byte error_m_age = cond(mother_age_birth==.,.,cond(mother_age_birth<13| mother_age_birth>52,1,0))

**Supprimer ces incohérences 
drop if error_m_age == 1
drop error_m_age

capture drop gp_mother_age_birth
gen byte gp_mother_age_birth = cond(mother_age_birth==.,4,cond(mother_age_birth<18,1,cond(mother_age_birth<36,2,3)))
label def gp_age 1"<18 years" 2"18 - 35 y" 3"35 years  +" 4"Missing",modify
label val gp_mother_age_birth gp_age

capture drop y3_mother_age_birth
gen int_mother_age_birth=int(mother_age_birth)
recode int_mother_age_birth (min/17=15 "15-17") (18/20=18 "18–20") (21/23=21 "21–23") ///
		(24/26=24 "24–26") (27/29=27 "27–29") (30/32=30 "30–32") (33/35=33 "33–35") ///
		(36/38=36 "36–38") (39/41=39 "39–41") (42/max=42 "42+") (.=99 "Missing"), gen(y3_mother_age_birth)
drop int_mother_age_birth

capture drop ecart_O 
gen ecart_O = (DoB - DoBOsibling)*12/31557600000
capture drop gp_ecart_O
gen byte gp_ecart_O = cond(ecart_O==.,0, ///
				cond(ecart_O<12,1, ///
				cond(ecart_O<15,2, ///
				cond(ecart_O<18,3, ///
				cond(ecart_O<21,4, ///
				cond(ecart_O<24,5, ///
				cond(ecart_O<27,6, ///
				cond(ecart_O<30,7, ///
				cond(ecart_O<33,0, ///
				cond(ecart_O<36,9, ///
				cond(ecart_O<39,10, ///
				cond(ecart_O<42,11, ///
				cond(ecart_O<45,12, ///
				cond(ecart_O<48,13, ///
				cond(ecart_O<51,14, ///
				cond(ecart_O<54,15, ///
				16))))))))))))))))
label def gp_age_so 0 "NoOS" 1 "<12 months" 2 "12-14 months" 3 "15-17 months" ///
		4 "18-20 months" 5 "21-23 months" 6 "24-26 months" 7 "27-29 months" ///
		8 "30-32 months" 9 "33-35 months" 10 "36-38 months" 11 "39-41 months" ///
		12 "42-44 months" 13 "45-47 months" 14 "48-50 months" 15 "51-53 months" 16"54 months +", modify
label val gp_ecart_O gp_age_so

capture drop gp_ecart_O_new
gen byte gp_ecart_O_new = cond(ecart_O==.,0, ///
				cond(ecart_O<12,1, ///
				cond(ecart_O<18,2, ///
				cond(ecart_O<24,3, ///
				cond(ecart_O<30,4, ///
				cond(ecart_O<36,5, ///
				cond(ecart_O<42,6, ///
				cond(ecart_O<48,7, ///
				8))))))))
label def lgp_ecart_O_new 0"NoOS" 1"<12 months" 2"12-17 months" 3"18-23 months" ///
		4 "24-29 months" 5 "30-35 months" 6 "36-41 months" 7 "42-47 months" 8 "48 months +",modify
label val gp_ecart_O_new lgp_ecart_O_new

capture drop ecart_Y 
gen ecart_Y = (DoBYsibling - DoB)*12/31557600000
capture drop gp_ecart_Y
gen byte gp_ecart_Y = cond(ecart_Y==.,0, ///
				cond(ecart_Y<12,1, ///
				cond(ecart_Y<15,2, ///
				cond(ecart_Y<18,3, ///
				cond(ecart_Y<21,4, ///
				cond(ecart_Y<24,5, ///
				cond(ecart_Y<27,6, ///
				cond(ecart_Y<30,7, ///
				cond(ecart_Y<33,0, ///
				cond(ecart_Y<36,9, ///
				cond(ecart_Y<39,10, ///
				cond(ecart_Y<42,11, ///
				cond(ecart_Y<45,12, ///
				cond(ecart_Y<48,13, ///
				cond(ecart_Y<51,14, ///
				cond(ecart_Y<54,15, ///
				16))))))))))))))))
label def gp_age_sy 0 "NoYS" 1 "<12 months" 2 "12-14 months" 3 "15-17 months" ///
		4 "18-20 months" 5 "21-23 months" 6 "24-26 months" 7 "27-29 months" ///
		8 "30-32 months" 9 "33-35 months" 10 "36-38 months" 11 "39-41 months" ///
		12 "42-44 months" 13 "45-47 months" 14 "48-50 months" 15 "51-53 months" 16"54 months +", modify
label val gp_ecart_Y gp_age_sy			
				
gen byte gp_ecart_Y_new = cond(ecart_Y==.,0, ///
				cond(ecart_Y<12,1, ///
				cond(ecart_Y<18,2, ///
				cond(ecart_Y<24,3, ///
				cond(ecart_Y<30,4, ///
				cond(ecart_Y<36,5, ///
				cond(ecart_Y<42,6, ///
				cond(ecart_Y<48,7, ///
				8))))))))
label def lgp_ecart_Y_new 0 "NoYS" 1 "<12 months" 2 "12-17 months" 3 "18-23 months" ///
		4 "24-29 months" 5 "30-35 months" 6 "36-41 months" 7 "42-47 months" 8 "48 months +" 
label val gp_ecart_Y_new lgp_ecart_Y_new

* Data errors:
* Gap between Younger sibling and index child DoB <9 months
browse concat_IndividualId DoB YsiblingId DoBYsibling ecart_Y MotherId  if ecart_Y<8 & lastrecord==1
gen temp=100*(ecart_Y<8)
table CentreId if lastrecord==1, contents(mean temp) // ET041 ET051 ET061 >1%
drop temp

* Gap between Older sibling and index child DoB <9 months
browse concat_IndividualId DoB OsiblingId DoBOsibling ecart_O MotherId  if ecart_O<8 & lastrecord==1
gen temp=100*(ecart_O<8)
table CentreId if lastrecord==1, contents(mean temp) // ET041 ET051 ET061 >1%
drop temp

* Fix these errors
drop if ecart_Y<8
drop if ecart_O<8

* Gap between Younger sibling and index child DoB >5 years
browse concat_IndividualId DoB YsiblingId DoBYsibling ecart_Y MotherId  if ecart_Y>60 & ecart_Y!=. & lastrecord==1
* Only 81 and none >61 months
* Gap between Older sibling and index child DoB >20 years
browse concat_IndividualId DoB OsiblingId DoBOsibling ecart_O MotherId  if ecart_O>240 & ecart_O!=. & lastrecord==1
* Only 16 
* No impact on sibling covariates

replace migrant_statusMO = 0 if MigDeadMO==1
bysort concat_IndividualId (EventDate): replace migrant_statusMO = migrant_statusMO[1] if migrant_statusMO==.

gen byte gp_ecart_Yres = cond(MigDeadY==2,gp_ecart_Y,0)
gen byte gp_ecart_Ores = cond(MigDeadO==2,gp_ecart_O,0)
gen byte gp_ecart_Ores_new = cond(MigDeadO==2,gp_ecart_O_new,0)
label val gp_ecart_Yres gp_age_sy
label val gp_ecart_Ores gp_age_so
label val gp_ecart_Ores_new lgp_ecart_O_new

sort concat_IndividualId EventDate
gen byte birth_int_Yres_12m = cond(gp_ecart_Y_new==1&MigDeadY==2,birth_int_YS ,0)
replace birth_int_Yres_12m=1 if birth_int_YS==1 & gp_ecart_Y_new[_n+1]==1
label val birth_int_Yres_12m lbirth_int_YS

gen byte birth_int_Yres_12_17m = cond(gp_ecart_Y_new==2&MigDeadY==2,birth_int_YS ,0)
replace birth_int_Yres_12_17m=1 if birth_int_YS==1 & gp_ecart_Y_new[_n+1]==2
label val birth_int_Yres_12_17m lbirth_int_YS

gen byte birth_int_Yres_18_23m = cond(gp_ecart_Y_new==3&MigDeadY==2,birth_int_YS ,0)
replace birth_int_Yres_18_23m=1 if birth_int_YS==1 & gp_ecart_Y_new[_n+1]==3
label val birth_int_Yres_18_23m lbirth_int_YS

gen byte birth_int_Yres_24_29m = cond(gp_ecart_Y_new==4&MigDeadY==2,birth_int_YS ,0)
replace birth_int_Yres_24_29m=1 if birth_int_YS==1 & gp_ecart_Y_new[_n+1]==4
label val birth_int_Yres_24_29m lbirth_int_YS

gen byte birth_int_Yres_30_35m = cond(gp_ecart_Y_new==5&MigDeadY==2,birth_int_YS ,0)
replace birth_int_Yres_30_35m=1 if birth_int_YS==1 & gp_ecart_Y_new[_n+1]==5
label val birth_int_Yres_30_35m lbirth_int_YS

gen byte birth_int_Yres_36_41m  = cond(gp_ecart_Y_new==6&MigDeadY==2,birth_int_YS ,0)
replace birth_int_Yres_36_41m=1 if birth_int_YS==1 & gp_ecart_Y_new[_n+1]==6
label val birth_int_Yres_36_41m lbirth_int_YS

gen byte birth_int_Yres_42_47m  = cond(gp_ecart_Y_new==7&MigDeadY==2,birth_int_YS ,0)
replace birth_int_Yres_42_47m=1 if birth_int_YS==1 & gp_ecart_Y_new[_n+1]==7
label val birth_int_Yres_42_47m lbirth_int_YS

gen byte birth_int_Yres_48_more  = cond(gp_ecart_Y_new==8&MigDeadY==2,birth_int_YS ,0)
replace birth_int_Yres_48_more=1 if birth_int_YS==1 & gp_ecart_Y_new[_n+1]==8
label val birth_int_Yres_48_more lbirth_int_YS

capture drop gp_birth_int_YS
gen int gp_birth_int_YS= MigDeadY*1000 + birth_int_Yres_12m + ///
	cond(birth_int_Yres_12_17m==0,0,10+ birth_int_Yres_12_17m) + ///
	cond(birth_int_Yres_18_23m==0,0,20+ birth_int_Yres_18_23m) + ///
	cond(birth_int_Yres_24_29m==0,0,30+ birth_int_Yres_24_29m) + ///
	cond(birth_int_Yres_30_35m==0,0,40+ birth_int_Yres_30_35m) + ///
	cond(birth_int_Yres_36_41m==0,0,50+ birth_int_Yres_36_41m) + ///
	cond(birth_int_Yres_42_47m==0,0,60+ birth_int_Yres_42_47m) + ///
	cond(birth_int_Yres_48_more==0,0,70+ birth_int_Yres_48_more)

label define lgp_birth_int_YS ///
0 "NoYS"	///
1 "Int <12m - pregnant" ///	
11 "Int 12-17m - pregnant" ///	
21 "Int 18-23m - pregnant" ///	
31 "Int 24-29m - pregnant" ///	
41 "Int 30-35m - pregnant" ///	
51 "Int 36-41m - pregnant" ///	
61 "Int 42-47m - pregnant" ///
71 "Int >=48m + - pregnant" ///	
1000 "y sibling non-res" ///
2002 "Int <12m - 0-6m" ///	
2003 "Int <12m - 6-12m" ///	
2004 "Int <12m - 12m +" ///	
2012 "Int 12-17m - 0-6m" ///	
2013 "Int 12-17m - 6-12m" ///	
2014 "Int 12-17m - 12m +" ///	
2022 "Int 18-23m - 0-6m" ///	
2023 "Int 18-23m - 6-12m" ///	
2024 "Int 18-23m - 12m +" ///	
2032 "Int 24-29m - 0-6m" ///	
2033 "Int 24-29m - 6-12m" ///	
2034 "Int 24-29m - 12m +" ///	
2042 "Int 30-35m - 0-6m" ///	
2043 "Int 30-35m - 6-12m" ///	
2044 "Int 30-35m - 12m +" ///	
2052 "Int 36-41m - 0-6m" ///	
2053 "Int 36-41m - 6-12m" ///	
2054 "Int 36-41m - 12m +" ///	
2062 "Int 42-47m - 0-6m" ///	
2063 "Int 42-47m - 6-12m" ///	
2064 "Int 42-47m - 12m +" ///	
2072 "Int >=48m + - 0-6m" ///	
2073 "Int >=48m + - 6m +" ///	
2074 "Int >=48m + - 12m +" ///	
3000 "y sibling dead", modify	

label val gp_birth_int_YS lgp_birth_int_YS

recode gp_birth_int_YS (2074=2073)
* Same variable but with different coding order
recode gp_birth_int_YS ///
(0 =0 "NoYS"					) ///
(1 =1 "Int <12m - pregnant" 	) ///	
(11=11 "Int 12-17m - pregnant" 	) ///	
(21=21 "Int 18-23m - pregnant" 	) ///	
(31=31 "Int 24-29m - pregnant" 	) ///	
(41=41 "Int 30-35m - pregnant" 	) ///	
(51=51 "Int 36-41m - pregnant" 	) ///	
(61=61 "Int 42-47m - pregnant" 	) ///
(71=71 "Int >=48m+ - pregnant" ) ///	
(1000=100 "y sibling non-res" 	) ///
(2002=200 "Int <12m - 0-6m" 	) ///	
(2003=300 "Int <12m - 6-12m" 	) ///	
(2004=400 "Int <12m - 12m+" 	) ///	
(2012=210 "Int 12-17m - 0-6m" 	) ///	
(2013=310 "Int 12-17m - 6-12m" 	) ///	
(2014=410 "Int 12-17m - 12m+" 	) ///	
(2022=220 "Int 18-23m - 0-6m" 	) ///	
(2023=320 "Int 18-23m - 6-12m" 	) ///	
(2024=420 "Int 18-23m - 12m+" 	) ///	
(2032=230 "Int 24-29m - 0-6m" 	) ///	
(2033=330 "Int 24-29m - 6-12m" 	) ///	
(2034=430 "Int 24-29m - 12m+" 	) ///	
(2042=240 "Int 30-35m - 0-6m" 	) ///	
(2043=340 "Int 30-35m - 6-12m" 	) ///	
(2044=440 "Int 30-35m - 12m+" 	) ///	
(2052=250 "Int 36-41m - 0-6m" 	) ///	
(2053=350 "Int 36-41m - 6-12m" 	) ///	
(2054=450 "Int 36-41m - 12m+"	) ///	
(2062=260 "Int 42-47m - 0-6m" 	) ///	
(2063=360 "Int 42-47m - 6-12m" 	) ///	
(2064=460 "Int 42-47m - 12m+" 	) ///	
(2072=270 "Int >=48m+ - 0-6m" 	) ///	
(2073=270 "Int >=48m+ - 6m+" 	) ///	
(3000=500 "y sibling dead"		), gen(birth_int_gp_YS)	
 
capture drop pregnant_YS
gen byte pregnant_YS = (birth_int_YS==1)
lab define pregnant 1 "3-9m pregnant" 0 "No this period"
label val pregnant_YS pregnant

capture drop twin
gen byte twin = (TwinId!="")
label define twin 1 "Yes" 0 "No"
label val twin twin

* Setting mortality analysis <5-year-old 
stset EventDate if residence==1, id(concat_IndividualId) failure(censor_death==1) ///
		time0(datebeg) origin(time DoB) exit(time DoB+(31557600000*5)+212000000) scale(31557600000)
/*
    562,349  subjects
     40,667  failures in single-failure-per-subject data
  1,765,541  total analysis time at risk and under observation
*/
compress
keep if _st==1
*Suprimer les cas où la variable Sex est une valeur manquante.
drop if Sex==9 /*Tous ces enfants viennent de Niakhar*/

*Vérifications et corrections
/*
foreach var of varlist MigDeadMO Sex y3_mother_age_birth migrant_statusMO MO_DTH_TVC MigDeadO gp_ecart_Ores ///
                       MigDeadY  birth_int_Yres_12m birth_int_Yres_12_17m ///
                       birth_int_Yres_18_23m birth_int_Yres_24_29m birth_int_Yres_30_35m birth_int_Yres_36_41m ///
                       birth_int_Yres_42_47m birth_int_Yres_48_more twin period {
					   
					   tab `var' [iw=_t-_t0], miss
					   }
*/
foreach var of varlist birth_int_Yres_12m birth_int_Yres_12_17m  ///
                       birth_int_Yres_18_23m birth_int_Yres_24_29m birth_int_Yres_30_35m birth_int_Yres_36_41m ///
                       birth_int_Yres_42_47m birth_int_Yres_48_more migrant_statusMO {
					   
					   replace `var' = 0 if `var'==.
					   }

capture drop MigDeadMO_MO_DTH_TVC
gen MigDeadMO_MO_DTH_TVC=	cond(MigDeadMO==2 & MO_DTH_TVC==0,0, cond(MigDeadMO==1 & MO_DTH_TVC==0,1, ///
							cond(MO_DTH_TVC==1,2, cond(MO_DTH_TVC==2,3, cond(MO_DTH_TVC==3,4, ///
							cond(MO_DTH_TVC==4,5, cond(MO_DTH_TVC==5,6, 7)))))))
label define lMigDeadMO_MO_DTH_TVC 0 "mother resident" 	1 "mother non resident" ///
						2 "-6m to -3m mother's death" 	3 "-3m to -15d mother's death" ///
						4 "+/- 15d mother's death" 		5 "15d to 3m mother's death" ///
						6 "+3m to +6m mother's death" 	7 "6m+ mother's death", modify
label val MigDeadMO_MO_DTH_TVC lMigDeadMO_MO_DTH_TVC

capture drop MigDeadO_O_DTH_TVC
gen MigDeadO_O_DTH_TVC=	cond(MigDeadO==2 & O_DTH_TVC==0,0, cond(MigDeadO==1 & O_DTH_TVC==0,1, ///
							cond(O_DTH_TVC==1,2, cond(O_DTH_TVC==2,3, cond(O_DTH_TVC==3,4, ///
							cond(O_DTH_TVC==4,5, cond(O_DTH_TVC==5,6, 7)))))))
replace MigDeadO_O_DTH_TVC=9 if MigDeadO==0
label define lMigDeadO_O_DTH_TVC 0 "O sib resident" 	1 "O sib non resident" ///
						2 "-6m to -3m O sib's death" 	3 "-3m to -15d O sib's death" ///
						4 "+/- 15d O sib's death" 		5 "15d to 3m O sib's death" ///
						6 "+3m to +6m O sib's death" 	7 "6m+ O sib's death" ///
						9 "no O sib", modify
label val MigDeadO_O_DTH_TVC lMigDeadO_O_DTH_TVC

capture drop MigDeadY_Y_DTH_TVC
gen MigDeadY_Y_DTH_TVC=	cond(MigDeadY==2 & Y_DTH_TVC==0,0, cond(MigDeadY==1 & Y_DTH_TVC==0,1, ///
							cond(Y_DTH_TVC==1,2, cond(Y_DTH_TVC==2,3, cond(Y_DTH_TVC==3,4, ///
							cond(Y_DTH_TVC==4,5, cond(Y_DTH_TVC==5,6, 7)))))))
replace MigDeadY_Y_DTH_TVC=9 if MigDeadY==0
label define lMigDeadY_Y_DTH_TVC 0 "Y sib resident" 	1 "Y sib non resident" ///
						2 "-6m to -3m Y sib's death" 	3 "-3m to -15d Y sib's death" ///
						4 "+/- 15d Y sib's death" 		5 "15d to 3m Y sib's death" ///
						6 "+3m to +6m Y sib's death" 	7 "6m+ Y sib's death" ///
						9 "no Y sib", modify
label val MigDeadY_Y_DTH_TVC lMigDeadY_Y_DTH_TVC

capture drop MigDeadTwin_Twin_DTH_TVC
gen MigDeadTwin_Twin_DTH_TVC=	cond(MigDeadTwin==2 & Twin_DTH_TVC==0,0, cond(MigDeadTwin==1 & Twin_DTH_TVC==0,1, ///
							cond(Twin_DTH_TVC==1,2, cond(Twin_DTH_TVC==2,3, cond(Twin_DTH_TVC==3,4, ///
							cond(Twin_DTH_TVC==4,5, cond(Twin_DTH_TVC==5,6, 7)))))))
replace MigDeadTwin_Twin_DTH_TVC=9 if MigDeadTwin==0
label define lMigDeadTwin_Twin_DTH_TVC 0 "Twin resident" 	1 "Twin non resident" ///
						2 "-6m to -3m Twin's death" 	3 "-3m to -15d Twin's death" ///
						4 "+/- 15d Twin's death" 		5 "15d to 3m Twin's death" ///
						6 "+3m to +6m Twin's death" 	7 "6m+ Twin's death" ///
						9 "no Twin", modify
label val MigDeadTwin_Twin_DTH_TVC lMigDeadTwin_Twin_DTH_TVC

recode birth_int_Yres_48_more (4=3)
label define lbirth_int_Yres_48_more 1 "pregnant_YS" 2 "0-6m" 3 "6m +", modify
label val birth_int_Yres_48_more lbirth_int_Yres_48_more

gen byte res_O_DTH_TVC= cond(MigDeadO<2,0, O_DTH_TVC)
lab val res_O_DTH_TVC DTH_TVC 

gen byte res_Y_DTH_TVC= cond(MigDeadY<2,0, Y_DTH_TVC)
lab val res_Y_DTH_TVC DTH_TVC 

gen byte res_Twin_DTH_TVC= cond(MigDeadTwin<2,0, Twin_DTH_TVC)
lab val res_Twin_DTH_TVC DTH_TVC 


gen byte MigDeadO_interv= MigDeadO*10 + gp_ecart_O_new*(MigDeadO==2) 
label def lMigDeadO_interv 0 "No Old sib" 10 "O sib non resident" 21 "O int <12m" ///
		22 "O int 12-17m" 23 "O int 18-23m" 24 "O int 24-29m" 25 "O int 30-35m" ///
		26 "O int 36-41m" 27 "O int 42-47m" 28 "O int 48m +" 30 "O sib dead", modify
lab val MigDeadO_interv lMigDeadO_interv
* Only in model -with both MigDeadO_interv and res_O_DTH_TVC
* 				-with 24 used as reference category 
recode MigDeadO_interv 30=24 // recode dead in the Ref category "O int 24-29m"

* Same with younger sibling:
* Only in model -with both birth_int_gp_YS and res_Y_DTH_TVC
* 				-with 24 used as reference category 
recode birth_int_gp_YS 500=230 // recode dead in the Ref category "Int 24-29m - 0-6m"
 
note: After computing all time-varying covariates
save analysis_final, replace

use analysis_final,clear
/*
log using tables_verif,replace
table MigDeadY birth_int_Yres_12m 		[iw=_t-_t0], content(freq) format(%10.0f) missing
table MigDeadY birth_int_Yres_12_17m 	[iw=_t-_t0], content(freq) format(%10.0f) missing
table MigDeadY birth_int_Yres_18_23m 	[iw=_t-_t0], content(freq) format(%10.0f) missing
table MigDeadY birth_int_Yres_24_29m 	[iw=_t-_t0], content(freq) format(%10.0f) missing
table MigDeadY birth_int_Yres_30_35m 	[iw=_t-_t0], content(freq) format(%10.0f) missing
table MigDeadY birth_int_Yres_36_41m 	[iw=_t-_t0], content(freq) format(%10.0f) missing
table MigDeadY birth_int_Yres_42_47m 	[iw=_t-_t0], content(freq) format(%10.0f) missing
table MigDeadY birth_int_Yres_48_more 	[iw=_t-_t0], content(freq) format(%10.0f) missing
table MigDeadMO migrant_statusMO 		[iw=_t-_t0], content(freq) format(%10.0f) missing
table MigDeadMO MO_DTH_TVC 				[iw=_t-_t0], content(freq) format(%10.0f) missing
table MigDeadY Y_DTH_TVC 				[iw=_t-_t0], content(freq) format(%10.0f) missing
table MigDeadO O_DTH_TVC 				[iw=_t-_t0], content(freq) format(%10.0f) missing
log close

* To detect some very few inconsistencies due to same date of events
sort concat_IndividualId EventDate
qui bys concat_IndividualId (EventDate): gen foll_MigDeadMO=MigDeadMO[_n+1]
lab var foll_MigDeadMO "Following event"
lab val foll_MigDeadMO MigDeadMO
tab MigDeadMO foll_MigDeadMO, missing
browse concat_IndividualId DoB EventDate MotherId MigDeadMO if foll_MigDeadMO<3 & MigDeadMO==3
browse  DoB EventDate MotherId MigDeadMO if concat_IndividualId=="288GH03169729"

qui bys concat_IndividualId (EventDate): gen foll_MigDeadO=MigDeadO[_n+1]
lab var foll_MigDeadO "Following event"
lab val foll_MigDeadO MigDeadO
tab MigDeadO foll_MigDeadO, missing

qui bys concat_IndividualId (EventDate): gen foll_MigDeadY=MigDeadY[_n+1]
lab var foll_MigDeadY "Following event"
lab val foll_MigDeadY MigDeadY
tab MigDeadY foll_MigDeadY, missing
*/

tab CentreId if lastrecord==1 
/* children
  11,344  BF021  Nanoro 
  42,290  BF031  Nouna	
  15,938  BF041  Ouagadougou  
  11,041  CI011  Taabo
  17,851  ET021  Gilgel Gibe   
   7,350  ET031  Kilite Awlaelo   
  19,469  ET041  Kersa
   2,999  ET042  Harar Urban
   7,586  ET051  Dabat  
  10,818  ET061  Arba Minch   
  38,606  GH011  Navrongo HDSS 
  32,885  GH021  Kintampo HDSS 
  14,884  GH031  Dodowa 
  27,912  GM011  Farafenni HDSS  
  23,078  KE031  Nairobi  
		  KE041  Mbita (missing IMG)
   7,708  KE051  Kombewa
   7,112  MW011  Karonga   
  14,146  MZ021  Chokwe  HDSS 
  23,075  NG011  Nahuche
  13,538  SN011  Bandafassi   
   5,036  SN012  IRD Mlomp
  37,080  SN013  IRD Niakhar 
  47,133  TZ011  IHI Ifakara Rural
  33,867  TZ012  IHI Rufiji  
  13,993  TZ021  Magu 
  18,364  UG011  Iganga/Mayuge
  44,757  ZA011  Agincourt 
   6,402  ZA021  Dikgale
  26,879  ZA031  Africa Centre   
------------+-----------------------------------
 583,145  total
*/

/* Without birth intervals, for ERC proposal
log using model_ERC_080818,replace
stcox ib2.MigDeadMO ib2.MigDeadO i.Sex ib21.y3_mother_age_birth ib0.migrant_statusMO ///
        ib2.MigDeadY  ib0.twin i.period, vce(cluster MotherId)
estimates store model_ERC_090818
matrix list e(b)

coefplot, yline(1) eform levels(95) ///
		keep(1.MigDeadMO  3.MigDeadMO ///
			0.MigDeadO 1.MigDeadO  3.MigDeadO  0.MigDeadY 1.MigDeadY  3.MigDeadY) ///
		mlabel format(%9.2f) mlabposition(12) mlabgap(*2) xlabel(, angle(vertical)) ///
		coeflabels(1.MigDeadMO = "non resident" 3.MigDeadMO ="dead" ///
				0.MigDeadO ="none" 1.MigDeadO="non resident" 3.MigDeadO="dead" ///
				0.MigDeadY ="none" 1.MigDeadY="non resident" 3.MigDeadY="dead", ///
				notick labsize(small) labcolor(purple) labgap(2)) ///
		vertical ///
		groups(1.MigDeadMO 3.MigDeadMO = "{bf:Mother}" 0.MigDeadO 1.MigDeadO 3.MigDeadO = "{bf:Older sibling}" ///
				0.MigDeadY 1.MigDeadY 3.MigDeadY = "{bf:Younger sibling}") 
log close
*/
tab CentreId if censor_death==1 & _st==1
/* Under-5 Deaths
   CentreId |      Freq.     Percent        Cum.
------------+-----------------------------------
      BF021 |        471        1.15        1.15
      BF031 |      3,748        9.14       10.28
      BF041 |        523        1.27       11.56
      CI011 |        792        1.93       13.49
      ET021 |      1,357        3.31       16.80
      ET031 |        227        0.55       17.35
      ET041 |      1,597        3.89       21.24
      ET042 |         31        0.08       21.32
      ET051 |        187        0.46       21.78
      ET061 |        327        0.80       22.57
      GH011 |      3,868        9.43       32.00
      GH021 |      1,540        3.75       35.76
      GH031 |        348        0.85       36.60
      GM011 |      2,051        5.00       41.60
      KE031 |      1,373        3.35       44.95
      KE051 |        274        0.67       45.62
      MW011 |        384        0.93       46.14
      MZ021 |        589        1.42       47.56
      NG011 |      3,608        8.72       56.28
      SN011 |      2,129        5.14       61.42
      SN012 |        315        0.76       62.18
      SN013 |      3,844        9.29       71.47
      TZ011 |      3,767        9.10       80.57
      TZ012 |      2,310        5.58       86.15
      TZ021 |      1,207        2.92       89.07
      UG011 |      1,159        2.80       91.87
      ZA011 |      1,949        4.71       96.57
      ZA021 |         99        0.24       96.81
      ZA031 |      1,319        3.19      100.00
------------+-----------------------------------
      Total |     41,393      100.00
*/
table CentreId [iw=_t-_t0], content(freq) format(%10.0f) missing row
/* Under-5 PYAR
 CentreId |      Freq.
----------+-----------
    BF021 |      27214
    BF031 |     143028
    BF041 |      45801
    CI011 |      30842
    ET021 |      59422
    ET031 |      17337
    ET041 |      55566
    ET042 |       4980
    ET051 |      22576
    ET061 |      27665
    GH011 |     141480
    GH021 |      97319
    GH031 |      35344
    GM011 |     101835
    KE031 |      60304
    KE051 |      17088
    MW011 |      23676
    MZ021 |      32502
    NG011 |      46344
    SN011 |      50943
    SN012 |      18380
    SN013 |     136814
    TZ011 |     146875
    TZ012 |     114288
    TZ021 |      42518
    UG011 |      56443
    ZA011 |     159776
    ZA021 |      22647
    ZA031 |     100270
          | 
    Total |    1839284
*/
table MigDeadY gp_ecart_Y [iw=_t-_t0], content(freq) format(%10.0f) missing
table MigDeadO gp_ecart_O [iw=_t-_t0], content(freq) format(%10.0f) missing
* To get "No Older Sibling" as the baseline when including both MigDeadO ib0.gp_ecart_Ores in the model
cap drop MigDeadObis
recode MigDeadO (2=0), gen(MigDeadObis)
lab val MigDeadObis MigDeadO
tab MigDeadObis gp_ecart_Ores_new 
table MigDeadY_Y_DTH_TVC gp_birth_int_YS [iw=_t-_t0], content(freq) format(%10.0f) missing
table MigDeadO_O_DTH_TVC gp_ecart_O [iw=_t-_t0], content(freq) format(%10.0f) missing

merge m:1 CentreId using site_chara_w
capture drop _merge
/*replace rain=rain*1000
replace travel=travel*60
replace PREC_NEW=PREC_NEW*1000
replace precavnew8008=precavnew8008*1000
*/
lab var rain            "Precipitation liter/m2"
lab var night           "Night light intensity"
lab var travel          "hour travel city>50k"
lab var elevation       "D3"
lab var elevation_SD    "D4"
lab var PREC_NEW        "Precipitation liter/m2"
lab var PRECMAX         "Max Precipitation liter/m2"
lab var PRECMIN         "Min Precipitation liter/m2"
lab var PRECSD          "St Dev Precipitation liter/m2"
lab var TEMP_NEW        "Temperature celsius"
lab var TEMPMAX         "Max Temperature celsius"
lab var TEMPMIN         "Min Temperature celsius"
lab var TEMPSD          "St Dev Temperature celsius"
lab var tempav_8008     "Average celsius 1980-2008"
lab var tempsd_8008     "St Dev Average celsius 1980-2008"
lab var precavnew8008   "Precipitation liter/m2"
lab var precsdnew8008   "St Dev Precipitation liter/m2"
lab var period          "5-year period"
save, replace
preserve

use site_chara_l
lab var vacc            "DPT % coverage (p10%)"
lab var hiv             "% female 15-49 HIV positive"
lab var edu             "% female 15-49 educated"
lab var gdp_ppp_        "GDP PPP in 1000US$"
lab var gdp_marketexr_  "GDP market exch rate in 1000US$"
save, replace

restore
merge m:1 CentreId period using site_chara_l
keep if _merge==3
replace vacc=vacc*10
drop _merge

merge m:1 CentreId using urbanicity
keep if _merge==3
drop _merge
sort concat_IndividualId EventDate EventCode
save, replace

gen p1000censor_death=censor_death*1000
table birth_int_gp_YS MigDeadY_Y_DTH_TVC  [iw=_t-_t0], content(freq) format(%10.0f) missing
table birth_int_gp_YS MigDeadY_Y_DTH_TVC  [iw=_t-_t0], content(mean p1000censor_death) missing
table gp_ecart_Ores_new  MigDeadO_O_DTH_TVC [iw=_t-_t0], content(freq) format(%10.0f) missing
table gp_ecart_Ores_new  MigDeadO_O_DTH_TVC [iw=_t-_t0], content(mean p1000censor_death) missing
table res_Twin_DTH_TVC  [iw=_t-_t0], content(freq) format(%10.0f) missing
table res_Twin_DTH_TVC  [iw=_t-_t0], content(mean p1000censor_death) missing
table period [iw=_t-_t0], content(mean rain mean PREC_NEW mean TEMP_NEW)  missing
/*
   period |     mean(rain)  mean(PREC_NEW)  mean(TEMP_NEW)
----------+-----------------------------------------------
     1990 |       658.4963        877.2901        26.79589
     1995 |       812.0327        939.6726        25.76668
     2000 |       901.4801        1026.887        25.46796
     2005 |        940.505        1082.506        24.76947
     2010 |       996.9833        1064.584        24.48016
     2015 |       969.3855         976.555        23.34827
*/
table period [iw=_t-_t0], content(mean travel mean vacc mean edu mean hiv mean gdp_ppp_)  missing
/*
   period | mean(travel)    mean(vacc)     mean(edu)     mean(hiv)  mean(gdp_~_)
----------+---------------------------------------------------------------------
     1990 |     144.5116             .             .             .      .6165305
     1995 |     174.1794             .             .             .     .57485906
     2000 |     209.6926      8.874839       3.39524      6.264101     .58444086
     2005 |     230.3512      8.947402      4.189189      6.477051     .90230432
     2010 |      258.483      8.322821      3.824535      5.194046             .
     2015 |      268.872      8.339012      4.841929      7.656536             .
*/
egen Centre_period=group(CentreLab period), label
tab Centre_period [iw=_t-_t0]
recode Centre_period (35 36 37=38)
save, replace

* Extract indicator of Older sibling death (including before index child birth)
use osibling.dta, clear
keep if OsiblingId!=""
bysort concat_IndividualId (EventDate): egen byte everDeadO =max(EventCodeO==7) 
keep concat_IndividualId everDeadO
duplicates drop
save everDeadO, replace
use analysis_final,clear
merge m:1 concat_IndividualId using everDeadO.dta
drop if _merge==2
drop _merge
recode everDeadO (.=0)
capture drop DeadOafterDoB
bysort concat_IndividualId (EventDate): egen byte DeadOafterDoB =max(res_O_DTH_TVC!=0) 
capture drop DeadObeforeDoB
gen byte DeadObeforeDoB=everDeadO==1 & DeadOafterDoB==0 & MigDeadO!=1

compress
save analysis_final, replace

cd "C:\Users\bocquier\Documents\INDEPTH\MADIMAH\MADIMAH 3 Child Mig\2018 analysis\"
log using session06-07-2019, replace
use analysis_final,clear
* To mimick Molitoris et al (2019) for <1 without/with younger sibling and no twin
stset EventDate if residence==1, id(concat_IndividualId) failure(censor_death==1) ///
		time0(datebeg) origin(time DoB) exit(time DoB+31557600000+106000000) scale(31557600000)
stcox 	i.Sex ib75.Centre_period ///
		ib21.y3_mother_age_birth ib0.MigDeadMO_MO_DTH_TVC ib0.migrant_statusMO ///
		/* ib0.MigDeadTwin_Twin_DTH_TVC */ ///
		DeadObeforeDoB ib24.MigDeadO_int ib0.res_O_DTH_TVC ///
        /* ib230.birth_int_gp_YS ib0.res_Y_DTH_TVC */ ///
		if MigDeadTwin_Twin_DTH_TVC==9 ///
		, vce(cluster MotherId) iter(10) 
outreg2 using Analyses_under1_noY, replace word stats(coef) ///
	bdec(2) nor2 eform ///
	addstat(Wald Chi-square, e(chi2), Log Lik, e(ll), Subjects, e(N_sub), Time at risk, ///
	e(risk), Failures, e(N_fail)) 
outreg2 using Analyses_under1_noY, word stats(se) ///
	sdec(2) nor2 eform
outreg2 using Analyses_under1_noY, word stats(pval) ///
	pdec(3) nor2 eform
outreg2 using Analyses_under1_noY, word stats(ci_low) ///
	cdec(2) nor2 eform  		
outreg2 using Analyses_under1_noY, word stats(ci_high) ///
	cdec(2) nor2 eform  	
* Same with	twins and younger sibling
* Simple codes for younger sibling (because <1 year)
stcox 	i.Sex ib75.Centre_period ///
		ib21.y3_mother_age_birth ib0.MigDeadMO_MO_DTH_TVC ib0.migrant_statusMO ///
		ib0.MigDeadTwin_Twin_DTH_TVC ///
		DeadObeforeDoB ib24.MigDeadO_int ib0.res_O_DTH_TVC ///
        ib0.MigDeadY ib0.birth_int_YS ///
		, vce(cluster MotherId) iter(10) 
outreg2 using Analyses_under1_Y, replace word stats(coef) ///
	bdec(2) nor2 eform ///
	addstat(Wald Chi-square, e(chi2), Log Lik, e(ll), Subjects, e(N_sub), Time at risk, ///
	e(risk), Failures, e(N_fail)) 
outreg2 using Analyses_under1_Y, word stats(se) ///
	sdec(2) nor2 eform
outreg2 using Analyses_under1_Y, word stats(pval) ///
	pdec(3) nor2 eform
outreg2 using Analyses_under1_Y, word stats(ci_low) ///
	cdec(2) nor2 eform  		
outreg2 using Analyses_under1_Y, word stats(ci_high) ///
	cdec(2) nor2 eform  	
	
*To mimick Molitoris et al (2019) for 1-4 without/with younger sibling and no twin
stset EventDate if residence==1, id(concat_IndividualId) failure(censor_death==1) ///
		time0(datebeg) origin(time DoB+31557600000+106000000) ///
		exit(time DoB+(5*31557600000)+212000000) scale(31557600000)
stcox 	i.Sex ib75.Centre_period ///
		ib21.y3_mother_age_birth ib0.MigDeadMO_MO_DTH_TVC ib0.migrant_statusMO ///
		/* ib0.MigDeadTwin_Twin_DTH_TVC */ ///
		DeadObeforeDoB ib24.MigDeadO_int ib0.res_O_DTH_TVC ///
        /* ib230.birth_int_gp_YS ib0.res_Y_DTH_TVC */ ///
		if MigDeadTwin_Twin_DTH_TVC==9 ///
		, vce(cluster MotherId) iter(10) 
outreg2 using Analyses_1-4_noY, replace word stats(coef) ///
	bdec(2) nor2 eform ///
	addstat(Wald Chi-square, e(chi2), Log Lik, e(ll), Subjects, e(N_sub), Time at risk, ///
	e(risk), Failures, e(N_fail)) 
outreg2 using Analyses_1-4_noY, word stats(se) ///
	sdec(2) nor2 eform
outreg2 using Analyses_1-4_noY, word stats(pval) ///
	pdec(3) nor2 eform
outreg2 using Analyses_1-4_noY, word stats(ci_low) ///
	cdec(2) nor2 eform  		
outreg2 using Analyses_1-4_noY, word stats(ci_high) ///
	cdec(2) nor2 eform  	
	
* Same with	twins and younger sibling
stcox 	i.Sex ib75.Centre_period ///
		ib21.y3_mother_age_birth ib0.MigDeadMO_MO_DTH_TVC ib0.migrant_statusMO ///
		ib0.MigDeadTwin_Twin_DTH_TVC ///
		DeadObeforeDoB ib24.MigDeadO_int ib0.res_O_DTH_TVC ///
        ib230.birth_int_gp_YS ib0.res_Y_DTH_TVC ///
		, vce(cluster MotherId) iter(10) 
outreg2 using Analyses_1-4_Y, replace word stats(coef) ///
	bdec(2) nor2 eform ///
	addstat(Wald Chi-square, e(chi2), Log Lik, e(ll), Subjects, e(N_sub), Time at risk, ///
	e(risk), Failures, e(N_fail)) 
outreg2 using Analyses_1-4_Y, word stats(se) ///
	sdec(2) nor2 eform
outreg2 using Analyses_1-4_Y, word stats(pval) ///
	pdec(3) nor2 eform
outreg2 using Analyses_1-4_Y, word stats(ci_low) ///
	cdec(2) nor2 eform  		
outreg2 using Analyses_1-4_Y, word stats(ci_high) ///
	cdec(2) nor2 eform  	
	
stset EventDate if residence==1, id(concat_IndividualId) failure(censor_death==1) ///
		time0(datebeg) origin(time DoB) scale(31557600000)
/*  583,145  subjects
     41,393  failures in single-failure-per-subject data
  1,819,653  total analysis time at risk and under observation
*/
* To mimick Molitoris et al (2019) for <5 without/with younger sibling and no twin
stcox 	i.Sex ib75.Centre_period ///
		ib21.y3_mother_age_birth ib0.MigDeadMO_MO_DTH_TVC ib0.migrant_statusMO ///
		/* ib0.MigDeadTwin_Twin_DTH_TVC */ ///
		DeadObeforeDoB ib24.MigDeadO_int ib0.res_O_DTH_TVC ///
        /* ib230.birth_int_gp_YS ib0.res_Y_DTH_TVC */ ///
		if MigDeadTwin_Twin_DTH_TVC==9 ///
		, vce(cluster MotherId) iter(10) 
outreg2 using Analyses_under5_noY, replace word stats(coef) ///
	bdec(2) nor2 eform ///
	addstat(Wald Chi-square, e(chi2), Log Lik, e(ll), Subjects, e(N_sub), Time at risk, ///
	e(risk), Failures, e(N_fail)) 
outreg2 using Analyses_under5_noY, word stats(se) ///
	sdec(2) nor2 eform
outreg2 using Analyses_under5_noY, word stats(pval) ///
	pdec(3) nor2 eform
outreg2 using Analyses_under5_noY, word stats(ci_low) ///
	cdec(2) nor2 eform  		
outreg2 using Analyses_under5_noY, word stats(ci_high) ///
	cdec(2) nor2 eform  	

* Full model for under5
* Basic model without macro, but with Centre*period "fixed effect"
stcox 	i.Sex ib75.Centre_period ///
		ib21.y3_mother_age_birth ib0.MigDeadMO_MO_DTH_TVC ib0.migrant_statusMO ///
		ib0.MigDeadTwin_Twin_DTH_TVC ///
		DeadObeforeDoB ib24.MigDeadO_int ib0.res_O_DTH_TVC ///
        ib230.birth_int_gp_YS ib0.res_Y_DTH_TVC ///
		, vce(cluster MotherId) iter(10) 
outreg2 using Analyses_under5, replace word stats(coef) ///
	bdec(2) nor2 eform ///
	addstat(Wald Chi-square, e(chi2), Log Lik, e(ll), Subjects, e(N_sub), Time at risk, ///
	e(risk), Failures, e(N_fail)) 
outreg2 using Analyses_under5, word stats(se) ///
	sdec(2) nor2 eform
outreg2 using Analyses_under5, word stats(pval) ///
	pdec(3) nor2 eform
outreg2 using Analyses_under5, word stats(ci_low) ///
	cdec(2) nor2 eform  		
outreg2 using Analyses_under5, word stats(ci_high) ///
	cdec(2) nor2 eform  		
log close

stcurve, hazard yscale(log) kernel(rectangle) width(.08333)  ///
        at(Sex=1 period=2000 y3_mother_age_birth=21 MigDeadMO_MO_DTH_TVC=0 migrant_statusMO=0 ///
		MigDeadTwin_Twin_DTH_TVC=9 ///
		MigDeadO_int=24 res_O_DTH_TVC=0 ///
		birth_int_gp_YS=230 res_Y_DTH_TVC=0 ///
		res_Y_DTH_TVC=0 CentreLab=22) outfile(baseline_curve, replace)

predict cs, csnell
sts generate km = s
generate H = -ln(km)
line H cs cs, sort ytitle("") clstyle(. refline) sav(coxsnell, replace)

predict mg, mgale
lowess mg _t, mean noweight title("") note("") m(o) sav(mgaleresid, replace)

predict dev, deviance
predict xb, xb
scatter dev xb, sav(deviance_xb, replace)

predict ld, ldisplace
predict lmax, lmax
scatter ld _t, mlabel(obs) sav(lldispl, replace)

* Neyman-Pearson acceptance test (a posteriori)
* prob event: 40,650 / 561,438  = .07240336
* compute standard deviation using age at death or censoring (last observation)
capture drop last_age
capture drop cum_time
capture drop last_obs
bysort concat_IndividualId (_t): egen double last_age=max(_t) if _st==1
bysort concat_IndividualId (_t): egen double cum_time=sum(_t-_t0) if _st==1
bysort concat_IndividualId (_t): gen double last_obs=last_age==_t if _st==1
summ _d  [iw=cum_time] if last_obs==1
* Event prob (weighted by person-years of exposure): .0230845 (against .07240336 unweighted) 
foreach variable of varlist Sex ///
		y3_mother_age_birth MigDeadMO_MO_DTH_TVC migrant_statusMO ///
		MigDeadTwin_Twin_DTH_TVC ///
		MigDeadO_int res_O_DTH_TVC ///
        birth_int_gp_YS res_Y_DTH_TVC ///
		{
			display "`variable' MDES for level..."
			quietly levelsof `variable', local(i)
			foreach level of local i {
				quietly gen dummy`level'=`variable'==`level'
				quietly summ dummy`level'  [iw=_t-_t0] 
				local sd = r(sd)
				drop dummy*
				quietly power cox, n(561438) power(0.95) alpha(0.05) eventprob(.0230845) r2(.2) ///
					sd(`sd') effect(hratio) direction(upper) onesided
				display "`level': >" %5.2f r(delta) " or : <" %5.2f 1/r(delta)
			}
}

quietly levelsof period, local(i)
quietly levelsof CentreLab, local(j)
foreach centre of local j {
	foreach per of local i {
		quietly gen dummy`per'_`centre'=period==`per' & CentreLab==`centre'
		quietly summ dummy`per'_`centre' [iw=_t-_t0] 
		local sd = r(sd)
		drop dummy*
		if `sd'>0 { 
			quietly power cox, n(561438) power(0.95) alpha(0.05) eventprob(.0234952) r2(.2) ///
				sd(`sd') effect(hratio) direction(upper) onesided 
			display "MDES for period : " `per' " and Centre : " `centre' " >" %6.2f r(delta) " or : <" %4.2f 1/r(delta)
		}
	}
}

** Checks 
**Graphiques
* sex + twin + period 

coefplot, xline(1) eform xtitle(Hazards Ratio) levels(95) ///
		keep(2.Sex 1.twin 1994.period 1999.period 2004.period 2009.period) ///
		mlabel format(%9.2f) mlabposition(12) mlabgap(*1) ///
		coeflabels(2.Sex="Female" 1.twin="Yes" ///
				1994.period="1994" 1999.period="1999" 2004.period="2004" 2009.period="2009" ///
				,notick labsize(small) labcolor(purple) labgap(2)) ///
		headings(2.Sex=`""{bf:Gender}" "Ref : Male""' 1.twin=`""{bf:Multiple birth}" "Ref : No ""' ///
				1994.period=`""{bf:Period}" "Ref : 1989""', labcolor(blue)) ///
		xlabel(0.5 1 2 4, format(%9.2f)) xscale(log range(0.5 5)) baselevels
graph save graph_sex_twin_period,replace

***2. relative to mother
coefplot, xline(1) eform xtitle(Hazards Ratio) levels(95) ///
		keep(15.y3_mother_age_birth 18.y3_mother_age_birth ///
			 24.y3_mother_age_birth 27.y3_mother_age_birth 30.y3_mother_age_birth ///
			 33.y3_mother_age_birth 36.y3_mother_age_birth 39.y3_mother_age_birth ///
			 42.y3_mother_age_birth ///
			 1.MigDeadMO_MO_DTH_TVC ///
			 1.migrant_statusMO 2.migrant_statusMO ) ///
		mlabel format(%9.2f) mlabposition(12) mlabgap(*1) ///
		coeflabels(15.y3_mother_age_birth="15-17" 18.y3_mother_age_birth="18-21" ///
				24.y3_mother_age_birth="24-26" 27.y3_mother_age_birth="27-29" ///
				30.y3_mother_age_birth="30-32" 33.y3_mother_age_birth="33-35" ///
				36.y3_mother_age_birth="36-38" 39.y3_mother_age_birth="39-41" ///
				42.y3_mother_age_birth="42+" ///
				1.MigDeadMO_MO_DTH_TVC="Non-resident" ///
				1.migrant_statusMO="0-24 months" 2.migrant_statusMO="2-5 years" ///
				, notick labsize(small) labcolor(purple) labgap(2)) ///
		headings(15.y3_mother_age_birth=`""{bf: Mother´s age at birth}" "Ref: 21-23 years""' ///
				1.MigDeadMO_MO_DTH_TVC=`""{bf: Mother out-migration status}" "Ref: Permanent resident""'  ///
				1.migrant_statusMO=`""{bf:Mother in-migration status}" "Ref: Permanent resident" "or resident 10+"""', labcolor(blue)) ///
		xlabel(0.5 1 2, format(%9.1f)) xscale(log range(0.5 2)) baselevels
graph save graph_mother_1,replace

coefplot, xline(1) eform xtitle(Hazards Ratio) levels(95) ///
		keep(2.MigDeadMO_MO_DTH_TVC ///
			 3.MigDeadMO_MO_DTH_TVC 4.MigDeadMO_MO_DTH_TVC 5.MigDeadMO_MO_DTH_TVC ///
			 6.MigDeadMO_MO_DTH_TVC ) ///
		mlabel format(%9.1f) mlabposition(12) mlabgap(*1) ///
		coeflabels(2.MigDeadMO_MO_DTH_TVC="6-3m < death" ///
			3.MigDeadMO_MO_DTH_TVC="3m-15d < death" 4.MigDeadMO_MO_DTH_TVC="+/-15d death" ///
			5.MigDeadMO_MO_DTH_TVC="15d-3m > death" ///
			6.MigDeadMO_MO_DTH_TVC="3-6m > death"  ///
			,notick labsize(small) labcolor(purple) labgap(2)) ///
		headings(2.MigDeadMO_MO_DTH_TVC=`""{bf: Mother death status}" "Ref: Permanent resident""' , labcolor(blue)) ///
		xlabel(1 2 5 10 20, format(%9.0f)) xscale(log range(1 20)) baselevels
graph save graph_mother_2,replace

graph combine graph_mother_2.gph graph_mother_1.gph 

* relative to twin
coefplot, xline(1) eform xtitle(Hazards Ratio) levels(95) ///
		keep( 9.MigDeadTwin_Twin_DTH_TVC  ///
			 1.MigDeadTwin_Twin_DTH_TVC 2.MigDeadTwin_Twin_DTH_TVC 3.MigDeadTwin_Twin_DTH_TVC ///
			 4.MigDeadTwin_Twin_DTH_TVC 5.MigDeadTwin_Twin_DTH_TVC 6.MigDeadTwin_Twin_DTH_TVC ///
			 ) ///
		order( 9.MigDeadTwin_Twin_DTH_TVC  ///
			 1.MigDeadTwin_Twin_DTH_TVC 2.MigDeadTwin_Twin_DTH_TVC 3.MigDeadTwin_Twin_DTH_TVC ///
			 4.MigDeadTwin_Twin_DTH_TVC 5.MigDeadTwin_Twin_DTH_TVC 6.MigDeadTwin_Twin_DTH_TVC ///
			 ) ///
		mlabel format(%9.2f) mlabposition(12) mlabgap(*1) ///
		coeflabels(9.MigDeadTwin_Twin_DTH_TVC="No twin" ///
			 1.MigDeadTwin_Twin_DTH_TVC="Twin non resident" ///
			 2.MigDeadTwin_Twin_DTH_TVC="6-3m < death" ///
			 3.MigDeadTwin_Twin_DTH_TVC="3m-15d < death" ///
			 4.MigDeadTwin_Twin_DTH_TVC="+/-15d death" ///
			 5.MigDeadTwin_Twin_DTH_TVC="15d-3m > death" ///
			 6.MigDeadTwin_Twin_DTH_TVC="3-6m > death" ///
			 , notick labsize(small) labcolor(purple) labgap(2)) ///
		headings(9.MigDeadTwin_Twin_DTH_TVC=`""{bf:Twin sibling status}" "Ref: Resident""' ///
				2.MigDeadTwin_Twin_DTH_TVC=`""{bf:Twin death status}" "Ref: Resident""' , labcolor(blue)) ///
		xlabel(1 2 4 8 15 30, format(%9.0f)) xscale(log range(.5 30)) baselevels
graph save graph_twin_sibling,replace

* relative to older sibling
coefplot, xline(1) eform xtitle(Hazards Ratio) levels(95) ///
		keep( 0.MigDeadO_interv 10.MigDeadO_interv ///
			 21.MigDeadO_interv 22.MigDeadO_interv 23.MigDeadO_interv ///
			 25.MigDeadO_interv 26.MigDeadO_interv 27.MigDeadO_interv 28.MigDeadO_interv ///
			 1.res_O_DTH_TVC 2.res_O_DTH_TVC 3.res_O_DTH_TVC ///
			 4.res_O_DTH_TVC 5.res_O_DTH_TVC ) ///
		mlabel format(%9.2f) mlabposition(12) mlabgap(*1) ///
		coeflabels(0.MigDeadO_interv="No older sibling" ///
			 10.MigDeadO_interv="Non resident" ///
			 21.MigDeadO_interv="O int <12m" 22.MigDeadO_interv="O int 12-17m" ///
			 23.MigDeadO_interv="O int 18-23m" 25.MigDeadO_interv="O int 30-35m" ///
			 26.MigDeadO_interv="O int 36-41m" 27.MigDeadO_interv="O int 42-47m" ///
			 28.MigDeadO_interv="O int 48m +" ///
			 1.res_O_DTH_TVC="6-3m < death" 2.res_O_DTH_TVC="3m-15d < death" ///
			 3.res_O_DTH_TVC="+/-15d death" 4.res_O_DTH_TVC="15d-3m > death" ///
			 5.res_O_DTH_TVC="3-6m > death" ///
			 , notick labsize(small) labcolor(purple) labgap(2)) ///
		headings(0.MigDeadO_interv=`""{bf:Older sibling status}" "Ref: Resident""' ///
				21.MigDeadO_interv=`""{bf:Birth interval with older sibling}" "Ref: 24-29m""' ///
				1.res_O_DTH_TVC=`""{bf:Older sibling death status}" "Ref: Resident""' , labcolor(blue)) ///
		xlabel(1 2 4 8, format(%9.1f)) xscale(log range(.7 8)) baselevels
graph save graph_older_sibling, replace

* relative to younger sibling
coefplot, xline(1) eform xtitle(Hazards Ratio) levels(95) ///
		keep( 0.birth_int_gp_YS 100.birth_int_gp_YS ///
			 1.res_Y_DTH_TVC 2.res_Y_DTH_TVC 3.res_Y_DTH_TVC ///
			 4.res_Y_DTH_TVC 5.res_Y_DTH_TVC ) ///
		mlabel format(%9.2f) mlabposition(12) mlabgap(*1) ///
		coeflabels(0.birth_int_gp_YS="No younger sibling" ///
			 100.birth_int_gp_YS="Non resident" ///
			 1.res_Y_DTH_TVC="6-3m < death" 2.res_Y_DTH_TVC="3m-15d < death" ///
			 3.res_Y_DTH_TVC="+/-15d death" 4.res_Y_DTH_TVC="15d-3m > death" ///
			 5.res_Y_DTH_TVC="3-6m > death" ///
			 , notick labsize(small) labcolor(purple) labgap(2)) ///
		headings(0.birth_int_gp_YS=`""{bf:Younger sibling status}" "Ref: Resident""' ///
				1.res_Y_DTH_TVC=`""{bf:.    Younger sibling death status}" "Ref: Resident""' , labcolor(blue)) ///
		xlabel(1 2 4 8, format(%9.1f)) xscale(log range(.7 8)) baselevels
graph save graph_younger_sibling, replace

coefplot, xline(1) eform xtitle(Hazards Ratio) levels(95) ///
		keep( 1.birth_int_gp_YS  11.birth_int_gp_YS  21.birth_int_gp_YS  31.birth_int_gp_YS  ///
			 41.birth_int_gp_YS  51.birth_int_gp_YS  61.birth_int_gp_YS  71.birth_int_gp_YS ///
			200.birth_int_gp_YS 210.birth_int_gp_YS 220.birth_int_gp_YS  ///
			240.birth_int_gp_YS 250.birth_int_gp_YS 260.birth_int_gp_YS 270.birth_int_gp_YS ///
			300.birth_int_gp_YS 310.birth_int_gp_YS 320.birth_int_gp_YS 330.birth_int_gp_YS  ///
			340.birth_int_gp_YS 350.birth_int_gp_YS 360.birth_int_gp_YS  ///
			400.birth_int_gp_YS 410.birth_int_gp_YS 420.birth_int_gp_YS 430.birth_int_gp_YS  ///
			440.birth_int_gp_YS 450.birth_int_gp_YS 460.birth_int_gp_YS  ///
			) ///
		mlabel format(%9.2f) mlabposition(12) mlabgap(*1) ///
		coeflabels( 1.birth_int_gp_YS="Int <12m"  11.birth_int_gp_YS="Int 12-17m" ///
			21.birth_int_gp_YS="Int 18-23m"  31.birth_int_gp_YS="Int 24-29m" ///
			41.birth_int_gp_YS="Int 30-35m"  51.birth_int_gp_YS="Int 36-41m" ///
			61.birth_int_gp_YS="Int 42-47m"  71.birth_int_gp_YS="Int >=48m+" ///
			200.birth_int_gp_YS="Int <12m" 210.birth_int_gp_YS="Int 12-17m" ///
			220.birth_int_gp_YS="Int 18-23m"  ///
			240.birth_int_gp_YS="Int 30-35m" 250.birth_int_gp_YS="Int 36-41m" ///
			260.birth_int_gp_YS="Int 42-47m" 270.birth_int_gp_YS="Int >=48m+" ///
			300.birth_int_gp_YS="Int <12m" 310.birth_int_gp_YS="Int 12-17m" ///
			320.birth_int_gp_YS="Int 18-23m" 330.birth_int_gp_YS="Int 24-29m"  ///
			340.birth_int_gp_YS="Int 30-35m" 350.birth_int_gp_YS="Int 36-41m" ///
			360.birth_int_gp_YS="Int 42-47m"  ///
			400.birth_int_gp_YS="Int <12m" 410.birth_int_gp_YS="Int 12-17m" ///
			420.birth_int_gp_YS="Int 18-23m" 430.birth_int_gp_YS="Int 24-29m"  ///
			440.birth_int_gp_YS="Int 30-35m" 450.birth_int_gp_YS="Int 36-41m" ///
			460.birth_int_gp_YS="Int 42-47m"  ///
			, notick labsize(small) labcolor(purple) labgap(2)) ///
		headings( 1.birth_int_gp_YS=`"{bf: 6-m pregnant with younger sibling}"' ///
				200.birth_int_gp_YS=`""{bf: 0-5m after younger sibling birth}" "Ref: Int 24-29m - 0-5m" " ""' ///
				300.birth_int_gp_YS=`"{bf: 5-11m after younger sibling birth}"' ///
				400.birth_int_gp_YS=`"{bf: 12m+ after younger sibling birth}"' ///
				, labcolor(blue)) ///
		xlabel(0.5 1 2 4, format(%9.1f)) xscale(log range(0.5 5)) baselevels
graph save graph_after_before_ysib_birth, replace 

* plot death bell-curves
* use order(coeflist) option
coefplot, xline(1) eform xtitle(Hazards Ratio) levels(95) ///
		keep( 2.MigDeadMO_MO_DTH_TVC ///
			 3.MigDeadMO_MO_DTH_TVC 4.MigDeadMO_MO_DTH_TVC 5.MigDeadMO_MO_DTH_TVC ///
			 6.MigDeadMO_MO_DTH_TVC ///
			 2.MigDeadTwin_Twin_DTH_TVC 3.MigDeadTwin_Twin_DTH_TVC ///
			 4.MigDeadTwin_Twin_DTH_TVC 5.MigDeadTwin_Twin_DTH_TVC 6.MigDeadTwin_Twin_DTH_TVC ///
			 1.res_O_DTH_TVC 2.res_O_DTH_TVC 3.res_O_DTH_TVC ///
			 4.res_O_DTH_TVC 5.res_O_DTH_TVC ///
			 1.res_Y_DTH_TVC 2.res_Y_DTH_TVC 3.res_Y_DTH_TVC ///
			 4.res_Y_DTH_TVC 5.res_Y_DTH_TVC ) ///
		order( 2.MigDeadMO_MO_DTH_TVC ///
			 2.MigDeadTwin_Twin_DTH_TVC ///
			 1.res_O_DTH_TVC ///
			 1.res_Y_DTH_TVC ///
			 3.MigDeadMO_MO_DTH_TVC ///
			 3.MigDeadTwin_Twin_DTH_TVC ///
			 2.res_O_DTH_TVC ///
			 2.res_Y_DTH_TVC ///
			 4.MigDeadMO_MO_DTH_TVC ///
			 4.MigDeadTwin_Twin_DTH_TVC ///
			 3.res_O_DTH_TVC ///
			 3.res_Y_DTH_TVC ///
			 5.MigDeadMO_MO_DTH_TVC ///
			 5.MigDeadTwin_Twin_DTH_TVC ///
			 4.res_O_DTH_TVC ///
			 4.res_Y_DTH_TVC ///
			 6.MigDeadMO_MO_DTH_TVC ///
			 6.MigDeadTwin_Twin_DTH_TVC ///
			 5.res_O_DTH_TVC ///
			 5.res_Y_DTH_TVC  ) ///
		mlabel format(%9.2f) mlabposition(12) mlabgap(*1) ///
		coeflabels( ///
			2.MigDeadMO_MO_DTH_TVC="Mother" ///
			3.MigDeadMO_MO_DTH_TVC="Mother" ///
			4.MigDeadMO_MO_DTH_TVC="Mother" ///
			5.MigDeadMO_MO_DTH_TVC="Mother" ///
			6.MigDeadMO_MO_DTH_TVC="Mother"  ///
			2.MigDeadTwin_Twin_DTH_TVC="Twin" ///
			3.MigDeadTwin_Twin_DTH_TVC="Twin" ///
			4.MigDeadTwin_Twin_DTH_TVC="Twin" ///
			5.MigDeadTwin_Twin_DTH_TVC="Twin" ///
			6.MigDeadTwin_Twin_DTH_TVC="Twin" ///
			1.res_O_DTH_TVC="Older sibling" ///
			2.res_O_DTH_TVC="Older sibling"  ///
			3.res_O_DTH_TVC="Older sibling" ///
			4.res_O_DTH_TVC="Older sibling"  ///
			5.res_O_DTH_TVC="Older sibling" ///
			1.res_Y_DTH_TVC="Younger sibling" ///
			2.res_Y_DTH_TVC="Younger sibling"  ///
			3.res_Y_DTH_TVC="Younger sibling" ///
			4.res_Y_DTH_TVC="Younger sibling"  ///
			5.res_Y_DTH_TVC="Younger sibling" ///
			 , notick labsize(small) labcolor(purple) labgap(2)) ///
		headings( ///
		2.MigDeadMO_MO_DTH_TVC=`""{bf: 6-3m < death}" 	"Ref: Resident""' ///
		3.MigDeadMO_MO_DTH_TVC=`""{bf:3m-15d < death}" 	"Ref: Resident""' ///
		4.MigDeadMO_MO_DTH_TVC=`""{bf:+/-15d death}" 	"Ref: Resident""' ///
		5.MigDeadMO_MO_DTH_TVC=`""{bf:15d-3m > death}" 	"Ref: Resident""' ///
		6.MigDeadMO_MO_DTH_TVC=`""{bf:3-6m > death}" 	"Ref: Resident""' ///
		, labcolor(blue)) ///
		xlabel(1 2 4 8 15 30 50, format(%9.0f)) xscale(log range(1 50)) baselevels

graph save graph_all_death, replace

 Some potential model simplifications:
*	- mother's age as continuous variable + squared
*	- all sibling's death (twin + younger + older)
*	- younger sibling: tvc (log?) from pregnancy for each birth interval

capture drop All_siblings_DTH_TVC
gen All_siblings_DTH_TVC=	///
					cond(MigDeadTwin_Twin_DTH_TVC<2 | res_O_DTH_TVC<1 | res_Y_DTH_TVC<1,0, ///
					cond(MigDeadTwin_Twin_DTH_TVC==2 | res_O_DTH_TVC==1 | res_Y_DTH_TVC==1,1, ///
					cond(MigDeadTwin_Twin_DTH_TVC==3 | res_O_DTH_TVC==2 | res_Y_DTH_TVC==2,2, ///
					cond(MigDeadTwin_Twin_DTH_TVC==4 | res_O_DTH_TVC==3 | res_Y_DTH_TVC==3,3, ///
					cond(MigDeadTwin_Twin_DTH_TVC==5 | res_O_DTH_TVC==4 | res_Y_DTH_TVC==4,4, ///
					cond(MigDeadTwin_Twin_DTH_TVC==6 | res_O_DTH_TVC==5 | res_Y_DTH_TVC==5,5, ///
					7))))))
replace MigDeadTwin_Twin_DTH_TVC=9 if MigDeadTwin==0
label define lAll_siblings_DTH_TVC 0 "Other" 	///
						1 "-6m to -3m sibling's death" 	2 "-3m to -15d sibling's death" ///
						3 "+/- 15d sibling's death" 	4 "15d to 3m sibling's death" ///
						5 "+3m to +6m sibling's death" 	6 "6m+ sibling's death" ///
						, modify
label val All_siblings_DTH_TVC lAll_siblings_DTH_TVC

recode MigDeadTwin (2 3 4=2), gen(MigDeadTwin2)
lab val MigDeadTwin2 MigDeadTwin
recode MigDeadO (2 3 4=2), gen(MigDeadO2)
lab val MigDeadO2 MigDeadO
recode MigDeadY (2 3 4=2), gen(MigDeadY2)
lab val MigDeadY2 MigDeadY
recode  gp_ecart_Yres (6/16=6), gen(gp_ecart_Yres2)
lab val gp_ecart_Yres2 gp_age_sy
recode birth_int_YS (.=0)
replace birth_int_YS=0 if MigDeadY2==1
lab def lbirth_int_YS 0 "no younger sibling", modify

egen Centre_period=group(CentreLab period), label
tab Centre_period [iw=_t-_t0]
recode Centre_period (35 36 37=38)

stcox 	i.Sex ib75.Centre_period ///
		c.mother_age_birth c.mother_age_birth#c.mother_age_birth ///
		ib0.MigDeadMO_MO_DTH_TVC ib0.migrant_statusMO ///
		ib0.MigDeadTwin2  ///
		ib0.MigDeadO2  ///
		ib2.MigDeadY2 ib0.gp_ecart_Yres2 ib0.birth_int_YS ///
        ib0.All_siblings_DTH_TVC ///
		, vce(cluster MotherId) iter(10) 
outreg2 using Analyses_under5simple, label word stats(coef) ///
	bdec(2) nor2 eform ///
	addstat(Wald Chi-square, e(chi2), Log Lik, e(ll), Subjects, e(N_sub), Time at risk, ///
	e(risk), Failures, e(N_fail)) 
outreg2 using Analyses_under5simple, word stats(se) ///
	sdec(2) nor2 eform
outreg2 using Analyses_under5simple, word stats(pval) ///
	pdec(3) nor2 eform
outreg2 using Analyses_under5simple, word stats(ci_low) ///
	cdec(2) nor2 eform  		
outreg2 using Analyses_under5simple, word stats(ci_high) ///
	cdec(2) nor2 eform  		


/* Parametric model (polynomial 2 nodes)
stpm2 i.Sex ib2000.period ///
		ib21.y3_mother_age_birth ib0.MigDeadMO_MO_DTH_TVC ib0.migrant_statusMO ///
		ib9.MigDeadTwin_Twin_DTH_TVC ///
		ib24.MigDeadO_int ib0.res_O_DTH_TVC ///
        ib230.birth_int_gp_YS ib0.res_Y_DTH_TVC ///
		ib22.CentreLab ///
		, df(3) scale(hazard) eform
graph twoway (rarea hstpm_lci hstpm_uci _t, pstyle(ci) sort) ///
	(line hstpm _t, sort clpattern(l)), ///
	yscale(log) legend(off) sav(pm_df3, replace)
*/

/* Basic model with macro, but without Centre "fixed effect"
stcox 	i.Sex ib2000.period ///
		ib21.y3_mother_age_birth ib0.MigDeadMO_MO_DTH_TVC ib0.migrant_statusMO ///
		ib0.twin ///
		ib24.MigDeadO_int ib0.res_O_DTH_TVC ///
        ib230.birth_int_gp_YS ib0.res_Y_DTH_TVC ///
		PREC_NEW TEMP_NEW /* rain */ travel ///
		ib1.urbanicity ///
		, /*vce(cluster MotherId)*/
* with square terms for macro
stcox 	i.Sex ib2000.period ///
		ib21.y3_mother_age_birth ib0.MigDeadMO_MO_DTH_TVC ib0.migrant_statusMO ///
		ib24.MigDeadO_int ib0.res_O_DTH_TVC ///
        ib9.MigDeadTwin_Twin_DTH_TVC ///
		ib230.birth_int_gp_YS ib0.res_Y_DTH_TVC ///
		c.PREC_NEW c.PREC_NEW#c.PREC_NEW c.TEMP_NEW c.TEMP_NEW#c.TEMP_NEW /* rain */ ///
		c.travel c.travel#c.travel ///
		, /*vce(cluster MotherId)*/
* limited to 2000+ but interesting
stcox 	i.Sex ib2000.period ///
		ib21.y3_mother_age_birth ib0.MigDeadMO_MO_DTH_TVC ib0.migrant_statusMO ///
		ib9.MigDeadTwin_Twin_DTH_TVC ///
		ib24.MigDeadO_int ib0.res_O_DTH_TVC ///
        ib230.birth_int_gp_YS ib0.res_Y_DTH_TVC ///
		PREC_NEW TEMP_NEW /* rain */ travel vacc edu  ///
		ib1.urbanicity ///
		, /*vce(cluster MotherId)*/
* with square terms for macro
stcox 	i.Sex ib2000.period ///
		ib21.y3_mother_age_birth ib0.MigDeadMO_MO_DTH_TVC ib0.migrant_statusMO ///
		ib9.MigDeadTwin_Twin_DTH_TVC ///
		ib24.MigDeadO_int ib0.res_O_DTH_TVC ///
        ib230.birth_int_gp_YS ib0.res_Y_DTH_TVC ///
		c.PREC_NEW c.PREC_NEW#c.PREC_NEW c.TEMP_NEW c.TEMP_NEW#c.TEMP_NEW /* rain */ ///
		c.travel c.travel#c.travel ///
		c.vacc c.vacc#c.vacc c.edu c.edu#c.edu  ///
		, /*vce(cluster MotherId)*/

* limited to 2000-2009 (to account for GDP)
* Note: reducing effect of HIV neutralised by GDP => HIV correlated with GDP
stcox 	i.Sex ib2000.period ///
		ib21.y3_mother_age_birth ib0.MigDeadMO_MO_DTH_TVC ib0.migrant_statusMO ///
		ib9.MigDeadTwin_Twin_DTH_TVC ///
		ib24.MigDeadO_int ib0.res_O_DTH_TVC ///
        ib230.birth_int_gp_YS ib0.res_Y_DTH_TVC ///
		PREC_NEW TEMP_NEW /* rain */ travel vacc edu hiv gdp_ppp_ ///
		, /*vce(cluster MotherId)*/
*/
		
estimates store model_standard
matrix list e(b)

*Yac18082018
capture drop MigDeadMO_migrant_statusMO
gen MigDeadMO_migrant_statusMO = cond(MigDeadMO==2 & migrant_statusMO==0,0,cond(MigDeadMO==2 & migrant_statusMO!=0,1, ///
                                 cond(MigDeadMO==1,2,3)))
label define lMigDeadMO_migrant_statusMO 0 "permanent res. or res in-mig 10y+" 1 "Résident in-mig <10y" ///
			2 "mother non resident" 3 "mother dead",modify
label val MigDeadMO_migrant_statusMO lMigDeadMO_migrant_statusMO
								 
save, replace
* End of analysis for all sites (African average) 
log close

*************************************************************************************
**** Analysis of the specificity of each site as compared to the African average ****
*************************************************************************************
decode CentreLab, gen(Center_string)
global Center_string   ET051 ET061 ///
                      GH011 GH021 GH031 GM011	KE011 KE031 MW011 MZ021 ///
					  SN011 SN012 SN013	 TZ011
					   *TZ012 TZ013 ZA011 ZA021 ZA031
					   *BF021 BF041 CI011 ET021 ET031 ET041
					    
					 
stset EventDate if residence==1, id(concat_IndividualId) failure(censor_death==1) ///
		time0(datebeg) origin(time DoB) exit(time DoB+(31557600000*5)+212000000) scale(31557600000)
		
foreach lname of global Center_string {
	stcox 	i.Sex ib0.twin i.period ib21.y3_mother_age_birth ib0.MigDeadMO_MO_DTH_TVC ib0.migrant_statusMO ///
		ib0.MigDeadObis ib0.gp_ecart_Ores_new ///
        ib0.gp_birth_int_YS if Center_string=="`lname'", iter(11) vce(cluster MotherId)
	estimates store Model_`lname'
	outreg2 using comp_mort_HDSS_hz_02102018, excel ci  eform dec(2) ///
		addstat(Wald Chi-square, e(chi2), Log Lik, e(ll), Subjects, e(N_sub), Time at risk, ///
		e(risk), Failures, e(N_fail)) ctitle("`lname'")label  sideway
	outreg2 using comp_mort_HDSS_tstats_02102018, excel  eform dec(2) alpha(0.001, 0.01, 0.05)  ///
		noparen  tstat addstat(Wald Chi-square, e(chi2), Log Lik, e(ll), Subjects, e(N_sub), Time at risk, ///
		e(risk), Failures, e(N_fail)) ctitle("`lname'")label  sideway
}

*YaC 08102018
** Begin classification
** New (simplified) variables for classification

**Migration status
recode migrant_statusMO (0=0 "permanent res. or in-mig 10y+") (1 2 3=1 "Migrants"), ///
					gen(migrant_statusMO_cl)

*period
recode period (1989=1) (1994=2) (1999=3) (2004=4) (2009=5), gen(period_cl)

*Older sibling (ecart with older sibling)
recode gp_ecart_Ores_new (0=0 "NoOS") ///
				(1 2=1 "<18 months") (3 4=2 "18-29 months") (5 6=3 "30-41 months") ///
				(7 8 = 4 "42 months&+"), gen(gp_ecart_Ores_new_cl)
*Younger sibling
recode gp_birth_int_YS (0=0 "NoYS") (1 11 = 11 "Int <18m - pregnant") (21 31 = 21 "Int 18-29m - pregnant") ///
                       (41 51=51 "Int 30-41m - pregnant") (61 71 =71 "Int 42months&+ - pregnant") ///
					   (1000=1000 "y sibling non-res") ///
					   (2002 2012=2012 "Int <18m - 0-6m") (2022 2032=2032 "Int 18-29m - 0-6m") ///
					   (2042  2052 =2052 "Int 30-41m - 0-6m") ///
					   (2062 2072=2072 "Int 42months&+ - 0-6m") ///
					   (2003 2013=2013 "Int <18m - 6-12m") (2023 2033=2033 "Int 18-29m - 6-12m") ///
					   (2043 2053=2053 "Int 30-41m - 6-12m") (2063 2073=2073 "Int <42months&+ - 6-12m") ///
					   (2004 2014 =2014 "Int <18m - 12m&+") (2024 2034=2034 "Int 18-29m - 12m&+") ///
					   (2044 2054 =2054 "Int 30-41m - 12m&+") (2064= 2064 "Int 42months&+ - 12m&+") ///
					   (3000=3000 "y sibling dead"),gen(gp_birth_int_YS_cl)

*Mother death
recode MigDeadMO_MO_DTH_TVC (2 3=2 "-6m to -15d mother's death") (4 5=3 "-15d to 3m mother's death") ///
						(6 7=4 "+3m&+ mother's death") (0=0 "mother resident") ///
						(1=1 "mother non resident") ,gen(MigDeadMO_MO_DTH_TVC_cl)

					
						
						
*Age de la mère
replace mother_age_birth=0 if mother_age_birth==.

*Age de la mère au carrée
gen mother_age_birth_sqrd=mother_age_birth*mother_age_birth


*Age de la mère (Missing values)
gen m_age_missing_val = cond(mother_age_birth==0,1,0)
label define lm_age_missing_val 1 "Missing value" 0 "No Missing value",modify
label val m_age_missing_val lm_age_missing_val

*log using p_year_gp_birth_int_YS

decode CentreLab, gen(Center_string)
global Center_string BF021 BF041 CI011 ET021 ET031 ET041  ET051 ET061 ///
                      GH011 GH021 GH031 GM011	KE011 KE031 MW011 MZ021 ///
					  SN011 SN012 SN013	 TZ011 TZ012 TZ013 ZA011 ZA021 ZA031

foreach lname of global Center_string {
disp "`lname'"
table gp_birth_int_YS_cl [iw=_t-_t0] if Center_string=="`lname'", nol 
}



*Sex
foreach lname of global Center_string {
disp "`lname'"
table Sex [iw=_t-_t0] if Center_string=="`lname'", nol 
}

*twin
foreach lname of global Center_string {
disp "`lname'"
table twin [iw=_t-_t0] if Center_string=="`lname'", nol 
}

*period_cl
foreach lname of global Center_string {
disp "`lname'"
table period_cl [iw=_t-_t0] if Center_string=="`lname'", nol 
}

*mother_age_birth
foreach lname of global Center_string {
disp "`lname'"
table c.mother_age_birth [iw=_t-_t0] if Center_string=="`lname'", nol 
}

*mother_age_birth_sqrd
foreach lname of global Center_string {
disp "`lname'"
table mother_age_birth_sqrd [iw=_t-_t0] if Center_string=="`lname'", nol 
}

*m_age_missing_val
foreach lname of global Center_string {
disp "`lname'"
table m_age_missing_val [iw=_t-_t0] if Center_string=="`lname'", nol 
}

*MigDeadMO_MO_DTH_TVC_cl
foreach lname of global Center_string {
disp "`lname'"
table MigDeadMO_MO_DTH_TVC_cl [iw=_t-_t0] if Center_string=="`lname'", nol 
}

*migrant_statusMO_cl
foreach lname of global Center_string {
disp "`lname'"
table migrant_statusMO_cl [iw=_t-_t0] if Center_string=="`lname'", nol 
}

*MigDeadObis
foreach lname of global Center_string {
disp "`lname'"
table MigDeadObis [iw=_t-_t0] if Center_string=="`lname'", nol 
}

*gp_ecart_Ores_new_cl
foreach lname of global Center_string {
disp "`lname'"
table gp_ecart_Ores_new_cl [iw=_t-_t0] if Center_string=="`lname'", nol 
}

*gp_birth_int_YS_cl
foreach lname of global Center_string {
disp "`lname'"
table gp_birth_int_YS_cl [iw=_t-_t0] if Center_string=="`lname'", nol 
}



**Classification
set maxiter 10
			   
foreach lname of global Center_string {
	gen center_`lname'=(Center_string=="`lname'")
	stcox 	(i.Sex ib0.twin c.period_cl c.mother_age_birth c.mother_age_birth_sqrd ib0.m_age_missing_val ///
		ib0.MigDeadMO_MO_DTH_TVC_cl ib0.migrant_statusMO_cl ///
		ib0.MigDeadObis ib0.gp_ecart_Ores_new_cl ///
        ib0.gp_birth_int_YS_cl)##center_`lname', iter(5) vce(cluster MotherId)
	estimates store Model_center`lname'
	outreg2 using comp_mort_HDSS_interaction_hz_08102018_verif, excel ci  eform dec(2) ///
		addstat(Wald Chi-square, e(chi2), Log Lik, e(ll), Subjects, e(N_sub), Time at risk, ///
		e(risk), Failures, e(N_fail)) ctitle("`lname'")label  sideway
	outreg2 using comp_mort_HDSS_interaction_tstat_08102018_verif, excel  eform dec(2) alpha(0.001, 0.01, 0.05)  ///
		noparen  tstat addstat(Wald Chi-square, e(chi2), Log Lik, e(ll), Subjects, e(N_sub), Time at risk, ///
		e(risk), Failures, e(N_fail)) ctitle("`lname'")label  sideway
}

**End classification
**************************************************************************************

**Results by site

**Analyses by country group 
* PhB: TO REVISE ACCORDING TO THE NEW RESULTS OF CLUSTER ANALYSIS
*Metric =  Gowers2
/*
 1.  BF021  Nanoro (group 1) ok
 2.  BF041  Ouagadougou (group 1) ok
 3.  CI011  Taabo (group 5) ok
 4.  ET021  Gilgel Gibe   (group 2) ok
 5.  ET031  Kilite Awlaelo (group 3) Ok
 6.  ET041  Kersa (group 3) ok
 7.  ET051  Dabat (group 4) ok 
 8.  ET061  Arba Minch  (group 3) ok
 9.  GH011  Navrongo HDSS (group 5) ok
 10. GH021  Kintampo HDSS  (group 5) ok
 11. GH031  Dodowa (<=2011) (group 4)  ok
 12. GM011  GM011	Farafenni HDSS  (group 2) ok
 13. KE011  Kilifi (group 4) ok
 14. KE031  Nairobi  (group 3) ok
 15. MW011  Karonga (group 3)  ok
 16. MZ021  Chokwe  HDSS   (group 2) ok
 17. SN011  Bandafassi (group 3)  ok
 18. SN012  IRD Mlomp (group 2) ok
 19. SN013  IRD Niakhar (group 4) ok
 20. TZ011  IHI Ifakara Rural (group 3) ok
 21. TZ012  IHI Rufiji  (group 5) ok
 22. TZ013  IHI Ifakara Urban   (group 4) ok
 23. ZA011  Agincourt (group 3) ok
 24. ZA021  Dikgale (group 3) ok
 25. ZA031  Africa Centre   (group 2) ok
*/

capture drop CentreLab
capture lab drop CentreLab
encode CentreId, gen(CentreLab)

capture drop group
recode CentreLab (1 2=1 "Group 1") (4 12 16 18 25 =2 "Group 2") ///
				(5 6 8 14 15 17 20 23 24 =3 "Group 3") (7 11 13 19 22=4 "Group 4") (3 9 10 21=5 "Group 5"), gen(group)

stset EventDate if residence==1, id(concat_IndividualId) failure(censor_death==1) ///
                time0(datebeg) origin(time DoB) exit(time .) scale(31557600000)

forval i=1/5 {
	stcox  i.Sex ib0.twin i.period ib21.y3_mother_age_birth ib0.MigDeadMO_migrant_statusMO ///
		ib0.MigDeadObis ib0.gp_ecart_Ores_new ///
        ib0.gp_birth_int_YS if group==`i', vce(cluster MotherId)
	estimates store Model_group`i'
	outreg2 using comp_mort_Group_interaction_hz, excel ci  eform dec(2) ///
		addstat(Wald Chi-square, e(chi2), Log Lik, e(ll), Subjects, e(N_sub), Time at risk, ///
		e(risk), Failures, e(N_fail)) ctitle("`i'") label  sideway
	outreg2 using comp_mort_Group_interaction_tstat, excel  eform dec(2) alpha(0.001, 0.01, 0.05)  ///
		noparen  tstat addstat(Wald Chi-square, e(chi2), Log Lik, e(ll), Subjects, e(N_sub), Time at risk, ///
		e(risk), Failures, e(N_fail)) ctitle("`i'") label  sideway
}

XX

stcox  i.Sex ib0.twin i.period ib21.y3_mother_age_birth ib0.MigDeadMO_migrant_statusMO ///
		ib0.MigDeadObis ib0.gp_ecart_Ores_new ///
        ib0.gp_birth_int_YS , vce(cluster MotherId)
estimates store Model_Africa
outreg2 using comp_mort_Group_interaction_hz, excel ci  eform dec(2) ///
	addstat(Wald Chi-square, e(chi2), Log Lik, e(ll), Subjects, e(N_sub), Time at risk, ///
	e(risk), Failures, e(N_fail)) ctitle("Africa")label  sideway
outreg2 using comp_mort_Group_interaction_tstat, excel  eform dec(2) alpha(0.001, 0.01, 0.05)  ///
	noparen  tstat addstat(Wald Chi-square, e(chi2), Log Lik, e(ll), Subjects, e(N_sub), Time at risk, ///
	e(risk), Failures, e(N_fail)) ctitle("Africa")label  sideway

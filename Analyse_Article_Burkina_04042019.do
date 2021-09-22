use   base_analyse_def_02052019,clear

*Corrections sur ma base
sort IndividualId EventDate EventCode
*drop if EventCode[_n-1]==4 & EventCode==9 & EventDate==1830384000000
*drop if EventCode[_n-1]==7 & EventCode==9 & EventDate==1830384000000


sort MotherId EventDateMO
bys MotherId : replace residenceMO = 0 if EventCodeMO==18 & EventDateMO-EventDateMO[_n-1]>15778800000 & center==1
bys MotherId : replace residenceMO = 1 if EventCodeMO==18 & EventDateMO-EventDateMO[_n-1]<=15778800000 & center==1

bys MotherId : replace residenceMO = 0 if EventCodeMO==18 & EventDateMO-EventDateMO[_n-1]>10519200000 & center==2
bys MotherId : replace residenceMO = 1 if EventCodeMO==18 & EventDateMO-EventDateMO[_n-1]<=10519200000 & center==2

sort FatherId EventDateFA 
bys FatherId : replace residenceFA= 0 if EventCodeFA==18 & EventDateFA-EventDateFA[_n-1]>15778800000 & center==1
bys FatherId : replace residenceFA = 1 if EventCodeFA==18 & EventDateFA-EventDateFA[_n-1]<=15778800000 & center==1

bys FatherId : replace residenceFA = 0 if EventCodeFA==18 & EventDateFA-EventDateFA[_n-1]>10519200000 & center==2
bys FatherId : replace residenceFA = 1 if EventCodeFA==18 & EventDateFA-EventDateFA[_n-1]<=10519200000 & center==2

sort MGFatherId  EventDateMGFA  
bys MGFatherId : replace residenceMGFA = 0 if EventCodeMGFA==18 & EventDateMGFA-EventDateMGFA[_n-1]>15778800000 & center==1
bys MGFatherId : replace residenceMGFA = 1 if EventCodeMGFA==18 & EventDateMGFA-EventDateMGFA[_n-1]<=15778800000 & center==1
bys MGFatherId : replace residenceMGFA = 0 if EventCodeMGFA==18 & EventDateMGFA-EventDateMGFA[_n-1]>10519200000 & center==2
bys MGFatherId : replace residenceMGFA = 1 if EventCodeMGFA==18 & EventDateMGFA-EventDateMGFA[_n-1]<=10519200000 & center==2

sort MGMotherId  EventDateMGMO  
bys MGMotherId : replace residenceMGMO = 0 if EventCodeMGMO==18 & EventDateMGMO-EventDateMGMO[_n-1]>15778800000 & center==1
bys MGMotherId : replace residenceMGMO = 1 if EventCodeMGMO==18 & EventDateMGMO-EventDateMGMO[_n-1]<=15778800000 & center==1
bys MGMotherId : replace residenceMGMO = 0 if EventCodeMGMO==18 & EventDateMGMO-EventDateMGMO[_n-1]>10519200000 & center==2
bys MGMotherId : replace residenceMGMO = 1 if EventCodeMGMO==18 & EventDateMGMO-EventDateMGMO[_n-1]<=10519200000 & center==2

sort PGFatherId  EventDatePGFA  
bys PGFatherId : replace residencePGFA = 0 if EventCodePGFA==18 & EventDatePGFA-EventDatePGFA[_n-1]>15778800000 & center==1
bys PGFatherId : replace residencePGFA = 1 if EventCodePGFA==18 & EventDatePGFA-EventDatePGFA[_n-1]<=15778800000 & center==1
bys PGFatherId : replace residencePGFA = 0 if EventCodePGFA==18 & EventDatePGFA-EventDatePGFA[_n-1]>10519200000 & center==2
bys PGFatherId : replace residencePGFA = 1 if EventCodePGFA==18 & EventDatePGFA-EventDatePGFA[_n-1]<=10519200000 & center==2

sort PGMotherId  EventDateMGMO  
bys PGMotherId : replace residencePGMO = 0 if EventCodePGMO==18 & EventDatePGMO-EventDatePGMO[_n-1]>15778800000 & center==1
bys PGMotherId : replace residencePGMO = 1 if EventCodePGMO==18 & EventDatePGMO-EventDatePGMO[_n-1]<=15778800000 & center==1
bys PGMotherId : replace residencePGMO = 0 if EventCodePGMO==18 & EventDatePGMO-EventDatePGMO[_n-1]>10519200000 & center==2
bys PGMotherId : replace residencePGMO = 1 if EventCodePGMO==18 & EventDatePGMO-EventDatePGMO[_n-1]<=10519200000 & center==2






capture drop a
sort IndividualId EventDate EventCode
bys IndividualId :gen a=1 if EventCode==9&EventCode[_n+1]==9 & (_n==_N-1) & EventDate[_n+1]==1830384000000
drop if a==1
drop if Sex==-1 /*Tous ces enfants viennent de Niakhar*/



capture drop datebeg
sort IndividualId EventDate EventCode
qui by IndividualId: gen double datebeg=cond(_n==1, DoB, EventDate[_n-1])
format datebeg %tc



sort IndividualId EventDate EventCode
cap drop censor_death
gen censor_death=(EventCode==7) if residence==1






* Creating indicator variables for death of mother and siblings:
**Détecter les mères recussité
bysort IndividualId (EventDate): gen check1= (EventCodeMO==7 & EventCodeMO[_n+1]!=18)

sort IndividualId EventDate EventCode
	*CHANGE 
capture drop Dead*
*bysort IndividualId (EventDate): gen DeadMO=sum(EventCodeMO[_n-1]==7)
bysort IndividualId (EventDate): gen DeadMO=sum(EventCodeMO[_n-1]==7) 
bysort IndividualId (EventDate): gen DeadFA=sum(EventCodeFA[_n-1]==7) 
bysort IndividualId (EventDate): gen DeadPGM=sum(EventCodePGM[_n - 1]==7) 
bysort IndividualId (EventDate): gen DeadPGF=sum(EventCodePGF[_n - 1]==7)
bysort IndividualId (EventDate): gen DeadMGM=sum(EventCodeMGM[_n - 1]==7) 
bysort IndividualId (EventDate): gen DeadMGF=sum(EventCodeMGF[_n - 1]==7) 

bysort IndividualId (EventDate): gen DeadY=sum(EventCodeY[_n - 1]==7) 
bysort IndividualId (EventDate): gen DeadO=sum(EventCodeO[_n -1]==7) 

* To note: some mothers and younger siblings died twice!
replace DeadMO = 1 if DeadMO>1 & DeadMO!=. /*Added*/
replace DeadFA = 1 if DeadFA>1 & DeadFA!=. /*Added*/
replace DeadPGM = 1 if DeadPGM>1 & DeadPGM!=. /*Added*/
replace DeadPGF = 1 if DeadPGF>1 & DeadPGF!=. /*Added*/
replace DeadMGM = 1 if DeadMGM>1 & DeadMGM!=. /*Added*/
replace DeadMGF = 1 if DeadMGF>1 & DeadMGF!=. /*Added*/


	replace DeadY = 1 if DeadY>1 & DeadY!=. /*Added*/
	replace DeadO = 1 if DeadO>1 & DeadO!=. /*Added*/



* New variable for residence accounting for death: (problems with these variables)
	capture drop MigDeadMO
	gen MigDeadMO=(1+residenceMO+2*DeadMO)
	lab def MigDeadMO 1"mother non resident" 2 "mother res" 3 "mother dead" 4 "mother res dead?",  modify
	lab val MigDeadMO MigDeadMO


**Vérifier le cas des 128
recode MigDeadMO (4 = 3)



* New variable for residence accounting for death: (problems with these variables)
	capture drop MigDeadFA
	gen MigDeadFA=(1+residenceFA+2*DeadFA)
	lab def MigDeadFA 1"father non resident" 2 "father res" 3 "father dead" 4 "father res dead?",  modify
	lab val MigDeadFA MigDeadFA

**Vérifier le cas des 128
recode MigDeadFA (4 = 3)



* New variable for residence accounting for death: (problems with these variables)
	capture drop MigDeadPGM
	gen MigDeadPGM=(1+residencePGM+2*DeadPGM)
	lab def MigDeadPGM 1"pgmother non resident" 2 "pgmother res" 3 "pgmother dead" 4 "pgmother res dead?",  modify
	lab val MigDeadPGM MigDeadPGM

**Vérifier le cas des 128
recode MigDeadPGM (4 = 3)


* New variable for residence accounting for death: (problems with these variables)
	capture drop MigDeadPGF
	gen MigDeadPGF=(1+residencePGF+2*DeadPGF)
	lab def MigDeadPGF 1"mgfather non resident" 2 "mgfather res" 3 "mgfather dead" 4 "mgfather res dead?",  modify
	lab val MigDeadPGF MigDeadPGF

**Vérifier le cas des 128
recode MigDeadPGF (4 = 3)


*XX
* New variable for residence accounting for death: (problems with these variables)
	capture drop MigDeadMGM
	gen MigDeadMGM=(1+residenceMGM+2*DeadMGM)
	lab def MigDeadMGM 1"mgmother non resident" 2 "mgmother res" 3 "mgmother dead" 4 "mgmother res dead?",  modify
	lab val MigDeadMGM MigDeadMGM

**Vérifier le cas des 128
recode MigDeadMGM (4 = 3)
recode MigDeadMGM (.=1)



* New variable for residence accounting for death: (problems with these variables)
	capture drop MigDeadMGF
	gen MigDeadMGF=(1+residenceMGF+2*DeadMGF)
	lab def MigDeadMGF 1"mgfather non resident" 2 "mgfather res" 3 "mgfather dead" 4 "mgfather res dead?",  modify
	lab val MigDeadMGF MigDeadMGF

**Vérifier le cas des 128
recode MigDeadMGF (4 = 3)



*gen MigDeadY=cond(residenceY==., 0, 1 + (residenceY==1) + 2*(DeadY==1))
gen MigDeadY=cond(residenceY==., 0, 1 + (residenceY==1) + 2*(DeadY==1))
lab def MigDeadY 0 "no young sibling" 1 "y sibling non-res" 2 "y sibling resident" 3 "y sibling non res dead" 4"y sibling res dead",  modify
lab val MigDeadY MigDeadY
gen MigDeadO=cond(residenceO==., 0, 1 + (residenceO==1) + 2*(DeadO==1))

lab def MigDeadO 0 "no older sibling" 1 "o sibling non-res" 2 "o sibling resident" 3 "o sibling dead" 4"o sibling res dead?",  modify
lab val MigDeadO MigDeadO

ta MigDeadY
ta MigDeadO

recode MigDeadY(4=3) 
recode MigDeadO(4=3) 

capture drop datebeg
sort IndividualId EventDate EventCode
qui by IndividualId: gen double datebeg=cond(_n==1, DoB, EventDate[_n-1])
format datebeg %tc

drop if datebeg<DoB


**Groupe d'âge de la mère
capture drop mother_age_birth
gen mother_age_birth = (DoB - DoBMO)/31557600000

**Erreurs (âge de la mère à la naissance inférieur à 13 ans ou supérieur à 50 ans)
gen error_m_age = cond(mother_age_birth==.,.,cond(mother_age_birth<13| mother_age_birth>50,1,0))

**Supprimer ces incohérences (7752 individus supprimés)
drop if error_m_age == 1

capture drop gp_mother_age_birth
gen gp_mother_age_birth = cond(mother_age_birth==.,4,cond(mother_age_birth<18,1,cond(mother_age_birth<36,2,3)))
label def gp_age 1"<18 years" 2"18 - 35 y" 3"35 years &+" 4"Missing",modify
label val gp_mother_age_birth gp_age

* PhB 05-07-2018:
capture drop y3_mother_age_birth
gen int_mother_age_birth=int(mother_age_birth)
recode int_mother_age_birth (min/17=15 "15-17") (18/20=18 "18–20") (21/23=21 "21–23") ///
		(24/26=22 "24–26") (27/29=27 "27–29") (30/32=30 "30–32") (33/35=33 "33–35") ///
		(36/38=36 "36–38") (39/41=39 "39–41") (42/max=42 "42+") (.=99 "Missing"), gen(y3_mother_age_birth)
drop int_mother_age_birth


**Groupe âge, âge du père
capture drop father_age_birth
gen father_age_birth = (DoB - DoBFA)/31557600000


capture drop y3_father_age_birth
gen int_father_age_birth=int(father_age_birth)
recode int_father_age_birth (min/29=1 "<30") (30/34=2 "30–34") (35/39=3 "35–39") ///
		(40/44=4 "40–44") (45/49=5 "45–49") (50/54=6 "50–54") (55/59=7 "55–59") ///
		(60/64=8 "60–64") (65/max=39 "65&+") (.=99 "Missing"), gen(y3_father_age_birth)
drop int_father_age_birth



*capture drop ecart_O
*gen ecart_O = (DoB - DoBOsibling)*12/31557600000
*capture drop gp_ecart_O
*gen gp_ecart_O = cond(ecart_O==.,0,cond(ecart_O<18,1,2))
*recode gp_ecart_O (2=0)



capture drop ecart_O 
gen ecart_O = (DoB - DoBOsibling)*12/31557600000
capture drop gp_ecart_O
* PhB 06-07-2018:
gen gp_ecart_O = cond(ecart_O==.,0, ///
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
		12 "42-44 months" 13 "45-47 months" 14 "48-50 months" 15 "51-53 months" 16"54+ months", modify
label val gp_ecart_O gp_age_so

*YaC 18082018 (for interactions)
capture drop gp_ecart_O_new
gen gp_ecart_O_new = cond(ecart_O==.,0, ///
				cond(ecart_O<12,1, ///
				cond(ecart_O<18,2, ///
				cond(ecart_O<24,3, ///
				cond(ecart_O<30,4, ///
				cond(ecart_O<36,5, ///
				cond(ecart_O<42,6, ///
				cond(ecart_O<48,7, ///
				8))))))))
				

label def lgp_ecart_O_new 0"NoOS" 1"<12 months" 2"12-17 months" 3"18-23 months" ///
		4 "24-29 months" 5 "30-35 months" 6 "36-41 months" 7 "42-47 months" 8 "48 months&+",modify
label val gp_ecart_O_new lgp_ecart_O_new






capture drop ecart_Y 
gen ecart_Y = (DoBYsibling - DoB)*12/31557600000
capture drop gp_ecart_Y
* PhB 06-07-2018:
gen gp_ecart_Y = cond(ecart_Y==.,0, ///
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
		12 "42-44 months" 13 "45-47 months" 14 "48-50 months" 15 "51-53 months" 16"54+ months", modify
label val gp_ecart_Y gp_age_sy			
				
				
*YaC 14072018
gen gp_ecart_Y_new = cond(ecart_Y==.,0, ///
				cond(ecart_Y<12,1, ///
				cond(ecart_Y<18,2, ///
				cond(ecart_Y<24,3, ///
				cond(ecart_Y<30,4, ///
				cond(ecart_Y<36,5, ///
				cond(ecart_Y<42,6, ///
				cond(ecart_Y<48,7, ///
				8))))))))

label def lgp_ecart_Y_new 0 "NoYS" 1 "<12 months" 2 "12-17 months" 3 "18-23 months" ///
		4 "24-29 months" 5 "30-35 months" 6 "36-41 months" 7 "42-47 months" 8 "48 months&+" 
		label val gp_ecart_Y_new lgp_ecart_Y_new

*Erreurs probables
edit IndividualId DoB OsiblingId DoBOsibling ecart_O MotherId  if ecart_O<9

*Erreurs
**Ecart entre le Younger sibling et index inférieur à 9 mois
edit IndividualId DoB YsiblingId DoBYsibling ecart_Y MotherId  if ecart_Y<9
*Ecart entre le Older sibling et index inférieur à 9 mois
edit IndividualId DoB OsiblingId DoBOsibling ecart_O MotherId  if ecart_O<9

*Ecart entre le Younger sibling et le index supérieur à 34 ans (408 mois)
edit IndividualId DoB YsiblingId DoBYsibling ecart_Y MotherId  if ecart_Y>408&ecart_Y!=.
*Ecart entre le Younger sibling et le index supérieur à 34 ans (408 mois)
edit IndividualId DoB OsiblingId DoBOsibling ecart_O MotherId  if ecart_O>408&ecart_O!=.


*Supprimer ces erreurs
drop if ecart_Y<9
drop if ecart_O<9
drop if ecart_O>408&ecart_O!=.
drop if ecart_Y>408&ecart_Y!=.
*XX

*PhB mail 03082018
replace migrant_statusMO = 0 if MigDeadMO==1
* PhB 05-07-2018: I asked to change the birth interval variable for resident sibling only:
gen gp_ecart_Yres = cond(MigDeadY==2,gp_ecart_Y,0)
gen gp_ecart_Ores = cond(MigDeadO==2,gp_ecart_O,0)
gen gp_ecart_Ores_new = cond(MigDeadO==2,gp_ecart_O_new,0)



label val gp_ecart_Yres gp_age_sy
label val gp_ecart_Ores gp_age_so
label val gp_ecart_Ores_new lgp_ecart_O_new


*YaC 14072018
sort IndividualId EventDate
gen birth_int_Yres_12m = cond(gp_ecart_Y_new==1&MigDeadY==2,birth_int_YS ,0)
replace birth_int_Yres_12m=1 if birth_int_YS==1 & gp_ecart_Y_new[_n+1]==1
label val birth_int_Yres_12m lbirth_int_YS

gen birth_int_Yres_12_17m = cond(gp_ecart_Y_new==2&MigDeadY==2,birth_int_YS ,0)
replace birth_int_Yres_12_17m=1 if birth_int_YS==1 & gp_ecart_Y_new[_n+1]==2
label val birth_int_Yres_12_17m lbirth_int_YS

gen birth_int_Yres_18_23m = cond(gp_ecart_Y_new==3&MigDeadY==2,birth_int_YS ,0)
replace birth_int_Yres_18_23m=1 if birth_int_YS==1 & gp_ecart_Y_new[_n+1]==3
label val birth_int_Yres_18_23m lbirth_int_YS

gen birth_int_Yres_24_29m = cond(gp_ecart_Y_new==4&MigDeadY==2,birth_int_YS ,0)
replace birth_int_Yres_24_29m=1 if birth_int_YS==1 & gp_ecart_Y_new[_n+1]==4
label val birth_int_Yres_24_29m lbirth_int_YS

gen birth_int_Yres_30_35m = cond(gp_ecart_Y_new==5&MigDeadY==2,birth_int_YS ,0)
replace birth_int_Yres_30_35m=1 if birth_int_YS==1 & gp_ecart_Y_new[_n+1]==5
label val birth_int_Yres_30_35m lbirth_int_YS

gen birth_int_Yres_36_41m  = cond(gp_ecart_Y_new==6&MigDeadY==2,birth_int_YS ,0)
replace birth_int_Yres_36_41m=1 if birth_int_YS==1 & gp_ecart_Y_new[_n+1]==6
label val birth_int_Yres_36_41m lbirth_int_YS

gen birth_int_Yres_42_47m  = cond(gp_ecart_Y_new==7&MigDeadY==2,birth_int_YS ,0)
replace birth_int_Yres_42_47m=1 if birth_int_YS==1 & gp_ecart_Y_new[_n+1]==7
label val birth_int_Yres_42_47m lbirth_int_YS

gen birth_int_Yres_48_more  = cond(gp_ecart_Y_new==8&MigDeadY==2,birth_int_YS ,0)
replace birth_int_Yres_48_more=1 if birth_int_YS==1 & gp_ecart_Y_new[_n+1]==8
label val birth_int_Yres_48_more lbirth_int_YS


/*
gen new_var= MigDeadY*1000 + birth_int_Yres_12m + (10+ birth_int_Yres_12_17m) + (20+ birth_int_Yres_18_23m) ///
+(30+ birth_int_Yres_24_29m)+ (40+ birth_int_Yres_30_35m)+ (50+ birth_int_Yres_36_41m)+ (60+ birth_int_Yres_42_47m) ///
+(70+ birth_int_Yres_48_more)
*/
capture drop gp_birth_int_YS
gen gp_birth_int_YS= MigDeadY*1000 + birth_int_Yres_12m + cond(birth_int_Yres_12_17m==0,0,10+ birth_int_Yres_12_17m) + cond(birth_int_Yres_18_23m==0,0,20+ birth_int_Yres_18_23m) ///
+ cond(birth_int_Yres_24_29m==0,0,30+ birth_int_Yres_24_29m)+ cond(birth_int_Yres_30_35m==0,0,40+ birth_int_Yres_30_35m)+ cond(birth_int_Yres_36_41m==0,0,50+ birth_int_Yres_36_41m)+ cond(birth_int_Yres_42_47m==0,0,60+ birth_int_Yres_42_47m) ///
+ cond(birth_int_Yres_48_more==0,0,70+ birth_int_Yres_48_more)

label define lgp_birth_int_YS ///
0"NoYS"	///
1"Int <12m - pregnant" ///	
11"Int 12-17m - pregnant" ///	
21"Int 18-23m - pregnant" ///	
31"Int 24-29m - pregnant" ///	
41"Int 30-35m - pregnant" ///	
51"Int 36-41m - pregnant" ///	
61"Int 42-47m - pregnant" ///
71"Int >=48m&+ - pregnant" ///	
1000"y sibling non-res" ///
2002"Int <12m - 0-6 month" ///	
2003"Int <12m - 6-12 month" ///	
2004"Int <12m - 12 month&+" ///	
2012"Int 12-17m - 0-6 month" ///	
2013"Int 12-17m - 6-12 month" ///	
2014"Int 12-17m - 12 month&+" ///	
2022"Int 18-23m - 0-6 month" ///	
2023"Int 18-23m - 6-12 month" ///	
2024"Int 18-23m - 12 month&+" ///	
2032"Int 24-29m - 0-6 month" ///	
2033"Int 24-29m - 6-12 month" ///	
2034"Int 24-29m - 12 month&+" ///	
2042"Int 30-35m - 0-6 month" ///	
2043"Int 30-35m - 6-12 month" ///	
2044"Int 30-35m - 12 month&+" ///	
2052"Int 36-41m - 0-6 month" ///	
2053"Int 36-41m - 6-12 month" ///	
2054"Int 36-41m - 12 month&+" ///	
2062"Int 42-47m - 0-6 month" ///	
2063"Int 42-47m - 6-12 month" ///	
2064"Int 42-47m - 12 month&+" ///	
2072"Int >=48m&+ - 0-6 month" ///	
2073"Int >=48m&+ - 6 month&+" ///	
2074"Int >=48m&+ - 12 month&+" ///	
3000"y sibling dead", modify	

label val gp_birth_int_YS lgp_birth_int_YS

recode gp_birth_int_YS (2074=2073)


capture drop pregnant_YS
gen pregnant_YS = (birth_int_YS==1)
lab define pregnant 1"3-9m pregnant" 0"No this period",modify
label val pregnant_YS pregnant

capture drop twin
gen twin = (TwinId !="")
label define twin 1"Yes" 0"No"
label val twin twin

**Vérifications des variables
stset EventDate if residence==1, id(IndividualId) failure(censor_death==1) ///
		time0(datebeg) origin(time DoB) exit(time .) scale(31557600000)

/*
log using tables_verif,replace
table MigDeadY birth_int_Yres_12m [iw=_t-_t0], content(freq) format(%10.0f) missing
table MigDeadY birth_int_Yres_12_17m [iw=_t-_t0], content(freq) format(%10.0f) missing
table MigDeadY birth_int_Yres_18_23m [iw=_t-_t0], content(freq) format(%10.0f) missing
table MigDeadY birth_int_Yres_24_29m [iw=_t-_t0], content(freq) format(%10.0f) missing
table MigDeadY birth_int_Yres_30_35m [iw=_t-_t0], content(freq) format(%10.0f) missing
table MigDeadY birth_int_Yres_36_41m [iw=_t-_t0], content(freq) format(%10.0f) missing
table MigDeadY birth_int_Yres_42_47m [iw=_t-_t0], content(freq) format(%10.0f) missing
table MigDeadY birth_int_Yres_48_more [iw=_t-_t0], content(freq) format(%10.0f) missing
table MigDeadMO migrant_statusMO [iw=_t-_t0], content(freq) format(%10.0f) missing
*table MigDeadMO MO_DTH_TVC [iw=_t-_t0], content(freq) format(%10.0f) missing
log close
*/

*XX
*Détection des incohérences
sort IndividualId EventDate
qui bys IndividualId : gen foll_MigDeadMO=MigDeadMO[_n+1]
lab var foll_MigDeadMO "Following event"
lab val foll_MigDeadMO MigDeadMO
tab MigDeadMO foll_MigDeadMO, missing

sort IndividualId EventDate
qui bys IndividualId : gen foll_MigDeadO=MigDeadO[_n+1]
lab var foll_MigDeadO "Following event"
lab val foll_MigDeadO OS
tab MigDeadO foll_MigDeadO, missing

sort IndividualId EventDate
qui bys IndividualId : gen foll_MigDeadY=MigDeadY[_n+1]
lab var foll_MigDeadY "Following event"
lab val foll_MigDeadY YS
tab MigDeadY foll_MigDeadY, missing





*Suprimer les cas où la variable Sex est une valeur manquante.

recode gp_mother_age_birth (.=4)
label val gp_mother_age_birth gp_age

*XX
*Yac 03082018
*Vérifications et corrections
foreach var of varlist MigDeadMO Sex y3_mother_age_birth migrant_statusMO  MigDeadO gp_ecart_Ores ///
                       MigDeadY  birth_int_Yres_12m birth_int_Yres_12_17m ///
                       birth_int_Yres_18_23m birth_int_Yres_24_29m birth_int_Yres_30_35m birth_int_Yres_36_41m ///
                       birth_int_Yres_42_47m birth_int_Yres_48_more twin  {
					   
					   ta `var',m
					   }



foreach var of varlist   birth_int_Yres_12m birth_int_Yres_12_17m  ///
                       birth_int_Yres_18_23m birth_int_Yres_24_29m birth_int_Yres_30_35m birth_int_Yres_36_41m ///
                       birth_int_Yres_42_47m birth_int_Yres_48_more migrant_statusMO{
					   
					   replace `var' = 0 if `var'==.
					   }


recode birth_int_Yres_48_more (4=3)
label define lbirth_int_Yres_48_more 1"pregnant_YS" 2"0-6m" 3"6m&+", modify
label val birth_int_Yres_48_more lbirth_int_Yres_48_more

stset EventDate if residence==1, id(IndividualId) failure(censor_death==1) ///
		time0(datebeg) origin(time DoB)  scale(31557600000)


ta Sex
replace Sex=1 if Sex==3
drop if Sex==-1
stset EventDate if residence==1, id(IndividualId) failure(censor_death==1) ///
		time0(datebeg) origin(time DoB) exit(censor_death==1 time DoB+(31557600000*5)+212000000) scale(31557600000)

	
drop if MotherId=="" & FatherId==""

save base_analyse_def_02052019_bis,replace
XX
*M1
forval i=1/2{
stcox ib2.MigDeadMO ib2.MigDeadO ib2.MigDeadY  ib0.twin i.Sex ib21.y3_mother_age_birth ///
 if center==`i',vce(cluster MotherId)iter(10)
}
*M2
stcox ib2.MigDeadMO ib2.MigDeadO ib2.MigDeadY ib2.MigDeadFA ib0.twin i.Sex ,vce(cluster MotherId)

*M3
stcox ib2.MigDeadMO ib2.MigDeadO ib2.MigDeadY ib2.MigDeadFA ib2.MigDeadPGM ib0.twin i.Sex ib21.y3_mother_age_birth ///
,vce(cluster MotherId)
*M4
stcox ib2.MigDeadMO ib2.MigDeadO ib2.MigDeadY ib2.MigDeadFA ib2.MigDeadPGM ib2.MigDeadPGF ib0.twin i.Sex ib21.y3_mother_age_birth ///
, vce(cluster MotherId)


XX Arrêt sur les analyses côté Niakhar


***Modèle Standard
log using modele_standard, replace
stcox ib2.MigDeadMO ib2.MigDeadO ib2.MigDeadY i.Sex ib21.y3_mother_age_birth ///
i.gp_ecart_Y  i.gp_ecart_O  i.pregnant_YS i.period, vce(cluster MotherId)
log close

estimates store mean_model

coefplot, xline(1) eform xtitle(Hazards Ratio)levels(95)drop(1.MigDeadMO  3.MigDeadMO ///
 1.gp_ecart_Y  2.gp_ecart_Y  3.gp_ecart_Y  4.gp_ecart_Y 5.gp_ecart_Y) ///
 mlabel format(%9.2f) mlabposition(12)mlabgap(*1) ///
 coeflabels (1.MigDeadMO = "No resident" 2.MigDeadO = "Resident" ///
 3.MigDeadO = "Dead"  1.MigDeadY="No resident" 2.MigDeadY= "Resident" ///
 3.MigDeadY = "Dead" 2.Sex="Girls" 2.gp_mother_age_birth="18 - 35 y" 3.gp_mother_age_birth="35y&+"  ///
 4.gp_mother_age_birth="DK" 1.gp_ecart_O ="<12 months",notick labsize(small) labcolor(purple) labgap(1)) ///
headings(1.MigDeadO=`""{bf:Older sibling Status}" "Ref : No older sibling""' 1.MigDeadY=`""{bf:Younger sibling Status}" "Ref : No younger sibling""' /// 
2.Sex=`""{bf:Gender}" "Ref : Boys""' ///
2.gp_mother_age_birth=`""{bf:Mother age}" "Ref : <18 years""' 1.gp_ecart_O=`""{bf:Spacing to the preceding birth}" "Ref : No older sibling"""', ///
labcolor(blue)) xscale(log)omitted 


coefplot, xline(1) eform xtitle(Hazards Ratio)levels(95)keep(1.MigDeadMO  3.MigDeadMO ///
 1.gp_ecart_Y  2.gp_ecart_Y  3.gp_ecart_Y  4.gp_ecart_Y 5.gp_ecart_Y) ///
 mlabel format(%9.2f) mlabposition(12)mlabgap(*1) ///
 coeflabels (1.MigDeadMO = "No resident" 3.MigDeadMO ="Dead" ///
 1.gp_ecart_Y ="<12 months"  0b.gp_ecart_Y="ref",notick labsize(small) labcolor(purple) labgap(2)) ///
headings(1.MigDeadMO=`""{bf:Mother Status}" "Ref : Resident""' ///
1.gp_ecart_Y=`""{bf:Spacing to the next birth}" "Ref : No younger sibling" "or > 24 months"""', labcolor(blue)) xscale(log range(0.5 15))baselevels
graph save graphique_2.png,replace


***Modèle Standard
* PhB 06-07-2018:
log using modele_standard_010820181, replace
stcox ib2.MigDeadMO i.Sex ib21.y3_mother_age_birth ib0.migrant_statusMO ib0.MO_DTH_TVC ib2.MigDeadO ib0.gp_ecart_Ores ///
ib2.MigDeadY  i.pregnant_YS ib0.gp_ecart_Yres ib0.birth_int_Yres_12m ib0.birth_int_Yres_12_17m ///
ib0.birth_int_Yres_18_23m ib0.birth_int_Yres_24_29m ib0.birth_int_Yres_30_35m ib0.birth_int_Yres_36_41m ///
ib0.birth_int_Yres_42_47m ib0.birth_int_Yres_48_more ib0.twin i.period, vce(cluster MotherId)
log close


* PhB 06-07-2018:
log using model1_bis_01082018,replace
stcox ib2.MigDeadMO#ib2.MigDeadO ib0.gp_ecart_Ores ib2.MigDeadMO#ib2.MigDeadY ib0.gp_ecart_Yres ///
i.pregnant_YS ib21.y3_mother_age_birth i.Sex ib0.migrant_statusMO ib0.MO_DTH_TVC ///
ib0.birth_int_Yres_12m ib0.birth_int_Yres_12_17m ib0.birth_int_Yres_18_23m ib0.birth_int_Yres_24_29m ///
ib0.birth_int_Yres_30_35m ib0.birth_int_Yres_36_41m ib0.birth_int_Yres_42_47m ib0.birth_int_Yres_48_more ib0.twin i.period ///
,vce(cluster MotherId) iter(10)
log close


* PhB 06-07-2018:
log using model_inter_MigDeadO_MigDeadY_bis,replace
stcox i.Sex ib2.MigDeadMO ib21.y3_mother_age_birth ib2.MigDeadO#ib2.MigDeadY  ///
ib0.gp_ecart_Ores ib0.gp_ecart_Yres i.pregnant_YS i.period, vce(cluster MotherId) iter(8)
log close

* Phb 03082018
  

log using model_standar_03082018
stcox ib2.MigDeadMO i.Sex ib21.y3_mother_age_birth ib0.migrant_statusMO ib0.MO_DTH_TVC ib2.MigDeadO ib0.gp_ecart_Ores ///
        ib2.MigDeadY  ib0.birth_int_Yres_12m ib0.birth_int_Yres_12_17m ///
        ib0.birth_int_Yres_18_23m ib0.birth_int_Yres_24_29m ib0.birth_int_Yres_30_35m ib0.birth_int_Yres_36_41m ///
        ib0.birth_int_Yres_42_47m ib0.birth_int_Yres_48_more ib0.twin i.period, vce(cluster MotherId)
log close



log using model1_bis_03082018
stcox ib2.MigDeadMO#ib2.MigDeadO ib0.gp_ecart_Ores i.Sex ib21.y3_mother_age_birth ib0.migrant_statusMO ib0.MO_DTH_TVC   ///
        ib2.MigDeadMO#ib2.MigDeadY  ib0.birth_int_Yres_12m ib0.birth_int_Yres_12_17m ///
        ib0.birth_int_Yres_18_23m ib0.birth_int_Yres_24_29m ib0.birth_int_Yres_30_35m ib0.birth_int_Yres_36_41m ///
        ib0.birth_int_Yres_42_47m ib0.birth_int_Yres_48_more ib0.twin i.period, vce(cluster MotherId)
log close




stcox ib2.MigDeadMO i.Sex ib21.y3_mother_age_birth ib0.migrant_statusMO ib0.MO_DTH_TVC ib2.MigDeadO ib0.gp_ecart_Ores ///
        ib2.MigDeadY  ib0.birth_int_Yres_12m ib0.birth_int_Yres_12_17m ///
        ib0.birth_int_Yres_18_23m ib0.birth_int_Yres_24_29m ib0.birth_int_Yres_30_35m ib0.birth_int_Yres_36_41m ///
        ib0.birth_int_Yres_42_47m ib0.birth_int_Yres_48_more ib0.twin i.period

log using tables,replace
table MigDeadY gp_ecart_Y [iw=_t-_t0], content(freq) format(%10.0f) missing
table MigDeadO gp_ecart_O [iw=_t-_t0], content(freq) format(%10.0f) missing
log close


log using model_ERC_080818,replace
stcox ib2.MigDeadMO i.Sex ib21.y3_mother_age_birth ib0.migrant_statusMO ib2.MigDeadO ///
        ib2.MigDeadY  ib0.twin i.period, vce(cluster MotherId)
log close



log using model_ERC_090818,replace
stcox ib2.MigDeadMO i.Sex ib21.y3_mother_age_birth ib2.MigDeadO ///
        ib2.MigDeadY  ib0.twin i.period, vce(cluster MotherId)

log close

estimates store model_ERC_090818
matrix list e(b)

coefplot, yline(1) eform levels(95)keep(1.MigDeadMO  3.MigDeadMO ///
 0.MigDeadO 1.MigDeadO  3.MigDeadO  0.MigDeadY 1.MigDeadY  3.MigDeadY) ///
 mlabel format(%9.2f) mlabposition(12)mlabgap(*2) xlabel(, angle(vertical)) ///
 coeflabels (1.MigDeadMO = "non resident" 3.MigDeadMO ="dead" ///
 0.MigDeadO ="none" 1.MigDeadO="non resident" 3.MigDeadO="dead" ///
  0.MigDeadY ="none" 1.MigDeadY="non resident" 3.MigDeadY="dead",notick labsize(small) labcolor(purple) labgap(2))vertical ///
 groups(1.MigDeadMO 3.MigDeadMO = "{bf:Mother}" 0.MigDeadO 1.MigDeadO 3.MigDeadO = "{bf:Older sibling}" ///
 0.MigDeadY 1.MigDeadY 3.MigDeadY = "{bf:Younger sibling}") 

*YAC 10082018
log using model_standar_11082018
stcox ib0.MigDeadMO_MO_DTH_TVC i.Sex ib21.y3_mother_age_birth ib0.migrant_statusMO ib2.MigDeadO ib0.gp_ecart_Ores ///
        ib2.MigDeadY  ib0.birth_int_Yres_12m ib0.birth_int_Yres_12_17m ///
        ib0.birth_int_Yres_18_23m ib0.birth_int_Yres_24_29m ib0.birth_int_Yres_30_35m ib0.birth_int_Yres_36_41m ///
        ib0.birth_int_Yres_42_47m ib0.birth_int_Yres_48_more ib0.twin i.period, vce(cluster MotherId)
log close

estimates store model_standard_11082018

**Vérifications
*Taux de mortalité
log using mortality_rate_bis,replace
table gp_ecart_Y_new birth_int_YS [iw=_t-_t0] , content(mean censor_death) format(%8.5f) missing
log close
*
sts graph, hazard kernel(rectangle) width(.1)

*
stcurve, hazard kernel(rectangle) width(.1) ///
        at(MigDeadMO_MO_DTH_TVC=0 Sex=1 y3_mother_age_birth=21 migrant_statusMO=0  MigDeadO=0 gp_ecart_Ores=0 ///
        MigDeadY=0  birth_int_Yres_12m=0 birth_int_Yres_12_17m=0 ///
        birth_int_Yres_18_23m=0 birth_int_Yres_24_29m=0 birth_int_Yres_30_35m=0 birth_int_Yres_36_41m=0 ///
        birth_int_Yres_42_47m=0 birth_int_Yres_48_more=0 twin=0 period=1989)






outreg2 using model_interaction, excel ci  eform dec(2) ///
addstat(Wald Chi-square, e(chi2), Log Lik, e(ll), Subjects, e(N_sub), Time at risk, ///
 e(risk), Failures, e(N_fail)) ctitle("new_result")label  sideway


**************************************************************************************
decode CentreLab, gen(Center_string)
		  
global Center_string  BF021 BF041 CI011 ET021  ET031 ET041  ET051 ET061 GH011 ///   
			          GH021 GH031 GM011 KE011  KE031 MW011  MZ021  SN011 SN012 SN013 ///
			          TZ011   TZ012  TZ013 ZA011  ZA021  ZA031
			   
			   
			   				  
stset EventDate if residence==1, id(IndividualId) failure(censor_death==1) ///
		time0(datebeg) origin(time DoB) exit(time .) scale(31557600000)
		
		

				  
foreach lname of global Center_string {
stcox ib0.MigDeadMO_MO_DTH_TVC i.Sex ib21.y3_mother_age_birth ib0.migrant_statusMO ib2.MigDeadO ib0.gp_ecart_Ores ///
ib2.MigDeadY  ib0.birth_int_Yres_12m ib0.birth_int_Yres_12_17m ///
ib0.birth_int_Yres_18_23m ib0.birth_int_Yres_24_29m ib0.birth_int_Yres_30_35m ib0.birth_int_Yres_36_41m ///
ib0.birth_int_Yres_42_47m ib0.birth_int_Yres_48_more ib0.twin i.period if Center_string=="`lname'",iter(11) vce(cluster MotherId)
estimates store Model_`lname'
outreg2 using comp_mort_HDSS_hz, excel ci  eform dec(2) ///
addstat(Wald Chi-square, e(chi2), Log Lik, e(ll), Subjects, e(N_sub), Time at risk, ///
 e(risk), Failures, e(N_fail)) ctitle("`lname'")label  sideway
 outreg2 using comp_mort_HDSS_tstats, excel  eform dec(2) alpha(0.001, 0.01, 0.05)  ///
noparen  tstat addstat(Wald Chi-square, e(chi2), Log Lik, e(ll), Subjects, e(N_sub), Time at risk, ///
 e(risk), Failures, e(N_fail)) ctitle("`lname'")label  sideway
}


****

foreach lname of global Center_string {
gen center_`lname' = (Center_string=="`lname'")
stcox (ib2.MigDeadMO ib2.MigDeadO ib2.MigDeadY i.Sex ib21.y3_mother_age_birth ///
i.gp_ecart_Y  i.gp_ecart_O)##center_`lname' i.period_HDSS_2, vce(cluster MotherId)
estimates store Model_center`lname'
outreg2 using comp_mort_HDSS_interaction_hz, excel ci  eform dec(2) ///
 addstat(Wald Chi-square, e(chi2), Log Lik, e(ll), Subjects, e(N_sub), Time at risk, ///
 e(risk), Failures, e(N_fail)) ctitle("`lname'")label  sideway
 outreg2 using comp_mort_HDSS_interaction_tstat, excel  eform dec(2) alpha(0.001, 0.01, 0.05)  ///
noparen  tstat addstat(Wald Chi-square, e(chi2), Log Lik, e(ll), Subjects, e(N_sub), Time at risk, ///
 e(risk), Failures, e(N_fail)) ctitle("`lname'")label  sideway
}


**Bis
 set maxiter 10
global Center_string  SN011 SN012 SN013 TZ011 TZ012 TZ013 ZA011 ZA021 ZA031
			   

****
foreach lname of global Center_string {
gen center_`lname' = (Center_string=="`lname'")
stcox (ib2.MigDeadMO ib2.MigDeadO ib2.MigDeadY i.Sex ib21.y3_mother_age_birth ///
i.gp_ecart_Y  i.gp_ecart_O)##center_`lname' i.period_HDSS_2, iter(5) vce(cluster MotherId)
estimates store Model_center`lname'
outreg2 using comp_mort_HDSS_interaction_hz, excel ci  eform dec(2) ///
 addstat(Wald Chi-square, e(chi2), Log Lik, e(ll), Subjects, e(N_sub), Time at risk, ///
 e(risk), Failures, e(N_fail)) ctitle("`lname'")label  sideway
 outreg2 using comp_mort_HDSS_interaction_tstat, excel  eform dec(2) alpha(0.001, 0.01, 0.05)  ///
noparen  tstat addstat(Wald Chi-square, e(chi2), Log Lik, e(ll), Subjects, e(N_sub), Time at risk, ///
 e(risk), Failures, e(N_fail)) ctitle("`lname'")label  sideway
}






**************************************************************************************







capture drop CentreLab
capture lab drop CentreLab
encode CentreId, gen(CentreLab)


	
capture drop group
recode CentreLab (15 10 1 5 9 7=1 "Group 1") (17 11 24 19 3 2 18 20 4 21 22 =2 "Group 2") ///
(13 =3 "Group 3") (12 23 25 =4 "Group 4") (16 6 8 14=5 "Group 5"), gen(group)
*order CentreId CentreLab Country SubContinent 


stset EventDate if residence==1, id(IndividualId) failure(censor_death==1) ///
                time0(datebeg) origin(time DoB) exit(time .) scale(31557600000)


forval i=1/5{
stcox  ib2.MigDeadMO ib2.MigDeadO ib2.MigDeadY i.Sex ib21.y3_mother_age_birth ///
i.gp_ecart_Y  i.gp_ecart_O if group==`i', vce(cluster MotherId)
estimates store Model_group`i'
outreg2 using comp_mort_Group_interaction_hz, excel ci  eform dec(2) ///
 addstat(Wald Chi-square, e(chi2), Log Lik, e(ll), Subjects, e(N_sub), Time at risk, ///
 e(risk), Failures, e(N_fail)) ctitle("`i'")label  sideway
 outreg2 using comp_mort_Group_interaction_tstat, excel  eform dec(2) alpha(0.001, 0.01, 0.05)  ///
noparen  tstat addstat(Wald Chi-square, e(chi2), Log Lik, e(ll), Subjects, e(N_sub), Time at risk, ///
 e(risk), Failures, e(N_fail)) ctitle("`i'")label  sideway
}

stcox  ib2.MigDeadMO ib2.MigDeadO ib2.MigDeadY i.Sex ib21.y3_mother_age_birth ///
i.gp_ecart_Y  i.gp_ecart_O, vce(cluster MotherId)
estimates store Model_group`i'
outreg2 using comp_mort_Group_interaction_hz, excel ci  eform dec(2) ///
 addstat(Wald Chi-square, e(chi2), Log Lik, e(ll), Subjects, e(N_sub), Time at risk, ///
 e(risk), Failures, e(N_fail)) ctitle("Afrique")label  sideway
 outreg2 using comp_mort_Group_interaction_tstat, excel  eform dec(2) alpha(0.001, 0.01, 0.05)  ///
noparen  tstat addstat(Wald Chi-square, e(chi2), Log Lik, e(ll), Subjects, e(N_sub), Time at risk, ///
 e(risk), Failures, e(N_fail)) ctitle("Afrique")label  sideway

use base_analyse_def_02052019_bis ,clear


**Groupe d'âge paternal grand mother
capture drop mgmother_age_birth
gen mgmother_age_birth = (DoB - DoBMGM)/31557600000
replace mgmother_age_birth=. if mgmother_age_birth<36
bys MGMotherId : replace DoBMGM = DoBMGM-(31557600000*9) if mgmother_age_birth!=.
format DoBMGM %tc
drop mgmother_age_birth 

save base_analyse_def_bis_1,replace






recode MigDeadMGF (3=1),gen(presenceMGF)
recode MigDeadMGM (3=1),gen(presenceMGM)
label define presence 1"Non résident" 2"Résident",modify
label val MigDeadMGM presence
label val MigDeadMGF presence

* Correction 
bys IndividualId (EventDate): replace DoBPGF = DoBPGF[_N]
bys IndividualId (EventDate): replace DoBPGF = DoBPGF[_N]
format DoBPGF %tc
format DoBPGF %tc

bys IndividualId (EventDate): replace DoBMGM = DoBMGM[_N]
bys IndividualId (EventDate): replace DoBMGM = DoBMGM[_N]
format DoBMGM %tc
format DoBMGM %tc

bys IndividualId: replace MotherId = MotherId[_n-1] if missing(MotherId) & _n > 1 
bys IndividualId: replace MotherId = MotherId[_N]
count if MotherId==""

bys IndividualId: replace OsiblingId  = OsiblingId[_n-1] if missing(OsiblingId) & _n > 1 
bys IndividualId: replace OsiblingId  = OsiblingId[_N]
count if OsiblingId ==""

bys IndividualId: replace YsiblingId  = YsiblingId[_n-1] if missing(YsiblingId) & _n > 1 
bys IndividualId: replace YsiblingId  = YsiblingId[_N]
count if YsiblingId ==""




**Groupe âge, âge du grand père paternel
capture drop pgfather_age_birth
gen pgfather_age_birth = (DoB - DoBPGF)/31557600000
replace pgfather_age_birth=. if pgfather_age_birth<40
capture drop gp_pgfather_age_birth
gen gp_pgfather_age_birth = cond(pgfather_age_birth==.,9,cond(pgfather_age_birth<65,1,2))
label def gp_age_pp 1"<65 years" 2"65&+" 9"Missing",modify
label val pgfather_age_birth gp_age_pp
gen gp_PGFres = cond(MigDeadPGF==2,gp_pgfather_age_birth,0)
label val gp_PGFres gp_age_pp


**Groupe d'âge paternal grand mother
capture drop pgmother_age_birth
gen pgmother_age_birth = (DoB - DoBPGM)/31557600000
replace pgmother_age_birth=. if pgfather_age_birth<36
capture drop gp_pgmother_age_birth
gen gp_pgmother_age_birth = cond(pgmother_age_birth==.,9,cond(pgmother_age_birth<65,1,2))
label def gp_age_pp 1"<65 years" 2"65&+" 9"Missing",modify
label val gp_pgmother_age_birth gp_age_pp
gen gp_PGMres = cond(MigDeadPGM==2,gp_pgmother_age_birth,0)
label val gp_PGMres gp_age_pp

/*
capture drop gp_pgmother_age_birth_bis
gen gp_pgmother_age_birth_bis = cond(pgmother_age_birth==.,9, ///
                                cond(pgmother_age_birth<55,1, ///
							    cond(pgmother_age_birth<65,2, ///
							    cond(pgmother_age_birth<75,3,4///
							    cond(pgmother_age_birth<65,5, ///
							    cond(pgmother_age_birth<70,6,7)))))))						
							
label def gp_age_pp_bis 1"<65 years" 2"65&+" 9"Missing",modify
label val gp_pgmother_age_birth gp_age_pp
gen gp_PGMres_bis = cond(MigDeadPGM==2,gp_pgmother_age_birth_bis,0)
label val gp_PGMres gp_age_pp
*/




**Groupe âge, âge du grand père maternel
capture drop mgfather_age_birth
gen mgfather_age_birth = (DoB - DoBMGF)/31557600000
replace mgfather_age_birth=. if mgfather_age_birth<40
capture drop gp_mgfather_age_birth
gen gp_mgfather_age_birth = cond(mgfather_age_birth==.,9,cond(mgfather_age_birth<65,1,2))
label def gp_age_pp 1"<65 years" 2"65&+" 9"Missing",modify
label val gp_mgfather_age_birth gp_age_pp
gen gp_MGFres = cond(MigDeadMGF==2,gp_mgfather_age_birth,0)
label val gp_MGFres gp_age_pp


**Groupe d'âge paternal grand mother
capture drop mgmother_age_birth
gen mgmother_age_birth = (DoB - DoBMGM)/31557600000
replace mgmother_age_birth=. if mgmother_age_birth<36
capture drop gp_mgmother_age_birth
gen gp_mgmother_age_birth = cond(mgmother_age_birth==.,9,cond(mgmother_age_birth<65,1,2))
label def gp_age_pp 1"<65 years" 2"65&+" 9"Missing",modify
label val gp_mgmother_age_birth gp_age_pp
capture drop gp_MGMres
gen gp_MGMres = cond(MigDeadMGM==2,gp_mgmother_age_birth,0)
label val gp_MGMres gp_age_pp

drop if gp_MGFres ==9 | gp_MGMres==9 | gp_PGFres==9 | gp_PGMres==9

*gen gp_ecart_Ores = cond(MigDeadO==2,gp_ecart_O,0)
*gen gp_ecart_Ores_new = cond(MigDeadO==2,gp_ecart_O_new,0)

capture drop presenceMGM_bis
gen presenceMGM_bis = 0 if MigDeadMGM==1 & gp_MGMres==0
replace presenceMGM_bis = 1 if MigDeadMGM>1 & gp_MGMres==1
replace presenceMGM_bis = 2 if  MigDeadMGM>1 & gp_MGMres==2
replace presenceMGM_bis=0 if MigDeadMGM==3
label define res 0"Non-resident" 1"Resident<65 ans" 2"Resident> 65 ans",modify
label val presenceMGM_bis res


capture drop presenceMGF_bis
gen presenceMGF_bis = 0 if MigDeadMGF==1 & gp_MGFres==0
replace presenceMGF_bis = 1 if MigDeadMGF>1 & gp_MGFres==1
replace presenceMGF_bis = 2 if  MigDeadMGF>1 & gp_MGFres==2
replace presenceMGF_bis=0 if MigDeadMGF==3
label define res 0"Non-resident" 1"Resident<65 ans" 2"Resident> 65 ans",modify
label val presenceMGF_bis res


capture drop presencePGM_bis
gen presencePGM_bis = 0 if MigDeadPGM==1 & gp_PGMres==0
replace presencePGM_bis = 1 if MigDeadPGM>1 & gp_PGMres==1
replace presencePGM_bis = 2 if  MigDeadPGM>1 & gp_PGMres==2
replace presencePGM_bis=0 if MigDeadPGM==3
label define res 0"Non-resident" 1"Resident<65 ans" 2"Resident> 65 ans",modify
label val presencePGM_bis res


capture drop presencePGF_bis
gen presencePGF_bis = 0 if MigDeadPGF==1 & gp_PGFres==0
replace presencePGF_bis = 1 if MigDeadPGF>1 & gp_PGFres==1
replace presencePGF_bis = 2 if  MigDeadPGF>1 & gp_PGFres==2
replace presencePGF_bis=0 if MigDeadPGF==3
label define res 0"Non-resident" 1"Resident<65 ans" 2"Resident> 65 ans",modify
label val presencePGF_bis res

stset EventDate if residence==1, id(IndividualId) failure(censor_death==1) ///
		time0(datebeg) origin(time DoB) exit(censor_death==1 time DoB+(31557600000*5)+212000000) scale(31557600000)

XX
**Description de l'échantillon
sts graph , ylabel(.75(.05)1)by(MigDeadMO)
sts graph , by(MigDeadMO)

sts test MigDeadMO, l

**Analyses descriptives
bys MigDeadFA : stdescribe
bys MigDeadMO : stdescribe
bys presenceMGF_bis : stdescribe
bys presenceMGM_bis : stdescribe
bys presencePGF_bis : stdescribe
bys presencePGM_bis : stdescribe

*Sexe de l'enfant
bys Sex :  stdescribe
tabstat _t, by(Sex) stat(mean p25 p50 p75) format(%9.3g)

*Âge du père à la naissance de l'enfant
bys y3_father_age_birth :  stdescribe
tabstat _t, by(y3_father_age_birth) stat(mean p25 p50 p75) format(%9.3g)

*Âge de la mère à la naissance de l'enfant
bys y3_mother_age_birth :  stdescribe
tabstat _t, by(y3_mother_age_birth) stat(mean p25 p50 p75) format(%9.3g)

*Gémélité
bys twin :  stdescribe
tabstat _t, by(twin) stat(mean p25 p50 p75) format(%9.3g)

 *HDSS
 bys center :  stdescribe
tabstat _t, by(center) stat(mean p25 p50 p75) format(%9.3g)





tabstat _t, by(migrant) stat(mean p25 p50 p75)
bys sex: tabstat _t, by(migrant) stat(mean p25 p50 p75)


stcox ib2.MigDeadMO ib2.MigDeadFA i.y3_father_age_birth ib21.y3_mother_age_birth i.presencePGF_bis ///
i.presencePGM_bis i.presenceMGF_bis i.presenceMGM_bis i.center 



**Durées de survies, nombre de décès, moyenne,p50 et 75%
sts graph , by(MigDeadMO)
sts test MigDeadMO, l

sts graph , ylabel(.75(.05)1)by(MigDeadFA)
sts test MigDeadFA, l

*Maternal grand parents

**Grand mother
sts graph , ylabel(.75(.05)1)by(presenceMGM)
sts test presenceMGM, l
**Grand father
sts graph , ylabel(.75(.05)1)by(presenceMGF)
sts test presenceMGF, l

*Paternal grand parents
**Grand mother
sts graph , ylabel(.75(.05)1)by(presencePGM)
sts test MigDeadPGM, l
**Grand father
sts graph , ylabel(.75(.05)1)by(presencePGF)
sts test MigDeadPGF, l
*
stcox ib2.MigDeadMO  ib21.y3_mother_age_birth i.twin i.Sex i.education i.gp_ecart_Yres i.gp_ecart_Ores

*M2
stcox ib2.MigDeadMO  ib21.y3_mother_age_birth i.twin i.Sex i.education i.gp_ecart_Yres i.gp_ecart_Ores i.MigDeadFA

*M3
stcox ib2.MigDeadMO  ib21.y3_mother_age_birth i.twin i.Sex i.education i.gp_ecart_Yres i.gp_ecart_Ores i.MigDeadFA ///
      i.presencePGF#i.gp_PGFres i.presencePGM#i.gp_PGMres

*M4
stcox ib2.MigDeadMO  ib21.y3_mother_age_birth i.twin i.Sex i.education i.gp_ecart_Yres i.gp_ecart_Ores i.MigDeadFA ///
      i.presencePGF#i.gp_PGFres i.presencePGM#i.gp_PGMres


bootstrap, reps(1000): stcox i.MigDeadMO ib2.MigDeadFA  ib21.y3_mother_age_birth i.presencePGF#i.gp_PGFres ///
i.presencePGM#i.gp_PGMres i.presenceMGF#i.gp_MGFres i.presenceMGM#i.gp_MGMres i.center ///
i.twin i.Sex i.education, vce(cluster MotherId)

stcox i.MigDeadMO ib2.MigDeadFA  ib21.y3_mother_age_birth i.presencePGF#i.gp_PGFres ///
i.presencePGM#i.gp_PGMres i.presenceMGF#i.gp_MGFres i.presenceMGM#i.gp_MGMres i.center ///
i.twin i.Sex i.education, vce(cluster MotherId)


bys center: stcox i.MigDeadMO ib2.MigDeadFA  ib21.y3_mother_age_birth i.presencePGF#i.gp_PGFres ///
i.presencePGM#i.gp_PGMres i.presenceMGF#i.gp_MGFres i.presenceMGM#i.gp_MGMres ///
i.twin i.Sex i.education, vce(cluster MotherId)

 stcox i.MigDeadMO ib2.MigDeadFA  ib21.y3_mother_age_birth i.presencePGF_bis ///
i.presencePGM_bis i.presenceMGF_bis i.presenceMGM_bis i.center ///
i.twin i.Sex i.educationMO educationFA, vce(cluster MotherId) 
  

  
  stcox ib2.MigDeadMO ib2.MigDeadFA  i.y3_father_age_birth ib21.y3_mother_age_birth i.presencePGF#i.gp_PGFres ///
i.presencePGM#i.gp_PGMres i.presenceMGF#i.gp_MGFres i.presenceMGM#i.gp_MGMres i.center ///
i.twin i.Sex  i.educationMO , vce(cluster MotherId)

***Final Model
  stcox ib2.MigDeadMO ib2.MigDeadFA  i.y3_father_age_birth ib21.y3_mother_age_birth i.presencePGF_bis ///
i.presencePGM_bis i.presenceMGF_bis i.presenceMGM_bis i.center ///
i.twin i.Sex , vce(cluster MotherId)
estimates store model_standard
matrix list e(b)


bootstrap, reps(1000): stcox ib2.MigDeadMO ib2.MigDeadFA i.y3_father_age_birth ib21.y3_mother_age_birth i.presencePGF_bis ///
i.presencePGM_bis i.presenceMGF_bis i.presenceMGM_bis i.center ///
i.twin i.Sex , vce(cluster MotherId)
estimates store model_standard
matrix list e(b)


*Graphiques 

* sex + twin + hdss

coefplot, xline(1) eform xtitle(Hazards Ratio) levels(95) ///
		keep(2.Sex 1.twin 2.center) ///
		mlabel format(%9.2f) mlabposition(12) mlabgap(*1) ///
		coeflabels(2.Sex="Female" 1.twin="Yes" 2.center="Nanoro" ///
				,notick labsize(small) labcolor(purple) labgap(2)) ///
		headings(2.Sex=`""{bf:Gender}" "Ref : Male""' 1.twin=`""{bf:Multiple birth}" "Ref : No ""' ///
				2.center=`""{bf:HDSS}" "Ref : Ouagadougou""', labcolor(blue)) ///
		xlabel(0.5 1 2 4, format(%9.2f)) xscale(log range(0.5 5)) baselevels
graph save graph_sex_twin_center,replace


* Grand parents
coefplot, xline(1) eform xtitle(Hazards Ratio) levels(95) ///
		keep(1.presenceMGF_bis  2.presenceMGF_bis 1.presencePGF_bis 2.presencePGF_bis ) ///
		mlabel format(%9.2f) mlabposition(12) mlabgap(*1) ///
		coeflabels(1.presenceMGF_bis="Resident & < 65yrs" 2.presenceMGF_bis="Resident & > 65yrs" ///
		            1.presencePGF_bis="Resident & < 65yrs" 2.presencePGF_bis="Resident & > 65yrs" ///
				,notick labsize(small) labcolor(purple) labgap(2)) ///
		headings(1.presenceMGF_bis=`""{bf:Maternal Grand Father}" "Ref : Non-resident""' ///
		1.presencePGF_bis=`""{bf:Paternal Grand Father}" "Ref : Non-resident ""' ///
				, labcolor(blue)) ///
		xlabel(0.5 1 2 4, format(%9.2f)) xscale(log range(0.5 5)) baselevels
graph save graph_MGF_PGF,replace
* 

coefplot, xline(1) eform xtitle(Hazards Ratio) levels(95) ///
		keep(1.presenceMGM_bis  2.presenceMGM_bis 1.presencePGM_bis 2.presencePGM_bis ) ///
		mlabel format(%9.2f) mlabposition(12) mlabgap(*1) ///
		coeflabels(1.presenceMGM_bis="Resident & < 65yrs" 2.presenceMGM_bis="Resident & > 65yrs" ///
		            1.presencePGM_bis="Resident & < 65yrs" 2.presencePGM_bis="Resident & > 65yrs" ///
				,notick labsize(small) labcolor(purple) labgap(2)) ///
		headings(1.presenceMGM_bis=`""{bf:Maternal Grand Mother}" "Ref : Non-resident""' ///
		1.presencePGM_bis=`""{bf:Paternal Grand Mother}" "Ref : Non-resident ""' ///
				, labcolor(blue)) ///
		xlabel(0.5 1 2 4, format(%9.2f)) xscale(log range(0.5 5)) baselevels
graph save graph_MGM_PGM,replace

graph combine graph_MGF_PGF.gph graph_MGM_PGM.gph


***2. relative to mother
coefplot, xline(1) eform xtitle(Hazards Ratio) levels(95) ///
		keep(15.y3_mother_age_birth 18.y3_mother_age_birth ///
			 24.y3_mother_age_birth 27.y3_mother_age_birth 30.y3_mother_age_birth ///
			 33.y3_mother_age_birth 36.y3_mother_age_birth 39.y3_mother_age_birth ///
			 42.y3_mother_age_birth ///
			 1.MigDeadMO  3.MigDeadMO) ///	 
		mlabel format(%9.2f) mlabposition(12) mlabgap(*1) ///
		coeflabels(15.y3_mother_age_birth="15-17" 18.y3_mother_age_birth="18-21" ///
				24.y3_mother_age_birth="24-26" 27.y3_mother_age_birth="27-29" ///
				30.y3_mother_age_birth="30-32" 33.y3_mother_age_birth="33-35" ///
				36.y3_mother_age_birth="36-38" 39.y3_mother_age_birth="39-41" ///
				42.y3_mother_age_birth="42+" ///
				1.MigDeadMO="Non-resident" ///
				, notick labsize(small) labcolor(purple) labgap(2)) ///
		headings(15.y3_mother_age_birth=`""{bf: Mother´s age at birth}" "Ref: 21-23 years""' ///
				1.MigDeadMO=`""{bf: Mother status}" "Ref: Permanent resident""'  ///
				, labcolor(blue)) ///
		xlabel(0.5 1 2, format(%9.1f)) xscale(log range(0.5 2)) baselevels

		graph save graph_mother,replace



***2. relative to father
coefplot, xline(1) eform xtitle(Hazards Ratio) levels(95) ///
		keep(2.y3_father_age_birth 3.y3_father_age_birth ///
			 4.y3_father_age_birth 5.y3_father_age_birth 6.y3_father_age_birth ///
			 7.y3_father_age_birth 8.y3_father_age_birth 39.y3_father_age_birth 99.y3_father_age_birth ///
			 42.y3_father_age_birth ///
			 1.MigDeadFA  3.MigDeadFA) ///	 
		mlabel format(%9.2f) mlabposition(12) mlabgap(*1) ///
		coeflabels(2.y3_father_age_birth="30-34" 3.y3_father_age_birth="35-39" ///
				4.y3_father_age_birth="40-44" 5.y3_father_age_birth="45-49" ///
				6.y3_father_age_birth="50-54" 7.y3_father_age_birth="55-59" ///
				8.y3_father_age_birth="60-64" 39.y3_father_age_birth="65&+" ///
				99.y3_father_age_birth="Missing" ///
				1.MigDeadFA="Non-resident" ///
				, notick labsize(small) labcolor(purple) labgap(2)) ///
		headings(2.y3_father_age_birth=`""{bf: Father´s age at birth}" "Ref: < 30 years""' ///
				1.MigDeadFA=`""{bf: Father status}" "Ref: Permanent resident""'  ///
				, labcolor(blue)) ///
		xlabel(0.5 1 2, format(%9.1f)) xscale(log range(0.5 2)) baselevels

		graph save graph_father,replace

		graph combine graph_mother.gph graph_father.gph

		
		

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




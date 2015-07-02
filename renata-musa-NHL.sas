libname napp "C:\Users\rmusa\Desktop\NHL";

data nhl2;
set napp.nhl;
if yod=9999 then yod=.;
if casectl=0 and vitalst=0 then age = intyr - yob; /*Alive controls*/
if casectl=0 and vitalst=1 then age = yod - yob;   /*Deceased controls*/
if casectl=1 and vitalst=0 then age = agedx;       /*Alive cases*/
if casectl=1 and vitalst=1 then age = yod - yob;   /*Deceased cases*/
if age=99 then age=.;
if age=. then age=62;

keep 
/*Descriptives*/
idnum casectl nhltype4 age sex location school usdcigrt proxy cafdrel cafdlym use_prot frm_wrlv ALLERGY ALLERGY_FOOD ALLERGY_DRUG ASTHMA HAYFEVER ARTHRITIS MONO TB CHEMO RADIATION

/*Pesticide types*/
aninsany crinsany fungany herbany 
handle_a handle_c handle_f handle_h

/*Fungicides: Use variables*/
fu_1 fu_3 fu_4 fu_8 fu_10 fu_13 fu_15

/*Fungicides: Handle variables*/
fu_h1 fu_h3 fu_h4 fu_h8 fu_h10 fu_h13 fu_h15

/*Herbicides: Use variables*/
he_35 he_13 he_1 he_22 he_45 he_3 he_4 he_5 he_6 he_7 he_8
he_14 he_15 he_16 he_17 he_40 he_18 he_19 he_21 he_23 he_24 
he_26 he_30 he_47 he_25 he_37 he_38

/*Herbicides: Handle variables*/
he_h35 he_h13 he_h1 he_h22 he_h45 he_h3 he_h4 he_h5 he_h6 he_h7 he_h8
he_h14 he_h15 he_h16 he_h17 he_h40 he_h18 he_h19 he_h21 he_h23 he_h24 
he_h26 he_h30 he_h47 he_h25 he_h37 he_h38

/*Insecticides: Use variables*/
ins_1 ins_5 ins_3 ins_4 ins_9 ins_10 ins_11 ins_12 ins_15 ins_20 
ins_21 ins_23 ins_24 ins_28 ins_32 ins_35 ins_37 ins_38
ins_44 ins_55 ins_39 ins_40 ins_41 cr_51 ins_49 ins_50
ins_52 ins_56 ins_57

/*Insecticides: Handle variables*/
ins_h1 ins_h5 ins_h9 ins_h10 ins_h11 ins_h12 ins_h15 ins_h20 
ins_h21 ins_h23 ins_h24 ins_h28 ins_h32 ins_h35 ins_h37 ins_h38
ins_h44 ins_h55 ins_h39 ins_h40 ins_h41 cr_51 ins_h49 ins_h50
ins_h52 ins_h56 ins_h57

;
run;
/* delete the age-related missing values and >100 years old*/
data nhl_temp2;
set nhl2;
if age > 100 then delete ;
if age = . then delete ;
run;

*mean age;
proc means data=nhl_temp2;
class casectl;
var age;
run;

/*convert all missing values (.) to unknown (9) for all numeric variables in dataset*/
data nhl_temp3;
set nhl_temp2;
array unkmiss[*] _NUMERIC_;
do i=1 to dim(unkmiss);
if unkmiss(i)=. then unkmiss(i)=9;
end;
drop i;
run;

proc logistic data=nhl_temp3 descending;
class proxy (ref="0") location /param=ref;
model casectl = proxy age location;
run;
proc logistic data=nhl_temp3 descending;
class frm_wrlv (ref="0") location /param=ref;
model casectl= frm_wrlv age location;
run;
proc logistic data=nhl_temp3 descending;
class cafdrel (ref="0") location /param=ref;
model casectl= cafdrel age location;
run;
proc logistic data=nhl_temp3 descending;
class cafdlym (ref="0") location /param=ref;
model casectl = cafdlym age location;
run;
proc logistic data=nhl_temp3 descending;
class USDCIGRT (ref="0") location /param=ref;
model casectl = USDCIGRT age location;
run; 
proc logistic data=nhl_temp3 descending;
class sex (param=ref ref=first);
class location (param=ref ref=first);
model casectl = sex age location;
run;

%macro log(data, y, x, class=);
	proc logistic data=nhl_temp3 descending;
	class &class;
	model &y = &x &class;
	run;
%mend log;

%let y = casectl;
%let x = age location; *cases and controls were matched by age and locations, so I always have to control for age and location;
%log(nhl_temp4, &y, &x, class = location);
%log(nhl_temp4, &y, &x frm_wrlv, class = location); *ever worked in a farm;
%log(nhl_temp4, &y, &x cafdrel , class = location cafdrel); *Any cancer in first degree relative;
%log(nhl_temp4, &y, &x cafdlym , class = location cafdlym); *Lymphatic/Hematopoietic cancer in first degree relative;
%log(nhl_temp4, &y, &x USDCIGRT , class = location USDCIGRT); *cigarette use;
%log(nhl_temp4, &y, &x sex , class = location sex);



/* Number of carcinogenic pesticides used - carc prob >=0.5 */
data nhl_temp6;
set nhl_temp3;
pestcount = (HE_35+HE_13+HE_1+HE_45+HE_3+HE_7+HE_16+HE_18+HE_21+HE_23+HE_24+HE_30+HE_25+HE_37+HE_38+INS_4+INS_9+INS_11+INS_20+INS_21+INS_23+INS_24+INS_35+INS_37+INS_38+INS_44+INS_55+INS_39+INS_3+INS_49+INS_56+FU_1+FU_3+FU_4+FU_8+FU_10);
run;

/* pesticide categories based on # of pesticides used
data nhl_temp7;
set nhl_temp6;
if pestcount=0 then pestcat="0";
else if pestcount=1 then pestcat="1";
else if pestcount=2 or pestcount=3 or pestcount=4 then pestcat="2-4";
else if pestcount ge 5 then pestcat="5+";
run;*/

/* pesticide categories based on # of pesticides used*/
data nhl_temp7;
set nhl_temp6;
if pestcount=0 then pestcat="0";
else if pestcount=1 then pestcat="1";
else if pestcount ge 2 then pestcat="2";
run;

proc freq data=nhl_temp7;
tables pestcat pestcount;
run;
proc freq data=nhl_temp7;
tables pestcat*casectl pestcat*nhltype4;
run;

/* crude Odds of NHL in association with pesticide category, controlling for age and residence*/
proc logistic data=nhl_temp7 descending;
class pestcat (param=ref ref=first);
class location (param=ref ref=first);
model casectl = pestcat age location;
run;

/*frequencies for medical condition*/
proc freq data = nhl_temp7;
tables allergy*casectl ALLERGY_FOOD*casectl ALLERGY_DRUG*casectl ASTHMA*casectl HAYFEVER*casectl ARTHRITIS*casectl mono*casectl TB*casectl CHEMO*casectl RADIATION*casectl/norow nopercent;
run;

proc logistic data = nhl_temp7 descending;
class pestcat  (param=ref ref="0");
class location (param=ref ref=first);
class proxy (param=ref ref="0");
class sex (param=ref ref=first);
class cafdlym (param=ref ref="0");
model casectl = pestcat age location proxy sex CAFDLYM;
run;

proc logistic data = nhl_temp7 descending;
class pestcat  (param=ref ref="0");
class location (param=ref ref=first);
class proxy (param=ref ref="0");
class sex (param=ref ref=first);
class cafdlym (param=ref ref="0");
class frm_wrlv (param=ref ref="0");
model casectl =  pestcat age location proxy sex CAFDLYM frm_wrlv;
run;

*my favourite model: no allergy to drug or food;
proc logistic data = nhl_temp7 descending;
class pestcat  (param=ref ref="0");
class location (param=ref ref=first);
class proxy (param=ref ref="0");
class sex (param=ref ref=first);
class cafdlym (param=ref ref="0");
class frm_wrlv (param=ref ref="0");
class allergy (param=ref ref=first);
class mono (param=ref ref=first);
class TB (param=ref ref=first);
class chemo (param=ref ref=first);
class asthma (param=ref ref=first);
class hayfever (param=ref ref=first);
class arthritis (param=ref ref=first);
class radiation (param=ref ref=first);
model casectl = pestcat pestcat*proxy age location proxy sex CAFDLYM frm_wrlv allergy mono TB asthma hayfever arthritis / selection=backward
slstay = 0.10 include = 1;
run;

proc logistic data = nhl_temp7 descending;
class pestcat  (param=ref ref="0");
class location (param=ref ref=first);
class proxy (param=ref ref="0");
class sex (param=ref ref=first);
class cafdlym (param=ref ref="0");
class frm_wrlv (param=ref ref="0");
class allergy (param=ref ref=first);
class allergy_drug (param=ref ref=first);
class allergy_food (param=ref ref=first);
class mono (param=ref ref=first);
class TB (param=ref ref=first);
class chemo (param=ref ref=first);
class asthma (param=ref ref=first);
class hayfever (param=ref ref=first);
class arthritis (param=ref ref=first);
class radiation (param=ref ref=first);
model casectl = pestcat age location proxy sex CAFDLYM frm_wrlv allergy allergy_drug allergy_food mono TB chemo asthma hayfever arthritis radiation;
run;

/* corr matrix */
proc corr data = nhl_temp7 noprob nosimple;
 var HE_35 HE_13 HE_1 HE_45 HE_3 HE_7 HE_16 HE_18 HE_21 HE_23 HE_24 HE_30 HE_25 HE_37 HE_38 INS_4 INS_9 INS_11 INS_20 INS_21 INS_23 INS_24 INS_35 INS_37 INS_38 INS_44 INS_55 INS_39 INS_3 INS_49 INS_56 FU_1 FU_3 FU_4 FU_8 FU_10;
run;

/*frequencies for medical condition by NHL subtype*/
proc freq data = nhl_temp7;
tables allergy*nhltype4 ALLERGY_FOOD*nhltype4 ALLERGY_DRUG*nhltype4 ASTHMA*nhltype4 HAYFEVER*nhltype4 ARTHRITIS*nhltype4 mono*nhltype4 TB*nhltype4 CHEMO*nhltype4 RADIATION*nhltype4/norow nopercent;
run;

/*******************************************************************************************/
/*****Odds of Follicular NHL controlling for age and residence, then for all covariates*****/
/*******************************************************************************************/

/* modify nhltype4 variable: 0 for controls and 1 for Follicular NHL */ 
data nhl_temp9;
set nhl_temp7;
if nhltype4 = 0 then nhltype4 = 0 ;
else if nhltype4 = 1 then nhltype4 = 1 ;
else if nhltype4 = 2 or nhltype4 = 3 or nhltype4 = 4 then delete;
run;

proc freq data=nhl_temp9;
tables nhltype4;
run;

proc freq data=nhl_temp9;
tables casectl*nhltype4 pestcat*nhltype4;
run;

*Crude  OR for Follicular NHL in association with pesticide category, controlling for age and residence;
proc logistic data=nhl_temp9 descending;
class pestcat (param=ref ref=first);
class location (param=ref ref=first);
model nhltype4 = pestcat age location;
run;

proc logistic data = nhl_temp9 descending;
class pestcat  (param=ref ref="0");
class location (param=ref ref=first);
class proxy (param=ref ref="0");
class sex (param=ref ref=first);
class cafdlym (param=ref ref="0");
model nhltype4 = pestcat age location proxy sex;
run;

proc logistic data = nhl_temp9 descending;
class pestcat  (param=ref ref="0");
class location (param=ref ref=first);
class proxy (param=ref ref="0");
class sex (param=ref ref=first);
class cafdlym (param=ref ref="0");
class frm_wrlv (param=ref ref="0");
model nhltype4 = pestcat age location proxy sex frm_wrlv;
run;

*my favourite model: no allergy to drug or food;
proc logistic data = nhl_temp9 descending;
class pestcat  (param=ref ref="0");
class location (param=ref ref=first);
class proxy (param=ref ref="0");
class sex (param=ref ref=first);
class cafdlym (param=ref ref="0");
class frm_wrlv (param=ref ref="0");
class allergy (param=ref ref=first);
class mono (param=ref ref=first);
class TB (param=ref ref=first);
class chemo (param=ref ref=first);
class asthma (param=ref ref=first);
class hayfever (param=ref ref=first);
class arthritis (param=ref ref=first);
class radiation (param=ref ref=first);
model nhltype4 = pestcat age location proxy sex CAFDLYM frm_wrlv allergy mono TB chemo asthma hayfever arthritis radiation;
run;

proc logistic data = nhl_temp9 descending;
class pestcat  (param=ref ref="0");
class location (param=ref ref=first);
class proxy (param=ref ref="0");
class sex (param=ref ref=first);
class cafdlym (param=ref ref="0");
class frm_wrlv (param=ref ref="0");
class allergy (param=ref ref=first);
class allergy_drug (param=ref ref=first);
class allergy_food (param=ref ref=first);
class mono (param=ref ref=first);
class TB (param=ref ref=first);
class chemo (param=ref ref=first);
class asthma (param=ref ref=first);
class hayfever (param=ref ref=first);
class arthritis (param=ref ref=first);
class radiation (param=ref ref=first);
model nhltype4 = pestcat age location proxy sex CAFDLYM frm_wrlv allergy allergy_drug allergy_food mono TB chemo asthma hayfever arthritis radiation;
run;

/****************************************************************************************/
/*****Odds of Diffuse NHL controlling for age and residence, then for all covariates*****/
/****************************************************************************************/

data nhl_diff;
set nhl_temp7;
if nhltype4 = 0 then nhltype4 = 0 ;
else if nhltype4 = 2 then nhltype4 = 1 ;
else if nhltype4 = 1 or nhltype4 = 3 or nhltype4 = 4 then delete;
run;

proc freq data=nhl_diff;
tables casectl*nhltype4 pestcat*nhltype4;
run;

*Crude OR for Diffuse NHL in association with pesticide category, controlling for age and residence;
proc logistic data=nhl_diff descending;
class pestcat (param=ref ref=first);
class location (param=ref ref=first);
model nhltype4 = pestcat age location;
run;

proc logistic data = nhl_diff descending;
class pestcat  (param=ref ref="0");
class location (param=ref ref=first);
class proxy (param=ref ref="0");
class sex (param=ref ref=first);
class cafdlym (param=ref ref="0");
model nhltype4 = pestcat age location proxy sex CAFDLYM;
run;

proc logistic data = nhl_diff descending;
class pestcat  (param=ref ref="0");
class location (param=ref ref=first);
class proxy (param=ref ref="0");
class sex (param=ref ref=first);
class cafdlym (param=ref ref="0");
class frm_wrlv (param=ref ref="0");
model nhltype4 = pestcat age location proxy sex CAFDLYM frm_wrlv;
run;

proc logistic data = nhl_diff descending;
class pestcat  (param=ref ref="0");
class location (param=ref ref=first);
class proxy (param=ref ref="0");
class sex (param=ref ref=first);
class cafdlym (param=ref ref="0");
class frm_wrlv (param=ref ref="0");
class allergy (param=ref ref=first);
class mono (param=ref ref=first);
class TB (param=ref ref=first);
class chemo (param=ref ref=first);
class asthma (param=ref ref=first);
class hayfever (param=ref ref=first);
class arthritis (param=ref ref=first);
class radiation (param=ref ref=first);
model nhltype4 = pestcat age location proxy sex CAFDLYM frm_wrlv allergy mono TB chemo asthma hayfever arthritis radiation;
run;

proc logistic data = nhl_diff descending;
class pestcat  (param=ref ref="0");
class location (param=ref ref=first);
class proxy (param=ref ref="0");
class sex (param=ref ref=first);
class cafdlym (param=ref ref="0");
class frm_wrlv (param=ref ref="0");
class allergy (param=ref ref=first);
class allergy_drug (param=ref ref=first);
class allergy_food (param=ref ref=first);
class mono (param=ref ref=first);
class TB (param=ref ref=first);
class chemo (param=ref ref=first);
class asthma (param=ref ref=first);
class hayfever (param=ref ref=first);
class arthritis (param=ref ref=first);
class radiation (param=ref ref=first);
model nhltype4 = pestcat age location proxy sex CAFDLYM frm_wrlv allergy allergy_drug allergy_food mono TB chemo asthma hayfever arthritis radiation;
run;

/**************************************************************************************************/
/*****Odds of Small lymphocytic NHL controlling for age and residence, then for all covariates*****/
/**************************************************************************************************/

data nhl_SmallLymph;
set nhl_temp7;
if nhltype4 = 0 then nhltype4 = 0 ;
else if nhltype4 = 3 then nhltype4 = 1 ;
else if nhltype4 = 1 or nhltype4 = 2 or nhltype4 = 4 then delete;
run;

proc freq data=nhl_SmallLymph;
tables casectl*nhltype4 pestcat*nhltype4;
run;

*Odds of Small lymphocytic NHL in association with pesticide category, controlling for age and residence;
proc logistic data=nhl_SmallLymph descending;
class pestcat (param=ref ref=first);
class location (param=ref ref=first);
model nhltype4 = pestcat age location;
run;

proc logistic data = nhl_SmallLymph descending;
class pestcat  (param=ref ref="0");
class location (param=ref ref=first);
class proxy (param=ref ref="0");
class sex (param=ref ref=first);
class cafdlym (param=ref ref="0");
model nhltype4 = pestcat age location proxy sex CAFDLYM;
run;

proc logistic data = nhl_SmallLymph descending;
class pestcat  (param=ref ref="0");
class location (param=ref ref=first);
class proxy (param=ref ref="0");
class sex (param=ref ref=first);
class cafdlym (param=ref ref="0");
class frm_wrlv (param=ref ref="0");
model nhltype4 = pestcat age location proxy sex CAFDLYM frm_wrlv;
run;

proc logistic data = nhl_SmallLymph descending;
class pestcat  (param=ref ref="0");
class location (param=ref ref=first);
class proxy (param=ref ref="0");
class sex (param=ref ref=first);
class cafdlym (param=ref ref="0");
class frm_wrlv (param=ref ref="0");
class allergy (param=ref ref=first);
class mono (param=ref ref=first);
class TB (param=ref ref=first);
class chemo (param=ref ref=first);
class asthma (param=ref ref=first);
class hayfever (param=ref ref=first);
class arthritis (param=ref ref=first);
class radiation (param=ref ref=first);
model nhltype4 = pestcat age location proxy sex CAFDLYM frm_wrlv allergy mono TB chemo asthma hayfever arthritis radiation;
run;

proc logistic data = nhl_SmallLymph descending;
class pestcat  (param=ref ref="0");
class location (param=ref ref=first);
class proxy (param=ref ref="0");
class sex (param=ref ref=first);
class cafdlym (param=ref ref="0");
class frm_wrlv (param=ref ref="0");
class allergy (param=ref ref=first);
class allergy_drug (param=ref ref=first);
class allergy_food (param=ref ref=first);
class mono (param=ref ref=first);
class TB (param=ref ref=first);
class chemo (param=ref ref=first);
class asthma (param=ref ref=first);
class hayfever (param=ref ref=first);
class arthritis (param=ref ref=first);
class radiation (param=ref ref=first);
model nhltype4 = pestcat age location proxy sex CAFDLYM frm_wrlv allergy allergy_drug allergy_food mono TB chemo asthma hayfever arthritis radiation;
run;

/**********************************************************************************************/
/*****Odds of other type of NHL controlling for age and residence, then for all covariates*****/
/**********************************************************************************************/

data nhl_other;
set nhl_temp7;
if nhltype4 = 0 then nhltype4 = 0 ;
else if nhltype4 = 4 then nhltype4 = 1 ;
else if nhltype4 = 1 or nhltype4 = 2 or nhltype4 = 3 then delete;
run;

proc freq data=nhl_other;
tables casectl*nhltype4 pestcat*nhltype4;
run;

*Crude OR for other type of NHL in association with pesticide category, controlling for age and residence;
proc logistic data=nhl_other descending;
class pestcat (param=ref ref=first);
class location (param=ref ref=first);
model nhltype4 = pestcat age location;
run;

proc logistic data = nhl_other descending;
class pestcat  (param=ref ref="0");
class location (param=ref ref=first);
class proxy (param=ref ref="0");
class sex (param=ref ref=first);
class cafdlym (param=ref ref="0");
model nhltype4 = pestcat age location proxy sex CAFDLYM;
run;

proc logistic data = nhl_other descending;
class pestcat  (param=ref ref="0");
class location (param=ref ref=first);
class proxy (param=ref ref="0");
class sex (param=ref ref=first);
class cafdlym (param=ref ref="0");
class frm_wrlv (param=ref ref="0");
model nhltype4 = pestcat age location proxy sex CAFDLYM frm_wrlv;
run;

proc logistic data = nhl_other descending;
class pestcat  (param=ref ref="0");
class location (param=ref ref=first);
class proxy (param=ref ref="0");
class sex (param=ref ref=first);
class cafdlym (param=ref ref="0");
class frm_wrlv (param=ref ref="0");
class allergy (param=ref ref=first);
class mono (param=ref ref=first);
class TB (param=ref ref=first);
class chemo (param=ref ref=first);
class asthma (param=ref ref=first);
class hayfever (param=ref ref=first);
class arthritis (param=ref ref=first);
class radiation (param=ref ref=first);
model nhltype4 = pestcat age location proxy sex CAFDLYM frm_wrlv allergy mono TB chemo asthma hayfever arthritis radiation;
run;

proc logistic data = nhl_other descending;
class pestcat  (param=ref ref="0");
class location (param=ref ref=first);
class proxy (param=ref ref="0");
class sex (param=ref ref=first);
class cafdlym (param=ref ref="0");
class frm_wrlv (param=ref ref="0");
class allergy (param=ref ref=first);
class allergy_drug (param=ref ref=first);
class allergy_food (param=ref ref=first);
class mono (param=ref ref=first);
class TB (param=ref ref=first);
class chemo (param=ref ref=first);
class asthma (param=ref ref=first);
class hayfever (param=ref ref=first);
class arthritis (param=ref ref=first);
class radiation (param=ref ref=first);
model nhltype4 = pestcat age location proxy sex CAFDLYM frm_wrlv allergy allergy_drug allergy_food mono TB chemo asthma hayfever arthritis radiation;
run;

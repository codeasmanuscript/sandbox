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



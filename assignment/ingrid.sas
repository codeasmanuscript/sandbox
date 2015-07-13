/*Ingrid's Assignment- July 13, 2015*/
/*Macro and ODS using the sashelp.heart dataset*/


options nodate nonumber nocenter formdlim="";

%let ds = sashelp.heart;

*contents*;
%macro contents(data);
    proc contents data=&data short;
    run;
    %mend contents;

%contents(&ds);

*print*;
%macro print(data);
    proc print data=&data noobs;
    run;
    %mend print;

%print(&ds);

*means*;
%macro means(data, outdata, var=, class=);
	ods listing close;
	proc means data=&data n mean stddev stackods;
        var &var;
        class &class;
		ods output Summary = &outdata;
    run;
	ods listing;

	data &outdata;
        set &outdata;
		 MeanSD = round(Mean, 0.01) || ' (' ||
            strip(round(StdDev, 0.01)) || ')';
		keep n &class MeanSD; 
	run;
	%print(&outdata);
    %mend means;

%means(&ds, meanSD);
%means(&ds, meanSD, class=status);

*univariate*;
%macro univariate (data, variable);
proc univariate data= &data normal plots;
var &variable;
run;
%mend univariate; 

%univariate(&ds, weight);
%univariate(&ds, Systolic);
%univariate(&ds, Diastolic);

*logistic regression*;
%macro logistic(data, y, x, class=, where =);
	ods listing close;
	proc logistic data=&data descending;
        class &class;
	model &y = &x &class
			/clodds=wald ;
		where &where;
	ods output NObs=obs
		ResponseProfile=response
		CLoddsWald=ORCI;
    run;
	ods listing;

	data obs;
		set obs;
		keep NObsRead NObsUsed;
	run;
	%print(obs);

	data response;
		set response;
		drop OrderedValue;
	run;
	%print(response);

	data ORCI;
		set ORCI;
	ORCI= round(OddsRatioEst, 0.001) || ' (' ||
		strip(round(LowerCL, 0.001)) || ' - ' ||
        strip(round(UpperCL, 0.001)) || ')' ;
	drop Unit OddsRatioEst LowerCL UpperCL;
	run;
	%print(ORCI);

    %mend logistic;


%logistic (&ds, status, weight systolic diastolic);
%logistic (&ds, status, weight systolic diastolic, where= sex= "Female");
%logistic (&ds, status, weight systolic diastolic sex Smoking_Status, class=sex Smoking_Status );


/**************************************/
/*testing- making proc logsitic macro*/
ods trace on;
proc logistic data=&ds descending;
class Chol_Status;
model status= Weight Systolic
/clodds=wald ;
where sex="Female";
ods output NObs=obs
	ResponseProfile=response
	 CLoddsWald=ORCI;
run;
ods trace off;
data obs;
	set obs;
	keep NObsRead NObsUsed;
run;

data test;
	set ORCI;
	ORCI= round(OddsRatioEst, 0.001) || ' (' ||
		strip(round(LowerCL, 0.001)) || ' - ' ||
        strip(round(UpperCL, 0.001)) || ')' ;
	drop Unit OddsRatioEst LowerCL UpperCL;
run;

%print(obs);
%print(response);
%print(ORCI);
%print(test);
/************************/

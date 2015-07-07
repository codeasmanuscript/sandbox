/**

    Objectives for this workshop:

    * Identify the name of the ODS object
    * Extract the ODS object
    * Manipulate the ODS object to resemble a table
    * Make a macro from it
    * Export to a file (excel)

    We'll do this for three `proc`s

    */
options nodate nonumber nocenter formdlim="";


%let ds = sashelp.class;

%macro contents(data);
    proc contents data=&data short;
    run;
    %mend contents;

/*
%contents(&ds);
*/

data temporary;
    set sashelp.class;
run;

%contents(temporary);
%macro print(data);
    proc print data=&data noobs;
    run;
    %mend print;

%macro means(data, outdata, var=);
    ods listing close;
    proc means data=&data n mean stddev stackods;
        ods output Summary = &outdata;
        var &var;
    run;
    ods listing;

    data &outdata;
        set &outdata;
        meanSD = round(Mean, 0.01) || ' (' ||
            strip(round(StdDev, 0.01)) || ')';
        drop Mean StdDev;
    run;

    %print(&outdata);
    %mend means;

/*
ods trace on;
%means(&ds, meansData);
ods trace off;
%means(sashelp.class, meansData, var = Age);
%means(sashelp.fish, meansFish);
%means(sashelp.fish, meansFish,
    var = Length1 Weight Height);
*/
data femaleData;
    set sashelp.class;
    if Sex = 'F' then output;
run;

data maleData;
    set sashelp.class;
    if Sex = 'M' then output;
run;

%print(femaleData);
%print(maleData);


ods listing close;
proc glm data=sashelp.class;
    class Sex;
    model Height = Sex Weight / solution clparm;
    ods output ParameterEstimates = betaDS
        FitStatistics = fitData;
run;
ods listing;

data betaDS;
    set betaDS;
    betaSE = round(Estimate, 0.01) || '(' ||
        strip(round(StdErr, 0.01)) || ')';
    betaCL = round(Estimate, 0.01) || ' (' ||
        strip(round(LowerCL)) || ' to ' ||
        strip(round(UpperCL)) || ')';
    drop Biased tValue Estimate StdErr LowerCL UpperCL;
run;

%print(betaDS);
%print(fitData);

proc export data=betaDS dbms = csv outfile = 'beta.csv' replace;
run;



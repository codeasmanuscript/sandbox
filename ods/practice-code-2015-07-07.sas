/**

    Objectives for this workshop:

    * Identify the name of the ODS object
    * Extract the ODS object
    * Manipulate the ODS object to resemble a table
    * Make a macro from it
    * Export to a file (excel)

    We'll do this for three `proc`s

    */
* These options make the output nicer... They are optional;
options nodate nonumber nocenter formdlim="";

* This is a macro variable. See the macros cheatsheet for a ;
* detailed explanation.  This just makes it easier to type out
* the dataset name. ;
%let ds = sashelp.class;

* Im creating this macro to make it easier to see what variables ;
* are inside a dataset.  See the macros cheatsheet for more explanation ;
* on what a macro is.  This code on its own does nothing.;
%macro contents(data);
    proc contents data=&data short;
    run;
    %mend contents;

* This calls the previously made macro and actually runs the code ;
* inside the macro above.;
%contents(&ds);

* This just highlights what the data .. set .. does. ;
data temporary; * This is for the name of the *new* dataset;
    set sashelp.class; * This is the name of the *old* dataset;
run;

* To show that temporary is the same as sashelp.class;
%contents(temporary);

* Create another macro for printing what is inside a dataset.;
%macro print(data);
    proc print data=&data noobs;
    run;
    %mend print;

* Create a macro for printing the means and standard deviation. ;
* See the cheatsheet in the macros lesson for more explanation on ;
* what a macro is.;
%macro means(data, outdata, var=); * data, outdate, and var= are arguments;
    * This stops output from being sent to the results tab;
    ods listing close; 

    * This is a procedure that calculates means and std dev.;
    proc means data=&data stddev mean n stackods; * &data is an argument from the list above;

        * ODS output sends the results of proc means to the &outdata dataset;
        ods output Summary = &outdata; * argument again;

        var &var; * argument again;
    run;

    * This allows SAS to send output to the results tab;
    ods listing;

    * We can now manipulate the proc means &outdata dataset.;
    data &outdata;
        set &outdata;

        * The || command combines things together.;
        * Strip removes whitespace.;
        meanSD = round(Mean, 0.01) || ' (' ||
            strip(round(StdDev, 0.01)) || ')';

        * Drop command removes the Mean and StdDev variables from the dataset;
        drop Mean StdDev;
    run;

    * Now, send the means dataset to the results tab (print it);
    %print(&outdata);

    * End the macro.;
    %mend means;

* ODS trace allows you to see inside the box (the proc);
ods trace on;
%means(&ds, meansData);
ods trace off;

%means(sashelp.class, meansData, var = Age);
%means(sashelp.fish, meansFish);
%means(sashelp.fish, meansFish,
    var = Length1 Weight Height);

/* This code below is a brief aside to explain how data .. set .. works. */
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
/* Back to the ODS stuff! */

* proc glm can run linear regressions;
ods listing close;
proc glm data=sashelp.class;
    class Sex;
    * `solution` tells SAS to do a linear regression;
    * `clparm` calculates confidence intervals/limits;
    model Height = Sex Weight / solution clparm; 

    * We can output just the estimates and the R-squared with this;
    ods output ParameterEstimates = betaDS
        FitStatistics = fitData;
run;
ods listing;

* And manipulate the estimates datasets to look how we want. ;
data betaDS;
    set betaDS;
    betaSE = round(Estimate, 0.01) || '(' ||
        strip(round(StdErr, 0.01)) || ')';
    betaCL = round(Estimate, 0.01) || ' (' ||
        strip(round(LowerCL)) || ' to ' ||
        strip(round(UpperCL)) || ')';
    drop Biased tValue Estimate StdErr LowerCL UpperCL;
run;

* Look at the datasets.;
%print(betaDS);
%print(fitData);

* We can export the datasets too! See the ods cheatsheet for an;
* explanation ;
proc export data=betaDS dbms = csv outfile = 'beta.csv' replace;
run;



proc contents data=sashelp.class;
run;

proc contents data=sashelp.class short;
run;

%let var = height age;
proc glm data=sashelp.class;
	class sex;
	model weight = sex &var;
run;

%let ds=sashelp.class;
proc means data=&ds;
	var &var;
run;

/*simple macros*/

%macro means(data, vars, class=);
proc means data=&data;
	var &vars;
	class &class;
run;
%mend means;

%let vars = height weight age;
%means(&ds, &vars, class = sex);
%means(&ds, age, class = name);
%means(&ds, weight, class = sex);
%means(&ds, weight);

proc glm data=&ds;
	class sex;
	model height = weight sex; /* predictor covariate*/
run;

%macro glm(data, y, x, class=);
	proc glm data = &data;
	class &class;
	model &y = &x &class;
run;
%mend glm;

%let y = height;
%glm(&ds, &y, weight age, class = sex);
%let x = weight age;
%glm(&ds, &y, &x, class = sex);
%glm(&ds, &y, age, class = sex);
%glm(&ds, &y, weight);
%glm(&ds, &y, weight age);

%let fish = sashelp.fish;
proc contents data = &fish;
run;

%means(&fish, weight, class = species);
%means(&fish, width, class = species);
%means(&fish, length1 weight, class = species);
%means(&fish, length1 weight, class=);

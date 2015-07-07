proc contents data=sashelp.cars;
run;

/*simple code without macros*/
proc glm data=sashelp.cars;
    class origin;
	model msrp = cylinders origin;
run;

proc glm data=sashelp.cars;
    class origin;
	model weight = cylinders horsepower origin;
run;

proc glm data=sashelp.cars;
    class type;
	model mpg_highway= cylinders horsepower type;
run;

/*with macros*/
%let cars=sashelp.cars;
%macro glm(data, y, x, class=);
	proc glm data = &data;
	class &class;
	model &y = &x &class;
run;
%mend glm;

%glm(&cars, msrp, cylinders, class = origin);
%let x = cylinders horsepower;
%glm(&cars, weight, &x, class = origin);
%glm(&cars, mpg_highway, &x, class = type);
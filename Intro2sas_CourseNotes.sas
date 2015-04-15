*To test data step before creating data set--NULL data set;

data _null_;
	infile saledata;
	input field name $ 1-17 month $ 9-11
	      residential 13-21 commercial 23-31;
	tatal=residential + commercial;
run;

*To test data step before creating data set--limiting obs;
data sasuser.sales;
	infile saledata obs=10;
	input field name $ 1-17 month $ 9-11
	      residential 13-21 commercial 23-31;
	tatal=residential + commercial;
run;

*creat a data set;
data sasuser.sales;
	infile saledata;
	input field name $ 1-17 month $ 9-11
	      residential 13-21 commercial 23-31;
	tatal=residential + commercial;
run;
proc print data=sasuser.sales;
run;

*put statement;
data sasuser.sales; 
	infile saledata; 
	input LastName $ 1-7 Month $ 9-11 
         Residential 13-21 
         Commercial 23-31;
	if month in ('JAN','FEB') then
		Total=residential+commercial;
	else put 'your message' month=;
run; 
proc print data=sasuser.sales; 
run;

*creat user defined format;
libname library 'C:\Users\mac\Desktop\SAS';
proc format lib=library fmtlib;
	value $ITEMFMT
		'C'='Cassette'
		'R'='Radio'
		'T'='Television';
run;
*use a user defined format on raw data;
data sasuser.orders;
	infile aug99dat;
	input ID 3. @5 Date date7.
         Item $13 Quantity 15-17
         Price 19-24 TotalCost 26-32;
	format date date 9.item $itemfmt.totalcost dollar9.2;
run;
proc print data=sasuser.orders;
run;

*create a report"across, where, column, order..";
proc report data=sasuser.diabetes nowd headline headskip;
	column id sex weight fastgluc postgluc; 
	where age > 40;
	define id /order descending;
	define weight/format=comma6.2 spacing=4;
	define sex / across width=7 spacing=4 center 'sex of/Patient';
	define fastgluc / 'Fasting/Glucose';
	define postgluc / 'Postprandial/Glucose' width=12;
run;

* summary report-"group, min, mean";
proc report data=sasuser.diabetes nowd headline headskip;
	column sex weight fastgluc postgluc; 
	where age > 40;
	define weight/mean 'average/weight'format=comma6.2 spacing=4 width=7;
	define sex/group width=7 spacing=4 center 'sex of/Patient';
	define fastgluc / min 'Minimum/Fasting/Glucose';
	define postgluc /max 'Maximum/Postprandial/Glucose' width=12;
run;

* summary report-"compute";
proc report data=sasuser.diabetes nowd headline headskip;
	column id sex weight fastgluc postgluc glucrange; *add computed var!!;
	where age > 40;
	define id /order descending;
	define weight/format=comma6.2 spacing=4;
	define sex / across width=7 spacing=4 center 'sex of/Patient';
	define fastgluc / 'Fasting/Glucose';
	define postgluc / 'Postprandial/Glucose' width=12;
	define glucrange / computed 'Glucose/Range';
	compute glucrange;
		glucrange = postgluc.sum - fastgluc.sum;
	endcomp;
run;

*statistics-"means, maxdec,var";
proc means data=sasuser.diabetes mean range std maxdec=1;
	var age pulse fastgluc postgluc;
run; 

*grouped series of statistics-"class";
proc means dat=sasuser.heart min mean max maxdec=0;
	var arterial heart cardiac urinary;
	class survive shock;
run;
*grouped series of statistics-"by";
proc sort data=sasuser.heart out=work.heartsort; *sort first!!!;
	by survive shock;
run;
proc means data=work.heartsort min mean max maxdec=0;
	var arterial heart cardiac urinary;
	by survive shock;
run;

*proc mean;
proc means data=sasuser.heart;
	var heart cardiac urinary;
	class survive shock;
	output out=work.sum_patients
		mean=avgheart avgcardiac avgurinary;
run;
*proc summary with option print;
proc summary data=sasuser.heart print;
	var heart cardiac urinary;
	class survive shock;
	output out=work.sum_patients
		mean=avgheart avgcardiac avgurinary;
run;
*PROC FREQ, table;
proc freq data=sasuser.heart;
	table sex shock survive;
run;

*two-way crosstabulation;
proc freq data=sasuser.heart;
	table survive*shock;
run;

*three-way corsstabulation;
proc freq data=sasuser.heart;
	table sex*survive*shock/list;
run;

*control content of crosstabulation output;
proc freq data=sasuser.heart;
	table shock*survive /nofreq nopercent;
run;

*HTML output;
ods listing close;
ods html body='C:\Users\mac\Desktop\SAS';
proc print data=sasuser.insure;
run;
ods html close;
ods listing;

*HTML output with frame;
ods listing close;
ods html body='C:\Users\mac\Desktop\SAS\myoutput.html'
	     contents='C:\Users\mac\Desktop\SAS\mytoc.html'
	     frame='C:\Users\mac\Desktop\SAS\myframe.html';
proc print data=sasuser.admit;
run;
proc print data=sasuser.insure;
run;
ods html close;
ods listing;

*PROC Tabulate;
proc tabulate data=sasuser.admit;
	class sex;
	var height weight;
	table sex,(height weight)*mean;
run;
*select obs and summarize categories, "keylabel, label", format;
proc tabulate data=sasuser.admit format=9.;
	class actlevel;
	var age;
	table actlevel all,age*mean;
	where sex='F';
	label actlevel='activity level';
	keylabel all='all levels' mean='average';
	title 'Statistics for Females';
run;
*enhanced table-"title, footnote, label";
proc tabulate data=sasuser.therapy;
	var walkjogrun swim;
	table walkjogrun swim;
	title 'Attendance in Exercise Therapies';
	footnote1 'March 1-15';
	label walkjogrun='Walk/Jog/Run';
run;

*three-dimensional table;
proc tabulate data=sasuser.admit format=9.;
	class actlevel sex;
	var age;
	table sex,actlevel all,age*mean;
	label actlevel='activity level';
	keylabel all='all levels' mean='average';
run;
*"styles" to heading cells (change color);
ods listing close;
ods html path='C:\Users\mac\Desktop\SAS' 
         body='active.html';
proc tabulate data=sasuser.admit format=4.1;
	var age;
	class sex actlevel/style={background=white};
	keyword mean/ style={background=white};
	table sex*actlevel*age,mean/
          box={style={background=itgray}};
run;
ods html close;
ods listing;

*"style" to class level, diffrent color for each class;
ods listing close;
ods html path='C:\Users\mac\Desktop\SAS' 
         body='active.html';
proc format;
	value$colsex 'F'='lipk'
	             'M'='pab';
proc tabulate data=sasuser.admit format=4.1;
	var age;
	class sex actlevel/style={background=vpab};
	classlev sex/style={background=$colsex.};
	keyword mean/ style={background=papk};
	table sex*actlevel*age,mean/
          box={style={background=papk}};
run;
ods html close;
ods listing;

*change color for other cells, parent style;
ods listing close;
ods html path='C:\Users\mac\Desktop\SAS' 
         body='active.html';
proc format;
	value$colsex 'F'='lipk'
	             'M'='vpab';
proc tabulate data=sasuser.admit format=4.1;
	var age/style=<parent>;
	class sex actlevel/style={background=vpag};
	classlev sex/style={background=$colsex.};
	classlev actlevel/style=<parent>;
	table sex*actlevel*age*{style=<parent>},mean/
          box={style={background=papk}};
	keyword mean/ style={background=vpag};
run;
ods html close;
ods listing;

*color cell by value range;
ods listing close;
ods html path='C:\Users\mac\Desktop\SAS' 
         body='active.html';
proc format;
	value$colsex 'F'='lipk'
	             'M'='vpab';
	value agealert low-29='lio'
	               other='vpag';
run;
proc tabulate data=sasuser.admit format=4.1;
	var age/style=<parent>;
	class sex actlevel/style={background=vpag};
	classlev sex/style={background=$colsex.};
	classlev actlevel/style=<parent>;
	table sex*actlevel*age*{style={background=agealert.
          font_weight=bold foreground=black}},mean/
          box={style={background=papk}};
	keyword mean/ style={background=vpag};
run;
ods html close;
ods listing;

*add text comment to cell;
ods listing close;
ods html path='C:\Users\mac\Desktop\SAS' 
         body='active.html';
proc format;
	value$colsex 'F'='lipk'
	             'M'='vpab';
	value agealert low-29='lio'
	               other='vpag';
	value ageflyov low-29='cound be a problem'
	               other='';
run;
proc tabulate data=sasuser.admit format=4.1;
	var age/style=<parent>;
	class sex actlevel/style={background=vpag};
	classlev sex/style={background=$colsex.};
	classlev actlevel/style=<parent>;
	table sex*actlevel*age*{style={background=agealert.
	      flyover=ageflyov.
          font_weight=bold foreground=black}},mean/
          box={style={background=papk}};
	keyword mean/ style={background=vpag};
run;
ods html close;
ods listing;

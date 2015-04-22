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

****************************************************;
*Creating and Managing Variables;
*get total using raw data;
data sasuser.sales (keep = month cumtotal); *cut variables;
	infile saledata;
	input LastName $ 1-7 Month $ 9-11
		Residential 13-21 
		Commercial 23-31;
	Tatal = Residential + Commercial;
	retain cumTotal 1254657; *set initial value of total;
	cumTotal+Tatal; *get total;
run;
proc print data=sasuser.sales;
run;

*format and label using raw data;
data sasuser.sales (keep = month cumtotal); *cut variables;
	infile saledata;
	input LastName $ 1-7 Month $ 9-11
		Residential 13-21 
		Commercial 23-31;
	format residential commercial dollar12.2;
	label month='Month of 1999';
run;
proc print data=sasuser.sales;
run;

*SELECT group to assign values;
data sasuser.regions;   
	length Region $ 13;
	infile cardata;   
	input Year 1-4 Country $ 6-11
		Type $ 13-18 @20 Sales comma10.;
	select(country);
		when ('US','CANADA''MEXICO') region='North America';
		when ('JAPEN') region='Asia';
		otherwise region='unknow';
	end;*remember to add end!!!!!
run;
proc print data=sasuser.regions;
run;
****************************************************;
* creat a data set, select obs based on condition;
data work.testtime (keep=timemin timesec); *create data set, keep obs;
	set sasuser.stress2 (drop=id name); *data to read from/not read obs;
	if Maxhr < 155 or resthr < 71; *select obs;
run;
proc print data=work.testtime;
run;
*grouping variable;
proc sort data=sasuser.pilots out=work.pilots;
   by state;
run;
data work.pilotjob(drop=salary);
   set work.pilots(keep=state salary);
   by state;
   if first.state then TotalPay=0; * select only the last observation;
   totalpay+salary;
   if last.state;
run;
proc print data=work.pilotjob noobs;
   sum totalpay;
   format totalpay dollar12.0;
run;

*end of data;
data work.testtime;
   set sasuser.stress2 end=last; *only get last obs;
   if last;
run;
proc print data=work.testtime;
run;

****************************************************;
*combining data sets 'set a, set c';
proc sort data=sasuser.admitjune out= work.adsort;
	by id;
run;
proc sort data=sasuser.stresstest out=work.strsort;
	by id;
run;
proc print data=work.adsort;
run;
proc print data=work.strsort;
run;
data work.one2one;
	set work.adsort(keep=id name sex age);*kept variables;
	set work.strsort(keep=Resthr Maxhr Tolerance);
run;
proc print data=work.one2one;
run;

*concatenating data sets 'set a b';
data work.combined (drop=Rechr);*drop var from new data set;
	set sasuser.stress98
	    sasuser.stress99 (drop=TimeMin TimeSec); *no 'set' needed!!!;
	if Resthr < 72; *select var for new data set;
run;
proc print data=work.combined;
run;

*Interleave data set 'by';
proc sort data=sasuser.stress98 out=work.stress98;
by Tolerance; *sort by var;
run;
proc sort data=sasuser.stress99 out=work.stress99;
by Tolerance;
run;
data work.Interlv;
	set work.stress98 work.stress99;
	by Tolerance;
run;
proc print data=work.Interlv;
run;

*Merge data sets, data have to 'sort!!!!!!' first;
data sasuser.merged;
	merge work.adsort work.strsort;
	by id;
run;
proc print data=sasuser.merged;
run;

*Merge data and Rename variables;
proc print data=sasuser.repertory;
run;
proc print data=sasuser.company;
run;
proc print datat=sasuser.finance;
run;
data work.finrep;
   merge sasuser.repertory 
         sasuser.finance (rename=(Name=LastName Date=HireDate))
         sasuser.company ;
   by ssn;
run;
proc print data=work.finrep;
run;

*Merge data and Exclude Unmatched obs;
data sasuser.merged;
   merge work.adsort
         (in=inad rename=(date=AdmitDate))
         work.strsort
         (in=instr rename=(date=VisitDate));
   by id;
   if inad and instr; *merged data with only obs appear in both data sets;
run;
proc print data=sasuser.merged;
run;

*Merge data with select variables;
data sasuser.merged;
   merge work.adsort
     (drop=height weight rename=(date=AdmitDate) in=inad)
      work.strsort
     (keep=id tolerance date rename=(date=VisitDate) in=instr);
   by id;
   if inad and instr;
run;
proc print data=sasuser.merged;
run;

****************************************************;
*PROC SQL;
proc sql;
	select actlevel,age,kgwgt,meterhgt,
		kgwgt/meterhgt**2 as BodyMass 
	from sasuser.newadmit
	where sex='F'
	order by actlevel; *indention, as new variable;
quit;

*Jion two tables using SQL;
proc sql;
	select therapy1999.month,walkjogrun,swim,
	       treadmill,newadmit,
		   walkjogrun+swim as Exercise
		from sasuser.therapy1999,sasuser.totals2000
		where therapy1999.month=totals2000.month;
quit;

*summarize and group data using SQL;
proc sql;
	select sex, avg(age) as AverageAge, avg(weight) as AverageWeight
	from  sasuser.diabetes
	group by sex;
quit;

****************************************************;
*charactor to numeric data;
data sasuser.talent2;
   set sasuser.talent;
   FtHeight=input(height,2.)/12;
proc print data=sasuser.talent2;
run;

*numeric data to character data;
data sasuser.njtalent;
   set sasuser.talent;
   NewPhone='(201)'||put(phone,7.); 
proc print data=sasuser.njtalent;
   var id phone newphone;
run;

*extract month from a date value;
data sasuser.talent10;
	set sasuser.talent;
	if month(LastHired)=10;
	format lasthired date9.;
run;
proc print data=sasuser.talent10;
run;

data sasuser.taloc99;
	set sasuser.talent;
	if month(lasthired)=10 and year(lasthired)=1999;
	format lasthired date9.;
run;
proc print data=sasuser.taloc99;
run;

*Extract year from a data value;
data sasuser.talent99;
	set sasuser.talent;
	if year(lasthired)=1999;
	format lasthired date9.;
run;
proc print data=sasuser.talent99;
run;

*'mdy';
data sasuser.Master;
	set sasuser.talent;
	RepHired=mdy(Month, Day, 1998);
run;
proc print data=sasuser.Master;
run;

*how many 'day'/'month'/'quatar' past;
data sasuser.master;
	set sasuser.master;
	Qtrselapsed=intck('qtr', rephired, lasthired);
run;
proc print data=sasuser.master;
run;

*Extract a word;
data sasuser.agency99;
	set sasuser.talent;
	State=scan(address2,2);
run;
proc print data=sasuser.agency99;
run;

*Extract a substring;
data sasuser.newtal;
	set sasuser.talent;
	sex=substr(id,4,1);
run;
proc print data=sasuser.newtal;
run;

*Replace contents of a character variable;
data sasuser.njtalent;
   set sasuser.talent;
   NewPhone='(201)'||phone;
proc print data=sasuser.njtalent;
   var id phone newphone;
run;

data sasuer.detalent;
	set sasuser.njtalent;
	substr(newphone,2,3)='302';
run;
proc print data=sasuser.detalent;
run;

*search a character 'index';
data sasuser.stage;
	set sasuser.talent;
	if index(comment, 'stage')>0;
run;
proc print data=sasuser.stage;
run;

****************************************************;
*DO loop;
data work.earn;
	Value=2000;
	do year=1 to 20;
		Interest=value*.075;
		value+interest;
	end;
run;
proc print data=work.earn;
run;

*nest Do loop;
data work.save;
	Rate=.0625/4;
	do year=1 to 20;
		Amount+2000;
		do qtr=1 to 4;
			amount+amount*rate;
		end;
   end;
run;
proc print data=work.save;
run;

*interatively process data;
data work.totals(drop=i balance interest);
   set sasuser.loans;
   balance=amount;
   TotalInterest=0;
   do i=1 to Months;
      Interest=balance*(rate/12);
      balance+interest-payment;
      totalinterest+interest;
   end;
run;
proc print data=work.totals;
run;

*Do until;
data work.retire;
   Savings=500000;
   Income=5000;
   do until (savings >= 1000000);
      Year+1;
      income+income*.04;
      savings+income*.10;
   end;
run;
proc print data=work.retire;
run;

*Do while;
data work.retire;
   Savings=8000;
   Income=42000;
   do while(savings<1000000);
      Year+1;
      income+(income*.04);
      savings+(income*.10);
   end;
run;
proc print data=work.retire;
run;

*Do loop until...;
data work.retire;
   Savings=6000;
   Income=38000;
   do year=1 to 30 until(savings>=1000000);
      Year+1;
      income+(income*.06);
      savings+(income*.20);
   end;
run;
proc print data=work.retire;
run;

****************************************************;
*Array;
data sasuser.added (drop=i);
	set sasuser.funddrive;
	array contrib{4} qtr1-qtr4;
	do i=1 to 4;
		contrib{i}=contrib{i}*1.25;
	end;
run;
proc print data=sasuser.added;
run;
		
* two-dimensional array;
data sasuser.summary(drop=i j total);
   set sasuser.survey;
   array section{3} eating exercise stress;
   array resp{3,6}item1-item18; *item !!!!;
   do i=1 to 3;
      Total=0;
      do j=1 to 6;
         total+(resp{i,j});
      end;
      section{i}=total/6;
   end;
run;
proc print data=sasuser.summary;
run;

****************************************************;
*Automatic Macro variable;
title;
footnote "Date: &sysdate9, &sysday"; *date, day of the week;
data sasuser.talent99;
   set sasuser.talent;
   if year(lasthired)=1999;
   format birthdate lasthired date.;
run;
proc print data=sasuser.talent99;
run; 
footnote; *cancel footnote;
run;

title1 'Temporary Employees for 1999';
title2 "as of &systime, &sysday, &sysdate9";
data work.talent99;
   set sasuser.talent;
   sasver="&sysver"; *SAS vesion;
   opsystem="&sysscp";*operating system;
   if year(lasthired)=1999;
   format birthdate lasthired date.;
run;
proc print data=work.talent99;
run;

*Creat reference Macro variables!!;
%let number=11;
%let name=November;
title1 "Actors Hired in &name";*don't forget the ""!;
footnote1 "Report Number &number";
data sasuser.newhire;
   set sasuser.talent99;
   if month(lasthired)=&number;
   format lasthired date9.;
run;
proc print data=sasuser.newhire;
run;
title; *cancel title and footnote;
footnote;
run;

*Display values of macro var in log;
options symbolgen; *display in log;
%let number=11;
%let name=November;
title1 "Actors Hired in &name";
footnote1 "Report Number &number";
data sasuser.newhire;
   set sasuser.talent99;
   if month(lasthired)=&number;
   format birthdate lasthired date.;
run;
proc print data=sasuser.newhire;
run;
title;
footnote;
run;

*Call Symput to creat macro var (calculated by Data step);
%let number=11;
%let name=November;
%let abbrev=nov;
%let year=99;
footnote1 "Report Number &number";
data &abbrev.hire;
   set sasuser.talent&year;
   if month(lasthired)=&number then
   do;
      Fee=rate*.10;
      TotFee+fee;
	  call symput('total',TotFee); *creat Macro var during data step;
      output;
   end;
   format lasthired date9.;
run;
title1 "Actors Hired in &name";
title2 "Agency Commission &total";
proc print data=&abbrev.hire;
run;

*control execution of Call Symput routine to only once;
%let number=11;
%let name=November;
%let abbrev=nov;
%let year=99;
data &abbrev.hire;
   set sasuser.talent&year end=final; *end-of-file marker;
   if month(lasthired)=&number then
   do;
      Fee=rate*.10;
      TotFee+fee;
	  if final then 
		call symput('total', put(TotFee,dollar6.));*"put"to remove blanks;
      output;
   end;
   call symput('total',
        put(totfee,dollar6.));
run;
title1 "Actors Hired in &name";
title2 "Agency Commission &total";
footnote1 "Report Number &number";
proc print data=&abbrev.hire;
run; 

**********************************************************;
*Reading data from raw data file;
data sasuser.choltest;
	infile choldata; *fileref to read nonSAS files; 
	input idnum $ 10-14 department $ 10-11
	      lastname $ 1-9 cholesterol 15-19; *space between name and col;
run;
proc print data=sasuser.choltest;
run;

*point chntrol for input raw data file;
data sasuser.vansales;
   infile vandata;
   input @1 Region $9. @13 Quarter 1.
         @16 TotalSales comma11.;
run;
proc print data=sasuser.vansales;
run;

*insert @or + column pointer;
data sasuser.vansales;
   infile vandata;
   input @13 Quarter 1. @1 Region $9.
         @16 TotalSales comma11.;
run;
proc print data=sasuser.vansales;
run;

*format input to read raw data;
data sasuser.carsales;
	infile cardata;
	input Year 4. @6 Country $6 @13 Type $6 @20 Sales comma10.;
run;
proc print data=sasuser.carsales;
run;

******************************************************;
*use list input to read free-format data;
data sasuser.booksale;
	infile bookdata;
	input bookid $ booktype $ numsold;
run;
proc print data=sasuser.booksale;
run;

*use DLM=option list input to read free-format data;
data sasuser.stock1;
	infile invent1 DLM=':';
	input bookid $ author $ booktype $ instock;
run;
proc print data=sasuser.stock1;
run;

*read data with missing values at the end;
data sasuser.childsrv;
	infile survey1 missover;
	input age (book1-book3) ($); *read miltiple cols;
run;
proc print data=sasuser.childsrv;
run;

*Length statement in list input;
data sasuser.stock2;
	infile invent2;
	length author $ 11; *avoid truck of the var;
	input bookid $ author $ booktype $ instock;
run;
proc print data=sasuser.stock2;
run;

*read nonstandard values with blank(&);
data sasuser.publish;
	infile pubdata ;
	input Bookid $ Publisher & $22. Year; *there are two blank in Publisher var;
run;
proc print data=sasuser.publish;
run;

*use column, formatted, and list input read raw data;
data sasuser.reorder;
    infile orderdat;
    input PubID 1-3 BookID $ 5-10 
              @12 Date date7.
              BookType $ Number;
run;
proc print data=sasuser.reorder;
     format date date9.;
run;

*****************************************************
*Date and Time;
option yearcutoff=1920;
data sasuser.powrcost;
	infile powerdat;
	input FirstDay date7. @10 LastDay date7. 
	      @19 KwhUsed 4. @25 KwhRate 5.;
		  day= LastDay - FirstDay +1; 
		  cost=KwhUsed*KwhRate;
		  AvgCost=cost/day;
run;
proc print data=sasuser.powrcost;
	format datein firstday lastday weekdate21.; *date format including weekday;
run;

**************************************************
*read multiple records as one obs;
data sasuser.emplist1;
	infile Personel;
	input Name $14. ID 16-19 /
		  JobCode 3. Department $5-16 /
		  Salary comma9.;
run;
proc print data=sasuser.emplist1;
run;

*read multiple records non-sequentially;
data sasuser.emplist2;
	infile Personel;
	input #2 Department $5-16 
          #1 ID 16-19
		  #1 Name $14. 
		  #2 JobCode 3.
		  #3 Salary comma9.;
run;
proc print data=sasuser.emplist2;
run;

* alternate;
data sasuser.emplist2;
	infile Personel;
	input #2 Department $5-16 
          #1 ID 16-19 @1 Name $14./ 
		  JobCode 3./
		  Salary comma9.;
run;
proc print data=sasuser.emplist2;
run;

************************************************;
*creat one obs for each repeating block of data;
data sasuser.actlevel;
	infile excdata1;
	input ID $ Actlevel : $9. @@;
run;
proc print data=sasuser.actlevel;
run;

*one obs for each repeating field;
data sasuser.group1;
   infile excdata2;
   input ID $ @;
   do Choice =1 to 3;
      input Activity : $10. @;
      output;
    end;
run;
proc print data=sasuser.group1;
run;

*create one obs for each repeating field with missing data;
data sasuser.group2;
   infile excdata3 missover; *ignore missing values at the end of obs;
   input ID $ Activity : $10. @;
   Choice=0;
   do while (activity ne '');
   		Choice +1;
		output;
		input Activity: $10. @;
   end;
run;
proc print data=sasuser.group2;
run;

**********************************************;
*read hierarchical file;
data sasuser.billing1(drop=type);
	infile Jan98dat;
	retain ID Name;
	input type $1. @;
	if Type='P' then input @3 ID $ Name $8-22.; *header records;
	if Type='C';
	input @3 Date mmddyy8. @12 Amount comma6.;*detail records;
	format date mmddyy8. amount dollar7.2;
run;
proc print data=sasuser.billing1;
run;

*read hierarchical file and create one obs per header record;
data sasuser.billing2 (drop=type amount);
	infile Jan98dat end=last; *label last obs;
	retain ID Name;
	input type $1. @;
	if type='P' then do; *header;
		if _n_ >1 then output;
		Totalcost=0;
		input @3 ID $ @8 Name $15.;
	end;
	else if type='C' then do;
		input @12 Amount comma6.;
		Totalcost + Amount; *sum amount as totalcost;
	end;
	if last then output;*output for the last obs;
run;
proc print data=sasuser.billing2;
run;

****************************************************;
*read fields with varying lengths;
data sasuser.scores1;
	infile satdata1 length=reclen;
	input SSN $11. @;
	namelen=reclen-14;
	input LastName $varying10. namelen 
	      SATscore;
run;
proc print data=sasuser.scores1(drop=namelen);
run;
	      
*read variable-length record with varying number of fiels;
data sasuser.scores2;
	infile satdata2 length=reclen;
	input SSN $11. @;
	do index=12 to reclen by 12;
		input Date : date. SATscore @;
		output;
	end;
run;
proc print data=sasuser.scores2(drop=index);
run;

















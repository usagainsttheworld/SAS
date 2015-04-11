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

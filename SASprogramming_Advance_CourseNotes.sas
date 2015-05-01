/*Performing queries using PROC SQL */
Proc sql; /* do not forget the semicolon */
	select ActLevel, Age, KgWgt, MeterHgt,
			kgwgt/meterhgt**2 as BodyMass
		from Sasuser.Newadmit
		where sex = 'F'
		order by ActLevel;
quit;

/*join two set using Proc sql*/
Proc sql;
	select therapy1999.month, walkjogrun, swim,
			treadmill, newadmit, 
			walkjogrun+swim as Exercise
		from sasuser.therapy1999, sasuser.totals2000
		where therapy1999.month = totals2000.month; /* do not forget the semicolon */
quit;

/*summarize and group data using Proc sql*/
Proc sql;
	select sex, 
			avg(age) as averageage, 
			avg(weight) as averageweight
		from sasuser.diabetes
		group by sex;
quit;

/*ceate table to store the result*/
Proc sql;
	create table Sas_base.ave_diabete as
	select sex, 
			avg(age) as averageage, 
			avg(weight) as averageweight
		from sasuser.diabetes
		group by sex;
quit;

/* subseting-Having*/
proc sql;
	select jobcode,avg(salary) as Avg
		from sasuser.payrollmaster
		group by jobcode
		having avg(salary)>40000
		order by jobcode;
quit;
/************************************************/
/*Performing Advanced queries using Proc SQL*/

/*  members whose last name is spelled like SANDERS or SAUNDERS. 
You also want the output to include any program 
members whose last name contains one or more 
additional letters at the end (such as SANDERSON). */
Proc sql;
	select name, ffid
	from sasuser.frequentflyers
	where Name like 'SA%NDERS%, %'
	order by names;

/*select all obs and get col list in log */
proc sql outobs=10 feedback;
	select *
	from sasuser.marchflights 
	order by flightnumber;
quit;

/*unique obs*/
proc sql;
	select distinct flightnumber
	from sasuser.marchflights 
	order by flightnumber;
quit;

/*calculated + new var*/
proc sql;
	select flightnumber, date, destination,
		sum(boarded, transferred, nonrevenue) as Total, passengercapacity
	from sasuser.marchflights 
	where calculated Total < passengercapacity/3
	order by Total;
quit;

*between and;
proc sql;
	select flightnumber, date, destination,
		sum(boarded, transferred, nonrevenue) as Total, passengercapacity
	from sasuser.marchflights 
	where calculated Total between 0 and 50
	order by Total;
quit;

*add title and format to var;
proc sql;
title 'Federal Taxes';
title2 'Male Employees with Payroll Changes';
	select empid label= 'Employee ID Number', 
			gender, jobcode, 
			salary format = comma9.2,
			salary/3 as Tax format = comma9.2
	from sasuser.payrollchanges
	where gender = 'M'
	order by jobcode;
quit;
title;

*summarizing and group data;
proc sql;
title'Number of Employees in Each City';
	select state, city, count(*) as Employees
	from sasuser.staffmaster
	group by state,city;
quit;
title;

*subseting data within group;
proc sql;
title Total Miles Traveled for States;
title2 with Fewer Than 5 Members;
	select state, 
			sum(milestraveled) as TotTravelMiles,
			count(*) as Members
	from sasuser.frequentflyers	
	group by state
	having Members < 5
	order by state;
quit;
title;

*subsetting data by using noncorrelated subqueries;
proc sql;
	select empid, jobcode, salary
	from sasuser.payrollchanges
	where salary < 
		(select avg(salary)
			from sasuser.payrollmaster)
	order by empid;
quit;

proc sql;
title 'Contact Information for Level 3 Mechanics';
	select empid, lastname, firstname, phonenumber
		from sasuser.staffmaster
		where empid in 
			(select empid
				from sasuser.mechanicslevel3)
	order by lastname;
quit;
title;

proc sql;
title 'Employees with February Anniversaries';
	select firstname, lastname, state
		from sasuser.staffmaster
		where empid in 
			(select empid
				from sasuser.payrollmaster 
				where month(dateofhire) = 2)
	order by lastname;
quit;

proc sql;
title 'Employees with February Anniversaries';
title2 'by State';
	select state, count(empid) as Employees
		from sasuser.staffmaster
		where empid in 
			(select empid
				from sasuser.payrollmaster 
				where month(dateofhire) = 2)
	group by state;
	order by lastname;
quit;

*Correlated subquery--using "exists"!!!!!;
*Create a PROC SQL query to list all frequent-flyer program 
members who are also airline employees;
proc sql;
title 'Frequent Flyers Who Are Employees';
	select name
		from sasuser.frequentflyers
		where exists
			(select * 
				from sasuser.staffmaster
				where name=trim(lastname)||', '||firstname)
	order by name;
quit;

*list all frequent-flyer program members who are not employees;
proc sql;
title 'Frequent Flyers Who Are not Employees';
	select name
		from sasuser.frequentflyers
		where not exists
			(select * 
				from sasuser.staffmaster
				where name=trim(lastname)||', '||firstname)
	order by name;
quit;

*Display total number of frequent-flyer program members 
 who are not employees;
proc sql;
title 'Frequent Flyers Who Are not Employees';
	select count(*) as Count
		from sasuser.frequentflyers
		where not exists
			(select * 
				from sasuser.staffmaster
				where name=trim(lastname)||', '||firstname);
quit;
title;

*quiz notes:
 where clause before group by
 having clause after group by;


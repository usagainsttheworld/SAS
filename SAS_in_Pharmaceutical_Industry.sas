/*SAS Programming in the Pharmaceutical Industry___by Jack Shostak*/
/***************************************************/

/*****Chapter 1: Environment and Guiding Principles******/
*Using a SAS Macro to Define Common Librefs;
%macro mylibs;
	libname traildata "c:\mytrial\sasdata";
	libname library "c:\mytrial\mysasformats";
	libname otherdata "c:\someotherdata";
%mend mylibs;
*call macro;
%mylibs

*defensive programming__parent-child data problem ;
data aes;
set aes;
by subjectid;
**** PARENT-CHILD WARNING;
if (aeyn ne "YES" and aetext ne "") or
(aeyn = "YES" and aetext = "") then
put "WARN" "ING: ae parent-child bug " aeyn= aetext=;
**** GET AES;
if aeyn = "YES" or aetext ne "";
run;

*defensive programming__if-then/else1;
if a > b then
a = a + b;
else if a < b then
a = a - b;
else
put "How does a relate to b? " a= b=;

*defensive programming__if-then/else2;
select;
when(a > b) a = a + b;
when(a < b) a = a - b;
otherwise put "What am I missing? " a= b=;
end;

/*****Chapter 2: Preparing and Classifying Clinical Trail Data******/
*Categorizing numeric data;
data demog;
set demog;
by subject;
if .z < age <= 18 then
age_cat = 1;
else if 18 < age <= 60 then
age_cat = 2;
else if 60 < age then
age_cat = 3;
run;

*handle free-text variables__put vars as coded;
data adverse;
label aecode = "Adverse Event Code"
ae_verbatim = "AE Verbatim CRF text"
ae_pt = "AE preferred term";
input subjectid $ 1-7 aecode $ 9-16
ae_verbatim $ 18-39 ae_pt $ 40-60;
datalines;
100-101 10019211 HEDACHE HEADACHE
100-105 10019211 HEADACHE HEADACHE 
100-110 10028596 MYOCARDIAL INFARCTION MYOCARDIAL INFARCTION
200-004 10028596 MI MYOCARDIAL INFARCTION
300-023 10061599 BROKEN LEG LOWER LIMB FRACTURE
400-010 10046735 HIVES URTICARIA
500-001 10013573 LIGHTHEADEDNESS DIZZINESS
500-001 10058818 FACIAL LACERATION SKIN LACERATION
;
*benefit of coding:
headaches and myocardial infarctions are grouped appropriately,
splitting lightheadedness and facial laceration into separate events 
leads to those data being summarized separately as well;
run;
proc freq
data = adverse;
tables ae_pt;
run;

*Avoid hardcoding data,if has to, use improved hardcoding as follows;
data endstudy;
set endstudy;
**** HARDCODE APPROVED BY DR. NAME AT SPONSOR ON 02/02/2005;
if subjid = “101-1002” and “&sysdate” <= “01MAY2005”d then
do;
****If you know that an IDMC meeting will be held in April 2005 and 
you do not want to worry about oldhardcodes, you could program them 
so that they expire in this way;
discterm = "Death";
put “Subject “ subjid “hardcoded to termination reason”
discterm;
run;

*The best way to link the serious adverse events and adverse events 
databases is to have the clinical data management system create a 
linking variable key for you;


/******Chapter3:Importing Data******/
*using SQL pass-through facility to get data from Oracle;
proc sql;
connect to oracle as oracle_tables
(user = USERID orapw = PASSWORD path = "INSTANCE");
create table AE as
select * from connection to oracle_tables
(select * from AE_ORACLE_TABLE );
disconnect from oracle_tables;
quit;

*to get selected data;
proc sql;
connect to oracle as oracle_tables
(user = USERID orapw = PASSWORD path ="INSTANCE");
create table library.AE as
select * from connection to oracle_tables
(select subject, verbatim, ae_date, pt_text
from AE_ORACLE_TABLE
where query_clean=”YES”);
disconnect from oracle_tables;
quit;

*using SAS/ACCESS LIBNAME to get data from Oracle;
libname oratabs oracle user=USERNAME
orapw = PASSWORD path = "@INSTANCE" schema = TRIALNAME;
data adverse;
set oratabs.AE_ORACLE_TABLE;
where query_clean = “YES”;
keep subject verbatim ae_date pt_text;
run;

*import ASCII text using Import Wizard;

*import ASCII text using data step(custom);
proc format;
value $gender "F" = "Female"
"M" = "Male";
run;
data labnorm;
infile 'C:\normal_ranges.txt' delimiter = '|' dsd missover
firstobs = 2;
informat Lab_Test $20.
Units $9.
Gender $1. ;
format Lab_Test $20.
Units $9.
Gender $gender.;
input Lab_Test $
Units $
Gender $
Low_Age
High_Age
Low_Normal
High_Normal;
label Lab_Test = "Laboratory Test"
Units = "Lab Units"
Gender = "Gender"
Low_Age = "Lower Age Range"
High_Age = "Higher Age Range"
Low_Normal = "Low Normal Lab Value Range"
High_Normal = "High Normal Lab Value Range";
run;

*importing test files using Enterprise Guide interface;

****importing Microsoft Office files*****;
*it is best not to accept Microsoft Excel data as a data 
source for clinical trials if at all possible;

*using Libname statement to read excel data;
libname xlsfile EXCEL "C:\normal_ranges.xls";
proc contents
data = xlsfile._all_;
run;
proc print
data = XLSFILE.'normal_ranges$'n;
run;

*Using Libname statement to read microsoft Access data;
libname accfile ACCESS "C:\normal_ranges.mdb";
proc contents
data = accfile._all_;
run;
proc print
data = accfile.normal_ranges;
run;

*using import wizard to read Excel and Access files;

*using Pass-throught facility to read Excel files;
**OBTAIN AVAILABLE WORKSHEET NAMES FROM EXCEL FILE;
proc sql;
connect to excel (path = "C:\normal_ranges.xls");
select table_name from connection to excel(jet::tables);
quit;
**GO GET NORMAL_RANGES WORKSHEET FROM EXCEL FILE;
proc sql;
connect to EXCEL (path = "C:\normal_ranges.xls" header = yes
mixed = yes version = 2000 );
create table normal_ranges as
select * from connection to excel
(select * from [normal_ranges$]);
disconnect from excel;
quit;

*using Pass-throught facility to read Acess files; 
*** OBTAIN AVAILABLE TABLE NAMES FROM ACCESS FILE;
proc sql;
connect to access (path = "C:\normal_ranges.mdb");
select table_name from connection to access(jet::tables);
quit;
**** GO GET NORMAL_RANGES WORKSHEET FROM ACCESS FILE;
proc sql;
connect to access (path="C:\normal_ranges.mdb");
create table normal_ranges as
select * from connection to access
(select * from normal_ranges);
disconnect from access;
quit;

****Importing XML****;
*using XML Libname engine to read XML data;
filename normals 'C:\normal_ranges.xml';
libname normals xml xmlmap=XML_MAP;
filename XML_MAP 'C:\xml_map.map';
proc contents
data = normals.normals;
run;
proc print
data = normals.normals;
run;

*SAS XML Mapper

*using Proc CDISC to read ODM XML data;
**** FILENAME POINTING TO ODM FILE;
filename dmodm "C:\dm.xml";
**** PROC CDISC TO IMPORT DM.XML TO DM WORK DATA SET;
proc cdisc
model = odm
read = dmodm
formatactive = yes
formatnoreplace = no;
odm
odmversion = "1.2"
odmmaximumoidlength = 30
odmminimumkeyset = no;
clinicaldata
out = work.dm
sasdatasetname = "DM";
run;

/**********Chapter 4: Transforming Data and creating analysis data set;****/

*Last Observation Carried Forward(LOCF) variables;
**** INPUT SAMPLE CHOLESTEROL DATA.
**** SUBJECT = PATIENT NUMBER, SAMPDATE = LAB SAMPLE DATE,
**** HDL = HDL, LDL = LDL, AND TRIG = TRIGLYCERIDES.;
data chol;
input subject $ sampdate date9. hdl ldl trig;
datalines;
101 05SEP2003 48 188 108
101 06SEP2003 49 185 .
102 01OCT2003 54 200 350
102 02OCT2003 52 . 360
103 10NOV2003 . 240 900
103 11NOV2003 30 . 880
103 12NOV2003 32 . .
103 13NOV2003 35 289 930
;
run;
**** INPUT SAMPLE PILL DOSING DATA.
**** SUBJECT = PATIENT NUMBER, DOSEDATE = DRUG DOSING DATE.;
data dosing;
input subject $ dosedate date9.;
datalines;
101 07SEP2003
102 07OCT2003
103 13NOV2003
;
run;

**** SORT CHOLESTEROL DATA FOR MERGING WITH DOSING DATA.;
proc sort
	data = chol;
		by subject sampdate;
run;
**** SORT DOSING DATA FOR MERGING WITH CHOLESTEROL DATA.;
proc sort
	data = dosing;
		by subject;
run;
**** DEFINE BASELINE HDL, LDL, AND TRIG VARIABLES;
data baseline;
	merge chol dosing;
	by subject;
	keep subject b_hdl b_ldl b_trig;
**** SET UP ARRAYS FOR BASELINE VARIABLES AND LAB VALUES;
	array base {3} b_hdl b_ldl b_trig;
	array chol {3} hdl ldl trig;
**** RETAIN NEW BASELINE VARIABLES SO THEY ARE PRESENT
**** AT LAST.SUBJECT BELOW.;
	retain b_hdl b_ldl b_trig;
**** INITIALIZE BASELINE VARIABLES TO MISSING.;
	if first.subject then
		do i = 1 to 3;
			base{i} = .;
		end;
**** IF LAB VALUE IS WITHIN 5 DAYS OF DOSING, RETAIN IT AS
**** A VALID BASELINE VALUE.;
	if 1 <= (dosedate - sampdate) <= 5 then
		do i = 1 to 3;
			if chol{i} ne . then
				base{i} = chol{i};
		end;

**** KEEP LAST RECORD PER PATIENT HOLDING THE LOCF VALUES.;
if last.subject;
label b_hdl = "Baseline HDL"
	b_ldl = "Baseline LDL"
	b_trig = "Baseline triglycerides";
run;

*calculating a Study Day without zero;
if event_date < intervention_date then
	study_day = event_date – intervention_date;
else if event_date >= intervention_date then
	study_day = event_date – intervention_date + 1;

*deriving a visit based on Visit Windowing;
**** INPUT SAMPLE LAB DATA.
**** SUBJECT = PATIENT NUMBER, LAB_TEST = LABORATORY TEST NAME,
**** LAB_DATE = LAB COLLECTION DATE, LAB_RESULT = LAB VALUE.;
data labs;
input subject $ lab_test $ lab_date lab_result;
datalines;
101 HGB 999 1.0
101 HGB 1000 1.1
101 HGB 1011 1.2
101 HGB 1029 1.3
101 HGB 1030 1.4
101 HGB 1031 1.5
101 HGB 1058 1.6
101 HGB 1064 1.7
101 HGB 1725 1.8
101 HGB 1735 1.9
;
run;
**** INPUT SAMPLE DOSING DATE.
**** SUBJECT = PATIENT NUMBER, DOSE_DATE = DATE OF DOSING.;
data dosing;
input subject $ dose_date;
datalines;
101 1001
;
run;
**** SORT LAB DATA FOR MERGE WITH DOSING;
proc sort
	data = labs;
		by subject;
run;
**** SORT DOSING DATA FOR MERGE WITH LABS.;
proc sort
	data = dosing;
		by subject;
run;
**** MERGE LAB DATA WITH DOSING DATE. CALCULATE STUDY DAY AND
**** DEFINE VISIT WINDOWS BASED ON STUDY DAY.;
data labs;
	merge labs(in = inlab)
			dosing(keep = subject dose_date);
		by subject;
		**** KEEP RECORD IF IN LAB AND RESULT IS NOT MISSING.;
		if inlab and lab_result ne .;
		**** CALCULATE STUDY DAY.;
		if lab_date < dose_date then
			study_day = lab_date - dose_date;
		else if lab_date >= dose_date then
			study_day = lab_date - dose_date + 1;
		**** SET VISIT WINDOWS AND TARGET DAY AS THE MIDDLE OF THE WINDOW.;
		if . < study_day < 0 then
			target = 0;
		else if 25 <= study_day <= 35 then
			target = 30;
		else if 55 <= study_day <= 65 then
			target = 60;
		else if 350 <= study_day <= 380 then
			target = 365;
		else if 715 <= study_day <= 745 then
			target = 730;
		**** CALCULATE OBSERVATION DISTANCE FROM TARGET AND
		**** ABSOLUTE VALUE OF THAT DIFFERENCE.;
		difference = study_day - target;
		absdifference = abs(difference);
run;
**** SORT DATA BY DECREASING ABSOLUTE DIFFERENCE AND ACTUAL
**** DIFFERENCE WITHIN A VISIT WINDOW.;
proc sort
	data=labs;
		by subject lab_test target absdifference difference;
run;
**** SELECT THE RECORD CLOSEST TO THE TARGET AS THE VISIT.
**** CHOOSE THE EARLIER OF THE TWO OBSERVATIONS IN THE EVENT OF
**** A TIE ON BOTH SIDES OF THE TARGET.;
data labs;
	set labs;
		by subject lab_test target absdifference difference;
		if first.target and target ne . then
			visit_number = target;
run;


*Transposing data with PROC TRANSPOSE*;
**** INPUT SAMPLE NORMALIZED SYSTOLIC BLOOD PRESSURE VALUES.
**** SUBJECT = PATIENT NUMBER, VISIT = VISIT NUMBER,
**** SBP = SYSTOLIC BLOOD PRESSURE.;
data sbp;
input subject $ visit sbp;
datalines;
101 1 160
101 3 140
101 4 130
101 5 120
202 1 141
202 3 161
202 4 171
202 5 181
;
run;
**** TRANSPOSE THE NORMALIZED SBP VALUES TO A FLAT STRUCTURE.;
proc transpose
	data = sbp
	out = sbpflat
	prefix = VISIT;
		by subject;
		id visit;
		var sbp;
run;
proc print data=sbpflat;
run;

*Using PROC TRANSPOSE when there is a missing value*;
**** INPUT SAMPLE NORMALIZED SYSTOLIC BLOOD PRESSURE VALUES.
**** SUBJECT = PATIENT NUMBER, VISIT = VISIT NUMBER,
**** SBP = SYSTOLIC BLOOD PRESSURE.;
data sbp;
input subject $ visit sbp;
datalines;
101 1 160
101 3 140
101 4 130
101 5 120
202 1 141
202 2 151
202 3 161
202 4 171
202 5 181
;
*notice missing visit=2;
run;
**** TRANSPOSE THE NORMALIZED SBP VALUES TO A FLAT STRUCTURE.;
proc transpose
	data = sbp
	out = sbpflat
	prefix = VISIT;
		by subject;
		id visit; *have to use ID statement to avoid error;
		*If order is important when transposing row data to columns,
		then the use of an ID statement in PROC TRANSPOSE is imperativ;
		var sbp;
run;

*Let’s look at a derivation of the previous systolic blood pressure 
transposition problem where visit 2 is always missing;
*Often in clinical trials reporting you want to report on all visits, 
treatments, orother expected parameters whether they are represented 
in the actual data or not. In this case, a DATA step with arrays is a 
better choice to transform the data.

*Thansposing data with DATA Step*;
**** INPUT SAMPLE NORMALIZED SYSTOLIC BLOOD PRESSURE VALUES.
**** SUBJECT = PATIENT NUMBER, VISIT = VISIT NUMBER,
**** SBP = SYSTOLIC BLOOD PRESSURE.;
data sbp;
input subject $ visit sbp;
datalines;
101 1 160
101 3 140
101 4 130
101 5 120
202 1 141
202 3 161
202 4 171
202 5 181
;
*notice visit=2 is alwasy missing;
run;
**** SORT SBP VALUES BY SUBJECT.;
proc sort
	data = sbp;
		by subject;
run;
**** TRANSPOSE THE NORMALIZED SBP VALUES TO A FLAT STRUCTURE.;
data sbpflat;
	set sbp;
		by subject;
		keep subject visit1-visit5;
		retain visit1-visit5;
		**** DEFINE ARRAY TO HOLD SBP VALUES FOR 5 VISITS.;
		array sbps {5} visit1-visit5;
		**** AT FIRST SUBJECT, INITIALIZE ARRAY TO MISSING.;
		if first.subject then
			do i = 1 to 5;
				sbps{i} = .;
			end;
		*** AT EACH VISIT LOAD THE SBP VALUE INTO THE PROPER SLOT
		**** IN THE ARRAY.;
		sbps{visit} = sbp;
		**** KEEP THE LAST OBSERVATION PER SUBJECT WITH 5 SBPS.;
		if last.subject;
run;
proc print data=sbpflat;
run;

*Performing a Many-to Many Jion with PROC SQL*;
**** INPUT SAMPLE ADVERSE EVENT DATA.
**** SUBJECT = PATIENT NUMBER, AE_START = START DATE OF AE,
**** AE_STOP = STOP DATE OF AE, ADVERSE_EVENT = NAME OF EVENT.;
data aes;
informat ae_start date9. ae_stop date9.;
input @1 subject $3.
		@5 ae_start date9.
		@15 ae_stop date9.
		@25 adverse_event $15.;
datalines;
101 01JAN2004 02JAN2004 Headache
101 15JAN2004 03FEB2004 Back Pain
102 03NOV2003 10DEC2003 Rash
102 03JAN2004 10JAN2004 Abdominal Pain
102 04APR2004 04APR2004 Constipation
;
run;
**** INPUT SAMPLE CONCOMITANT MEDICATION DATA.
**** SUBJECT = PATIENT NUMBER, AE_START = START DATE OF AE,
**** AE_STOP = STOP DATE OF AE, ADVERSE_EVENT = NAME OF EVENT.;
data conmeds;
informat cm_start date9. cm_stop date9.;
input @1 subject $3.
		@5 cm_start date9.
		@15 cm_stop date9.
		@25 conmed $20.;
datalines;
101 01JAN2004 01JAN2004 Acetaminophen
101 20DEC2003 20MAR2004 Tylenol w/ Codeine
101 12DEC2003 12DEC2003 Sudafed
102 07DEC2003 18DEC2003 Hydrocortisone Cream
102 06JAN2004 08JAN2004 Simethicone
102 09JAN2004 10MAR2004 Esomeprazole
;
run;
**** MERGE/JOIN ADVERSE EVENTS WITH CONCOMITANT MEDICATIONS.
**** KEEP MEDICATIONS THAT STARTED OR STOPPED DURING AN ADVERSE
**** EVENT OR ENTIRELY SPANNED ACROSS AN ADVERSE EVENT.;
proc sql;
	create table ae_meds as
	select a.subject, a.ae_start, a.ae_stop,
			a.adverse_event, c.cm_start, c.cm_stop,
			c.conmed from
	aes as a left join conmeds as c
	on (a.subject = c.subject) and
		( (a.ae_start <= c.cm_start <= a.ae_stop) or
		(a.ae_start <= c.cm_stop <= a.ae_stop) or
		((c.cm_start < a.ae_start) and (a.ae_stop < c.cm_stop)));
quit;

*Bringing MedDRA Dictionary tables together*;
**** SORT LOW LEVEL TERM DATA FROM MEDDRA WHERE
**** LOW_LEVEL_TERM = LOWEST LEVEL TERM, LLT_CODE = LOWEST
**** LEVEL TERM CODE, AND PT_CODE = PREFERRED TERM CODE.;
proc sort
	data = low_level_term(keep = low_level_term llt_code pt_code);
	by pt_code;
run;
**** SORT PREFERRED TERM DATA FROM MEDDRA WHERE
**** PREFERRED_TERM = PREFERRED TERM, SOC_CODE = SYSTEM
**** ORGAN CLASS CODE, AND PT_CODE = PREFERRED TERM CODE.;
proc sort
	data = preferred_term(keep = preferred_term pt_code soc_code);
		by pt_code;
run;
**** MERGE LOW LEVEL TERMS WITH PREFERRED TERMS KEEPING ALL LOWER
**** LEVEL TERM RECORDS.;
data llt_pt;
	merge low_level_term (in = inlow) preferred_term;
		by pt_code;
		if inlow;
run;
**** SORT BODY SYSTEM DATA FROM MEDDRA WHERE
**** SYSTEM_CLASS_TERM = SYSTEM ORGAN CLASS TERM AND SOC_CODE =
**** SYSTEM ORGAN CLASS CODE.;
proc sort
	data = soc_term(keep = system_class_term soc_code);
		by soc_code;
run;
**** SORT LOWER LEVEL TERM AND PREFERRED TERMS FOR MERGE WITH
**** SYSTEM ORGAN CLASS DATA.;
proc sort
	data = llt_pt;
		by soc_code;
run;
**** MERGE PREFERRED TERM LEVEL WITH BODY SYSTEMS;
data meddra;
	merge llt_pt (in = in_llt_pt) soc_term;
		by soc_code;
		if in_llt_pt;
run;

*Pulling perferred terms out of WHODrug*;
proc sort
	data = whodrug(keep = seq1 seq2 drug_name drugrecno
			where = (seq1 = ‘01’ and seq2 = ‘001’) )
		nodupkey;
	by drugrecno drug_name;
run;

*using Implicit or Explicit Centuries with dates*;
**** DISPLAY YEARCUTOFF SETTING PIVOT POINT;
proc options option = yearcutoff;
run;
**** DATES DEFINED WITH IMPLICIT CENTURY;
data _null_;
	date = "01JAN19"d;
	put date = date9.;
	date = "01JAN20"d;
	put date = date9.;
run;
**** DATES DEFINED WITH EXPLICIT CENTURY;
data _null_;
	date = "01JAN1919"d;
	put date = date9.;
	date = "01JAN1920"d;
	put date = date9.;
run;

*Redefining a variable with a DATA step*;
**** INPUT SAMPLE ADVERSE EVENT DATA WHERE SUBJECT = PATIENT ID
**** AND ADVERSE_EVENT = ADVERSE EVENT TEXT.;
data aes;
input @1 subject $3.
	@5 adverse_event $15.;
datalines;
101 Headache
102 Rash
102 Fatal MI
102 Abdominal Pain
102 Constipation
;
run;
**** INPUT SAMPLE DEATH DATA WHERE SUBJECT = PATIENT NUMBER AND
**** DEATH = 1 IF PATIENT DIED, 0 IF NOT.;
data death;
input @1 subject $3.
		@5 death 1.;
datalines;
101 0
102 0
;
run;
**** FLAG EVENTS THAT RESULTED IN DEATH;
data aes;
	merge death(rename = (death = _death)) aes;
		by subject;
		**** DROP OLD DEATH VARIABLE.;
		drop _death;
		**** CREATE NEW DEATH VARIABLE.;
		if adverse_event = "Fatal MI" then
			death = 1;
		else
			death = _death;
run;
proc print;
run;
*!!!there is a safe and simple way to avoid the unplanned retention 
 of variables: Do not redefine a pre-existing variable within a DATA step;

*using the ROUND function with Floating-Point comparisons;
**** FLAG LAB VALUE AS LOW OR HIGH;
**** FLAG LAB VALUE AS LOW OR HIGH;
data labs;
	set labs;
		if .z < round(lab_value,.000000001) < 3.15 then
			hi_low_flag = "L";
		else if round(lab_value,.000000001) > 5.5 then
			hi_low_flag = "H";
run;

*creat a blood pressure Change-from -Baseline data set*;
**** INPUT SAMPLE BLOOD PRESSURE VALUES WHERE
**** SUBJECT = PATIENT NUMBER, WEEK = WEEK OF STUDY, AND
**** TEST = SYSTOLIC (SBP) OR DIASTOLIC (DBP) BLOOD PRESSURE.;
data bp;
input subject $ week test $ value;
datalines;
101 0 DBP 160
101 0 SBP 90
101 1 DBP 140
101 1 SBP 87
101 2 DBP 130
101 2 SBP 85
101 3 DBP 120
101 3 SBP 80
202 0 DBP 141
202 0 SBP 75
202 1 DBP 161
202 1 SBP 80
202 2 DBP 171
202 2 SBP 85
202 3 DBP 181
202 3 SBP 90
;
run;
**** SORT DATA BY SUBJECT, TEST NAME, AND WEEK;
proc sort
	data = bp;
		by subject test week;
run;
**** CALCULATE CHANGE FROM BASELINE SBP AND DBP VALUES.;
data bp;
	set bp;
		by subject test week;
		**** CARRY FORWARD BASELINE RESULTS.;
		retain baseline;
		if first.test then
			baseline = .;
		**** DETERMINE BASELINE OR CALCULATE CHANGES.;
		if visit = 0 then
			baseline = value;
		else if visit > 0 then
			do;
				change = value - baseline;
				pct_chg = ((value - baseline) /baseline )*100;
			end;
run;
proc print
	data = bp;
run;

*creating a Time-to-Event data set for seizures*;
**** INPUT SAMPLE SEIZURE DATA WHERE
**** SUBJECT = PATIENT NUMBER, SEIZURE = BOOLEAN FLAG
**** INDICATING A SEIZURE AND SEIZDATE = DATE OF SEIZURE.;
data seizure;
informat seizdate date9.;
format seizdate date9.;
label subject = "Patient Number"
		seizdate = "Date of Seizure"
		seizure = "Seizure: 1=Yes,0=No";
input subject $ seizure seizdate;
datalines;
101 1 05MAY2004
102 0 .
103 . .
104 1 07JUN2004
;
run;
**** INPUT SAMPLE END OF STUDY DATA WHERE
**** SUBJECT = PATIENT NUMBER, EOSDATE = END OF STUDY DATE.;
data eos;
informat eosdate date9.;
format eosdate date9.;
label subject = "Patient Number"
		eosdate = "End of Study Date";
input subject $ eosdate;
datalines;
101 05AUG2004
102 10AUG2004
103 12AUG2004
104 20AUG2004
;
run;
**** INPUT SAMPLE DOSING DATA WHERE
**** SUBJECT = PATIENT NUMBER AND DOSEDATE = DRUG DOSING DATE.;
data dosing;
informat dosedate date9.;
format dosedate date9.;
label subject = "Patient Number"
		dosedate = "Start of Drug Therapy";
input subject $ dosedate;
datalines;
101 01JAN2004
102 03JAN2004
103 06JAN2004
104 09JAN2004
;
run;
**** CREATE TIME TO SEIZURE DATA SET;
data time_to_seizure;
	merge dosing eos seizure;
		by subject;
		if seizure = 1 then
			time_to_seizure = seizdate - dosedate + 1;
		else if seizure = 0 then
			time_to_seizure = eosdate - dosedate + 1;
		else
			time_to_seizure = .;
		label time_to_seizure = "Days to Seizure or Censor Day";
run;
proc print
	label data = time_to_seizure;
run;

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

*page45;

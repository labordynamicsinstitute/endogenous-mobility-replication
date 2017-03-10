*00.01.annearn_ilinwi.sas;
*Author: K. McKinney 20160203;
*** DATASETS ***;
/*
INPUTS:  inputs.pikNN_analysis_dataset
         inputs.pikNN_analysis_implicate1
OUTPUTS: interwrk.annearn_s2013_ilinwi
*/
*** Three state pull from the AKM input files based on the  s2013 snapshot ***;
*** IL IN WI (FIPS code 17 18 55) for years 1990 - 2013                    ***;


*** Options and Libnames ***;
options mprint mlogic symbolgen msglevel=i ls=150 ps=1000 obs=max;

libname inputs "/mixedtmp/co00538/users/zhao0310/akm_data_setup/interwrk";

libname outputs "/temporary/interwork/zhao0310/cg_interwrk";

*** First two digits of PIKs ***;
%LET PIK2digit =
00 01 02 03 04 05 06 07 08 09
10 11 12 13 14 15 16 17 18 19
20 21 22 23 24 25 26 27 28 29
30 31 32 33 34 35 36 37 38 39
40 41 42 43 44 45 46 47 48 49
50 51 52 53 54 55 56 57 58 59
60 61 62 63 64 65 66 67 68 69
70 71 72 73 74 75 76 77 78 79
80 81 82 83 84 85 86 87 88 89
90 91 92 93 94 95 96 97 98 99;

*** Macro to stack pikNN files ***;
%MACRO AKMstack(iset=,oset=);
data &oset. /view=&oset.;
        set
                %LET ii = 1;
                %DO %WHILE ("%SCAN(&PIK2digit.,&ii.)" ~= "");
                        %LET NN = %SCAN(&PIK2digit.,&ii.);
                                inputs.pik&NN._&iset.
                        %LET ii = %EVAL(&ii.+1);
                %END;
        ;
   run;
%MEND AKMstack;

*** Stack earnings variables ***;
%AKMstack(iset=analysis_dataset,oset=dseta);

proc contents data=dseta;
proc print data=dseta(obs=100);
run;

*** Stack characteristics variables - implicate 1 ***;
%AKMstack(iset=analysis_implicate1,oset=dsetb);

proc contents data=dsetb;
proc print data=dsetb(obs=100);
run;

*** Output only IL, IN, WI observations ***;
data outputs.annearn_s2013_ilinwi;
   merge dseta(in=a) dsetb(in=b drop=dominant contribution);
      by pik sein year;

   length _merge 3;

   _merge=a+2*b;

   if state in ("IL","IN","WI") then output;
run;

proc contents;
proc freq;
   tables _merge;
run;
proc print data=outputs.annearn_s2013_ilinwi(obs=100);
run;

%let wrkpath = REDACTED;             /* Should point to text file generated in ../../CG_Code/s02_CG_est_JBES */
%let outpath = REDACTED;             /* Should point to same locations as ../../dataprep/config.sas */
*%let annearn_path = $P?;

libname interwrk "&wrkpath.";
libname outputs  "&outpath.";

options nocenter ls=130 ps=32000;

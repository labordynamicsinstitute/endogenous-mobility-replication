*files in netearn are gzipped and must be unzipped before that directory can be used;
*libname netearn "/PATH/data/schmu005/netearn/current";

*** UPDATED BY NELLIE 20160217 ***;
libname inputs   "$TEMP/interwork/abowd001/networks/inputs" access=readonly;
libname interwrk "$TEMP/interwork/abowd001/networks/interwrk";
libname outputs  "$TEMP/interwork/abowd001/networks/outputs";
libname annearn  "$TEMP/interwork/zhao0310/cg_interwrk" access=readonly;

options nocenter ls=130 ps=32000;

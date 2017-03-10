* 01.02.prep_for_CG.sas;
* I. Schmutte 2016 Feb 11;
* after 01.01.AKM_Universe.sas;

%include "config.sas";
options obs=max;

/*create sequential pik and sein identifiers.*/
proc sort data=interwrk.AKM_Universe_ids(keep=pik) nodupkey out=interwrk.AKM_Universe_piklist;
	by pik;
run;

proc sort data=interwrk.AKM_Universe_ids(keep=sein) nodupkey out=interwrk.AKM_Universe_seinlist;
	by sein;
run;

data interwrk.AKM_Universe_piklist;
	set interwrk.AKM_Universe_piklist;
	pikcount = _n_;
run;

data interwrk.AKM_Universe_seinlist;
	set interwrk.AKM_Universe_seinlist;
	seincount = _n_;
run;

title2 "##### Sequential IDs #####";
proc print data=interwrk.AKM_Universe_piklist(obs=10);
run;
proc print data=interwrk.AKM_Universe_seinlist(obs=10);
run;

title2 "##### PIK and SEIN IDs #####";
proc print data=interwrk.AKM_Universe_ids(obs=25);
run;


/*Replace pik and sein with sequential identifiers.*/
data interwrk.AKM_Universe_ids(keep=pikcount seincount year obsnum);
  if _n_=1 then do;
    if 0 then
    set interwrk.AKM_Universe_piklist
        interwrk.AKM_Universe_seinlist;
    declare hash pikid(dataset: 'interwrk.AKM_Universe_piklist',
               ordered: 'ascending');
    pikid.definekey ("pik");
    pikid.definedata("pikcount");
    pikid.definedone();

    declare hash seinid(dataset: 'interwrk.AKM_Universe_seinlist',
               ordered: 'ascending');
    seinid.definekey ("sein");
    seinid.definedata("seincount");
    seinid.definedone();

  end;
  retain pikcount seincount year obsnum;
  set interwrk.AKM_Universe_ids;
  pikid.find();
  seinid.find();
run;

title2 "##### SEQUENTIAL PIK and SEIN IDs #####";
proc print data=interwrk.AKM_Universe_ids(obs=25);
run;

proc contents data=interwrk.AKM_Universe_ids;
run;


proc export data=interwrk.AKM_Universe_variables
  outfile="/temporary/interwork/abowd001/networks/outputs/AKM_Universe_variables.csv"
  dbms=csv
  replace;
run;

proc export data=interwrk.AKM_Universe_ids
  outfile="/temporary/interwork/abowd001/networks/outputs/AKM_Universe_ids.csv"
  dbms=csv
  replace;
run;
%Ian M. Schmutte
%LatentClassProbs.m
%plot wage parameters

clear all;
addpath ./v20160324-output;

load wageParms_Out;
start = 1; last = 10;
varMean = wageParms_Out(1,start:last);
varMCSE = wageParms_Out(2,start:last);
var95 = wageParms_Out(97,start:last);
var5 = wageParms_Out(7,start:last);
figure(1);
hold on;
axis manual;
axis([1 10 -3.5 2])
subplot(3,2,1)
 plot(1:10,varMean,'-xr',1:10,var5,':b',1:10,var95,':b','LineWidth',2,'MarkerSize',10)
 title('\theta with 5th and 95th percentile','FontSize',16);
 axis manual;
 axis([1 10 -3.5 2])
 set(gca,'XTick',1:10,'YTick',-3:2)	
 %axis tight;
subplot(3,2,2)
 plot(1:10,varMean,'-xr',1:10,varMean-2*varMCSE,':b',1:10,varMean+2*varMCSE,':b','LineWidth',2,'MarkerSize',10)
 title('\theta +/- 2*MCSE','FontSize',16);
 %axis tight;
axis manual;
axis([1 10 -3.5 2])
 set(gca,'XTick',1:10,'YTick',-3:2)	

start = 11; last = 20;
varMean = wageParms_Out(1,start:last);
varMCSE = wageParms_Out(2,start:last);
var95 = wageParms_Out(97,start:last);
var5 = wageParms_Out(7,start:last);
subplot(3,2,3)
 plot(1:10,varMean,'-xr',1:10,var5,':b',1:10,var95,':b','LineWidth',2,'MarkerSize',10)
 title('\psi with 5th and 95th percentile','FontSize',16);
 %axis tight;
 axis manual;
axis([1 10 -3.5 2])
 set(gca,'XTick',1:10,'YTick',-3:2)	
subplot(3,2,4)
 plot(1:10,varMean,'-xr',1:10,varMean-2*varMCSE,':b',1:10,varMean+2*varMCSE,':b','LineWidth',2,'MarkerSize',10)
  title('\psi +/- 2*MCSE','FontSize',16);
  %axis tight;
 axis manual;
axis([1 10 -3.5 2])
 set(gca,'XTick',1:10,'YTick',-3:2)	

start = 21; last = 30;
varMean = wageParms_Out(1,start:last);
varMCSE = wageParms_Out(2,start:last);
var95 = wageParms_Out(97,start:last);
var5 = wageParms_Out(7,start:last);
subplot(3,2,5)
 plot(1:10,varMean,'-xr',1:10,var5,':b',1:10,var95,':b','LineWidth',2,'MarkerSize',10)
 title('\mu with 5th and 95th percentile','FontSize',16);
 %axis tight;
 axis manual;
axis([1 10 -3.5 2])
 set(gca,'XTick',1:10,'YTick',-3:2)	

subplot(3,2,6)
 plot(1:10,varMean,'-xr',1:10,varMean-2*varMCSE,':b',1:10,varMean+2*varMCSE,':b','LineWidth',2,'MarkerSize',10)
  title('\mu +/- 2*MCSE','FontSize',16);
  %axis tight;
  axis manual;
axis([1 10 -3.5 2])
 set(gca,'XTick',1:10,'YTick',-3:2)	
hold off;
print('-f1','-djpeg','WageParmsPlots');
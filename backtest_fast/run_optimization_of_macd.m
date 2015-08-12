%% Fast optimization of macd parameters
% cambia i parametri in input qui sotto o fallo girare csi com'�

% close all
% clear all
% 

%annualScaling = sqrt(250);
%annualScaling = sqrt(360000);

%out=importdata('table.csv',',',1);
%adjCl=out.data(:,6);

%input parameters:

%hisData=load('EURUSD_2012_2015.csv');
hisData=load('EURUSD_smallsample2014_2015.csv');
cross = 'EURUSD';
actTimeScale = 1;
newTimeScale = 30;
cost = 1; % spread



[r,c] = size(hisData);


% includi colonna delle date se non esiste nel file di input
if c == 5
    
    hisData(1,6) = datenum('01/01/2015 00:00', 'mm/dd/yyyy HH:MM');
    
    for j = 2:r;
        hisData(j,6) = hisData(1,6) + ( (actTimeScale/1440)*(j-1) );
    end
    
end

% dividi lo storico in test per ottimizzare l'algo e paper trading
% (75% dello storico � Test, l'ultimo 25% paper trading)
rTest = floor(r*0.75);
hisDataTest = hisData(1:rTest,:);
hisDataPaperTrad = hisData(rTest+1:end,:);


% riscala temporalmente se richiesto
if newTimeScale > 1
    
    expert = TimeSeriesExpert_11;
    expert.rescaleData(hisDataTest,actTimeScale,newTimeScale);
    
    closeXminsTest = expert.closeVrescaled;
    dateXminsTest = expert.openDrescaled;
    
    expert.rescaleData(hisDataPaperTrad,actTimeScale,newTimeScale);
    
    closeXminsPaperTrad = expert.closeVrescaled;
    dateXminsPaperTrad = expert.openDrescaled;
    
    
end


%% prova semplice

% bktfast=bkt_fast_macd;
% bktfast=bktfast.fast_macd(hisDataTest(:,4),closeXminsTest,dateXminsTest,newTimeScale,cost,20,10,1);

%% Estimate parameters over a range of values
% Puoi cambiare i TP e SL consigliati

matrixsize = 50;
R_over_maxDD = nan(matrixsize,matrixsize);


tic
for n = 5:40
    
    display(['n =', num2str(n)]);
    
    for m = 5:40
        
%         display(['n =', num2str(n),' m = ',  num2str(m)]);
        
        bktfast=bkt_fast_macd;
        bktfast=bktfast.fast_macd(hisDataTest(:,4),closeXminsTest,dateXminsTest,newTimeScale,cost,n,m,0);
        
        p = Performance_05;
        performance = p.calcSinglePerformance('macd','bktWeb',cross,newTimeScale,cost,10000,10,bktfast.outputbkt,0);
        
        R_over_maxDD(n,m) = performance.pipsEarned / abs(performance.maxDD);
        
    end
end
toc

%visualizza i risultati come surface plot
sweepPlot_BKT_Fast(R_over_maxDD)



%% Plot best performance from Test
% occhio che ind2sub deve prender come primo parametro la lunghezza della
% matrice dei risultati, e che lavora solo su matrici quadrate

 [~, bestInd] = max(R_over_maxDD(:)); % (Linear) location of max value
 [bestN, bestM] = ind2sub(matrixsize, bestInd); % Lead and lag at best value
 
 display(['bestN =', num2str(bestN),' bestM =', num2str(bestM)]);

bktfastTest=bkt_fast_macd;
bktfastTest=bktfastTest.fast_macd(hisDataTest(:,4),closeXminsTest,dateXminsTest,newTimeScale,cost,bestN,bestM,1);

p = Performance_05;
performanceTest = p.calcSinglePerformance('macd','bktWeb',cross,newTimeScale,cost,10000,10,bktfastTest.outputbkt,0);

risultato = performanceTest.pipsEarned / abs(performanceTest.maxDD);

figure
plot(cumsum(bktfastTest.outputbkt(:,4)))
title(['Test Best Result, Final R over maxDD = ',num2str( risultato) ])

%% now the final check using the Paper Trading

bktfastPaperTrading=bkt_fast_macd;
bktfastPaperTrading=bktfastPaperTrading.fast_macd(hisDataPaperTrad(:,4),closeXminsPaperTrad,dateXminsPaperTrad,newTimeScale,cost,bestN,bestM,0);

p = Performance_05;
performancePaperTrad = p.calcSinglePerformance('macd','bktWeb',cross,newTimeScale,cost,10000,10,bktfastPaperTrading.outputbkt,0);
risultato = performancePaperTrad.pipsEarned / abs(performancePaperTrad.maxDD);

figure
plot(cumsum(bktfastPaperTrading.outputbkt(:,4)))
title(['Paper Trading Result, Final R over maxDD = ',num2str( risultato) ])

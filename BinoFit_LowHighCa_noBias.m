function [ output_args ] = BinoFit_LowHighCa_noBias(mydata, experiment)
%Binomial fit to GluSnFR data from single synapse
% n = number of readily releasable vesicles
% p = (vesicular) probability of release
% q = df/f caused by one vesicle

paraN=[1:1:15];
paraP=[0.01:0.01:1];%[0.1:0.02:1]; % 0.1-0.7, typical 0.5 in 2 Ca2+
paraQ=[0.4:0.01:1.7];  % 0.2-0.9 before compression, typical 0.6
paraQ=unCompress(paraQ);

errorCube=zeros(length(paraN),length(paraP),length(paraQ));
errorPlaneLow=zeros(length(paraP),length(paraQ));
errorCubeHigh=errorCube;

xout=[-1:0.01:4]; % fine steps for plotting of curves
binSize=1/6;
xHist=[-1:binSize:4]; %specify centers of bins


if isempty(mydata)
    return
else  %mydata is organized with 4 coumns per experiment
    
    myStim=mydata(:,experiment*4-3); %responses in low Ca2+
    [r,c,myStim]=find(myStim); %remove zeros
    
    myStimHigh=mydata(:,experiment*4-1); %responses in high Ca2+
    [r,c,myStimHigh]=find(myStimHigh); %remove zeros
    
    myNoise=mydata(:,experiment*4-2); %noise in low Ca2+
    [r,c,myNoise]=find(myNoise); %remove zeros
    sigma1=std(myNoise);
    
    myNoiseHigh=mydata(:,experiment*4); %noise in high Ca2+
    [r,c,myNoiseHigh]=find(myNoiseHigh); %remove zeros
    sigma2=std(myNoiseHigh);
    
    sigma=(sigma1 + sigma2)/2;
    photonsAtBaseline=2/sigma^2
    totalTrials=length(myStim)+length(myStimHigh)
end

h = waitbar(0,'processing data','Name','creating binomial predictions...');


% plot the data (histogram)
figure('Color',[1 1 1],'InvertHardcopy','off','position', [0, 0, 1000, 500]);
subplot(2,3,1);
cla;
% nHist=hist(myStim,xHist,'FaceColor','c','EdgeColor','none');
% bar(xHist,nHist,'c','EdgeColor','none');
%
% subplot(2,3,2);
allNoise=[myNoise' myNoiseHigh'];
noiseHist=hist(allNoise,xHist);
bar(xHist,noiseHist,'g','EdgeColor','none');
hold on;
noiseFit=normpdf(xout,0,sigma);
scaledNoiseFit=noiseFit.*(mean(noiseHist)/mean(noiseFit));
plot(xout,scaledNoiseFit,'black','LineWidth',2);
hold off;
set(gca,'XLim',[-1 4]);
set(gca, 'Layer','top');
title('no stim');
ylabel('# events');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1) low Ca fit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

xHist=[-1:binSize:5];
nHistLow=hist(myStim,xHist);
totalLow=sum(nHistLow);
for n=1  % since synaptic release probability is very low, we assume univesicular release
         % goal of this first pass analyis is to find a good value for q
    for p=1:length(paraP)
        for q=1:length(paraQ)
            % calculate probabilies
            events = binomialProcess(n, paraP(p));
            failures=1-sum(events);
            allEvents=[failures events];
            
            % calculate error for the histogram bin positions(xHist)
            bells=MultiGauss2(sigma,allEvents,xHist,0,paraQ(q),n);
            prediction=sum(bells,2);
            scaledPrediction=prediction.*(sum(nHistLow)/sum(prediction));
            error=((scaledPrediction-nHistLow').^2);
            %error(15:end,1)=error(15:end,1).*10; %try to put more importance to the larger signals
            errorPlaneLow(p,q)=sqrt(sum(error));       %RMS error
        end
    end
end

bestSet=min(min(errorPlaneLow));
[pPos,qPos] = ind2sub(size(errorPlaneLow),find(errorPlaneLow == bestSet));

% we throw away information about p, since we assume univesicular release
errorPlaneLow=repmat(errorPlaneLow(pPos,:),[size(errorPlaneLow,1),1]);

% figure(34)
% surf(errorPlaneLow)

% make a cube for later...
errorCubeLow=repmat(errorPlaneLow,[1,1,numel(paraN)]); 
errorCubeLow = permute(errorCubeLow,[3 1 2]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% now try fitting the high Ca data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% plot the data (histogram)
subplot(2,3,3);
cla;
nHist=hist(myStimHigh,xHist,'FaceColor','c','EdgeColor','none');
bar(xHist,nHist,'r','EdgeColor','none');
hold on;
nHist=hist(myStimHigh,xHist);

for n=1:length(paraN)
    for p=1:length(paraP)
        for q=1:length(paraQ)
            % calculate probabilies
            events = binomialProcess(paraN(n), paraP(p));
            failures=1-sum(events);
            %synPr=round((1-failures)*100)/100;
            allEvents=[failures events];
            
            % calculate error for the histogram bin positions(xHist)
            bells=MultiGauss2(sigma,allEvents,xHist,0,paraQ(q),paraN(n));
            prediction=sum(bells,2);
            scaledPrediction=prediction.*(sum(nHist)/sum(prediction));
            error=((scaledPrediction-nHist').^2);
            %error(1:20,1)= error(1:20,1).*10;
            errorCubeHigh(n,p,q)=sqrt(sum(error));       %RMS error
        end
    end
    waitbar(n / length(paraN),h,sprintf('Number of vesicles: %d',n))
end

errorCube=sqrt((errorCubeLow.^2) + errorCubeHigh.^2);

% find smallest error
bestSet=min(min(min(errorCube)));
[nPos,pPos,qPos] = ind2sub(size(errorCube),find(errorCube == bestSet));
bestN=paraN(nPos);
bestP=paraP(pPos);
bestQ=paraQ(qPos);

subplot(2,3,4)
errPlane=squeeze(errorCube(:,:,qPos));
errPlane=log(errPlane);
imagesc(errPlane);
ylabel('number of vesicles');
xlabel('ves. release probability [%]');
title('error function');
hold on;
plot(bestP*100,bestN,'y*');
hold off;
%colorbar

%uncomment to print out the minimum error for all tested vesicle numbers
% errorValley=min(errPlane,[],2) 

% regenerate curve for visual comparison
events = binomialProcess(bestN, bestP);
failures=1-sum(events);
allEvents=[failures events];
bells=MultiGauss2(sigma,allEvents,xout,0,bestQ,bestN);
smoothPrediction=sum(bells,2); % smooth curve

% to get the correct scaling factor, produce simulated
% histogram
bells2=MultiGauss2(sigma,allEvents,xHist,0,bestQ,bestN);
prediction=sum(bells2,2);
scaledPrediction=smoothPrediction.*(sum(nHist)/sum(prediction));   %For ploting fitting curve on
%top of histogram smoothPrediction gets rescaled

disp('    n      p_ves     q       error');
displayQ=compress(bestQ);
bestFit=[bestN,bestP,displayQ,bestSet];
disp(bestFit);

% subplot(2,3,1);
% cla;
% ves=[0:1:length(allEvents)-1];
% bar(ves,allEvents,0.3)
% title('binomial probabilities')


subplot(2,3,3);
% hold on;
% plot(xout,scaledPrediction,'Color','black','LineWidth',2);
% hold off;
set(gca,'XLim',[-1 4]);
set(gca, 'Layer','top');
title('high Ca2+')
ylabel('# events');


%% CD Plotting the compressed bells
subplot(2,3,6);
cla;
hold on;
scaleF=max(noiseHist)/max(bells(:,1));
bells=bells*scaleF;
for p=1:size(bells,2)
    plot(xout,bells(:,p),'black','LineWidth',1);
end
plot(xout,sum(bells,2),'red','LineWidth',2);
txt=strcat('q = ',num2str(displayQ),'  n = ',num2str(bestN),'  p = ',num2str(bestP));
title(txt);
set(gca,'XLim',[-1 4]);
set(gca, 'Layer','top');
set(gca,'YTick',[]);


% h2=figure(778);
% nHist=hist(myStim,xHist,'FaceColor','c','EdgeColor','none');
% bar(xHist,nHist,'c','EdgeColor','none');
% hold on
% plot(xout,scaledPrediction,'Color','red','LineWidth',2);
% nHist=hist(myStimHigh,xHist,'FaceColor','c','EdgeColor','none');
% bar(xHist,nHist,'r','EdgeColor','none');
% set(gca,'XLim',[-0.5 4],'Layer','Top');
% ylabel('# events');

%now that we have n and q, we need to look again at the
%lowCa data to get P_low

nHistLow=hist(myStim,xHist);
errorVector=zeros(length(paraP),1);
for p=1:length(paraP)
    % calculate probabilies
    events = binomialProcess(bestN, paraP(p));
    failures=1-sum(events);
    synPr=round((1-failures)*100)/100;
    allEvents=[failures events];
    
    % calculate error for the histogram bin positions(xHist)
    bells=MultiGauss2(sigma,allEvents,xHist,0,bestQ,bestN);
    prediction=sum(bells,2);
    scaledPrediction=prediction.*(sum(nHistLow)/sum(prediction));
    error=((scaledPrediction-nHistLow').^2);
    errorVector(p,1)=sqrt(sum(error));       %RMS error
end

bestVal=min(errorVector);
[pPos] = ind2sub(size(errorVector),find(errorVector == bestVal));
bestP_low=paraP(pPos)

%need smooth curve for low Ca, too
events = binomialProcess(bestN, bestP_low);
failures=1-sum(events);
allEvents=[failures events];
bells=MultiGauss2(sigma,allEvents,xout,0,bestQ,bestN);
smoothPredictionLow=sum(bells,2); % smooth curve

% to get the correct scaling factor, produce simulated histogram
bells2=MultiGauss2(sigma,allEvents,xHist,0,bestQ,bestN);
prediction=sum(bells2,2);
scaledPredictionLow=smoothPredictionLow.*(sum(nHistLow)/sum(prediction));

%% CD Plotting the compressed bells
subplot(2,3,5);
cla;
hold on;
% scaleF=max(noiseHist)/max(bells(:,1));
% bells=bells*scaleF;
for p=1:size(bells,2)
    plot(xout,bells(:,p),'black','LineWidth',1);
end
plot(xout,sum(bells,2),'cyan','LineWidth',2);
txt=strcat('q = ',num2str(displayQ),'  n = ',num2str(bestN),'  p = ',num2str(bestP_low));
title(txt);
set(gca,'XLim',[-1 4]);
set(gca, 'Layer','top');
set(gca,'YTick',[]);
hold off;

subplot(2,3,2);
cla;
nHist=hist(myStim,xHist,'FaceColor','c','EdgeColor','none');
bar(xHist,nHist,'c','EdgeColor','none');
%plot(xout,scaledPredictionLow,'Color','black','LineWidth',2)
set(gca,'XLim',[-1 4]);
set(gca, 'Layer','top');
ylabel('# events');
title('low Ca2+')

delete(h)       % DELETE the waitbar
end


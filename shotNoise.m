function shotNoise(phot)
%UNTITLED2 wrote this to understand how shot noise affects df/f
%   phot=number of photons collected at baseline
%   for simplicity, I assume one vesicle causes doubling of fluorescence (q=100%)
%   no indicator saturation, no variability in vesicle content
% TGO 2018

vesicles=8;
trials=1000;
baseline=ones(trials,1);
dat=ones(trials,vesicles);
dff=ones(trials,vesicles);


ab=baseline*phot + (baseline.*randn(size(baseline))*sqrt(phot)); %baseline fluorscence + shot noise
baselineCV=std(ab)/mean(ab)
measuredNoise=zeros(vesicles,1);
calcNoise=zeros(vesicles,1);
for i=1:vesicles
    dat(:,i)=dat(:,i).*(phot*i) + (dat(:,i).*randn(trials,1).*sqrt(phot*i));
    dff(:,i)= (dat(:,i)-ab)./ab;
    measuredNoise(i,1)=std(dff(:,i));
    
    %************** here comes the key formula *********************
    %****** df/f = (f/f0)-1 ********** error from division**********
    calcNoise(i,1)=abs(mean(dff(:,i))+1).*sqrt((std(ab)/mean(ab))^2 + (std(dat(:,i))/mean(dat(:,i)))^2);
    %********** heureka! *******************************************
end

%estimatedPhotonsFromRaw=(std(dat(:,1)))^2
%estimatedPhotonsFromDFF=2/(std(dff(:,1)))^2

x=[0:1:vesicles-1];
figure(6);
subplot(2,2,3);
plot(calcNoise,measuredNoise);
hold on;
xlabel('predicted std from error propagation');
ylabel('measured std of df/f');

subplot(2,2,4);
plot(x,calcNoise,'*r');
hold on;
xlabel('vesicles');
ylabel('stdev(responses)');

vesCV=std(dff(:,1))/mean(dff(:,1))

subplot(2,2,1);
x=-1:0.1:14.5;
hist(dff,x);

subplot(2,2,2);
allEvents=reshape(dff,[],1);
hist(allEvents,x);

end


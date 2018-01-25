function generateFakeData(n, p, q, trials, photons)

%this function calls BoutonSim to generate a full dataset (high Ca, low Ca,
%and noise) to be analyzed by BinoFit_LowHighCa

%the purpose is to evalulate how many trials are necessary for reliable
%parameter extraction

%example: generateFakeData(4,0.7,0.9,100)

global myFakeData

if n<1 || n>20 || ~(n==round(n))
    disp('number of vesicles is not plausible');
    return
end

if p<0 || p>1
    disp('vesicular release probability has to be between 0 and 1');
    return
end

if p<0 || p>1
    disp('quantal response between 0.1 and 2.0 df/f');
    return
end

myFakeData=zeros(4,trials);

myFakeData(2,:)=BoutonSim(n,0,q,trials,photons);   %noise
myFakeData(1,:)=BoutonSim(n,p/6,q,trials,photons);  %low Ca
myFakeData(4,:)=BoutonSim(n,0,q,trials,photons);  %noise
myFakeData(3,:)=BoutonSim(n,p,q,trials,photons);  %high Ca

myFakeData=myFakeData';

end


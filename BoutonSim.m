function fakeData=BoutonSim(n,p,q, trials,phot)
%UNTITLED Simulate glutamate release from a single bouton
%   Detailed explanation goes here
% TGO 2018

global myFakeData glusim

if nargin==4
    output=0;
    phot=150; % number of photons collected at baseline
else
    output=1;
end

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

q=unCompress(q);

baseline=zeros(trials,1); % initialize array
release=rand(trials,n); % initialize second array for all vesicles
release=release<p;
response=sum(release'*q); %scale in df/f
response=compress(response); % these are the responses without any noise 

% add photon shot noise

% sigma is an array with the expected std for each df/f0 value
% we sum the relative errors of f and f0 (root of sum of squares) 
% for example: for df/f0=0, the stdev of f is sqrt(photons),
%                           the stdev of f0 is also sqrt(photons)
% scale them, square them, add them, take the root, scale by response+1
%
% try the function 'shotNoise' to convince yourself that this is correct

sigma=(response+1).*sqrt((sqrt(phot*(response+1))./(phot*(response+1))).^2   +  (sqrt(phot)/phot)^2);

responseNoise= response + (randn(1,trials).*sigma);  %add Gaussian noise with the right sigma 

if isfield(glusim,'trials')
    ha=guidata(gcf);
    axes(ha.axes1);
    plot(responseNoise,'*r');
    axes(ha.axes2);
    hist(responseNoise,25);
    set(gca,'XLim',[-1 4]);
end

if output
    fakeData=responseNoise';
else
    fakeData='output is off';
end

end


function bells = MultiGauss2(sigma,events,x,plotting,q,n)
plotting=1;
% MultiGauss 
%  - generates gaussian curves with amplitudes specified in 'events'
%  - location of centers is specified by 'q', the quantal amplitude
%  - width of 'failure' distribution is specified as 'sigma'
%  - output are the individual bell curves (resolution specified in 'x')

bells=zeros(length(x),n);
pos=[0:1:n].*q;  %these are the centers of the Gaussians in df/f scaling
pos=compress(pos);   %take into account GluSNR saturation
phot=2/sigma^2; %calculate photons from df/f data (no stim.) 

%allSigma=(pos+1).*sqrt((sqrt(phot*(pos+1))./(phot*(pos+1))).^2   +  (sqrt(phot)/phot)^2);

% we perform two independent measurements, f0 and f
% df/f0 can be rewritten as (f/f0)-1
% For quotients, the fractional uncertainties add in quadrature. 
% In practice, it is usually simplest to convert all of the uncertainties into percentages before applying the formula
% We calculate the %errors based on the photon counts for f and f0, then
% convert the RMS error into df/f space by multiplying with the (mean df/f +1) =
% center of the gaussians +1 = pos+1


allSigma=sqrt( (sqrt(phot*(pos+1))./(phot*(pos+1))).^2 +   sigma^2 );
allSigma=allSigma.*(pos+1);

% CD20200623 to know the number of Multivesicular events in 1 mM Ca2+ sum (events(i>3) i=1 is a failres, i=2 is a UVR event
% Or AllEvents- (events(1)+ events(2)). This can be measured when we fix
% the values of the best prediction.
for i=1:n+1 %first index is failures, second one vesicle, etc.
    bells(:,i) = events(i) * normpdf(x,pos(i),allSigma(i));  %takes care of amplitude, too!
end

% if plotting 
%     figure(666);
%     title('expected probabilities');
%     xlabel('delta f / f');
%     cla;
%     hold on;
%     for i=0:n
%         plot(x,bells(:,i+1),'b');
%     end
%     hold off;
% end

end


function bells = MultiGauss2(sigma,events,x,plotting,q,n)

% MultiGauss 
%  - generates gaussian curves with amplitudes specified in 'events'
%  - location of centers is specified by 'q', the quantal amplitude
%  - width of 'failure' distribution is specified as 'sigma'
%  - output are the individual bell curves (resolution specified in 'x')

bells=zeros(length(x),n);
pos=[0:1:n].*q;  %these are the centers of the Gaussians in df/f scaling
pos=compress(pos);   %take into account GluSNR saturation
phot=2/sigma^2; %calculate photons from df/f data (no stim.) 

allSigma=(pos+1).*sqrt((sqrt(phot*(pos+1))./(phot*(pos+1))).^2   +  (sqrt(phot)/phot)^2);

for i=1:n+1 %first index is failures, second one vesicle, etc.
    bells(:,i) = events(i) * normpdf(x,pos(i),allSigma(i));  %takes care of amplitude, too!
end

if plotting
    figure(666);
    title('expected probabilities');
    xlabel('delta f / f');
    cla;
    hold on;
    for i=0:n
        plot(x,bells(:,i+1),'b');
    end
    hold off;
end

end


function compX = compress(x)

%   use Langmuir equation to simulate GluSnFR saturation (hyperbolic
%   binding curve)(mass action kinetic)

maxChange=4.4; % GluSnFr saturates at 440% df/f
Kd=maxChange/2;

x=x./2;
fractionOccupied=x./(x+Kd);%Langmuir isotherm hyperbolic equation
compX=fractionOccupied.*maxChange; % 100% 0ccupancy (=1) equals maxChange

end


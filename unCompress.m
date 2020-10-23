function strechtedX = unCompress(x)

%   use Langmuir equation to simulate GluSnFR saturation (hyperbolic binding curve)

maxChange=4.4; % GluSnFr saturates at 540% df/f
if max(x)>maxChange
    disp('Warning:unCompress will not work, input exceeds paramter space!')
end

Kd=maxChange/2;

x=x./maxChange;%normalization
strechtedX=(x.*Kd*-2)./(x-1); %

end


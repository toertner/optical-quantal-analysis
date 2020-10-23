function [ events ] = binomialProcess( n, p )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

events=zeros(1,n);

for i=1:n   % calculate the probability of i vesicles released simultaneously
    
    bc= factorial(n)/(factorial(i)*factorial(n-i)); %binomial coefficient
    pi = bc*(p^i)*((1-p)^(n-i)); %probability of i vesicles released
    
    events(i)=pi;
end

end


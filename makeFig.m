function [ output_args ] = makeFig( input_args )
%UNTITLED 21.1.2018
%   Detailed explanation goes here

n=[6 3 2 4 4 2 3 3];
nx=[1,1,0.9,0.9,1.1,1.1,0.8,1.2];
p1=[0.51 0.92 0.63 0.72 0.89 0.9 0.76 0.85];
q=[0.84 1.25 0.6 0.94 0.6 1.33 1.17 0.97];
p2=[0.07 0.14 0.14 0.16 0.04 0.19 0.1 0.23];
phot=[267 233 488 173 88 260 246 235];
trials=[180 166 180 180 238 105 160 262];

figure(66);
subplot(1,3,1);
hist(n,[1,2,3,4,5,6,7,8]);
xlabel('readily releasble vesicles');

subplot(1,3,2);
hist(p2,[0.1,0.2,0.3,0.4]);
h = findobj(gca,'Type','patch');
set(h,'FaceColor','r')
hold on;
hist(p1,[0.5,0.6,0.7,0.8,0.9]);
hold off;
xlabel('ves. release prob.');

subplot(1,3,3);
hist(q,[0.5, 0.75,1,1.25,1.5]);
xlim([0 2]);
xlabel('quantal amp. [df/f]');


figure(67);
subplot(1,3,1);
plot(nx,n,'k*');
hold on;
plot(1,mean(n),'rd','MarkerFaceColor','r');
ylim([0 8]);
xlim([0 2]);
set(gca,'XTickLabel',[]);
ylabel('number of vesicles');

subplot(1,3,2);
hold on;
x=[1,2];
p=[p2;p1];
for i=1:8
    plot(x,p(:,i),'k-o');
end
plot(0.9,mean(p2),'rd','MarkerFaceColor','r');
plot(2.1,mean(p1),'rd','MarkerFaceColor','r');
hold off;
xlim([0.5 2.5]);
set(gca,'XTickLabel',[]);
ylabel('ves. release probability');

subplot(1,3,3);
plot(q,'k*');
hold on;
plot(1,mean(q),'rd','MarkerFaceColor','r');
ylim([0 2]);
xlim([-10 20]);
set(gca,'XTickLabel',[]);
ylabel('quantal response [df/f]');
end
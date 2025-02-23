clear
clc
close all

m=3;
n=4;

% plots the nodes
hold on 
for i=1:m
    for j=1:n
    plot(j,i,'b.')
    axis equal
    ylim([0 m+1])
    xlim([0 n+1])
    end
end 

% plots the anchors
% Anchor at 1,1
plot([1 .7],[1 1.2],'k-')
plot([1 .7],[1 .8],'k-')
plot([.7 .7],[.8 1.2],'k-')

% Anchor at 1,3
plot([1 .7],[3 3.2],'k-')
plot([1 .7],[3 2.8],'k-')
plot([.7 .7],[2.8 3.2],'k-')

% plots the applied force vector
quiver(n,round(m/2),0,-.9,'r')
hold off


% Finds the total number of possible trusses
poss_truss=nchoosek(n*m,2);


area=1;

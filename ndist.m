function [dij,thetaij]=ndist(X1,Y1,X2,Y2)
dij=sqrt((X2-X1)^2+(Y2-Y1)^2);  %dist between the two nodes
thetaij=atan2((Y2-Y1),(X2-X1));  %the angle between the two nodes


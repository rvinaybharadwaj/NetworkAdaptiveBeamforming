function sd=sdist(X,Y,thet)
%returns distance a plane wave travels from antenna at X,Y until it
%encounters the origin.
%"thet" is arrival angle measured clockwise off of vertical axis.  
%If thet is row vector, then sd is a row vector of distances.
r=sqrt(X^2+Y^2);  %dist from X,Y to origin
beta=atan2(Y,X);  %angle between radius to X,Y and the x axis
alpha=beta+thet;  %angle between radius and planewave going thru origin
sd=r*sin(alpha);  %sd will be negative if wave front hits origin before hitting sensor
% sd=X*cos(thet)+Y*sin(thet);

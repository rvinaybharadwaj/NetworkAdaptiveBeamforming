function v=tryvalg2_Real(w)
% Version June 2012. 
% Gives performance of unconstrained case Real Part

%global statement should match that in other functions for this application
global A DESIRED WaveNumber LookAngles CheckAngle  OptType PerfType

response=w*A;

if strcmp(PerfType,'MSE')
    v=abs((DESIRED-response)*(DESIRED-response)'); %sum of squared errors
elseif strcmp(PerfType,'NSR') || strcmp(PerfType,'MinMax')
    sigpow=sum(abs(response(DESIRED>0)).^2);
    noisepow=sum(abs(response(DESIRED==0)).^2);
    v= noisepow/sigpow;
else
    error('Bad PerfType value. tryvalg.m')
end

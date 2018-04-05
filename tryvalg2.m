function v=tryvalg2(phi)
% Version June 2012. 
% Gives performance of constrained (phase only) case
% Used with fitness.m when using fminsearch
%     outputs either noise-to-signal power ratio or sum of squared errors
%     depending on PerfType

%phi(k) is the phase of the phase shifter for k-th sensor.

%global statement should match that in other functions for this application
global A DESIRED WaveNumber LookAngles CheckAngle  OptType PerfType

wH=exp(j*phi);
response=wH*A;

if strcmp(PerfType,'MSE')
    v=(DESIRED-response)*(DESIRED-response)'; %sum of squared errors
elseif strcmp(PerfType,'NSR')
    sigpow=sum(abs(response(DESIRED>0)).^2);
    noisepow=sum(abs(response(DESIRED==0)).^2);
    v= noisepow/sigpow;
elseif strcmp(PerfType,'MinMax')
    sigpow=sum(abs(response(DESIRED>0)).^2);
    noisepow=sum(abs(response(DESIRED==0)).^2);
    v=noisepow/sigpow;
elseif strcmp(PerfType,'SD')  
    v=sqrt(((DESIRED-response)*(DESIRED-response)')/(length(DESIRED)-1)); 
else
    error('Bad PerfType value. tryvalg.m')
end

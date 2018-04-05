function [SQE, NSR]=evaluate(arryshort)

arry=[0,0,arryshort];
%'global' statement should match the one in tryvalg and any other program that calls this.
global A DESIRED WaveNumber LookAngles CheckAngle  OptType PerfType

%OptType='CON' gives phase only
%OptType='UNCON' gives unconstrained LS
%Not used in this routine:  PerfType='MSE'  minimizes squared error
%                           PerfType='NSR'  minimizes noise to signal ratio
%DESIRED array has desired gains. Corresponds to angles in DTHET.

Nsens=length(arry)/2; % This gives the number of sensors, as we specify the cartesian coordinates (x,y), its length divided by 2 is the number of sensors
NLookAngles=length(LookAngles);%Number of look angles
Nmeas = length(DESIRED);  %Number of angles with specified desired gains
SQE=zeros(NLookAngles,1); %holds errors for one array
NSR=zeros(NLookAngles,1); %holds nsr for one array
guess=zeros(1,Nsens);
MaxFunEvals=40000;
MaxIter=10000;
options=optimset('MaxFunEvals',MaxFunEvals,'MaxIter',MaxIter);


%Now create beam for each angle in LookAngles and compute performance.
for kthet=1:NLookAngles
    look=LookAngles(kthet); %this angle corresponds to middle gain in DESIRED
    DTHET=CheckAngle+look; %DTHET array ranges from look-pi to look+pi, with look as center angle
    %DTHET angles correspond to desired gains in DESIRED for this look angle
    s=zeros(Nsens,Nmeas); %each column represents element delays for each DTHET angle
    for ksens=0:Nsens-1  %Compute distance from origin to each sensor
        ix=ksens*2+1;    %arry ordered in x-y pairs
        s(ksens+1,:)=sdist(arry(ix),arry(ix+1),DTHET);
    end
    A=exp(1i*s*WaveNumber); %each column of A corresponds to steering vector for angle CheckAngle+look.
    if strcmp(OptType,'CON')
        [phi,fval,exitflag,output] = fminsearch(@tryvalg2,guess,options);
        phi=phi.';
        w=exp(1i*phi).';    %constrained weights, converted to row vector
    elseif strcmp(OptType,'UNCON')
        if strcmp(PerfType,'MSE')
            w = DESIRED/A;     %unconstrained LS weights
        elseif strcmp(PerfType,'SD') 
            w = DESIRED/A;
        elseif strcmp(PerfType,'NSR')
            W_snr_re=fminsearch(@tryvalg2_Real,guess,options);
            %unconstrained snr optimization real part
            W_snr_im=fminsearch(@tryvalg2_Imag,guess,options);
            %unconstrained snr optimization imaginary part
            w=W_snr_re+1i*W_snr_im;
        end
    
    else
        error('Bad OptType value')
    end

    response=w*A;  %actual array responses from look-pi to look+pi
    
%     if strcmp(OptType,'UNCON')
%         Allplotrslt(A,w,DESIRED,DTHET);
%     end
    SQE(kthet)=abs((DESIRED-response)*(DESIRED-response)')/Nmeas; %mean of squared errors for this look angle
    sigpow=sum(abs(response(DESIRED>0)).^2);
    noisepow=sum(abs(response(DESIRED==0)).^2);
    NSR(kthet)= noisepow/sigpow;
end


function response=plotresponse(arryshort)
%modified from evaluate.m to plot array responses
%in this version, arryshort has multiple geometries, one per row
%This will plot all responses on same plot
%legnd has legend strings

[narry,ns]=size(arryshort);  %narry = # array geometries; (ns+2)/2 = # sensors


%'global' statement should match the one in tryvalg and any other program that calls this.
global A DESIRED WaveNumber LookAngles CheckAngle  OptType PerfType

%OptType='CON' gives phase only
%OptType='UNCON' gives unconstrained LS
%Not used in this routine:  PerfType='MSE'  minimizes squared error
%                           PerfType='NSR'  minimizes noise to signal ratio
%DESIRED array has desired gains. Corresponds to angles in DTHET.

arry2=[zeros(narry,2),arryshort];  %first element x,y is at 0,0 for all arrays

Nsens=(ns+2)/2; % # sensors
NLookAngles=length(LookAngles);
Nmeas = length(DESIRED);  %Number of angles with specified desired gains
guess=zeros(1,Nsens);
MaxFunEvals=40000;
MaxIter=10000;
options=optimset('MaxFunEvals',MaxFunEvals,'MaxIter',MaxIter);

response=zeros(narry,Nmeas);

%Now create beam for each angle in LookAngles and compute performance.
for kthet=1:NLookAngles
    look=LookAngles(kthet); %this angle corresponds to middle gain in DESIRED
    DTHET=CheckAngle+look; %DTHET array ranges from look-pi to look+pi, with look as center angle
    %DTHET angles correspond to desired gains in DESIRED for this look angle
    for kgeo=1:narry
        arry=arry2(kgeo,:); %extract next array geometry
        s=zeros(Nsens,Nmeas); %each column represents element delays for each DTHET angle
        for ksens=0:Nsens-1  %Compute distance from origin to each sensor
            ix=ksens*2+1;    %arry ordered in x-y pairs
            s(ksens+1,:)=sdist(arry(ix),arry(ix+1),DTHET);
        end
        A=exp(j*s*WaveNumber); %each column of A corresponds to steering vector for angle CheckAngle+look.
        if strcmp(OptType,'CON')
            [phi,fval,exitflag,output] = fminsearch(@tryvalg2,guess,options);
            phi=phi.';
            w=exp(j*phi).';    %constrained weights, converted to row vector
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
                w=W_snr_re+j*W_snr_im;
            end

        else
            error('Bad OptType value')
        end

        response(kgeo,:)=w*A;  %actual array responses from look-pi to look+pi
        response(kgeo,:)=response(kgeo,:)/max(abs(response(kgeo,:)));
    end %kgeo
    plot(DTHET*180/pi,20*log10(abs(response)),[look,look]*180/pi,[-5,+5],'d-');
    axis([min(DTHET)*180/pi,max(DTHET)*180/pi,-40,10])
    grid
%    legend(legnd)
    xlabel('Angle (deg)'),ylabel('Gain (dB)'),title([PerfType,'   ',OptType])
    pause(.1)
end


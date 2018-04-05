%This version June 22 2011:  
% Solves for min mse or min noise-to-signal ratio (depending on how tryvalsq2.m is set up)
% Rotates desired gain through 360 degrees and evaluates each case
%SquareSwitch determines type of antenna array
%    0 for linear array
%    1 to get sateesh square array 4 antennas. 
%    2 for kub square version with 4 antennas
%    3 for kub square version with 5 antennas (one in center)
%    4 for kub Y array with 4 antennas
%    5 for modified Y array with equal antenna distance
%    6 90 degree rotated Y
%    7 square in quadrant 1, lower left corner = origin
%    8 upside down T


clear
clear global
close all
clc
global DESIRED DTHETA KD SquareSwitch

plotflag=1;  %set to 1 to output plots
f0=900e6;
c=300e6; 
lamb=c/f0; %wavelength
k=2*pi/lamb; %wavenumber
d=0.25*lamb;
KD=k*d;

Nmeas=57; %# antenna pattern gains to plot. ODD number and Nmeas-1 divisible by 2*Nsens (Nsens=4)
        %This is also the number of points over which we measure SNR
        %Note that MSE is measured over Nthet points corresponding to
        %DTHETA and DESIRED
delthet=2*pi/Nmeas; 
center=(Nmeas+1)/2; %index of center of beam

beamwidth=(Nmeas-1)/4; %approx best beamwidth assuming Nsens=4 antennas
snrmask=zeros(1,Nmeas);
beam=round(center-round(beamwidth/2):center+round(beamwidth/2));
snrmask(beam)=ones(size(beam));
% snrmask(round(center1-beamwidth/2-0.5:center1+beamwidth/2-0.5))=ones(1,beamwidth+1);
% snrmask(round(center2-beamwidth/2-0.5:center2+beamwidth/2-0.5))=ones(1,beamwidth+1);
% snrmask(final-beamwidth/2:final)=ones(1,beamwidth/2+1);
% snrmask(1:beamwidth/2)=ones(1,beamwidth/2);
thetplt0=-pi+(0:Nmeas-1)*delthet; %for plotting

wt=40; %how much weight to give desired gain
methods=[2,5,8];
offstdeg=[0:10:359]; %look directions
for p=methods
    disp(['Processing method # ',num2str(p)]);
    SquareSwitch=p; 
    i=1;
    if p==3
        Nsens=5; %special case square array with center antenna
    else
        Nsens=4;
    end

    szer=steervec(pi/2,KD,SquareSwitch); %steering vector for 0 deg.
%     phisave=zeros(360,4);
    for off=offstdeg  %look directions in degrees
        offst=off/360*2*pi;

        % DTHETA=[-1,0,-2/3,2/3]*pi+offst;
        % DESIRED=[0,1,0,0]*wt;
        %build a set of desired angle/gain values
        Nthet=56; %# desired angle/gain pairs.  keep even number
        delthet=2*pi/Nthet; 
        DTHETA=-pi+(0:Nthet-1)*delthet+offst;  %angles at which to have desired gain
        DESIRED=zeros(1,Nthet);  %will have form:  [0 0 0 0 0 wt 0 0 0 0]
        DESIRED(Nthet/2)=wt;
        %DESIRED(Nthet/2+4)=wt;
        %DESIRED(Nthet/2+8)=wt;
%         note: the final 0 is at pi-delthet. If we had another zero it would be at pi but we already have one at -pi

        thetplt=thetplt0+offst;
        %  result is -pi to pi, but pi not included in range.

        %Now solve for optimum phi values
        phiguess=zeros(1,Nsens);
        if SquareSwitch %non-linear array
            [phi,fval,exitflag,output] = fminsearch(@tryvalsq2,phiguess);
        else %linear array
            [phi,fval,exitflag,output] = fminsearch(@tryval2,phiguess);
        end
%         phisave(offstdeg+1,:)=phi;
        phi=phi.';
%constrained weights
        wH=exp(j*phi).'; 
        s=steervec(thetplt,KD,SquareSwitch);
        A=exp(j*s);

%unconstrained weights
        sdes=steervec(DTHETA,KD,SquareSwitch);
        Ades=exp(j*sdes);
        W=DESIRED/(Ades); %unconstrained weights

        if plotflag
            plotrslt(A,wH,Ades,W,DESIRED,DTHETA,thetplt,SquareSwitch,snrmask);
        end
        
        Error(p,i)=(DESIRED-wH*Ades)*(DESIRED-wH*Ades)';
        Error_ucon(p,i)=(DESIRED-W*Ades)*(DESIRED-W*Ades)';

        G = abs(wH*A);  %gain at each plot angle:  Constrained
        sigpow=sum(abs(G(snrmask>0)).^2);
        noisepow=sum(abs(G(snrmask==0)).^2);
        SNR(p,i)= sigpow/noisepow;

        G = abs(W*A);  %gain at each plot angle:  Unconstrained
        sigpow=sum(abs(G(snrmask>0)).^2);
        noisepow=sum(abs(G(snrmask==0)).^2);
        SNRucon(p,i)= sigpow/noisepow;

        i=i+1;
    end %offst loop
end  %p loop


%% print results table
fprintf('Case    MSEc  MSEu     meanSNRc  meanSNRu     minSNRc minSNRu      maxSNRc maxSNRu \n')  
for i=methods
    meanSE=10*log10(mean(Error(i,:)));
    meanSEucon=10*log10(mean(Error_ucon(i,:)));
    meanSNR=10*log10(mean(SNR(i,:)));
    meanSNRucon=10*log10(mean(SNRucon(i,:)));
    minSNR=10*log10(min(SNR(i,:)));
    maxSNR=10*log10(max(SNR(i,:)));
    minSNRucon=10*log10(min(SNRucon(i,:)));
    maxSNRucon=10*log10(max(SNRucon(i,:)));

    fprintf(' %d    %6.2f %6.2f       %6.2f %6.2f      %6.2f  %6.2f      %6.2f  %6.2f \n',...
        i,meanSE,meanSEucon,meanSNR,meanSNRucon,minSNR,minSNRucon,maxSNR,maxSNRucon);
    
end

%%  summary plot of results 
figure(2)
nmeth=length(methods);
kp=0;
for k=methods
    kp=kp+1;
    subplot(1,nmeth,kp)
    plot(offstdeg,10*log10(SNR(k,:)),offstdeg,10*log10(SNRucon(k,:)),'-.')
    axis([0,360,-2,15])
    title(['Method ',num2str(k)])
    grid on
    ylabel('SNR (dB)')
    legend('Phase Only','Unconstrained')
end
% polar(thetplt,10*log10(SNR'))
% title('SNR Constrained (-)    SNR Unconstrained (-.)')
% xlabel('beam direction (radians)')

%%  draw arrays to make sure steering vector equations make sense
if 1
    kp=0;
    figure(3)
    for k=methods
        kp=kp+1;
        subplot(1,nmeth,kp)
        x=steervec(pi/2,1,k), y=steervec(0,1,k),
        plot(x,y,'*');
        title(['method ',num2str(k)])
        grid
        axis([-1.1,1.1,-1.1,1.1]),axis square
    end
        
end


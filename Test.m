%program to evaluate and compare array geometries.

%% Set up variables
clear
clear global
close all

%'global' statement should match the one in tryvalg and any other program that calls this.
global A DESIRED WaveNumber LookAngles CheckAngle  OptType PerfType
f0=900e6;
c=300e6; 
lamb=c/f0; %wavelength
WaveNumber=2*pi/lamb; %wavenumber

wantdB=0; %set=1 to output results in dB
Nsens=5; %# antennas
wt=3; %only makes a difference if PerfType='MSE'
NLookAngles=48;  %number of look angles where total array performance tested
Nmeas=48; %# antenna gains to specify for given look direction. Used to measure performance
           %Nmeas should be divisible by 2*Nsens

d=lamb/4; %used below
%arrays to evaluate
arryshort=[-d,0 d,0 0,-d 0,d;... %diamond array
d,0 2*d,0 3*d,0 4*d,0;...%uniform linear array
 ];


leg=['diamond';'UniLinA'];                       %define legend for plot results,must all be same length

[Narray,nsensshort]=size(arryshort);
delLook=2*pi/NLookAngles;
delthet=2*pi/Nmeas; 
center=Nmeas/2+1; %center of beam
bwfactor=10; %make this bigger to make desired beam width narrower
beamwidth=Nmeas/Nsens/bwfactor;  %approx best beamwidth since Nmeas spans 360 degs
DESIRED=zeros(1,Nmeas);  %middle gain in DESIRED corresponds to look direction.
DESIRED(center-beamwidth/2:center+beamwidth/4)=ones(1,beamwidth/4+1)*wt;
DESIRED(center+beamwidth/4:center+beamwidth/2)=ones(1,beamwidth/4+1)*wt;
CheckAngle=-pi+(0:Nmeas-1)*delthet; %check beam performance in these directions relative to look direction
LookAngles=(0:NLookAngles-1)*delLook;  %all look directions to check. This case ensures array can look in all directions
SQE_C=zeros(NLookAngles,Narray);
NSR_C=zeros(NLookAngles,Narray);
SQE_U=zeros(NLookAngles,Narray);
NSR_U=zeros(NLookAngles,Narray);

%% evaluate arrays
OptType='CON';  %find weights for constrained case
PerfType='NSR';
response=plotresponse(arryshort,leg);  %plot comparison

%now compute performance
for karry=1:Narray
    OptType='CON';  %find weights for constrained case
    PerfType='NSR';
    [SQE_C(:,karry), NSR_C(:,karry)]=evaluate(arryshort(karry,:));
    OptType='UNCON';  %find weights for unconstrained case
    PerfType='SD';   %the NSR unconstrained version doesnt work!
    [SQE_U(:,karry), NSR_U(:,karry)]=evaluate(arryshort(karry,:));
end

%% now plot results

if wantdB
    NSR_C=10*log10(NSR_C);
    NSR_U=10*log10(NSR_U);
    SQE_C=10*log10(SQE_C);
    SQE_C=10*log10(SQE_C);
end
minNSR=min(min(min(NSR_C,NSR_U)));
maxNSR=max(max(max(NSR_C,NSR_U)));
minSQE=min(min(min(SQE_C,SQE_U)));
maxSQE=max(max(max(SQE_C,SQE_U)));
figure(1)
subplot(1,2,1)
    plot(LookAngles*180/pi,NSR_C)
    legend(leg);
    title('Constrained: Noise to Signal')
    grid
    xlabel('Look Angles')
    ylabel('Noise to Signal ratio')
    axis([0,360,minNSR,maxNSR]);
subplot(1,2,2)
    plot(LookAngles*180/pi,NSR_U)
    title('UNconstrained: Noise to Signal')
    xlabel('Look Angles')
    ylabel('Noise to Signal ratio')
    legend(leg);
    grid
    axis([0,360,minNSR,maxNSR]);
figure(2)
subplot(1,2,1)
    plot(LookAngles*180/pi,SQE_C)
    legend(leg);
    xlabel('Look Angles')
    ylabel('sum of Squared Error')
    title('Constrained: squared error')
    grid
    axis([0,360,minSQE,maxSQE]);
subplot(1,2,2)
    plot(LookAngles*180/pi,SQE_U)
    xlabel('Look Angles')
    ylabel('sum of Squared Error')
    title('UNconstrained: squared error')
    legend(leg);
    grid
    axis([0,360,minSQE,maxSQE]);
figure(gcf)

%% make a table of results
fprintf('Case     MSEc  MSEu       meanNSRc  meanNSRu    minNSRc minNSRu     maxNSRc maxNSRu \n')  
for k=1:Narray
    meanSE_C=(mean(SQE_C(:,k)));
    meanSE_U=(mean(SQE_U(:,k)));
    meanNSR_C=(mean(NSR_C(:,k)));
    meanNSR_U=(mean(NSR_U(:,k)));
    minNSR_C=(min(NSR_C(:,k)));
    maxNSR_C=(max(NSR_C(:,k)));
    minNSR_U=(min(NSR_U(:,k)));
    maxNSR_U=(max(NSR_U(:,k)));

    fprintf(' %s  %7.2f %7.2f       %6.2f %6.2f      %6.2f  %6.2f      %6.2f  %6.2f \n',...
        leg(k,:),meanSE_C,meanSE_U,meanNSR_C,meanNSR_U,minNSR_C,minNSR_U,maxNSR_C,maxNSR_U);
    
end

%% plot out arrays using delay algorithm to double check all is well
figure(3)
for k=1:Narray
    subplot(1,Narray,k)
    arry=[0,0,arryshort(k,:)];
    x=zeros(Nsens,1); %x locations of array elements
    y=zeros(Nsens,1); %y locations of array elements
    for ksens=0:Nsens-1  %Compute delays to each sensor
        ix=ksens*2+1;    %arry ordered in x-y pairs
        x(ksens+1)=sdist(arry(ix),arry(ix+1),pi/2)/lamb;
        y(ksens+1)=sdist(arry(ix),arry(ix+1),0)/lamb;
    end
    plot(x,y,'*');
    xmin=min(-1.1,min(x)); xmax=max(1.1,max(x)); %kludge to handle xmin=xmax or ymin=ymax
    ymin=min(-1.1,min(y)); ymax=max(1.1,max(y));
    
    title(leg(k,:))
    grid
    axis([xmin,xmax,ymin,ymax]),axis square
end

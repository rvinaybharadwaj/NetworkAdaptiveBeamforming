% This function is called by the fminsearch and it returns the average NSR
function nsr1=nsr(phi)
%phi(k) is the phase of the phase shifter for k-th sensor.

global Narray lambda node pairs sigma2 nsr2 nsr3 Nsens 

%initialize the interference and desired signal
for i=1:Narray
%     node(i).V=0;
    node(i).V_dir=0;
    node(i).V_omni=0;
%     node(i).S=0;
    node(i).S_dir=0;
    node(i).S_omni=0;
%     node(i).N=0;
    node(i).N_dir=0;
    node(i).N_omni=0;
end
%initialize the weights 
for i=1:Narray
    node(i).w=exp(1i*phi(i,:));
    node(i).omni_w=ones(1,Nsens)./Nsens;%weight vectors for omnidirectional pattern
end
%% Calculate the gain at node i facing towards node j
%power gain is voltage gain squared  
for i=1:Narray
   % node(i).gain=abs(node(i).w*node(i).sv).^2;% gain in all directions to compute the noise power
   node(i).gain_dir=abs(node(i).w*node(i).sv).^2;% gain in all directions to compute the noise power
   node(i).gain_omni=abs(node(i).omni_w*node(i).sv).^2;% gain in all directions to compute the noise power
    for j=1:Narray
        if(i==j)
            pairs(i,j).G_dir=0;
            pairs(i,j).G_omni=0;
        else
            pairs(i,j).G_dir=abs(node(i).w*pairs(i,j).A)^2; %gain in the desired directions    
            pairs(i,j).G_omni=abs(node(i).omni_w*pairs(i,j).A)^2; %omnidirectional gain
        end
    end
end

%% Calculate the received power at node i from node j
deltheta=0:pi/24:2*pi;
a=size(deltheta);
for i=1:Narray
    for j=1:a(2)
%         node(i).N=node(i).N+sigma2*node(i).gain(j); %noise power at each node=sigma2*sum(gains in all directions)
        node(i).N_dir=node(i).N_dir+sigma2*node(i).gain_dir(j); %noise power at each node=sigma2*sum(gains in all directions)
        node(i).N_omni=node(i).N_omni+sigma2*node(i).gain_omni(j); %noise power at each node=sigma2*sum(gains in all directions)
    end
end
for i=1:Narray   
    for j=1:Narray
        if (i~=j) 
            %compute the received power at node i from node j using Friis equation
%             pairs(i,j).P=node(j).TranPwr*pairs(i,j).G*pairs(j,i).G*(lambda/4/pi/pairs(i,j).dij)^2; 
            pairs(i,j).P_dir=node(j).TranPwr*pairs(i,j).G_dir*pairs(j,i).G_dir*(lambda/4/pi/pairs(i,j).dij)^2; 
            pairs(i,j).P_omni=node(j).TranPwr*pairs(i,j).G_omni*pairs(j,i).G_omni*(lambda/4/pi/pairs(i,j).dij)^2; 
        else
%             pairs(i,j).P=0;
            pairs(i,j).P_dir=0;
            pairs(i,j).P_omni=0;
        end
    end
end
%% Calculate the total sums of the desired signal power and the interference power at node i
nsrindx=0;
nsrindx1=0;
for i=1:Narray
    for j=1:Narray
        if strcmp(node(j).type,'interference')||strcmp(pairs(i,j).friend,'no') %treat all other nodes other than pairwise friends to be interfering
%             node(i).V = node(i).V + pairs(i,j).P; %sum up the interference power
            node(i).V_dir = node(i).V_dir + pairs(i,j).P_dir; %sum up the interference power
            node(i).V_omni = node(i).V_omni + pairs(i,j).P_omni; %sum up the interference power
        else%if strcmp(pairs(i,j).friend,'yes')
%             node(i).S=node(i).S+pairs(i,j).P; %sum up the desired signal power
            node(i).S_dir=node(i).S_dir+pairs(i,j).P_dir; %sum up the desired signal power
            node(i).S_omni=node(i).S_omni+pairs(i,j).P_omni; %sum up the desired signal power
        end
    end
% calculate the noise to signal ratio  
    if node(i).S_dir~=0 && strcmp(node(i).type,'desired')
        nsrindx=nsrindx+1;
        NSR_dir(nsrindx)=(node(i).V_dir+node(i).N_dir)/node(i).S_dir; % NSR = (sum of noise power+sum of interference power)/sum of desired signal power
    end 
    if node(i).S_omni~=0 && strcmp(node(i).type,'desired')
        nsrindx1=nsrindx1+1;
        NSR_omni(nsrindx1)=(node(i).V_omni+node(i).N_omni)/node(i).S_omni; % NSR = (sum of noise power+sum of interference power)/sum of desired signal power
    end 
end
% Find the average value of nsr 
nsr1=mean(NSR_dir);

nsr2=NSR_omni;
nsr3=NSR_dir;




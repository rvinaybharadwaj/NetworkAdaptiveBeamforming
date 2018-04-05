function required_power()

global Narray Nsens node pairs Ndes SNRmin f0 lambda deltheta

for i=1:Narray
    node(i).omni_w=ones(1,Nsens);%weight vectors for omnidirectional pattern
end

for i=1:Ndes
    for j=1:Narray
        if(i==j)
            % initialize the gains
            pairs(i,j).G_dir=0;
            pairs(i,j).G_omni=0;
        else
            %gain in the desired directions (power gain is voltage gain squared)
            pairs(i,j).G_dir=abs(node(i).w*pairs(i,j).A).^2; % directional gain
            pairs(i,j).G_omni=abs(node(i).omni_w*pairs(i,j).A).^2; %omnidirectional gain
             % Scale the gain
            pairs(i,j).G_dir = (2*pi/trapz(deltheta, node(i).gain_dir))*pairs(i,j).G_dir;
            pairs(i,j).G_omni = (2*pi/trapz(deltheta, node(i).gain_omni))*pairs(i,j).G_omni;
        end
    end
end

%% define parameters for WIM
h_bs = 3.5; % height of base station (transmitter) in meters (4 - 50 m)
h_m = 3.5; % height of receiver in meters (1 - 3 m)
h_B = 10; % height of building in meters 
b = 14; % building separation in meters
w = 8; % width of street in meters
phiflag = 0; % don't include street orientation
phi = 0; % street orientation angle w.r.t. incident wave
freq = f0/1e6; % frequency of operation in MHz (800 - 2000 MHz)
city_type = 0; % required for Hata model ... ignore for now
hataflag = 0; % don't include Hata path loss

%% Received power
for i=1:Ndes
    for j=1:Narray
        if (i~=j) 
            %compute the received power at node i from node j 
            
            % Loss using Friis equation (free space model)
%             loss = (4*pi*pairs(i,j).dij/lambda)^2;
            
%             % Compute path loss using Walfisch-Ikegami model 
%             % distance must be in km. pairs(i,j).dij is divided by 100 to
%             % give coordinate*10/1000 so that the values are in range of 20 -
%             % 5000 m
            loss_dB = wim(h_bs, h_m, h_B, b, w, phiflag, phi, pairs(i,j).dij/1000, freq, city_type, hataflag);
            loss = 10^(loss_dB/10); % convert dB to non-dB path loss
            % Compute the received power at node i from node j
            pairs(i,j).P_dir = node(j).TranPwr * pairs(i,j).G_dir * pairs(j,i).G_dir / loss; 
            pairs(i,j).P_omni = node(j).TranPwr * pairs(i,j).G_omni * pairs(j,i).G_omni / loss; 
        else
            pairs(i,j).P_dir=0;
            pairs(i,j).P_omni=0;
        end
    end
end

for i=1:Ndes
    % initialization of interference power
    node(i).V_dir=0;
    node(i).V_omni=0;
end

for i=1:Ndes
    for j=1:Narray
        if strcmp(node(j).type,'interference')||strcmp(pairs(i,j).friend,'no')
            node(i).V_dir = node(i).V_dir + pairs(i,j).P_dir; %sum up the interference power
            node(i).V_omni = node(i).V_omni + pairs(i,j).P_omni; %sum up the interference power
        end
    end
end

for i=1:Ndes
    % required power based on the min SNR
    arryPow_dir(i) = SNRmin*node(i).V_dir;
    arryPow_omni(i) = SNRmin*node(i).V_omni;
end
    
% Plot the min required transmission power at each node based on the
% specified minimum SNR
figure;
hold all;
plot(1:Ndes,10*log10(arryPow_dir),'r-*');
plot(1:Ndes,10*log10(arryPow_omni),'b-s');
hold off;
xlim([0 5])
xlabel('Node #');
ylabel('Minimum required power (dBW)');
legend('dir','omni');


% Display the total power and print it to a file
file = fopen('power_6_3_wim','a');
disp('The minimum required transmission power:');
disp('Omnidirectional case');
disp(sum(arryPow_omni));
fprintf(file,'%f    ',sum(arryPow_omni));
disp('Directional case');
disp(sum(arryPow_dir));
fprintf(file,'%f\n',sum(arryPow_dir));
fclose(file);

function required_power()

global Narray Nsens lambda node pairs Ndes SNRmin

for i=1:Narray
    node(i).omni_w=ones(1,Nsens)/Nsens;%weight vectors for omnidirectional pattern
end

for i=1:Narray
    for j=1:Narray
        if(i==j)
            % initialize the gains
            pairs(i,j).G_dir=0;
            pairs(i,j).G_omni=0;
        else
            %gain in the desired directions 
            pairs(i,j).G_dir=abs(node(i).w*pairs(i,j).A)^2; % directional gain
            pairs(i,j).G_omni=abs(node(i).omni_w*pairs(i,j).A)^2; %omnidirectional gain
        end
    end
end

for i=1:Narray   
    for j=1:Narray
        if (i~=j) 
            %compute the received power at node i from node j using Friis equation
            pairs(i,j).P_dir=node(j).TranPwr*pairs(i,j).G_dir*pairs(j,i).G_dir*(lambda/4/pi/pairs(i,j).dij)^2; 
            pairs(i,j).P_omni=node(j).TranPwr*pairs(i,j).G_omni*pairs(j,i).G_omni*(lambda/4/pi/pairs(i,j).dij)^2; 
        else
            pairs(i,j).P_dir=0;
            pairs(i,j).P_omni=0;
        end
    end
end

for i=1:Narray
    % initialization of interference power
    node(i).V_dir=0;
    node(i).V_omni=0;
end

for i=1:Narray
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
plot(1:Ndes,arryPow_dir);
plot(1:Ndes,arryPow_omni);
xlabel('Node #');
ylabel('Minimum required power');
legend('directional antenna','omnidirectional antenna');
hold off;

% Display the total power and print it to a file
file = fopen('power_1_30_15','a');
disp('The minimum required transmission power:');
disp('Omnidirectional case');
disp(sum(arryPow_omni));
fprintf(file,'%f    ',sum(arryPow_omni));
disp('Directional case');
disp(sum(arryPow_dir));
fprintf(file,'%f\n',sum(arryPow_dir));
fclose(file);

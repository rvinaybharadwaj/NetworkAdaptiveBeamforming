%**************************************************************************
% Author: Vinay Ramakrishnaiah
% function that finds the optimal antenna weights
%**************************************************************************
function evaluateMultinode(arryshort)

global WaveNumber Narray Nsens Ncoord index node pairs nsr2 nsr3 ind deltheta

%**************************************************************************
% pairs is a 2D structure with 6 members
%     dij = distance between node i and node j
%     thetaij = angle between node i and node j
%     friend = the next and previous hop neighbors are pairwise friends
%     s = the distance the wavefronts has to travel from sensor to sensor when travelling from one node to another
%     A = the steering vector in the direction of the other nodes
%     G = the gain of each node in the direction of the other nodes
%     P = the power received at node i from node j
%**************************************************************************

deltheta=0:pi/24:2*pi; % look at all directions for white noise
a=length(deltheta); % # of sample look directions

% initialize friends
for i=1:Narray
    for j=1:Narray
        pairs(i,j).friend='no';
    end
end

%% Get dij and thetaij and determine pairwise friends
for i=1:Narray
    for j=1:Narray
        [pairs(i,j).dij,pairs(i,j).thetaij]=ndist(arryshort(i,1),arryshort(i,2),arryshort(j,1),arryshort(j,2));%ndist gives the Euclidian distance and the angle between the nodes
        % only the next and previous hop neighbors in the route are pairwise friends
        if ((node(i).number==node(j).previous) || (node(i).number==node(j).next))
            pairs(i,j).friend='yes';
        end
    end
end
%% Steering vector for calculating the noise power
for i=1:Narray % go through all nodes
    for ksens=0:Nsens-1 % all antennas in the array
        ix=ksens*2+1; % to index the coordinates of sensors, x-y ordered pairs
        for j=1:a % consider all directions
            node(i).sLook(ksens+1,j)=sdist(arryshort(i,ix),arryshort(i,ix+1),deltheta(j));%calculate the steering vector for the nodes by considering all directions(for noise power)            
        end
    end
end
%% Get the steering vector  
Nsens=Ncoord/2; % each sensor is represented by cartesian coordinates
for i=1:Narray
    for j=1:Narray
        for ksens=0:Nsens-1  %Compute distance from origin to each sensor
            ix=ksens*2+1;    %arry ordered in x-y pairs
            %sdist gives the distance travelled by the wavefront in travelling from one sensor to another in the direction thetaij
            pairs(i,j).s(ksens+1,:)=sdist(arryshort(i,ix),arryshort(i,ix+1),pairs(i,j).thetaij);            
        end
        %each column of A corresponds to steering vector for angle thetaij
        pairs(i,j).A=exp(1i*pairs(i,j).s*WaveNumber);
        %each column of sv corresponds to steering vector in sampled look
        %direction, the entire matrix covering all dimensions
        node(i).sv=exp(1i*node(i).sLook*WaveNumber); % take this outside the inner loop???
    end
end

%% Optimization
guess=zeros(1,Nsens);%initial guess of phi values to pass to fminsearch
guess1(1:Nsens)=-1i*log(1/Nsens);
for i=1:Narray
    node(i).w=ones(1,Nsens);%initialize weight vectors
end


%constraints on fminsearch
% MaxFunEvals=40000;
MaxFunEvals=realmax;
MaxIter=realmax;

options=optimset('MaxFunEvals',MaxFunEvals,'MaxIter',MaxIter);

flag = 0;
for index=0:99
    ind=randi(100);
     % stopping criteria for iterations   
      if ((index > 1) && ((outputnode(index-1)-outputnode(index)) < 1e-3))
        flag = flag+1;
        if (flag == Narray)
            node(rem(index-1,Narray)+1).w=exp(1i*phi_vec(index - Narray,:));%use the optimal value of phi to assign the weight vector to a node
            node(rem(index-1,Narray)+1).phase=phi_vec(index - Narray,:);
            break; % Check if NSR did not improve for an entire pass of the algorithm through all the nodes in the route
        end
      else
        flag = 0;
      end

     % call fminsearch to get the min nsr and the set phi which produces it
      if (strcmp(node(rem(index,Narray)+1).friend,'yes'))
%     if strcmp(pairs(rem(index,Narray)+1,i).friend,'yes')
        [phi,fval,exitflag,output] = fminsearch(@nsr,guess,options);
        phi_vec(index+1,:) = phi; 
        node(rem(index,Narray)+1).w=exp(1i*phi);%use the optimal value of phi to assign the weight vector to a node
        node(rem(index,Narray)+1).phase=phi;
        outputnode(index+1) = fval; %the value of the function nsr at the optimal value of phi 
        outputnode_omni(index+1) = mean(nsr2); %the value of the nsr for omni-directional antennas
        nsr2_vec(index+1,:) = nsr2;
        nsr3_vec(index+1,:) = nsr3;
        if (index == 0)
            figure
            plot(1:length(nsr3),10*log10(1./nsr3),'b-o') % plot the inital SNR at each node
            hold on
        end
      else
        outputnode(index+1) = nsr(guess1);
      end      
end
nsr2 = nsr2_vec(end-1,:);
nsr3 = nsr3_vec(end-1,:);
plot(1:length(nsr3),10*log10(1./nsr3),'r-*'); % plot the final SNR at each node
xlim([0 5])
hold off
xlabel('node #');
ylabel('SNR (dB)');
legend('initial','final');

node.phase
% Writing the result to a file
file = fopen('snr_6_3_wim','a');
fprintf(file,'%f    %f\n',1/mean(nsr2),1/mean(nsr3));% this corresponds to the last written value of the nsr which is the optimized value
fclose(file);
disp('Signal to Noise ratio of omni:');
disp(1/mean(nsr2));
disp('Signal to Noise ratio of dir:');
disp(1/mean(nsr3));

% minimum transmission power required based on the min SNR
required_power();
    
%% plot the value
figure;
hold all
plot(10*log10(outputnode(1:end-1))); %plot the nsr vs the number of iterations
plot(10*log10(outputnode_omni(1:end-1)))
hold off
xlabel('iteration #');
ylabel('NSR (dB)');
legend('dir','omni');
plotmultinode(arryshort); %function to plot the beam pattern


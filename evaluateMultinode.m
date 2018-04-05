function SNR=evaluateMultinode(arryshort)

global WaveNumber Narray Nsens Ncoord node pairs

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

deltheta=0:pi/24:2*pi;%look at all directions for white noise
a=length(deltheta);% # of sample look directions

% initialize friends
for i=1:Narray
    for j=1:Narray
        pairs(i,j).friend='no';
    end
end

%% Get dij and thetaij
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
for i=1:Narray
    for ksens=0:Nsens-1  
        ix=ksens*2+1;   
        for j=1:a % consider all directions
            node(i).sLook(ksens+1,j)=sdist(arryshort(i,ix),arryshort(i,ix+1),deltheta(j));%calculate the steering vector for the nodes by considering all directions(for noise power)            
        end
    end
end
%% Get the steering vector  
Nsens=Ncoord/2;%each sensor is represented by cartesian coordinates
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
        node(i).sv=exp(1i*node(i).sLook*WaveNumber);
    end
end

%% Monte Carlo trials with different random phi values
for j=1:1000
    SNR(j)=1/nsr(rand(Narray,Nsens)*2*pi);
end

    


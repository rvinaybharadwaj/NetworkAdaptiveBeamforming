%**************************************************************************
% Author: Vinay Ramakrishnaiah
% function to optimize multiple nodes
%**************************************************************************
function MultiNode()
clear all
close all

%% Set up variables
global WaveNumber lambda node Narray Nsens Ncoord sigma2 SNRmin Ndes f0
f0=900e6;               % frequency
c=300e6;                % velocity of light
lambda=c/f0;            % wavelength
WaveNumber=2*pi/lambda; % wavenumber
d=lambda/4;             % distance between the sensors
sigma2=1;               % white noise power
SNRmin=100;             % min value of SNR at each node
rng('shuffle');         % random seed
% rng(55);                % For test purpose
%**************************************************************************
% node is a structure which has 13 members
%     TranPwr = transmitter power 
%     number = node number
%     next = next hop neighbor
%     previous = previous hop neighbor
%     type = the type of node - 'interference' or 'desired'
%     friend = 'yes' means its weights can be modified, 'no' means its weights cannot be modified. All desired nodes are friendly nodes
%     angle = the orientation of the nodes
%     sCoord = sensor coordinates
%     sLook = the distance the wavefronts has to travel from one sensor to another when travelling from different directions (360 degrees)
%     sv = steering vectors in all directions
%     w = node weights
%     V = interference power
%     S = desired signal power
%     N = white noise power
%     gain = the gain of each node in all directions
%     response = the gain in the desired directions
%     PT_fact_w = power factor of directional array
%     PT_fact_omni_w = power factor of omni-directional array
%**************************************************************************
%initialize the nodes 
%constrain the node angle to be only in the first quadrant 
%Enter the coordinates of the bottom left most sensor of each node first

x1=50;
y1=50;
x2=100;
y2=100;
x3=150;
y3=50;
x4=200;
y4=100;
% x5=150;
% y5=150;
% x6=75;
% y6=100;
% x7=100;
% y7=100;

    % desired nodes
    node(1).TranPwr=10;
    node(1).number=1;
    node(1).next=2;
    node(1).previous=0;
    node(1).type='desired';
    node(1).friend='yes';
    node(1).angle=0;
    node(1).sCoord=[x1,y1 x1+d,y1 x1,y1+d x1+d,y1+d x1,y1+2*d x1+2*d,y1 x1+2*d,y1+d x1+d,y1+2*d x1+2*d,y1+2*d];
    
    node(2).TranPwr=10;
    node(2).number=2;
    node(2).next=3;
    node(2).previous=1;
    node(2).type='desired';
    node(2).friend='yes';
    node(2).angle=0;
    node(2).sCoord=[x2,y2 x2+d,y2 x2,y2+d x2+d,y2+d x2,y2+2*d x2+2*d,y2 x2+2*d,y2+d x2+d,y2+2*d x2+2*d,y2+2*d];
    
    node(3).TranPwr=10;
    node(3).number=3;
    node(3).next=4;
    node(3).previous=2;
    node(3).type='desired';
    node(3).friend='yes';
    node(3).angle=0;
    node(3).sCoord=[x3,y3 x3+d,y3 x3,y3+d x3+d,y3+d x3,y3+2*d x3+2*d,y3 x3+2*d,y3+d x3+d,y3+2*d x3+2*d,y3+2*d];
    
    node(4).TranPwr=10;
    node(4).number=4;
    node(4).previous=3;
    node(4).next=0;
    node(4).type='desired';
    node(4).friend='yes';
    node(4).angle=0;
    node(4).sCoord=[x4,y4 x4+d,y4 x4,y4+d x4+d,y4+d x4,y4+2*d x4+2*d,y4 x4+2*d,y4+d x4+d,y4+2*d x4+2*d,y4+2*d];
    
%     node(5).TranPwr=10;
%     node(5).number=5;
%     node(5).previous=4;
%     node(5).next=0;
%     node(5).type='desired';
%     node(5).friend='yes';
%     node(5).angle=0;
%     node(5).sCoord=[x5,y5 x5+d,y5 x5,y5+d x5+d,y5+d x5,y5+2*d x5+2*d,y5 x5+2*d,y5+d x5+d,y5+2*d x5+2*d,y5+2*d];
    
%     node(6).TranPwr=10;
%     node(6).number=6;
%     node(6).previous=5;
%     node(6).next=0;
%     node(6).type='desired';
%     node(6).friend='yes';
%     node(6).angle=0;
%     node(6).sCoord=[x6,y6 x6+d,y6 x6,y6+d x6+d,y6+d x6,y6+2*d x6+2*d,y6 x6+2*d,y6+d x6+d,y6+2*d x6+2*d,y6+2*d];
%     
%     node(7).TranPwr=10;
%     node(7).number=7;
%     node(7).previous=6;
%     node(7).next=0;
%     node(7).type='desired';
%     node(7).friend='yes';
%     node(7).angle=0;
%     node(7).sCoord=[x7,y7 x7+d,y7 x7,y7+d x7+d,y7+d x7,y7+2*d x7+2*d,y7 x7+2*d,y7+d x7+d,y7+2*d x7+2*d,y7+2*d];
    
%      node(4).sCoord=[x4,y4 x4,y4 x4,y4 x4,y4 x4,y4 x4,y4 x4,y4 x4,y4 x4,y4];
    Ndes=length(node);
    
    % interference nodes
    n=5; %next node in the sequence
    close_thresh = 20; %how close the nodes can be
    for i=n:5
        node(i).TranPwr=10;
        node(i).number=i;
        node(i).previous=0;
        node(i).next=0;
        node(i).type='interference';
        node(i).friend='no';
        node(i).angle=0;
        x=round(rand(1,2)*100); % randomly set the position of interference node
%         x(1)=7; x(2)=8;
%         node(i).sCoord=[x(1),x(2) x(1)+d,x(2) x(1),x(2)+d x(1)+d,x(2)+d x(1),x(2)+2*d x(1)+2*d,x(2) x(1)+2*d,x(2)+d x(1)+d,x(2)+2*d x(1)+2*d,x(2)+2*d];
        node(i).sCoord=[x(1),x(2) x(1),x(2) x(1),x(2) x(1),x(2) x(1),x(2) x(1),x(2) x(1),x(2) x(1),x(2) x(1),x(2)]; % all antennas are at the same position to form omnidirectional beam
        for m=1:length(node)-1
            % Check if two nodes are very close
            if (norm(node(i).sCoord(1:2) - node(m).sCoord(1:2)) < close_thresh)
                n=n-1; % Redo the iteration if two nodes overlap
                continue;
            end
        end      
    end

    Node=length(node);% # of nodes

    %array to evaluate
    for i=1:Node
        arryshort(i,:)=[node(i).sCoord;];
    end

    [Narray,Ncoord] = size(arryshort);% the matrix dimensions
    Nsens=Ncoord/2; % Each sensor has both x and y coordinates, so divide by 2
%     %% Take care of the orientation of nodes
%     %shift the nodes to the origin to perform the rotation
%     for i=1:Narray
%         for ksens=0:Nsens-1  %Compute distance from origin to each sensor
%             ix=ksens*2+1;    %arry ordered in x-y pairs
%             arryshift(i,ix:ix+1) = arryshort(i,ix:ix+1)-arryshort(i,1:2);
%         end
%     end
%     % incorporate the rotation of the sensors in the nodes
%     for i=1:Narray
%         R=[cos(node(i).angle) -sin(node(i).angle);sin(node(i).angle) cos(node(i).angle)];
%         for ksens=0:Nsens-1  %Compute distance from origin to each sensor
%             ix=ksens*2+1;    %arry ordered in x-y pairs
%             arryshift(i,ix:ix+1) = (R*arryshift(i,ix:ix+1)')' ;
%         end
%     end
%     %shift the sensor back to originial position after performing rotation
%     for i=1:Narray
%         for ksens=0:Nsens-1  %Compute distance from origin to each sensor
%             ix=ksens*2+1;    %arry ordered in x-y pairs
%             arryshift(i,ix:ix+1) = arryshift(i,ix:ix+1)+arryshort(i,1:2);
%         end
%     end
%     arryshort=arryshift;%assign it back to the original array

    %% now compute performance
    evaluateMultinode(arryshort);




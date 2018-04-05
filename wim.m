% This is the COST 231 Walfisch Ikegami model(WIM) used in propagation
% modelling in a wireless environment. It is an empherical model and is an
% improvement of the propagation model developed by Joram Walfisch and
% Henry L Bertoni with the building model developed by Ikegami. 
%##########################################################################
%Harish Muralidhara
%2009
%##########################################################################
%In the calculation of path loss, apart from the distance between the
%transmitter and the receiver, it takes into account the height of
%buildings, separation between buildings and width of the street. 

%The three main loss factors in WIM are
% 1. l_rts = Roof to street diffraction and scatter loss  
% 2. l_msd = Multi screen diffraction loss
% 3. l_fs = Free Space loss

%The various terms used in the calculation of the path loss are explained
%below.

% h_bs = transmitter antenna height from ground level in meters
% h_m = receiver antenna height in meters
% h_B = building height in meters
% b = building separation in meters
% w = width of street in meters
%Mod by BK:  phiflag=0 then don't include orientation
% phi = angle of incident wave wrt street (degrees)
% d = Distance between transmitter and receiver in km
% freq = Frequency of operation
%BK mod hataflag=1 requires Hata model
%--------------------------------------------------------------------------
function [loss] = wim(h_bs, h_m, h_B, b, w, phiflag, phi, d, ...
    freq, city_type, hataflag);

if hataflag %exceeds valid range for WIM. Use Hata
    loss = har_hata (h_bs, h_m, d, freq, city_type, h_B);
    return
end

delta_hm = h_B - h_m; %Difference between building height and receiver height

delta_hb = h_bs - h_B;%Difference between transmitter height and building height

if phiflag==0 %|| d==0    
    l_ori=0; %for now remove orientation effects
else
    if (phi < 35 && phi >=0)
        l_ori = -10+0.354*phi;
    else if (phi < 55 && phi >= 35)
            l_ori = 2.5+0.075*(phi-35); %Calculate orientation loss depending on the value of phi
        else if  (phi <= 90 && phi >=55)
                l_ori = 4-0.114*(phi-55);
            end
        end
    end
end %phiflag
   
l_rts = -16.9-10*log10(w) + 10*log10(freq)+ 20*log10(delta_hm)+l_ori; %roof to street diffraction and scatter loss
%To calculate multi screen diffraction loss

if (delta_hb > 0)
    l_bsh = -18*log10(1+delta_hb);  %Shadowing gain (negetive loss)
else
    l_bsh = 0;
end

if (delta_hb >= 0)  %BK changed this section to remove matlab error
    k_a = 54;
else
    if (d >= 0.5)
        k_a = 54+0.8* abs(delta_hb);%This parameter denotes the increase
%         in path loss for transmitters whose antenna height is less than building heights
    else
        k_a = 54+0.8* abs(delta_hb)*(d/0.5);
    end
end

if (delta_hb > 0)
    k_d = 18;               %distance factor
else
%     k_d = 18 + 15 * (delta_hb/h_B);
    k_d = 18 - 15 * (delta_hb/delta_hm);
end

%For our analysis I have considered a medium city 

k_f = -4 + 0.7 * ((freq/925)-1); %Frequency factor
%k_f = -4+ 1.5* (freq/925-1); %for metropolitan centers



if d>0
    logterm=log10(d);
else %this shouldnt happen
    logterm=0; %don't include d for result at xmtr locaiton
end
l_msd = l_bsh + k_a + k_d*logterm + k_f*log10(freq)-9*log10(b);%Multiscreen diffraction loss

l_fs = 32.45 + 20*logterm + 20*log10(freq);%free space loss


%Compute the final path loss. If l_rts and l_msd are negative, final loss
%is just the free space loss.

if (l_rts+l_msd >=0)
    loss = l_fs + l_rts + l_msd; 
else
    loss = l_fs;
end

end

%End of WIM
            
            
 

 

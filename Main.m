%**************************************************************************
% 7/8/2014
% This is the main program which calls the function MultiNode.m
%**************************************************************************
clear
clear global
close all
global SNR
tic % Start collecting the execution time
N=1000;% The number of topologies
for top=1:N
    MultiNode(top);
end
toc% Stop collecting time;
%% Plot the values
figure;
hold on;
histfit(mean(SNR,1),100,'kernel');% Plot the SNR for omnidirectional case
h = findobj(gca,'Type','patch');
set(h,'FaceColor',[0.5 0 0],'EdgeColor','w');
ylabel('# of repetitions');
xlabel('SNR');

file = fopen('snr_mc','a');
fprintf(file, '%0.4f\n', mean(SNR,1)); %average over 1000 random weights for each topology
fclose(file);


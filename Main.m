%**************************************************************************
% 7/8/2014
% Author: Vinay Ramakrishnaiah
% This is the main program which calls the function MultiNode.m
% It also reads the results and plots different graphs
%**************************************************************************
tic % Start collecting the execution time
N=1000;% The number of times the program has to repeat
for i=1:N
    MultiNode();
end

%% Read the SNR values from the file
file=fopen('snr_6_3_wim','r');
snr = textscan(file,'%f %f');
fclose(file);

%% Read the total power from the file
file1=fopen('power_6_3_wim','r');
power=textscan(file1,'%f %f');
fclose(file1);

%% Plot the values
% figure;
% hold on;
% hist(snr{1},10);% Plot the SNR for omnidirectional case
% h = findobj(gca,'Type','patch');
% set(h,'FaceColor',[0.5 0 0],'EdgeColor','w');
% hist(snr{2},20);% Plot the SNR for directional case
% hold off;
% ylabel('# of repetitions');
% xlabel('SNR');
% legend('omni','dir');

figure;
hold on;
h_snr2 = histfit(snr{2},30,'kernel');% Plot the SNR for directional case
set(h_snr2(1),'FaceColor',[0.527 0.86 0.42],'EdgeColor','w');
set(h_snr2(2),'color','b');
h_snr1 = histfit(snr{1},15,'kernel');% Plot the SNR for omnidirectional case
set(h_snr1(1),'FaceColor',[0.718 0.496 0.968],'EdgeColor','w');
set(h_snr1(2),'color','r');
hold off;
ylabel('# of repetitions');
xlabel('SNR');
legend('dir','dirPdf','omni','omniPdf');
xlim([0 inf]);

figure;
hold on;
plot(10*log10(power{1}),'r');% Plot the total power for omnidirectional case
plot(10*log10(power{2}),'b');% Plot the total power for directional case
hold off;
xlabel('Experiment number');
ylabel('Total power (dBW)');
legend('omni','dir');
toc% Stop collecting time

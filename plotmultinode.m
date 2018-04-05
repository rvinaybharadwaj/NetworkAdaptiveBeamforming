function plotmultinode(arryshort)
global WaveNumber Nsens node Narray Ndes
ktheta=0:0.01:5*pi/2;

%Now create beam for each angle and compute performance.

for knode=1:Narray
    counter=1;
    for kthet=0:0.01:5*pi/2
        arry=arryshort(knode,:); %extract individual nodes
        for ksens=0:Nsens-1  %Compute distance from origin to each sensor
            ix=ksens*2+1;    %arry ordered in x-y pairs
            s(ksens+1,:)=sdist(arry(ix),arry(ix+1),kthet);%sdist gives the distance the wavefront has to travel from one sensor to another within a node which results in phase delays
        end
        A=exp(1j*s*WaveNumber); %each column of A corresponds to steering vector 
        node(knode).response(counter,:)=abs(node(knode).w*A); % the voltage gain response
        counter=counter+1;
    end 
end

% plot the beam pattern
fh=figure;
for i=Narray:-1:1
    ah(i) = axes('Parent',fh,'units','pixels',...
        'Position',[arryshort(i,1:2)*5 100 100]);%polar plots set to the scaled location of nodes to make it intuitive to understand
    h_dummy=polar(ah(i),ktheta',((Nsens+1)*ones(size(ktheta'))));
    hold on;
    p=polar(ah(i),ktheta',(abs(node(i).response))); %plot the gain (dBi) vs angle
%     set(h_dummy,'Visible','Off');
%     h=findall(gcf,'type','text');
%     h(h == p) = [];
%     delete(h);
%     h=findall(gcf,'type','line');
%     h(h == p) = [];
%     delete(h);
    delete(findall(ancestor(p,'figure'),'HandleVisibility','off','type','line','-or','type','text')); 
%     xlabel(i);
end
hold off


figure
hold on
for i=1:Ndes
    plot(ktheta'*180/pi,20*log10(abs(node(i).response)));
end
hold off
grid
xlim([0 360]);
xlabel('theta')
ylabel('Gain (dBi)')
legend('node1','node2','node3','node4')


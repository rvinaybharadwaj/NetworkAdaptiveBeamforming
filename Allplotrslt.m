function Allplotrslt(A,w,DESIRED,DTHETA)
%makes polar plot of array patterns
%includes nice kludge to prevent polar plot from autoscaling

        Nthet=length(DTHETA);
        response=20*log10(abs(w*A));

        %for polar we need to get rid of neg values
        response=max(response,0);
        maxy=15; %max y axis
        miny=0; %min y
        izer=find(DESIRED<=0);   %indices of desired zero gains
        polar([DTHETA,0,0],[response,miny,maxy]) %append points at min and max to force const autoscale 
        axis([-maxy,maxy,-maxy,maxy])
        hold on
        polar(DTHETA,DESIRED,'m--');  %plot beamwidth
        %now draw lines at desired gain points
        for kk=1:Nthet
            if ismember(kk,izer)
                polar([DTHETA(kk),DTHETA(kk)],[miny,maxy],'g:')
            else
                polar([DTHETA(kk),DTHETA(kk)],[miny,maxy],'r--')
            end
        end
        hold off
        pause(.25)

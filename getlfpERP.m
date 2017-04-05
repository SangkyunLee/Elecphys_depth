
function [ERP,twin,ERPj, ERP2, ERPj2] = getlfpERP(lfp_data,eventTime,twin_sec,twin0_sec)

    Fs = lfp_data.Att.Fs;
    lfp   = lfp_data.data;  %1d
    
    t = (0 : size(lfp,1)-1)/Fs + lfp_data.Att.t0/1000;
    
    valevt = eventTime - (t(1)+twin_sec(1))>0 & eventTime-(t(end)+twin_sec(2))<0;
    eventTime = eventTime(valevt);
    nevt = length(eventTime);
    twin = twin_sec(1):1/Fs:twin_sec(end);



    %extract event-triggered trace. 
    for j = 1 : nevt    
%         [td,tinx] = min(abs(t - eventTime(j)));
%         assert(td<1/Fs,sprintf('trial #%d NOT selected',j));
%         twin_inx = tinx + twin_sec*Fs; 
%         twin_inx = twin_inx(1):twin_inx(end);
        
        twin_inx = time2inx(t,eventTime(j),twin_sec);
        twin0_inx = time2inx(t,eventTime(j),twin0_sec);
        
        twin_inx2 = twin_inx + Fs ;
        twin0_inx2 = twin0_inx + Fs ;
        assert(twin_inx(1)>t(1) & twin_inx(end)>t(end)); 
        if j==1,
            ERPj = NaN*ones(nevt,length(twin_inx));
            ERPj2 = NaN*ones(nevt,length(twin_inx));
        end
        if isempty(twin0_inx)
            ERPj(j,:) = lfp(twin_inx);    
            ERPj2(j,:) = lfp(twin_inx2);      
        else
            ERPj(j,:) = lfp(twin_inx) - mean(lfp(twin0_inx));    
            ERPj2(j,:) = lfp(twin_inx2)- mean(lfp(twin0_inx2));      
        end
    end
    ERP =  mean(ERPj,1);
    ERP2 = mean(ERPj2,1);
    
end


function twin_inx = time2inx(ts,evttime,twin_sec)
    Fs = 1/diff(ts(1:2));
    [td,tinx] = min(abs(ts - evttime));
    assert(td<1/Fs);
    twin_inx = tinx + twin_sec*Fs; 
    if ~isempty(twin_inx)
        twin_inx = twin_inx(1):twin_inx(end);
    end
end
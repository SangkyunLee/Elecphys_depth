%fix the bug resulted from createTT (new clustering Htt data appended to existing file)

%fn = 'j:\CEREBUS\DataFile\CerebusData\acute\NormLuminance\2011-Oct-21\16-49-39\Sc15.Htt';

%fd = 'j:\CEREBUS\DataFile\CerebusData\acute\NormLuminance\2011-Oct-21\16-49-39\';

fd = 'j:\CEREBUS\DataFile\CerebusData\acute\SquareMappingExperiment\2011-Oct-22';
d = rdir(fullfile(fd,'**\*.Htt'));

diary('c:\work\fixHttAppendError.txt');
diary OFF;

%beforeDate = [2011 10 22 01 01 01];
beforeDate = '2011-Oct-22\01-01-01'; 
beforeDateNum = datenum(beforeDate,'yyyy-mmm-dd\HH-MM-SS'); %skip data before the set date.

for i = 1 : length(d)
    
    try
        
        fn = d(i).name;
        
        [ix1,ix2] = regexp(fn,'\\201\d-\w{3}-\d\d\\');
        if d(i).datenum <= beforeDateNum || datenum(fn(ix1+1:ix1+20),'yyyy-mmm-dd\HH-MM-SS') <= beforeDateNum
            continue;
        end
        
        tt = ah_readTetData(fn,'all'); %.Htt file
        
        fprintf('%d|%d: %s \n',i,length(d),fn);
        
        if isempty(tt); disp('empty Htt file'); continue; end
        %
        tmin = min(tt.t);
        tmax = max(tt.t);
        tlen = tmax(1)-tmin(1);
        %index for turn point
        m = find(diff(tt.t)<0);
        if length(m)<1; disp('no turn point'); continue; end
        %last index
        k = m(end);
        %
        deltaT = tt.t(k+1)-tt.t(k);
        %verify it's a large deflection --- distinguish it from small
        %doubletriggers from data processed with old method.
        if abs(deltaT) < 0.8 * tlen ; disp('small deflection ! no data appended'); continue; end
        
        %remove the portion before appending.
        tt.t(1:k) = [];
        for ii = 1 : length(tt.w)
            tt.w{ii}(:,1:k)=[];
        end
        tt.h(1:k,:)=[];
        
        diary ON;
        fprintf('%d|%d: %s Turns#%d\n',i,length(d),fn, length(m));
        diary OFF;
        
        %write back to Htt file.
        Fs = 30000;
        outFile = fn;
        ah_writeTT_HDF5(outFile, tt, 'samplingRate', Fs, ...
            'version', 2, 'units', 'muV');
        
        clear tt;
        
    catch 
        diary ON;
        %disp('error');
        lasterr
        diary OFF;
    end

end
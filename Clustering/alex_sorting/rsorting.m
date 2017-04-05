%fp = 'c:\Work\Experiment\Data\CerebusData\acute\NormLuminance\2012-Feb-16\17-34-29\cluster\';
%fd = 'e:\CEREBUS\DataFile\CerebusData\acute\NormLuminance\';
% fd = 'f:\Cerebus\DataFile\CerebusData\acute\NormLuminance\';

%sortExp = 'SquareMappingExperiment';
%fd = fullfile('e:\CEREBUS\DataFile\CerebusData\acute\',sortExp);

sortExp = 'NormLuminance';
fd = fullfile('c:\Data\DataFile\CerebusData\acute\',sortExp);

d = rdir(fullfile(fd,'**\model*.mat'));

depthFile = 'e:\CEREBUS\Acute Experiment Excel Log\tetrode_depth.mat';
td = load(depthFile);

%fout = 'e:\sorting.txt'; 
%fp = fopen(fout,'w+');

%beforeDate = [2011 10 22 01 01 01];
beforeDate = '2011-Oct-01\01-01-01'; 
beforeDateNum = datenum(beforeDate,'yyyy-mmm-dd\HH-MM-SS'); %skip data before the set date.

nSU = 0; 
toTagSU = false; 

skipSorted = false; %sort on new data only (no manual sorting done)

depthBased = false; %sort on datasets that listed in depth database

for i = 1 : length(d)
    
    fn = d(i).name;
    if ~isempty(strfind(fn,'modelTT')); continue; end %skip the old modeling files.
    if skipSorted
        if exist(strrep(fn,'model','manual'),'file'); continue; end
    end
    
     [ix1,ix2] = regexp(fn,'\\201\d-\w{3}-\d\d\\');
    if d(i).datenum <= beforeDateNum || datenum(fn(ix1+1:ix1+20),'yyyy-mmm-dd\HH-MM-SS') <= beforeDateNum
        continue;
    end
    
    if depthBased 
        recFound = false;  %only sort datasets listed in depth database.
        for j = 1 : length(td.tetDepth)
            if ~isempty(strfind(fn,td.tetDepth(j).date)&strfind(fn,td.tetDepth(j).time))
                recFound = true;
                break;
            end
        end
        
        if ~recFound ; continue; end
    end
    
    fprintf('%d|%d: %s',i,length(d),fn);
    
    fmanual = strrep(fn,'model','manual'); 
    
    try
        fprintf('\tLoad...');
        load(fn); %load model data
        
    catch err
        err.identifier
        disp('error loading data');        
        continue;
    end
    
    
    %update the model with manual result
    if exist(fmanual,'file')
        model = loadManualResult(model,fmanual); 
    end
    %
    manual=ManualClustering(model);
    %
    if ~isempty(manual)
        saveManualResult(manual,fn);
    end

    fprintf('Done\r\n');
    
    if toTagSU
        [FP,FN]=calContamination(manual);
        SUI = find(FP+FN <= 0.1 & FP+FN > 0);

        nSU = nSU + numel(SUI);

        for j = 1 : numel(SUI)
            manual.ClusterTags.data{SUI(j)} = {'SingleUnit'}; %or DoubleTriggered
        end

        if numel(SUI)>0
            avgFR = sum(manual.ContaminationMatrix.data.n(SUI))/numel(SUI)/3600;
        else
            avgFR = 0;
        end

        fprintf(fp,'%s %d|%d %.3f\n',fn,numel(SUI),numel(FP),avgFR);
    end
    
    %save(strrep(fn,'model','manual'),'manual');
    
    %count the single units by statistic
    %pause;
    clear manual;
    clear model;
end

if exist('fp','var')
    fclose(fp);
end


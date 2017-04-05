function refinecluster(fd)
%fp = 'c:\Work\Experiment\Data\CerebusData\acute\NormLuminance\2012-Feb-16\17-34-29\cluster\';
%fd = 'e:\CEREBUS\DataFile\CerebusData\acute\NormLuminance\';
% fd = 'f:\Cerebus\DataFile\CerebusData\acute\NormLuminance\';
%fd = 'h:\CEREBUS\DataFile\CerebusData\acute\SquareMappingExperiment\';
if nargin < 1
    fd = 'h:\CEREBUS\DataFile\CerebusData\acute\NormLuminance\';
end

%fd = 'e:\CEREBUS\DataFile\CerebusData\acute\FlashingBar\';
d = rdir(fullfile(fd,'**\model*.mat'));
overwrite = true;

fout = 'c:\sorting.txt'; 
%fp = fopen(fout,'w+');

%beforeDate = [2011 10 22 01 01 01];
beforeDate = '2011-Oct-01\01-01-01'; 
beforeDateNum = datenum(beforeDate,'yyyy-mmm-dd\HH-MM-SS'); %skip data before the set date.

nSU = 0; 
toTagSU = false; 

ttSelect = [8];
%ttSelect = [7 8 10 14 15 17];

for i = 1 : length(d)
    
    fn = d(i).name;
    if ~isempty(strfind(fn,'modelTT')); continue; end %skip the old modeling files.
    if ~overwrite 
        if exist(strrep(fn,'model','manual'),'file'); continue; end
    end
    
    %only process the first 
    
     [ix1,ix2] = regexp(fn,'\\201\d-\w{3}-\d\d\\');
    if d(i).datenum <= beforeDateNum || datenum(fn(ix1+1:ix1+20),'yyyy-mmm-dd\HH-MM-SS') <= beforeDateNum
        continue;
    end
    
    if isempty(strfind(fn,'-Oct-')); continue; end
    
    fprintf('%d|%d: %s\n',i,length(d),fn);
    
    ii = strfind(fn,'model');
    jj = strfind(fn,'.mat');
    
    ttNo = str2double(fn(ii+5:jj-1));
    
    if ~any(ttNo == ttSelect); continue; end
    
    fmanual = strrep(fn,'model','manual'); 
    
    try
        fprintf('\tLoad...');
        load(fn); %load model data
        load(fmanual); %load manual data
    catch err
        err.identifier
        disp('error loading data');        
        continue;
    end
    
    %update the model with manual result
    
%     saveFields = fieldnames(manual);
%     for j = 1 : length(saveFields)
%         model.(saveFields{j}) = manual.(saveFields{j});
%     end
    
    %update the model with manual result
    model = loadManualResult(model,fmanual); 
    %
    try 
        manual=ManualClustering(model);
    catch err
        err.identifier
        disp('error loading GUI');        
        continue;
    end
        
    %
    if ~isempty(manual)
        saveManualResult(manual,fn);
    end

    fprintf('Done\r\n');
    
    if toTagSU
        [FP,FN]=calContamination(manual);
        SUI = find(FP+FN < 0.05 & FP+FN > 0);

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

%i = 3; fn = sprintf('%smodel%d.mat',fp,i);
%fprintf('model%d.mat\n',i);
%load(fn);
% manual=ManualClustering(model);
% if ~isempty(manual)
%     saveManualResult(manual,fn);
% end

%     hfig = findobj(0,'Name','ManualClustering');
%     hObject = findobj(hfig,'Tag','opAccept');
%     callbackFun = get(hObject,'Callback');
%     ManualClustering('opAccept_Callback',hObject,[],hfig);

%fp = 'c:\Work\Experiment\Data\CerebusData\acute\NormLuminance\2012-Feb-16\17-34-29\cluster\';
fd = 'h:\CEREBUS\DataFile\CerebusData\acute\NormLuminance\';
%fd = 'e:\CEREBUS\DataFile\CerebusData\acute\FlashingBar\';
d = rdir(fullfile(fd,'**\manual*.mat'));
%overwrite = true;

fout = sprintf('c:\\work\\sorting_disk_%s_%s.txt', fd(1),datestr(now,'dd-mmm-yyyy_HH-MM-SS')); 
fp = fopen(fout,'w+');

fprintf(fp,'root: %s\r\n',fd);

nSU = 0; 
nClustered = 0; 
%toTagSU = false; 

for i = 1 : 24;
  tet(i).nSU = [];
  tet(i).nTOT = [];
  tet(i).avgFR = [];
  tet(i).Filename = {};
end

for i = 1 : length(d)
    fn = d(i).name;
    
    fprintf('%d|%d: %s\r\n',i,length(d),fn);
    
    try
        load(fn); %load manual data
     catch err
        err.identifier
        disp('error loading data');        
        continue;
    end
    
    m = strfind(fn,'manual');
    tetID = str2num(fn(m+6:end-4));

        [FP,FN]=calContamination(manual);
        SUI = find(FP+FN < 0.05 & FP+FN > 0);

        nSU = nSU + numel(SUI); %single unit
        nClustered = nClustered + numel(FP); %auto-clustered units. 

%         for j = 1 : numel(SUI)
%             manual.ClusterTags.data{SUI(j)} = {'SingleUnit'}; %or DoubleTriggered
%         end

        if numel(SUI)>0
            avgFR = sum(manual.ContaminationMatrix.data.n(SUI))/numel(SUI)/3600;
        else
            avgFR = 0;
        end

        fprintf(fp,'%s %d|%d %.3f\n',fn(length(fd):end-4),numel(SUI),numel(FP),avgFR);
    
        tet(tetID).nSU(end+1)  = numel(SUI);
        tet(tetID).nTOT(end+1) = numel(FP);
        tet(tetID).avgFR(end+1) = avgFR;
        tet(tetID).Filename{end+1} = fn;
    
    %save(strrep(fn,'model','manual'),'manual');
    
    %count the single units by statistic
    %pause;
    clear manual;
    %clear model;
end

fprintf(fp,'total SU %d | %d \r\n', nSU , nClustered);

if exist('fp','var')
    fclose(fp);
end

fmat = strrep(fout,'.txt','.mat');
save(fmat);

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

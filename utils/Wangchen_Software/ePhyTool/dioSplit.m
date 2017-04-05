%function dioSplit
%split the 16-bit digital values into events for each channel (bit).
%1. load the blackrock nev file into neuroexploer. 
%2. run this script in matlab.
%3. get matlab variables for the post-processed events in Neuroexplorer.

useNEX = true; %set false if digin data already loaded in matlab.
useIndex = false; %specify doc index or get the active document
nexDocIdx = 1; %1-based document index

diginName = 'digin_DIO_'; %name preceding the digital number
DIOMAX = 2^16;
%variable name to send back to nex.
diginNameAfterSplit = 'DIOChan';

if useNEX
    %open nex interface or connect to the running instance of Nex.
    try
        nex = actxserver('NeuroExplorer.Application');
    catch
        nex = [];
        fprintf('Error::NeuroExploer\n');
        lasterr;
    end
    if useIndex 
        nexDoc = get(nex,'Document',nexDocIdx);
    else
        nexDoc = get(nex,'ActiveDocument');
    end
    %show the file to be processed.
    fprintf('File -> %s\n', nexDoc.get('Path'));
    
    nexEventCount = nexDoc.EventCount;
    nexEventNames = cell(1,nexEventCount);
    nexEventIndex = zeros(1,nexEventCount);
    %nexEventCount = 1;
    k = 1;
    for i = 1 : nexEventCount
        if ~isempty(findstr(nexDoc.Event(i).name,diginName))
            nexEventNames{k} = nexDoc.Event(i).name;
            nexEventIndex(k) = i;
            k = k + 1;
        end
    end
    
    diginVars = nexEventNames;
    diginVars(cellfun(@isempty,diginVars))=[]; %keep the digin variables only

else
    diginVars = who([diginName,'*']); %digin data imported from nex already
   
end

diginValue = zeros(1,length(diginVars));
diginChan = cell(1,length(diginVars));
diginChanState = cell(1,length(diginVars));

nChanOnDuty = 0;
iChanOnDuty = []; % indice of channels on duty

for i = 1 : length(diginVars)
    s = regexp(diginVars{i},diginName,'split');
    diginValue(i) = DIOMAX - str2num(s{2});
    diginChan{i} = dec2bin(diginValue(i));
    diginChanState{i} = (diginChan{i}=='1');
    diginChanState{i} = diginChanState{i}(end:-1:1);
    iChanOnDuty = [iChanOnDuty find(diginChanState{i}==1)];
    %nChanOnDuty = max(length(diginChanState{i}),nChanOnDuty); 
end

iChanOnDuty = sort(unique(iChanOnDuty)); %list of active channels
nChanOnDuty = length(iChanOnDuty);
dioChanData = cell(nChanOnDuty,1); %activity on each channel
%assign timestamps to each channel
for i = 1 : length(diginVars)
    for j = 1 : length(diginChanState{i})
        if (diginChanState{i}(j))
            if useNEX
                value = nexDoc.Event(nexEventIndex(i)).Timestamps;
            else
                value = eval(diginVars{i});
            end
            if size(value,2)>1; value = value'; end
            dioChanData{j} = [dioChanData{j}; value];
        end
    end
end

%sort the timestamps and remove the duplicates
for i = 1 : nChanOnDuty
    if ~isempty(dioChanData{i})
        %
        dioChanData{i} = sort(unique(dioChanData{i}));
    end
end

%display the activity on each channel
f1 = figure('name','DIO Channel Event');
rasterplot(dioChanData,f1);
if useNEX
    title(nexDoc.get('FileName'));
    set(f1,'name',[get(f1,'name'),'-',nexDoc.get('FileName')]);
end

%clear the names for post-processed variables 
clear([diginNameAfterSplit,'*']);

%generate variables with specified prefix and channel id.
for i = 1 : nChanOnDuty
    cmd = sprintf('%s_%d = %s;',diginNameAfterSplit,iChanOnDuty(i),'dioChanData{i}');
    eval(cmd);
    %eval([diginNameAfterSplit,'_',iChanOnDuty(i),' = dioChanData{i};']);
end

%send the sorted channels back to nex? - not implemented by NEX.  
if useNEX
    %
end














    
    


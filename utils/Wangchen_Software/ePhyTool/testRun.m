useNEX = true; %set false if digin data already loaded in matlab.
useIndex = false; %specify doc index or get the active document
nexDocIdx = 1; %1-based document index

diginName = 'flashEvent'; %name preceding the digital number
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

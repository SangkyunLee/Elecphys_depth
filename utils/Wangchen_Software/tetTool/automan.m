function automan(fod,optLoadSorted,optSaveSorted,optSaveDisp)
% automate the manualclustering for two tasks 
%    1) generate the mua data, i.e, the manual.mat files. 
%    2) save the clustering display into picture.
% fod         : file name or directory. in case of directory, all files will be processed recursivly. 
% optLoadSorted : flag to load manual data and model data. 'false' loads the model data only.
% optSaveSorted : flag to save the output from gui as manual data
% optSaveDisp   : flag to save display to picture
% automan(file,0,1,...) load model and save manual.
% automan(file,1,0,...) load model&manual for display without saving.
% automan(file,0,0,0) default.

% diary('c:\work\error.txt');
diary OFF;

if nargin < 2
    optLoadSorted = false;
    optSaveSorted = false;
    optSaveDisp = false;
end

if nargin < 3
    optSaveSorted = false;
    optSaveDisp = false; 
end

if nargin < 4
    optSaveDisp = false;
end

if exist(fod) == 7
    files = rdir(fullfile(fod,['**' filesep 'model*.mat']));
elseif exist(fod) == 2 && ~isempty(strfind(fod,'model'))
    files = rdir(fod);  %return the struct 
else
    fprintf('no files found\n');
    return;
end

%in autoact mode, the button action is auto-executed and figure remains open afterwards. 
for i = 1 : length(files)
    modelfile = files(i).name;
    fprintf('%d|%d) %s\n', i, length(files),modelfile);
    clear model manual
    try 
        load(modelfile);
    catch
        diary ON;
        lasterr
        diary OFF;
        continue;
    end
    %load the existing manual files
    if optLoadSorted
        model = loadman2mod(model,strrep(modelfile,'model','manual'));
    end
    %
    if optSaveSorted
        autoact = 'Accept';
    else
        autoact = 'Skip';
    end
    
    manual = ManualClustering(model,modelfile,autoact);
    %find the handle to the window
    h = findobj(findall(0,'Type','Figure'),'Tag','figure1');
    if isempty(strfind(get(h,'Name'),'ManualClustering'))
        error('handle not found');
    end
    
    if optSaveDisp
        %save the display window
        savefig(h,strrep(modelfile,'.mat','.png'));
    end
    
    if optSaveSorted && ~isempty(manual)
        %save the clustering info in manual result
        savemanout(manual,strrep(modelfile,'model','manual'));
    end
    
    %close the figure manually if autoact is enabled. 
    if ~isempty(h) && ishandle(h); delete(h); end
    
end
 
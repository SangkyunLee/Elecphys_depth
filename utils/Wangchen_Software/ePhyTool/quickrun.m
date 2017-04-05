%main_acute; mainRate2; plotRateFigs([],neurons,s,t_SETS,s.nevFolder);

%load MD5 struct on J in workspace
%errIdxOnJ; 

% TotalSize = 0;
% for i = 1 : length(errIdxOnJ)
%     m = errIdxOnJ(i);
%     info = dir(M(m).Filename);
%     TotalSize = TotalSize + info.bytes;
% end
% 
% fprintf('total size = %.1f MB \n', TotalSize/1e6);

%copy the 'right' files from G to other disks.

%load MD5 structs.

file_ref = 'c:\Work\MD5_CerebusData\checkMD5Result_SS-STIM01_Disk_K.mat';
file_H = 'c:\Work\MD5_CerebusData\checkMD5Result_KLUSTER_Disk_H.mat';
file_J = 'c:\Work\MD5_CerebusData\checkMD5Result_KLUSTER_Disk_J.mat';

Mref = load(file_ref); Mref = Mref.MD5Result;
MH = load(file_H);     MH = MH.MD5Result;
MJ = load(file_J);     MJ = MJ.MD5Result;

%creat a log file
% % flog = 'c:\work\MD5_RAID_Source.txt'; 
% % fp = fopen(flog,'w+');
% % for i = 1 : length(Mref)
% %     fprintf(fp,'%d %s\t%s\n', i, Mref(i).Filename,Mref(i).MD5);
% % end
% % fclose(fp);

%find error index
I = compareMD5(MH,Mref);
errOnH = find(I==0);
I = compareMD5(MJ,Mref);
errOnJ = find(I==0);

%return;
errOnDisk = {errOnH,errOnJ};
MD5OnDisk = {MH, MJ};

for k = 1 : length(errOnDisk)
    
    errIndex = errOnDisk{k};
    M = MD5OnDisk{k};
    
    for i = 1 : length(errIndex)
        %test
        %if i > 1 ; continue; end
        %
        m = errIndex(i);
        desFile = M(m).Filename;
        sourceFile = desFile;
        sourceFile(1) = 'G';
        if ~exist(sourceFile,'file');
            fprintf('Not exist %s\n', sourceFile);
        end
        
        if ~exist(fileparts(desFile),'dir')
            mkdir(fileparts(desFile));
        end
        fprintf('%d)%s --> %s\n', i,sourceFile,desFile);
        copyfile(sourceFile,desFile,'f');
    end
    
end

%check write

for k = 1 : length(errOnDisk)
    
    errIndex = errOnDisk{k};
    M = MD5OnDisk{k};
    
    clear MD5Result;
    
    for i = 1 : length(errIndex)
        %test
        %if i > 1 ; continue; end
        %
        m = errIndex(i);
        desFile = M(m).Filename;
        [MD5,TYPE,SIZE] = MD5Checker(desFile);
        MD5Result(i).Filename = desFile;
        MD5Result(i).MD5 = MD5;
        MD5Result(i).TYPE = TYPE;
        MD5Result(i).SIZE = SIZE;
    end
    checkM{k} = MD5Result;
end

for k = 1 : length(errOnDisk)
    I = compareMD5(checkM{k},Mref);
end

%copy files (error on J) to disk c

errIndex = errOnJ;
M = MJ;
%copy file index
totalSize = 0;

p = [23,54]; %94 [1,15] flashing bar. [23,54] normgrating. [62,87] normluminance.

for i = p(1) : p(2)
    %test
    %if i > 1 ; continue; end
    %
    m = errIndex(i);
    desFile = M(m).Filename;
    %skip
    if ~isempty(strfind(desFile,'-Aug-')) || ~isempty(strfind(desFile,'_SpontaneousActivity')) || ~isempty(strfind(desFile,'GratingExperiment')) ; continue; end
    if ~isempty(strfind(desFile,'Nov-01')) || ~isempty(strfind(desFile,'.nev')) ; continue; end
    
    desFile(1) = 'G';
    sourceFile = desFile;
    sourceFile(1) = 'J';
    if ~exist(sourceFile,'file');
        fprintf('Not exist %s\n', sourceFile);
    end
    
    if ~exist(fileparts(desFile),'dir')
        mkdir(fileparts(desFile));
    end
    fprintf('%d)%s --> %s\n', i,sourceFile,desFile);
    
    info = dir(sourceFile);
    totalSize = totalSize + info.bytes;
    copyfile(sourceFile,desFile,'f');
end

fprintf('total size %.1f Gb \n', totalSize/1e9);


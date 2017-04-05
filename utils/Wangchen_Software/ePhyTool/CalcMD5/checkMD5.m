function MD5Result = checkMD5(rootdir,fileType)
%check the data file copying error
%

if nargin < 2
    fileType = {'*.nev','*.ns5'}; %or '.ns5'; 
end

if ~iscell(fileType) && ischar(fileType)
    fileType = { fileType };
end

%fileType = {'mat','nex'}; %or '.ns5'; 
%
%rootdir = 'J:\CEREBUS\DataFile\CerebusData\acute'; 
%rootdir = 'G:\CEREBUS\DataFile\StimulationData\acute'; 

if strcmpi(rootdir(1),'c')
    outfile = fullfile(rootdir(1:2),'Work',sprintf('checkMD5Result.mat'));
else
    outfile = fullfile(rootdir(1:2),sprintf('checkMD5Result.mat'));
end
%
clear fileSets;
clear MD5Result;

%resume option to deal with out-of-memory problem that occur after long execuation time.
resumeCheck = false; %make sure outfile points to the one left off from previous run.

if resumeCheck && exist(outfile,'file') && strfind(outfile,'checkMD5Result')
    load(outfile);
    m = length(MD5Result);
    fprintf('Resume from %d records in %s\n',m,outfile);
else
    m = 0;
end

for i = 1 : length(fileType)
    fileSets{i} = rdir(fullfile(rootdir,['**\',fileType{i}]));
end

%number of data file type 
nSets = length(fileSets);
%total data files
nTotalFile = 0;
for i = 1 : length(fileSets)
    nTotalFile = nTotalFile + length(fileSets{i});
end

%m = 0 ;
for i = 1 : length(fileSets)
    nFiles = length(fileSets{i});
    for j = 1 : nFiles
        m = m + 1 ; 
        fprintf('%d|%d,%d|%d: ---> %s \n',i,nSets,j,nFiles,fileSets{i}(j).name);
        MD5Result(m).Filename = fileSets{i}(j).name;
        [MD5,TYPE,SIZE] = MD5Checker(MD5Result(m).Filename);
        MD5Result(m).MD5 = MD5;
        MD5Result(m).TYPE = TYPE;
        MD5Result(m).SIZE = SIZE;
    end
end

if ~exist(fileparts(outfile),'dir')
    mkdir(fileparts(outfile));
end

save(outfile,'MD5Result');

%save a copy if done.
outfile_spec = fullfile(fileparts(outfile),sprintf('checkMD5Result_%s_Disk_%s.mat',getenv('computername'),rootdir(1)));
if length(MD5Result) == nTotalFile
    save(outfile_spec,'MD5Result');
end





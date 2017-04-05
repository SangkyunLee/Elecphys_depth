function cleanFiles(d)
%reorganize the sorted nev files 
%1. create sort folder
%2. delete old nev files and keep the orignal and last sorted one only.
%3. rename the last file and move to sort folder

ext = 'nev';
files = rdir(fullfile(d,['**\*.',ext]));

fprintf('copy %d|%d ...\n',i, length(d));
    datafile = d(i).name;
    [fdir,fname] = fileparts(datafile);
    tdir = fdir;
    tdir(1) = targetdir(1); 
    if ~exist(tdir,'dir'); mkdir(tdir); end
    copyfile(datafile,fullfile(tdir,[fname,'.',ext]));
    
folders = {};
foldernum = zeros(1,length(files));
j = 0;

for i = 1 : length(files)
    datafile = files(i).name;
    [fdir,fname] = fileparts(datafile);
end
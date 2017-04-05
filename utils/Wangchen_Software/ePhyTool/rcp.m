function rcp(rootdir,targetdir,ext)
%copy files . 
%rootdir : source direcotry. all files including subfolders will be processed
%eg: rcp('c:\abc\','d:\','.png')
%target directory concretate the source directory name 'abc' and
%target dir 'd:\'.



if strcmp(ext(1),'.'); ext(1)=[]; end
%search the 'target' files to locate the data subfolders.
% d = rdir(fullfile(rootdir,'**\*.ns5'));
d = rdir(fullfile(rootdir,['**\*.',ext]));
%
for i = 1 : length(d)
    fprintf('copy %d|%d ...\n',i, length(d));
    datafile = d(i).name;
    [fdir,fname] = fileparts(datafile);
    tdir = fdir;
    tdir(1) = targetdir(1); 
    if ~exist(tdir,'dir'); mkdir(tdir); end
    copyfile(datafile,fullfile(tdir,[fname,'.',ext]));
end
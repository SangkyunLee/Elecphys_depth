function rfinderr(rootdir)
%search the 'target' files to locate the data subfolders.

%
targetFile = 'Sc*.*';
d = rdir(fullfile(rootdir,sprintf('**\\%s',targetFile)));
%
fprintf('%d \n', length(d));

ec = 0 ; 

for i = 1 : length(d)
    fileName = d(i).name;  
    
    [fpath,fname,fext] = fileparts(fileName);
    
    if ~strcmp(fext,'.Htt')
        ec = ec + 1; 
        fprintf('%d: [%d]/%d : %s ... \n',ec,i,length(d),fileName);
    end
    
    
end

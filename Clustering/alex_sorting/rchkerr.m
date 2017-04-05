function rchkerr(rootdir,beforeDate)
%run the tetrode data clustering recursively
%beforeDate : process the folders before that date. format: [Y M D], e.g [2012 10 23]
%
if nargin < 2
    beforeDate = [2001 08 30];
end

beforeDateNum = datenum(beforeDate);

%search the ns5 files in subfolders under rootdir.
s = fullfile(rootdir,'**\*.Htt*');
%
d = rdir(s);
%
counter = 0; 

for i = 1 : length(d)
    f = d(i).name;
    %check ext with error tag, e.g,'err*' 
    [fp,fn,fext] = fileparts(f);
    %fprintf('Process File %d/%d\n', i, length(d));
    %disp(f);
    if length(fext)>4 % other than .Htt
        counter = counter + 1; 
        fprintf('%d:[%d|%d]: %s\n\t\t%s\t%.1f Kb\n',counter,i,length(d),fp,[fn,fext],d(i).bytes/1e3);
    end
end

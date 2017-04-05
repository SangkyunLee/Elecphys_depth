function [MD5,TYPE,SIZE] = MD5Checker(file)
%check the nev/nsx data integrity by MD5. 
%file: 
%MD5 : 
%TYPE: = 1/0 (real MD5 of raw input or 'pseudo' type)  
%CalcMD5 handles up to 2.1G. For oversized file (*.ns5),
%the data chunks are read and the md5 strings are concatated.
%the final MD5 will return as the md5 of the concated string.
%SIZE: =0 for raw file. or =chunk size for pseudo type.
%[fpath,fname,fext] = fileparts(file);

info = dir(file);
%file size
fsize = info.bytes/10^9 ; %in GB

%chunk size
M = 200*1e6;
nc = ceil(info.bytes/M); %number of chunks to read
string = char(1,32*nc);
%data = zeros(1,M,'uint8');

if fsize < 2.1
    TYPE = 1;
    SIZE = 0;
    MD5 = CalcMD5(file,'File');
else
    %pseudo MD5
    TYPE = 0;
    SIZE = M;
    %
    fid = fopen(file);
    for i = 1 : nc
        fprintf('Reading : %d%% of %.1fGB...\n',round(i/nc*100),fsize);
        data = fread(fid,M,'*uint8');
        string(1 + (i-1)*32 : i*32) = CalcMD5(data,'CHAR');
    end
        
    MD5 = CalcMD5(string,'CHAR');
    
    fclose(fid);
    
end

    
        
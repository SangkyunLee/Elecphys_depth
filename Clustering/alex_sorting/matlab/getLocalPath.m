function p = getLocalPath(p,os)
% Converts path names to local operating system format using lab conventions.
%
%    localPath = getLocalPath(inputPath) converts inputPath to local OS format 
%    using lab conventions. The following paths are converted:
%   
%       input       Linux            Windows      Mac
%       /lab        /mnt/lab         Z:\          /Volumes/lab
%       /stor01     /mnt/stor01      Y:\          /Volumes/stor01
%       /stor02     /mnt/stor02      X:\          /Volumes/stor02
%       /scratch01  /mnt/scratch01   V:\          /Volumes/scratch01
%       /stimulation  /mnt/stor01/stimulation   Y:\stor01\stimulation       /Volumes/stor01/stimulation
%
%    localPath = getLocalPath(inputPath,OS) will return the path in the format
%    of the operating system specified in OS ('global' | 'linux' |'win' | 'mac')
%
% AE 2011-04-01

return; %for local use.-WW

% determine operating system;
if nargin < 2
    os = computer;
end
os = lower(os(1:min(3,length(os))));

% convert file separators if necessary
p = strrep(p,'\','/');

% a few fixes for outdated paths
p = strrep(p,'/stor01/hammer','/at_scratch/hammer');
p = strrep(p,'/stor02/hammer','/at_scratch/hammer');
p = strrep(p,'hammer/ben','hammer/Ben');

% mapping table
mapping = {'/stimulation','/mnt/stor01/stimulation','Y:/stimulation','/Volumes/stor01/stimulation'; ...
           '/processed','/mnt/stor01/processed','Y:/processed','/Volumes/stor01/processed'; ...
           '/lab/users/alex','/mnt/lab','Z:','/lab'; ...
           '/lab','/mnt/lab','Z:','/lab'; ...
           '/stor01','/mnt/stor01','Y:','/Volumes/stor01'; ...
           '/stor02','/mnt/stor02','X:','/Volumes/stor01'; ...
           '/scratch01','/mnt/scratch01','V:','/Volumes/stor01'; ...
           '/at_scratch','/mnt/at_scratch','W:','/Volumes/at_scratch'; ...
           '/raw','/mnt/at_scratch','W','/Volumes/at_scratch'; ...
           };
       
% local os' column
switch os
    case 'glo'
        local = 1;
    case {'lin','gln'}
        local = 2;
    case {'win','pcw'}
        local = 3;
    case 'mac'
        local = 4;
    otherwise
        error('unknown OS');
end

% convert path
sz = size(mapping);
for i = 1:sz(1)
    for j = 1:sz(2)
        n = length(mapping{i,j});
        if j ~= local && strncmpi(p,mapping{i,j},n)
            p = fullfile(mapping{i,local},p(n+2:end));
            break;
        end
    end
end

if filesep == '\' && ~isequal(os,'glo')
    p = strrep(p,'/','\');
else
    p = strrep(p,'\','/');
end


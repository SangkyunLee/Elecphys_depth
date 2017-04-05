function copyf(a,b)
% Copies file a to b
%   WHY? On Unix, Matlab's copyfile defaults to 'cp -p'.
%   Timestamp preservation is only possible when the current
%   user is the file owner; group write and read permissions don't suffice and
%   result in the function failing.
%   This replacement calls copyfile under Windows and cp under Unix
%   to work around this issue.
%
% Code by AH
% Created here by AE 2008-01-25

if isunix
    system( sprintf('%s %s %s', 'cp', a, b) );
else
    copyfile(a,b)
end


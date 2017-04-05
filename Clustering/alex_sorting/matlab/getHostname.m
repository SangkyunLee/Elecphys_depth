function hostname = getHostname()
% Returns hostname without domain etc.
% AE 2009-07-22

[foo hostname] = system('hostname');
hostname = strtrim(hostname);

% try to identify known host
known = {'at-s1no1','at-s1no2','at-s1stim1', ...
         'at-s2no1','at-s2no2','at-s2stim1', ...
         'at-s3no1','at-s3no2','at-s3stim1', ...
         'at-s4no1','at-s4no2','at-s4stim1', ...
         'at-compute001'};
match = cellfun(@(x) ~isempty(strfind(hostname,x)),known);
if sum(match) == 1
    hostname = known{match};
    return
end

% get rid of domain
ndx = strfind(hostname,'.');
if ~isempty(ndx)
    hostname = hostname(1:ndx(1)-1);
end





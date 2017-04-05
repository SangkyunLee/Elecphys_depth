function folder = parseFolder(fpath)
%parse the path to the data into folder structure
%s : data path
%
folder = struct('base',[],'subject',[],'exp',[],'date',[],'time',[],'etc',[]);

%s = {matFolder,nexFolder,nevFolder};
if ~iscell(fpath)
    s = {fpath}; %string input
else
    s = fpath; %cell array of path names.
end

try
    for i = 1 : length(s)
        parts = regexp(s{i},'\\','split');
        pes = parts{end};
        lastpart = length(parts);
        %check the length of chars '=8' and first char numeric for 'time'
        if length(pes)==8 && ~isempty(str2num(pes(1))) ...
                && ~isempty(str2num(pes(end))) && strmatch(pes(3),'-')
            %no subfoler for 'etc'
            folder(i).etc = [];
        else
            folder(i).etc = pes;
            lastpart = lastpart -1;
        end
        folder(i).time = parts{lastpart};
        folder(i).date = parts{lastpart-1};
        folder(i).exp  = parts{lastpart-2};
        folder(i).subject = parts{lastpart-3};
        %base
        for j = 1 : (lastpart - 4)
            if j == 1 ; folder(i).base = parts{j}; continue; end
            folder(i).base = [folder(i).base,'\',parts{j}];
        end
    end
catch
    disp('Data Path not parsed');
end
function [cmap,leadSpacing] = getChannelMapFile(s,opt)
%get the channel map file for the given data file.
%s : folder struct or path name of data file
%opt : check option. 
%    : 'part' --- partial check on date consistency only
%    : 'full' ---  defaults to full check on both date and time.

if nargin < 2
    opt = 'full';
end

% fd = 'c:\work\experiment\latest\new\ePhyTool\';
fd = fileparts(mfilename('fullpath'));
%automate the selection of the channel map file
cmapFiles{1} = 'Tetrode_96ch_4C.cmp';
cmapFiles{2} = '32ch double-headstage map.CMP';
cmapFiles{3} = '32ch-EDGE double-headstage map.CMP';
%
file_base_name = 'depthDateBase_template_FR_DEC_17_2012.txt'; 
%
file_base = fullfile(fd,file_base_name);

%find the probe type for the given experiment.
[fb_path,fb_name,fb_ext] = fileparts(file_base);
if strcmpi(fb_ext,'.xls')
    b = xlsread(file_base);
else
    b = textread(file_base,'%f','commentstyle','matlab');
    b = reshape(b,10,[]); b = b';
end

if isstruct(s)  %folder struct
    experiment_date = [s.date,'\',s.time];
else
    experiment_date = regexp(s,'201\d-\w{3}-\d\d\\\d{2}-\d{2}-\d{2}','match');
end

try
    expdatevec = datevec(experiment_date,'yyyy-mmm-dd\HH-MM-SS');
catch
    expdatevec = datevec(experiment_date,'yyyy-mmm-dd\HH-MM-SS');
end

%
p = -Inf;
leadSpacing = 0; %probe spacing 
found = false; 

for i = 1 : size(b,1)
    r = b(i,1:6);
    dvdiff = expdatevec - r ;
    switch opt
        case 'part'
            if all(dvdiff(1:3)==0) 
                found = true;
            end
        case 'full'
            if all(dvdiff==0)
                found = true;
            end
    end
    
    if found 
        p = b(i,7);
        leadSpacing = b(i,8);
        break;
    end
end

switch p
    case 1
        %standard probe
        m = 2;
    case 0
        %edge probe
        m = 3;
    case 2
        m = 1; %tetrode
    otherwise
        disp('experiment not found');
        m = [];
end

if isempty(m); cmap = []; return ; end

file_map = fullfile(fd,cmapFiles{m});
%
%convert to 5-column format for NPMK cmap class function.
cmapFile  = ccmap(file_map);
%return the map
cmap = readCerebusMap(cmapFile);


        
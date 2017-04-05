function Info = get_seslist(depthDB, expID,exptype)
% function Info = get_seslist(depthDB, expID,exptype)
% 2017-04-04 sangkyun Lee
%
% if isempty(depthDB)
%     depthDB = 'W:\data\Wangchen\Acute Experiment Excel Log\tetrode_depth.mat';
%     fprintf('DEPTH DATABASE: %s file loaded.\n',depthDB);
% end
% exptype ='FlashingBar'
% expID : 1 : oct-2011. 2 : Feb-2012  3: Nov-2012

if isempty(depthDB)
    depthDB = 'W:\data\Wangchen\Acute Experiment Excel Log\tetrode_depth.mat';
    fprintf('DEPTH DATABASE: %s file loaded.\n',depthDB);
end
load(depthDB); 

switch expID
    case 1
        expToken = 'Oct';
    case 2
        expToken = 'Feb';
    case 3
        expToken = 'Nov';
end
fdnames = fieldnames(tetDepth(1));
Info = [];
for i =1 :length(fdnames)
   Info.(fdnames{i})=[];
end
Info = repmat(Info,[1000 1]);

%find the flashingbar experiments in records
k = 0;
for i = 1 : length(tetDepth)
    if strcmp(tetDepth(i).exp,exptype) && ~isempty(strfind(tetDepth(i).date,expToken))
        k = k + 1;
        Info(k) = tetDepth(i);        
    end
end
Info = Info(1:k,:);


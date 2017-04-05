function D = getTetrodeDepth(tetDepth,eid,expName,tid)
%return the depth of given tetrode from given session/experiment. 
%tetDepth:  tetrode depth variable
%tid : tetrode index array, N
%expName : experiment name : ('FlashingBar' has 1 less recording than others)
%eid : exp id. 1 = oct 2011, 2= Feb 2012, 3=Nov 2012
%D   : depth matrix MxN, N is number of tetrode, M is the number of depth recorded for given experiment 
% org written 2013-09-09 wangchen wang
% I debuged 2017-03-22 sangkyun lee

switch eid
    case 1
        expDateToken = 'Oct';
    case 2
        expDateToken = 'Feb';
    case 3
        expDateToken = 'Nov';
end

D = NaN*ones(100,24);
k = 0; 
for i = 1 : length(tetDepth)
    if strcmpi(tetDepth(i).exp,expName) && ~isempty(strfind(tetDepth(i).date,expDateToken))
        k = k + 1;
        D(k,:) = tetDepth(i).depth;
    end
end

D = D(1:k,tid);



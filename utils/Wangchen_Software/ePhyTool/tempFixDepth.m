%fix the incorrect assignment of '-1' to depth in tetDepth variable.
%(the depth at which tetrode is recording multiple times are incorrectly marked with -1).
depthFile = 'e:\CEREBUS\Acute Experiment Excel Log\tetrode_depth.mat';
load(depthFile); 

expID = 2;

switch expID
    case 1
        expToken = 'Oct';
    case 2
        expToken = 'Feb';
    case 3
        expToken = 'Nov';
end

expName = 'FlashingBar';

k = 0;
clear F;
%find the flashingbar experiments
for i = 1 : length(tetDepth)
    if strcmp(tetDepth(i).exp,expName) && ~isempty(strfind(tetDepth(i).date,expToken))
        k = k + 1;
        F(k) = tetDepth(i);
    end
end


%set the session/exp indices
for i = 1:length(tetDepth);
    if i <= 71
        m = i;
    else
        m = i + 1;
    end
    if mod(m,4) == 0
        sessionIDS(i) = m/4;
    else
        sessionIDS(i) = fix(m/4) + 1;
    end
end

for i = 1 : length(tetDepth)
    switch tetDepth(i).date(6:8)
        case 'Oct'
            tetDepth(i).expID = 1;
        case 'Feb'
            tetDepth(i).expID = 2;
        case 'Nov'
            tetDepth(i).expID = 3;
    end
    tetDepth(i).sessionID = sessionIDS(i);
   
end

for i = 1 : length(tetDepth)

    switch tetDepth(i).expID 
        case 1
            dID = 0;
        case 2
            dID = 9;
        case 3
            dID = 18;
    end
    tetDepth(i).sessionID = tetDepth(i).sessionID-dID;
   
end

%recording sessions : 9 + 8 + 12.
%Manual Fix: 
%Oct-2011: tt22: set 4th~9th to 3rd depth = 569um. 10th in whitematter. 11th out.

%Feb-2012: tt5 : set 5th/6th to 520um(4th), 7th/8th/9th to 860um(6th).
%          tt23: set 7th/8th = 1040. 


for i = 1 : length(tetDepth)
    if tetDepth(i).expID == 1 && any(tetDepth(i).sessionID == [4:9])
        tetDepth(i).depth(22) = 569;
    end
    
    if tetDepth(i).expID == 2 && any(tetDepth(i).sessionID == [5:6])
        tetDepth(i).depth(5) = 520;
    end
    
    if tetDepth(i).expID == 2 && any(tetDepth(i).sessionID == [7:9])
        tetDepth(i).depth(5) = 860;
    end
    
    if tetDepth(i).expID == 2 && any(tetDepth(i).sessionID == [7:8])
        tetDepth(i).depth(23) = 1040;
    end
    
    
   
end


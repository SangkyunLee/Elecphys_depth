function u = chopper(n,badpts)
%chop the stim-event into uniform spaced segments with break points from badpts 
%input : 
%    n : length of stim-event vector
% badpts: irregular points's upper indices returned from regISI.
%output: 
%    u : nx2 vector. the start/end indice of chopped segment are in column.
%

%segments number
ns = length(badpts)+1;
u = zeros(ns,2);
u(1,1)=1;
u(ns,2)=n;

for i = 1 : length(badpts)
    u(i,2)= badpts(i); %end of preivous segment
    u(i+1,1) = badpts(i)+1;%start of new segment.
end
    
    
    
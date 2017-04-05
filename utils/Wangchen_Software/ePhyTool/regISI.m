function [r,badpts] = regISI(t,e,tol)
%analyze the regularity of inter-stim-event interval.
%t: series of timestamps of stim-events/screen flips
%e: expected ISI. 
%tol: tolerance of ISI deviation from e. tol=(isi-e)/e;
%e.g: regISI(t,2/60,0.05)

%flag to check out-of-bound points 
check = true;
%regularity flag
r = false;

if nargin < 2
    check = false;
end

n = length(t);
dt = diff(t);
minISI = min(dt);
maxISI = max(dt);
meanISI = mean(dt);
stdISI = std(dt);

fprintf('Regularity of input data : ===> %d points \n',n);
fprintf('ISI mean: %f\t std: %f\t min: %f\t max: %f\n',meanISI,stdISI,minISI,maxISI);

%points out of boundaries given by e + tol.
%
if ~check ; return; end

%dt(i)=t(i+1)-t(i) 
badpts = find(abs((dt-e)/e) >= tol);
nb = length(badpts); 
fprintf('Regularity check : ==> %d irregular interval-points \n', nb); 

if nb == 0 
    r = true;
end


    







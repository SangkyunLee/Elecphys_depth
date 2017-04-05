function [I,r]=lnnsearch_reg(t,K,verbose)
%use elment-wise comparision regressively to search for the LNN index. refer to lnnsearch
%function.
if nargin < 3
    verbose = true;
end
if verbose
    fprintf('lnnsearch_reg---Searching Lower-Nearest Neighbors...\n');
end
if size(t,1) > 1; t = t'; end %row vector

% Nt = length(t);
dt = mean(diff(t));
%number of spikes, number of sta time kernal elements.
[Nspk, Nsta] = size(K);
I = zeros(size(K)); r = true;
%shift t by 1 
t1 = [t(2:end) t(end)+dt];
%
for i = 1 : Nspk
    for j = 1 : Nsta
        S = (t-K(i,j)).*(t1-K(i,j)) < 0 | K(i,j)-t==0 ; 
        idx = find(S);
        if isempty(idx)
            fprintf('\t\tNo LNN index found at [%d,%d]: \n',i,j);
            idx =0; 
            r = false;
        elseif length(idx)>1
            fprintf('\t\tMultiple LNN index found at [%d,%d]: \n',i,j);
            idx
            idx = idx(1);
        else
        end
        I(i,j) = idx;
    end
    if mod(i,round(Nspk/3))==0; fprintf('\t\tSearched [%d|%d]\n',i,Nspk); end
end



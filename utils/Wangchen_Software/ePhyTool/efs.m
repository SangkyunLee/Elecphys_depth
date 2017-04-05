function v = efs(s,m,opt)
%compute the 'effective-stimlus' value of stimulus input.
%s: the stimulus input vector s 
%m: the mean-effective-stimulus vector m.
%p: normalization option. 
%   'norm' --- projection is normalized by the magnitude of m, i.e, s projects onto the
%   unit vector <m> = m/norm(m). default
%   'raw'  --- no normalization of the projections
%v: the output vector of effective-stimulus-value. It has the same length
%   as s. the leading elements in size of m are padded zero. 
%
%s and m should be regular spaced and have the same bin size.   
%

if nargin < 3
    opt = 'norm';
end

if strcmpi(opt,'norm')
    M = m/norm(m);
else
    M = m;
end

N = length(M);
pad = 0;       %pad element 

% %implemented by definition
% v = zeros(size(s));
% for i = 1 : length(s)
%     if i <= N
%         v(i) = pad ; 
%     else
%         v(i) = s(i-N : i-1)*M';
%     end
% end

%implemented by filter
v = circshift(filter(fliplr(M),1,s),[0 1]); %right shift along column by 1. 
v(1:N) = pad;  %first N elements are ignored. 



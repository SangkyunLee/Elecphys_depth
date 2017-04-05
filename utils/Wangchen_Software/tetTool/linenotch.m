function out = linenotch(data,sf,m,Q,nf)
% apply notch filtering at homonics of line freq m*60Hz to lfp data.
% data: columnar data (time points * variables) (filter is to be filtered along first non-singleton
% dimension)
% sf: sampling rate (in Hz)
% m : homonic order to be filtered. (1 for 60hz, 2 for 60,2*60,etc).
%
% Note : filter works with rows data for matlab R2011b above. 

if nargin < 4
    Q = 35;
    nf = 60;
end

if nargin < 5
    nf = 60;
end

%Q = 35; %suppression quality factor.
w = nf /(sf/2); 
%bw = wo/Q;
out = data;

for i = 1 : m
    wo = i * w; 
    bw = wo / (i * Q);  %same bandwidth for hormonics 
    [b,a] = iirnotch(wo,bw);
    out = filter(b,a,out);
end

% %%%%%%%% apply notch filter %%%%%%%
% % notch at 60 Hz
% wo = 60/(sr/2); bw = wo/35;
% [b,a] = iirnotch(wo,bw);
% out = filter(b,a,data)'; %filter works on columns
% 
% %notch at 120 Hz
% wo = 120/(sr/2); bw = wo/35;
% [b,a] = iirnotch(wo,bw);
% out = filter(b,a,out)'; %filter works on columns
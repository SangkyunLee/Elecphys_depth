function x = lnfilter(x,Fs,Q,Fn)
% notch filter to remove 50Hz noise
%Fs : sampling freq
%Q  : 
%Fn : noise freq
%Q = 1.2;                                    % Quality factor - !!IMPORTANT PARAMETER!!
wo = Fn/(Fs/2);  
bw = wo/Q;                                  % bandwidth at the -3 dB point set to bw 
[bn,an] = iirnotch(wo,bw);  
x = (filter(bn,an,x));

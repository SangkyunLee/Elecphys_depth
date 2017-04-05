function [y,x] = upss(s,t,x)
% up-sample stimulus data timestamped with photodiode.
% upss returns the regularized stimulus upsampled with smaller bins.
% s :  recorded stimulus data 
% t :  timestamps of stimulus onsets, in sec
% b :  sampling bin size, in sec
% y :  resampled stimulus data 
% x :  resampling time 

sb = mean(diff(t));
np = length(t);    %num of stimulus points

b = x(2)-x(1);

%fprintf('Stimulus Bin = %f, Resample Bin = %f\n', sb, b);

% if nargin < 4
% % time bins of resampled stimulus
%     x = t(1) : b : t(end) ; 
% end

% indices of 'lowest neighbors' for x in t
K = nearest_point(t,x,'lower');
%difference between the timestamp interval D and the distance to 'lowe-nearrest neighbor' DLN
nextK = K+1 ;
nextK(nextK > np) = np; %

%interval of timestamps for 'lowest neighbors'
dTk = t(nextK) - t(K) ;
%differential value in stimulus intensity
dSk = s(nextK) - s(K) ;
%time difference b/w resample vector and its lower-nearest neighbors 
deltaTk = x - t(K);

if any(deltaTk < 0) ; error('error in time difference'); end

%interpolation slope b/w neighboring points
slope = (dTk - deltaTk)/b - 1 ;
%
signConst = sign(slope);
%sign constant for the slope
signConst(signConst>=0) = 0; %1 -->0
signConst(signConst<0 ) = 1; %-1 --> 1
%signConst = 0;

y = s(K) - signConst.*slope.*dSk ; %or set signConst 0 for 'nearest' interoplation







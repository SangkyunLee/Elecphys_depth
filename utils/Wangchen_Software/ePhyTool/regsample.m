function [yi] = regsample(x,y,xi)
% interpolate the irregular spaced data s with regular bins. 
% it's used to upsample/downsample stimulus data timestamped with photodiode.
% y :  stimulus data (1 x n) 
% x :  stimulus onsets time. 
% yi :  resample stimulus data 
% xi :  resample time with regular bins
% More general interpolation algorithm than function 'upss', i.e, it can
% downsample input by averaging all points falling into each bin in output.
%

np = length(x);    %num of stimulus points
ni = length(xi);   %num of resample points
%resample bin 
b = xi(2)-xi(1);

%
yi = zeros(size(xi));

% if nargin < 4
% % time bins of resampled stimulus
%     x = t(1) : b : t(end) ; 
% end

% indices of 'lowest neighbors' for x in t, i.e, starting t index to x for
% resample. 
Ks = nearest_point(x,xi,'lower');
% indices of LNN for next x in t,also the ending t index to x
Ke = circshift(Ks,[0 -1]);
Ke(end) = Ke(end-1);     % the last element will hold value from LNN 
% indices of x in b/w Ks and Ke


%interval b/w input time x
dX = [diff(x) mean(diff(x))];
%distance from xi to its LNN x
dD = xi - x(Ks);

for i = 1 : ni
    ws = y(Ks(i)) * (dX(Ks(i))-dD(i));
    if Ks(i)+1 <= Ke(i)-1
        wm = sum( y((Ks(i)+1) : (Ke(i)-1)) .* (dX((Ks(i)+1):(Ke(i)-1))) );
        tm = sum( dX((Ks(i)+1) : (Ke(i)-1)) ); %summed duration for middle points 
    else
        wm = 0;
        tm = 0;
    end
    we = y(Ke(i)) * ( b - (dX(Ks(i))-dD(i)) - tm );
    
    yi(i) = (ws + wm + we)/b;
end


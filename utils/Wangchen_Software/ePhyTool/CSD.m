function csd = CSD(lfp)

%CSD - Compute current source density.
%
%  USAGE
% Check number of parameters
 if nargin < 1,
   error('Incorrect number of parameters (type ''help <a href="matlab:help CSD">CSD</a>'' for details).');
 end
 
 t = lfp(:,1);
 y = lfp(:,2:end);
%  y = y - repmat(mean(y),length(t),1);
%avgpts = 3; %average time points for baseline correction.
%y = y - repmat(mean(y(1:avgpts,:)),length(t),1);
 d = -diff(y,2,2);
 csd = [t d];
function [To,STA,STC] = sta1q(s,dt,x,T)
%calcaute spike-triggered-average in a quick fashion
%s : stimulus array that starts from t=0 and is regularlyed spaced by dt
%dt: stimulus bin size in seconds. 
%    onset times of stimus is [0 : dt : (n-1)*dt]
%x : spike train
%T : STA time window 
%A : STA
%To: STA time
%ALL vectors are row vectors.

if diff(T) <= 0 ; error('wrong sta time window'); end

dN1 = abs(floor(T(1)/dt)); %num of bins before t=0 
dN2 = ceil(T(2)/dt);  %num of bins after t=0
To =  -dN1*dt : dt : dN2*dt ; 

m = length(To) ;%num of STA bins
p = length(s)  ;%num of stimulus points

%eliminate spikes that occur inside STA time window (no whole stimulus for
%the whole block of STA time prior to or post those spikes)

%x(x < dT1 | x+dT2 > length(s)*dt) = [] ; 
K = ceil(x/dt);
x( K-dN1<1 | K+dN2 < 1 | K-dN1 >p | K+dN2 >p ) = [];

n = length(x) ; %num of spikes

fprintf('num of spikes used %d\n', n);

A = zeros(m,n); %column loaded with stimulus vector.
s = s';

for i = 1 : n
    k = ceil(x(i)/dt);
    A(:,i) = s(k-dN1 : k+dN2);
end

STA = mean(A,2); %column vector

STC = (A*A' - n*(STA*STA'))/n ; %covariance matrix

%STC = sqrt(diag(M)/n);

%transpose to row vector
STA = STA';
STC = STC'; 



function [I,r] = lnnsearch(t,K,verbose)
%lnnsearch finds the index of lower-nearest neighbor in t to K
%input : 
%     t: stimulus timestamps. 1d vector. near-regular interval.
%     K: sta sampling time matrix with the size of [Nspk, Nt]
%        K = spike time + D(t), where D(t) is time kernal of sta.
%output:
%     I: lower-nearest neibor index for each element in K.
%     K(I)-t(I)>=0 , K(I)-t(I) = min(K-t)
%     r: flag indicating a success search.
%
%
if nargin < 3
    verbose = true;
end
if verbose
    fprintf('lnnsearch---Searching Lower-Nearest Neighbors...\n');
end
if size(t,1) > 1; t = t'; end %row vector
%sta sampling bin size
%bin = K(1,2)-K(1,1);
%mean interval of stimulus time
smp = mean(diff(t));
%
Nt = length(t);
%linear fit of stimulus time
P = polyfit(1:Nt,t,1);

%
%slope = P(1);
%intercept = P(2);

%initialize I with linear-fit indices
I = floor((K-P(2))/P(1));
%set the boundary
I(I<1) = 1; 
I(I>Nt) = Nt;
%calibration with local seed
dI = floor((K - t(I))/smp);

I = I + dI;

%???? 
% I(I<1) = 1; 
% I(I>Nt) = Nt;

I(I<1) = 1; 
I(I>=Nt) = Nt-1;

% %assert that I is LNN index array
 S = (t(I)-K).*(t(I+1)-K) < 0 | K-t(I)==0 ;
% 
%non
FS = find(~S);
%off-target points
np = numel(FS);
if np == 0
    r = true;
    return;
else
    if verbose
        fprintf('\t\tCalibration: %d out of %d points off-target. use stepping-up approach now...\n',np,numel(K));
    end
end
%directional sign
for i = 1 : np
    L = FS(i); % off-target point position in I.
    m = I(L) ; % LNN index in stimulus time t.
    ts = K(L); % sta sample time
    tm = t(m); %stimulus time which is 'off-target'
    tm1 = t(m+1); % 
    j = 0;
    while ~((tm-ts)*(tm1-ts) < 0 || ts-tm==0)
        m = m + sign(ts-tm)*1;
%         if m < 1 || m >= Nt 
%             error('search out of bound');
%         end
        if m < 1 ; m = 1; end
        if m >= Nt; m = Nt-1; end
        tm = t(m);
        tm1 = t(m+1);
        j = j + 1;
        if j > 1000; break; end
    end
    I(L)=m;
end

%
S = (t(I)-K).*(t(I+1)-K) < 0 | K-t(I)==0 ;

np = numel(find(~S));
if np==0
    r = true;
    if verbose; fprintf('\t\tFinal: Done\n'); end;
else
    r = false;
    if verbose; fprintf('\t\tFinal: [%d|%d] points off-target. Search failed.\n',numel(find(~S)),numel(K)); end
end



        
        
    
    
    


    


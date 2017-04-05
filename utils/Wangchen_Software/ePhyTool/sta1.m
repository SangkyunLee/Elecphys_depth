function [s,c,E,t,Nspk,spkVecArray] = sta1(data_spk,data_img,st,bin,plt,w,T,D,err)
% Spike Triggered Average                            
%     Usage: [s,t,E] = sta1(data_spk,data_img,st,bin,plt,w,T,D,err)
%
% modified from sta script in chronux library - WW2010
%
% rewrite the script with following major changes: 
% 1. sample the stimulus data with STA time kernel in staircase fashion
% instead of 'linear' interpolation. The 'staircase' sampling represents
% the stimulus value more precisely than 'linear' interpolation.  Note the
% algorithm only takes care of the up-sampling case. i.e,
% bin(sta)<bin(stimulus). 
% 2. utilize the matrix computation rather than looping through spike
% vector. 
% -WW2011
%     
% Inputs                                              
%                                                    
% Note that all times have to be consistent. If data_spk
% is in seconds, so must be sig and t. If data_spk is in 
% samples, so must sig and t. The default is seconds.
%
% data_spk    - strucuture array of spike times data 
%               or zero padded matrix,
% data_spk(i).data = [spikes of i-th trial] or 
% data_spk(trials,spikes) 
% 
% data_img    - 2d array of stimulus data(trials x samples)         
%               i.e,data_img(trials,samples). 
%
% st -  stimulus onset timestamps. 
%        
% data_img(1) data_img(2) .....
%       st(1)       st(2) .....
%
% Note that sta1 requires uniformly spaced data for st and sta time elements.
%
%
% Optional...                                  
% bin - sta bin size. e.g, 1/60 s 
% plt 'n'|'r' etc                                    
% width kernel smoothing in s                        
% T = [ ] - selection window on stimulus time st.  
% D - range of sta output [D(1) D(2)]. i.e, extract this range about each
% spk. relax lower bound D(1) and fix D(2) and bin so that D is uniform.
%
% err = calcluate error bars (bootstrap)             
%                                                    
% Outputs:                                             
%                                                    
% s  spike triggered average                         
% t  times                                           
% E  bootstrap standard err                          

if nargin < 3;error('Require spike, stimulus data and stimulus times');end
if isstruct(data_spk)
   [data_spk]=padElement(data_spk); % create a zero padded data matrix from input structural array
end

if isempty(data_spk)
    error('no spike data found');
end

verbose = 1;
%t = st;

if nargin < 4; bin = st(2)-st(1);end
if nargin < 5; plt = 'r'; end
if nargin < 6; w = 0; end
if nargin < 7; T = [min(st) max(st)]; end
if nargin < 8; D = 0.25*[-1 0]; end         %default: 250msec
if nargin < 9; err = 1;end

if isempty(bin); bin = st(2)-st(1); end
if isempty(plt); plt = 'r'; end
if isempty(w); w = 0; end
if isempty(T); T = [min(st) max(st)]; end
if isempty(D); D = 0.25*[-1 0]; end
if isempty(err); err = 1;end

if w > (T(2)-T(1))/2
  disp('Smoothing > data segment : should be in seconds : turn off smoothing')
  w = 0;
end

chronux_path = which('chronux');
if isempty(chronux_path)
    %disp('chronux not found: turn off smoothing');
    w = 0; %no locsmooth available. turn off smoothing
end

sz = size(data_spk);
NT = sz(1); %number of trials
mimg = 0; % mean of stim values
simg = 0; % square of stim values
Nspk = 0; %
smp = mean(diff(st)); %stimulus event interval.

% %t1: time points when sampling stimulus for each spike
% if D(1) <= 0 && D(2) >= 0
%   t1 = [D(1):smp:(-smp+eps) 0:smp:D(2)+eps]; %keep 0
% else
%   t1 = (round(D(1)/smp)*smp):bin:D(2);
% end

if bin > smp; bin = smp; end %upsampling only

%t1 = (round(D(1)/bin)*bin):bin:D(2);
%fix the upper bound and bin, relax the lower bound.
t = D(2):-bin:D(1);
t= t(end:-1:1);

%t1: time points plotted for sta 
if D(1) <= 0 && D(2) >= 0
  sta_t1 = [D(1):bin:(-bin+eps) 0:bin:D(2)+eps]; %keep 0
else
  sta_t1 = t;
end

% count up the spikes...
ssi = zeros(NT,2);   %index(in spk) of spikes good for sta. 
for n=1:NT
    %logical values of spikes inside T window,excluding 0-padding ones.
    spklv = (data_spk(n,:)>T(1) & data_spk(n,:)<T(2) & data_spk(n,:)~=0);
    if ~isempty(spklv) > 0
      %spktime + D - boundary conditon for sta computation
      lspkt = data_spk(n,:) + t(1); %left bound of sta from spk times
      rspkt = data_spk(n,:) + t(end); %right bound of sta from spk times
      stalv = (lspkt < T(2) & lspkt > T(1) & rspkt < T(2) & rspkt > T(1)); %whether spiks with D are out of T window.
      spkidx = find(spklv & stalv);  %qualified spikes 
      if ~isempty(spkidx)
        ssi(n,1) = min(spkidx);  %start spike index -- assume spikes are timely ordered.
        ssi(n,2) = max(spkidx);  %end spike index
        Nspk = Nspk + length(spkidx);
      end
    end
end

%clear data variables to save some space.
clear spklv lspkt rspkt stalv spkidx;
% 
% if err
%   Err = zeros(Nspk,length(t1));
% end

Nspk = 0;

%stimulus segment chosen by T window
% indx = find(st>=T(1)& st<=T(2));
indx = (st>=T(1)& st<=T(2));
tt = st(indx);
%inter-stimulus interval array, 
dd = diff(tt);
dd = [dd smp];

mimg = zeros(1,length(t));
cimg = zeros(length(t),length(t));

spkVecArray = nan(NT,length(t)); %return the spike-triggered vectors. WW2013

for n=1:NT
  %stimulus data
  img = data_img(n,indx);
  spk = data_spk(n,ssi(n,1):ssi(n,2));
  
  if ~isempty(spk)
    ND = length(spk);
    K = repmat(t,ND,1); %sta kernal 
    X = bsxfun(@plus,K,spk'); %dimension--(spike time,sta times)
    I = lnnsearch(tt,X,0);
%     dx = (X - tt(I)) + (bin-smp);
    dx = (X - tt(I)) + (bin-dd(I));
    offset = 0.5*sign(dx).*(1+sign(dx)).*(dx/bin);
    Y = img(I)+ offset.*(img(I+1)-img(I)); %use sign for step function
    mimg = mimg + sum(Y,1); % sta as (1,sta times)
    cimg = cimg + (Y'*Y);
    Nspk = Nspk + ND;
    %fprintf('Trial %d, Selected Spikes [%d|%d], Total Spikes Processed %d \n',n,ND,length(data_spk(n,:)),Nspk);
    spkVecArray(n,:) = Y;
  end  
end

mimg = mimg /Nspk; %sta
cimg = (cimg - Nspk*mimg'*mimg)/(Nspk); %covariance matrix stc.
%stdimg = sqrt(diag(cimg)*(Nspk-1)/Nspk); ?stardard dev ?
stdimg = sqrt(diag(cimg)/Nspk); %standard error
stdimg = stdimg'; % row vector (1,sta times)

%return 
s = mimg;
c = cimg;
E = stdimg;

if Nspk == 0
  if verbose;disp('sta1 : No spikes in interval');end
  %t = t1;
  s = zeros(1,length(t));
  c = zeros(length(t),length(t));
  E = zeros(1,length(t));
  return
end


% % local smoother...
% 
% N = fix(w/smp);
% if N > 5
%   mimg = locsmooth(mimg,N,fix(N/2)); 
% end

% % bootstrap errorbars...
% 
% if err == 1;
%   Nboot = 20;  
%   bimg = 0;
%   simg = 0;
%   for n = 1:Nboot
%     indx = floor(Nspk*rand(1,Nspk)) + 1;
%     imgtmp = mean(Err(indx,:));
%     if N > 5
%       imgtmp = locsmooth(imgtmp,N,fix(N/2));
%     end
%     bimg = bimg + imgtmp;
%     simg = simg + imgtmp.^2;
%   end
%   stdimg = sqrt((simg/Nboot - bimg.^2/Nboot^2));
% end  
% 

% %interpet sta output with given 'bin' size
% s = interp1(t1,s,sta_t1);
% E = interp1(t1,E,sta_t1);
%output time range.
t = sta_t1;

%cols = 'krbgycm';
if plt == 'n';return;end
%plot sta results
figure('Name','STA output'); hold on;
plot(t,s,plt);
xax = get(gca,'xlim');
%yax = get(gca,'ylim');
if err == 1
  me = real(2*mean(stdimg));
  line(xax,me*[1 1],'color','b')
  line(xax,-me*[1 1],'color','b')
  line(xax,0*[1 1],'color','k')
%  errorbar(0.1*xax(2)+0.9*xax(1),0.1*yax(2)+0.9*yax(1), ...
%         mean(stdlfp),'k')
%plot(0.1*xax(2)+0.9*xax(1),0.1*yax(2)+0.9*yax(1),'k.')
end
     
title(['spike triggered average : ' ...
      num2str(Nspk) ' used : '     ...
      ' Errorbars are two std err']);
%line(get(gca,'xlim'),mean(mlfp)*[1 1],'color','k')  
line([0 0],get(gca,'ylim'),'color','k')
hold off









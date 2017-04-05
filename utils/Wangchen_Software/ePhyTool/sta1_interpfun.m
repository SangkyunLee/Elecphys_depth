function[s,t,E] = sta1(data_spk,data_img,st,bin,plt,w,T,D,err)
% Spike Triggered Average                            
%     Usage: [s,t,E] = sta1(data_spk,data_img,st,bin,plt,w,T,D,err)
%
% modified from sta script in chronux library - WW2010
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
% data_img    - 2d array of stimulus data(samples x trials)         
%               i.e,data_img(trials,samples). 
%
% st -  timestamps for the onset of each stimulus event. 
%        
% data_img(1) data_img(2) .....
%       st(1)       st(2) .....
% assume stimulus is continuous without background, i.e., stimulus duration = st(2)-st(1)
%
% Optional...                                  
% bin - sta bin size. e.g, 1/60 s 
% plt 'n'|'r' etc                                    
% width kernel smoothing in s                        
% T = [-0.1 0.1] - extract this range about each spk 
% D - range of sta output [D(1) D(2)]. i.e, the range of stimulus averaged before each spike.
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
    error('no spike data found\n');
end

verbose = 1;
t = st;

if nargin < 4; bin = t(2)-t(1);end
if nargin < 5; plt = 'r'; end
if nargin < 6; w = 0; end
if nargin < 7; T = [min(t) max(t)]; end
if nargin < 8; D = 0.25*[-1 1]; end         %default: 250msec
if nargin < 9; err = 1;end

if isempty(bin); bin = t(2)-t(1); end
if isempty(plt); plt = 'r'; end
if isempty(w); w = 0; end
if isempty(T); T = [min(t) max(t)]; end
if isempty(D); D = 0.25*[-1 1]; end
if isempty(err); err = 1;end

if w > (T(2)-T(1))/2
  disp('Smoothing > data segment : should be in seconds : turn off smoothing')
  w = 0;
end

chronux_path = which('chronux');
if isempty(chronux_path)
    disp('chronux not found: turn off smoothing');
    w = 0; %no locsmooth available. turn off smoothing
end

sz = size(data_spk);
NT = sz(1); %number of trials
mimg = 0; % mean of stim values
simg = 0; % square of stim values
Nspk = 0; %
smp = t(2)-t(1); %stimulus event interval.

%t1: time points plotted for sta
if D(1) <= 0 && D(2) >= 0
  t1 = [D(1):bin:(-bin+eps) 0:bin:D(2)+eps]; %keep 0
else
  t1 = (round(D(1)/bin)*bin):bin:D(2);
end

% count up the spikes...
ssi = zeros(NT,2);   %index(in spk) of spikes good for sta. 
for n=1:NT
    %logical values of spikes inside T window,excluding 0-padding ones.
    spklv = (data_spk(n,:)>T(1) & data_spk(n,:)<T(2) & data_spk(n,:)~=0);
    if ~isempty(spklv) > 0
      %spktime + D - boundary conditon for sta computation
      lspkt = data_spk(n,:) + D(1); %left bound of sta from spk times
      rspkt = data_spk(n,:) + D(2); %right bound of sta from spk times
      stalv = (lspkt > T(1) & rspkt < T(2)); %whether spiks with D are out of T window.
      spkidx = find(spklv & stalv);  %qualified spikes 
      if ~isempty(spkidx)
        ssi(n,1) = min(spkidx);  %start spike index -- assume spikes are timely ordered.
        ssi(n,2) = max(spkidx);  %end spike index
        Nspk = Nspk + length(spkidx);
      end
    end
end

if err
  Err = zeros(Nspk,length(t1));
end

Nspk = 0;

%stimulus segment chosen by T window
indx = find(t>=T(1)&t<=T(2));
tt = t(indx);

for n=1:NT
  %stimulus data
  img = data_img(n,indx);
  spk = data_spk(n,ssi(n,1):ssi(n,2));
  
  if ~isempty(spk)
    ND = length(spk);
    for s=1:ND
        spktime = spk(s);
        sta_t = t1 + spktime; %the sampling time points for sta
        if tt(1) < sta_t(1) && tt(end) > sta_t(end) % sta range falls inside stimulus range

            sta_lvl = find(tt < sta_t(1));
            if isempty(sta_lvl); continue; end
            sta_lvl = sta_lvl(end); %left bound below sta_t(1)
            sta_lvr = find(tt > sta_t(end));
            if isempty(sta_lvr); continue; end
            sta_lvr = sta_lvr(end); %upper bound above sta_t
            %rand of indices
            sta_lv = sta_lvl:sta_lvr;
            img_spk = img(sta_lv);%value segment around the spike
            tt_spk  = tt(sta_lv); %time segment around the spike
            img_spk = double(img_spk); %convert for interp1
            %sample the stim segment by t1 using linear interpolation
            mimg_t1 = interp1q(tt_spk',img_spk',sta_t'); %transposed to column vectors.
            mimg = mimg + mimg_t1;
            simg = simg + mimg_t1.^2;
            Nspk = Nspk + 1;
            if err; Err(Nspk,:) = mimg_t1; end
        
        end
    end
  end  
end

if Nspk == 0
  if verbose;disp('sta1 : No spikes in interval');end
  t = t1;
  s = zeros(length(t),1);
  E = zeros(length(t),1);
  return
end
mimg = mimg/Nspk;
simg = simg/Nspk;
stdimg = sqrt((simg - mimg.^2)/Nspk);

% local smoother...

N = fix(w/smp);
if N > 5
  mimg = locsmooth(mimg,N,fix(N/2)); 
end

% bootstrap errorbars...

if err == 1;
  Nboot = 20;  
  bimg = 0;
  simg = 0;
  for n = 1:Nboot
    indx = floor(Nspk*rand(1,Nspk)) + 1;
    imgtmp = mean(Err(indx,:));
    if N > 5
      imgtmp = locsmooth(imgtmp,N,fix(N/2));
    end
    bimg = bimg + imgtmp;
    simg = simg + imgtmp.^2;
  end
  stdimg = sqrt((simg/Nboot - bimg.^2/Nboot^2));
end  

s = mimg-mean(mimg);
E = stdimg;
t = t1;

%cols = 'krbgycm';
if plt == 'n';return;end
%plot sta results
figure('Name','STA output'); hold on;
plot(t1,s,plt);
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









function[s,t,E] = sta2(data_spk,data_img,st,bin,plt,w,T,D,err)
% Spike Triggered Average                            
%     Usage: [s,t,E] = sta2(data_spk,data_img,st,bin,plt,w,T,D,err)
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

if w~=0
    w = 0; %smoothing on 2d matrix ? sth to do.
end

%check format of stimulus data
dim = ndims(data_img);
if ~(dim ==4 || dim ==3)
    error('wrong format of stimulus data');
end

sz = size(data_img);
if dim == 3
    NT = 1;
else
    NT = sz(4); %number of trials
end
xdim = sz(1); 
ydim = sz(2); %image dimension.
mimg = 0; % mean of stim values
simg = 0; % square of stim values
Nspk = 0; %
smp = t(2)-t(1); %stimulus event interval.

%t1: time points plotted for sta 
if D(1) <= 0 && D(2) >= 0
  sta_t1 = [D(1):bin:(-bin+eps) 0:bin:D(2)+eps]; %keep 0
else
  sta_t1 = (round(D(1)/bin)*bin):bin:D(2);
end

%t1: time points when sampling stimulus blocks
if D(1) <= 0 && D(2) >= 0
  t1 = [D(1):smp:(-smp+eps) 0:smp:D(2)+eps]; %keep 0
else
  t1 = (round(D(1)/smp)*smp):bin:D(2);
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
%   Err = zeros(Nspk,length(t1));
  Err = zeros(Nspk,xdim,ydim,length(t1));
end

Nspk = 0;

%stimulus segment chosen by T window
indx = find(t>=T(1)&t<=T(2));
tt = t(indx);

for n=1:NT
  %stimulus data
%   img = reshape(data_img(:,:,indx,n),[xdim,ydim,indx]); %reduce 1 dim.
  img = data_img(:,:,indx,n); % img reduced to 3d indeed.
  spk = data_spk(n,ssi(n,1):ssi(n,2));
%   %transform img to (samples,x,y) format for interp1 function input. this
%   %will save time inside the loop.
%   img = shiftdim(img,2);
%   
  if ~isempty(spk) > 0
      ND = length(spk);
      for s=1:ND
          spktime = spk(s);
          t0 = tt - spktime ;
          
          if min(t0) < (D(1)-smp) && max(t0) > (D(2)+smp);
              indx = find(t0<D(1));
              indx = indx(length(indx));
              offset = (t0(indx)-D(1))/smp;
              indx = indx:(indx+length(t1)-1);
              if indx(end)+1 > size(img,3); continue; end
              mimg_t1 = img(:,:,indx) + (img(:,:,indx+1)-img(:,:,indx))*offset;

              mimg = mimg + mimg_t1;
              simg = simg + mimg_t1.^2;
              Nspk = Nspk + 1;

              if Nspk==round(ND/3) || Nspk==round(2*ND/3)
                  fprintf('Trial %d: Spikes %d, Total Spikes Processed %d \n',n,ND,Nspk);
              end

              if err
                  Err(Nspk,:,:,:) = mimg_t1; %Err created in (t1_samples,x,y) format.
              end
          end
          
      end
      fprintf('Trial %d, Spikes %d, Total Spikes Processed %d \n',n,ND,Nspk);
  end
end

% %transform the mimg/simg back to (x,y,samples) format
% mimg = shiftdim(mimg,1);
% simg = shiftdim(simg,1);

if Nspk == 0
  if verbose;disp('sta2 : No spikes in interval');end
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

%(x,y,t1_samples). average over t1
s = mimg-mean(mean(mean(mimg,3),2),1);
E = stdimg;

%interpet sta output with given 'bin' size
%transform to (samples,x,y);
s = shiftdim(s,2);
E = shiftdim(E,2);
s = interp1(t1,s,sta_t1);
E = interp1(t1,E,sta_t1);
%shift back to (x,y,samples).
s = shiftdim(s,1);
E = shiftdim(E,1);
%output time range.
t = sta_t1;

%cols = 'krbgycm';
if plt == 'n';return;end
%plot sta results
figure('Name','STA output'); 
title(['spike triggered average : ' ...
      num2str(Nspk) ' used : '     ...
      ' Errorbars are two std err']);
hold off;

pcolor(s(:,:,1)); axis image;

set(gcf,'doublebuffer','on');%avoid flickering while updating plot
% Generate constants for use in uicontrol initialization
pos=get(gca,'position');
% This will create a slider which is just underneath the axis
% but still leaves room for the axis labels above the slider
Newpos=[pos(1) pos(2)-0.1 pos(3) 0.05];

%num of samples in t1;
nsmp=length(sta_t1);

% Creating Uicontrol
h=uicontrol('style','slider',...
    'units','normalized','position',Newpos...
    );
xmin = get(h,'min');
xmax = get(h,'max');

set(h,'userdata',s); %save sta to slider handle.

S = ['s=get(gcbo,''userdata'');' 'c=(s(:,:,round(1+(get(gcbo,''value'')-' num2str(xmin) ')*' ...
    num2str((nsmp-1)/(xmax-xmin)) ')));' 'pcolor(c); axis image;']; 

set(h,'callback',S);









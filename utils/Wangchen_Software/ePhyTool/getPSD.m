function [p,fp,e] = getPSD(x,params)
%return averaged power spec estimation for multiple trials
%x      :  data array (samples x trials)
%params : 
%params.Fs       : sampling freq
%params.fpass    : freq band to keep
%params.trialavg : flag to average the psd 
%p      : array of power spectral density in db units (frequency x trials)
%fp     : frequency (hz).
%e      : error

Fs = params.Fs;
fpass = params.fpass;
trialavg = params.trialavg;

n = size(x,2); %number of trials
L = size(x,1); %length of data 
NFFT = 2^nextpow2(L);
f = Fs/2*linspace(0,1,NFFT/2+1);

if ~isempty(fpass)
    I = ((fpass(1) <= f & f <= fpass(2)));
else
    I = ones(size(f));
end

p = zeros(length(f),n);

for i = 1 : n
    %x = cos(2*pi*60*t)+0.5*randn(size(t));
%     psdest = psd(spectrum.periodogram,x(:,i),'NFFT',npts,'Fs',params.Fs,...
%         'SpectrumType','Onesided','CenterDC',true);
    PSD = abs(fft(x(:,i),NFFT)).^2/L/Fs;
    p(:,i) = PSD(1:NFFT/2+1); %single-sided amplitude spectrum.
end

e = zeros(size(p,1),1);

if trialavg
    p = mean(p,2);
    e = std(p,1,2)/sqrt(size(p,2));
end

%selected freq range.
p = p(I,:);
fp= f(I);
e = e(I);

p = db(p);

%plot(psdest)
%avgpower(psdest,[58,62])
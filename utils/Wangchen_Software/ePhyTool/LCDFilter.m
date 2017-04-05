function y = LCDFilter(x,fs,viewspec)
%low-pass filter for photodiode signal from LCD monitor
%the signal is modulated by the frequency component ~220Hz and its high order hormonics.
%
%fs :         sampling rate
%x  :         photodiode signal.
%viewspec :   show analysis spectrum.

if ~exist('viewspec','var') || isempty(viewspec)
    viewspec = false; %default: not view the spectram.
end

%screen refresh rate
refreshRate = 60;
%high freq modulation ~220 Hz
modFreq = 222.8;
%width of modulation freq spread
modFreqWidth = 1.5;
%cutoff freq for the low-pass filter
fc = modFreq - modFreqWidth;
%normalized cutoff freq wrt half-sampling rate
fnorm = fc/(fs/2) ;

%sampling interval
dt = 1 / fs;
%number of data pts
n = length(x);
%time data
t = linspace(0,(n-1)*dt,n);

if viewspec
    %show the power-density-spectrum of signal
    nfft = 2^nextpow2(n);
    %
    PowerSpec = abs(fft(x,nfft)).^2/n;
    %show upto 5*fc in power-spectrum
    npass = min([nfft/2, round((5*fc)/(fs/2)*(nfft/2))]);
    %
    f = fs/2*linspace(0,1,nfft/2);
    f = f(1:npass);
    %
    p = 10*log10(PowerSpec(1:npass));
    %single-sided power spectrum
    figure('name','Power Spectrum');
    plot(f,p);
    xlabel('Frequency(Hz)');
    ylabel('Power Magnitude(dB)');
    %
    clear nfft PowerSpec f p;
end

%butter-filter order
order = 4;
%number of hormonics
nHorm = 3;

%
y = x;

for i = 1 : nHorm
    [b a] = butter(order, [modFreq*i - modFreqWidth, modFreq*i + modFreqWidth]./(fs/2), 'stop');
    % %set the low-pass butter filter.
    % [b,a] = butter(order,fnorm,'low');
    %filtered signal
    y = filtfilt(b,a,y);
end

if viewspec
    %show first 5sec data only
    npass = min([round(10*fs), n]);
    %filter spec.
    figure('name','Filter Specs');
    freqz(b,a,128,fs);
    figure('name','Filtered Signal');
    subplot(2,1,1);plot(t(1:npass),x(1:npass),'b');hold on;plot(t(1:npass),y(1:npass),'r');
    subplot(2,1,2);plot(t(1:npass),x(1:npass),'b');hold on;plot(t(1:npass),y(1:npass),'r');
end

clear t;



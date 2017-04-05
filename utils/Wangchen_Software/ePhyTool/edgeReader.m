function [t,I] = edgeReader(pds,fs,mode,viewspec)
%get timestamps for the onset the event (from rising edge of the pulse)
%WW2010
%
%pds : input photodiode signal. pre-processed by LCDFilter to remove 220hz
%      modulation frequency from the raw signal. the pds needs to confirm to a
%      well-behaved square-wave.
%fs  : sampling frequency,e.g, 30k/s
%ff  : flash frequency (stimulus event occurance)
%mode: edge detection mode. 'rising'=1 is the default. 
%      (others:'falling'=-1;'both'=0)
%viewspec: view analysis spectrum. defalut = false.
%
%t   : timestamps of events
%I   : index array of t in pds, i.e, pds(I)=t

if nargin < 2
    disp('parameters missing.\n');
end

% if ~exist('ff','var') || isempty(ff)
%     ff = 1; %just to create the variable
%     %alternative way is finding flash freq from the powerspectrm which is
%     %likely less accurate.
% end

if ~exist('mode','var') || isempty(mode)
    mode = 1; %set the default of the variable. or mode = 'rising'
end

if ~exist('viewspec','var') || isempty(viewspec)
    viewspec = false; %default of the variable
end

%monitor refresh rate
fr = 60;
%num of sampling points.
n = length(pds);

%-------------------------------
%apply FFT analysis
nfft = 2^nextpow2(n);
%
PowerSpec = abs(fft(pds,nfft)).^2/n;
%show upto 2*fr in power-spectrum (sync can only flash as fast as fr/2)
npass = min([nfft/2, round((2*fr)/(fs/2)*(nfft/2))]);
%
f = fs/2*linspace(0,1,nfft/2);
f = f(1:npass);
%power magnitude in decible (dB)
p = 10*log10(PowerSpec(1:npass));
%the average of signal: the 0-th order Fourier component
avg = sqrt(PowerSpec(1)*n)/n;
%-------------------------------

%show the power spec
if viewspec
    %single-sided power spectrum
    figure('name','Power Spectrum');
    plot(f,p);
    xlabel('Frequency(Hz)');
    ylabel('Power Magnitude(dB)');
    %
end

clear nfft PowerSpec f p;

%quantitize the filtered data pds to a square wave (0,1).
%set the threshold as the average of signal, i.e, F0
threshold = avg; 
%quantitized pds in [0,1]
digPDS = (pds > threshold);

switch mode
    case {1,'rising'} %find the indices of rising edges only
        edges = find(diff(digPDS)==1);
    case {-1,'falling'}
        edges = find(diff(digPDS)==-1);
    case {0,'both'}
        edges = find(diff(digPDS)~=0);
end

%time for photodiode signal pds
tPDS = linspace(0,(n-1)*(1/fs),n);
%timestamp (onset of each stimulus event)
t = tPDS(edges);
I = edges;

clear edges tPDS digPDS;



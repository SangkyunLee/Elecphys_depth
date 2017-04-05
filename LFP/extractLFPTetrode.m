function extractLFPTetrode(sourceFile, fun, cutoff, outpath)
% Extract continuous signal.
%   extractLFPTetrode(reader, fun, cutoff, outFile) extracts a continuous
%   signal from the reader and applies the function fun before appying a
%   bandpass filter with given cutoff.
%  
% This function is a modified version of extractTetrodeCont(reader, fun, cutoff, outFile)
% AE 2011-10-15
% Sangkyun Lee 2017-03-31

% Load data


br0 = baseReader(sourceFile);
assert(~isa(br0, 'baseReaderHammer'), 'This function has not been tested for data recorded by Hammer. Watch out for sign flips and make sure it''s correct before removing this error!')
samplingRate = getSamplingRate(br0);
factors = calcDecimationFactors(samplingRate, cutoff(2));

% Get tetrode
tets = getTetrodes(br0);
nTet = numel(tets);
% nbsample = getNbSamples(br0);

% Limit memory usage
targetSize = 100 * 2.^20;                              % 100 MB chunks
blockSize = ceil(targetSize / 4 / 4);  % 4 bytes per sample x 1 tetrode(4 channels)
blockSize = blockSize + prod(factors) - mod(blockSize, prod(factors));


filttyp ='fir';
if cutoff(1)>0
    filter = filterFactory.createHighpass(max(cutoff(1)-0.5, 0.5),...
        cutoff(1), samplingRate / prod(factors),'attenuation',30);
    % highpass filtering
    cf = struct(filter);
    cf = cf.filt; 
else
    cf =[];
end


% %fp = H5Tools.createFile(outFile, 'driver', 'family');
dataall = cell(24,1);
for it = 1 : nTet    
    tetinx = tets(it);
    
    br = baseReader(sourceFile,sprintf('t%dc*',tetinx));    
    pr = packetReader(br, 1, 'stride', blockSize);          
    NB = length(pr);
    x = cell(NB,1);
    for p = 1 : NB 
    
        raw = pr(p);
        raw = toMuV(pr, raw);    
        x1 = fun(raw);    
    
        % resample
        for decFactor = factors
            x1 = decimatePackage(x1, decFactor,filttyp);
        end
        
        x{p} = x1;        
    end
    
            
    if ~isempty(cf)
        data = filtfilt(cf,1,cell2mat(x));        
    else
        data = cell2mat(x);
    end
    dataall{tetinx}=data;

    
    % write data to disc
    parent = getParentReader(pr);
%     t0 = parent(prod(factors),'t'); 
%     Att = struct('BandPass', cutoff,...
%         'Fs', samplingRate / prod(factors),...
%         't0', t0, ...
%         'scale', 1e-6,...
%         'timeunit','millisecond');
%     outfn = fullfile(outpath,sprintf('LFP_tt%d.mat',tetinx));
%     save(outfn,'data','Att','-v7.3');
    
    progress(it, nTet, 20);
end
data = dataall;
t0 = parent(prod(factors),'t'); 
Att = struct('BandPass', cutoff,...
    'Fs', samplingRate / prod(factors),...
    't0', t0, ...
    'scale', 1e-6,...
    'tetrodes',tets,...
    'deci_flttyp',filttyp,...
    'timeunit','millisecond');
outfn = fullfile(outpath,'LFP_all.mat');
save(outfn,'data','Att','-v7.3');


    
    




function decFactors = calcDecimationFactors(samplingRate, cutoffFreq)

targetRate = cutoffFreq * 2 / 0.8;		% 0.8 is the cutoff of the Chebyshev filter in decimate()
coeff = samplingRate / targetRate;

if (coeff < 2)
    error('Cannot decimate by %g', coeff)
end

% Calculate a series of decimation factors
decFactors = [];
testFactors = 13:-1:2;
while (coeff > 13)
    rems = mod(coeff, testFactors);
    [~, ix] = min(rems);
    decFactors = [decFactors, testFactors(ix)]; %#ok<AGROW>
    coeff = coeff / testFactors(ix);
end

coeff = floor(coeff);
if (coeff >= 2)
    decFactors = [decFactors, coeff];
end


function out = decimatePackage(data, factor,filttyp)

[m,n] = size(data);
% crop package at a multiple of decimation factor. this is important
% because otherwise decimate will cause random jitter of up to one sample
m = fix(m / factor) * factor; 
out = zeros(m/factor,n);
for col = 1:n
    if strcmp(filttyp,'fir')
        out(:,col) = decimate(data(1:m,col), factor,'fir');
    else
        out(:,col) = decimate(data(1:m,col), factor);
    end
end

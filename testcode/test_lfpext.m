function test_lfpext(sourceFile, fun, cutoff, outFile)
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
nbsample = getNbSamples(br0);

% Limit memory usage
targetSize = 100 * 2.^20;                              % 100 MB chunks
blockSize = ceil(targetSize / 4 / 4);  % 4 bytes per sample x 1 tetrode(4 channels)
blockSize = blockSize + prod(factors) - mod(blockSize, prod(factors));

filter = filterFactory.createHighpass(max(cutoff(1)-0.5, 0.5), cutoff(1), samplingRate / prod(factors),'attenuation',30);
NB = ceil(nbsample/blockSize);


fp = H5Tools.createFile(outFile);
% %fp = H5Tools.createFile(outFile, 'driver', 'family');

for it = 1 : nTet    
    for p = 1 : NB    


        tetinx = tets(it);        

        br = baseReader(sourceFile,sprintf('t%dc*',tetinx));        
        pr = packetReader(br, 1, 'stride', blockSize);          

        raw = pr(p);
        raw = toMuV(pr, raw);    
        x1 = fun(raw);    

        % resample
        for decFactor = factors
            x1 = decimatePackage(x1, decFactor);
        end
        % highpass filtering
        cf = struct(filter);
        cf = cf.filt;


        x = filtfilt(cf,1,x1);        



        % write data to disc
        if p == 1
            [dataSet, written] = seedDataset(fp,x);
            save('x.mat','x');
        else
            written = written + extendDataset(dataSet, x, written);
            X1=load('x.mat');
            X1.x=[X1.x; x];
            x=X1.x;
            save('x.mat','x');
        end

        progress(p, length(pr), 20);
    end
end

H5D.close(dataSet);

% channel names
channelNames = [sprintf('t%d,', tets), sprintf('ref%d,', refs)];

% Now create/copy the remaining attributes etc.
H5Tools.writeAttribute(fp, 'BandPass', cutoff);
H5Tools.writeAttribute(fp, 'Fs', samplingRate / prod(factors));
H5Tools.writeAttribute(fp, 'channelNames', channelNames(1:end-1));
H5Tools.writeAttribute(fp, 'class', 'Electrophysiology');
H5Tools.writeAttribute(fp, 'version', 1);
H5Tools.writeAttribute(fp, 'scale', 1e-6);  % data are in muV
parent = getParentReader(pr);
% Determine t0. Because of the way decimate works, when decimating by a
% factor of k, the k^th sample in the original trace is equal to the first
% sample in the decimated trace [i.e. y = decimate(x, k) --> y(1) = x(k)]
t0 = parent(prod(factors),'t'); 
H5Tools.writeAttribute(fp, 't0', t0);
H5F.close(fp);



function [dataSet, written] = seedDataset(fp, data)

nbDims = 2;
dataDims = size(data);
dataDims(1:2) = dataDims([2 1]);
dataType = H5Tools.getHDF5Type(data);
dataSpace = H5S.create_simple(nbDims, dataDims, [dataDims(1) -1]);

setProps = H5P.create('H5P_DATASET_CREATE'); % create property list
chunkSize = [4, 100000]; 		% define chunk size
chunkSize = min(chunkSize, dataDims);
H5P.set_chunk(setProps, chunkSize); % set chunk size in property list

dataSet = H5D.create(fp, '/data', dataType, dataSpace, setProps);
H5D.write(dataSet, 'H5ML_DEFAULT', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', data);

H5P.close(setProps);
H5T.close(dataType);
H5S.close(dataSpace);
written = size(data, 1);


function written = extendDataset(dataSet, data, written)

% Extend dataset
H5D.extend(dataSet, [size(data,2), written+size(data,1)])

% Select appended part of the dataset
fileSpace = H5D.get_space(dataSet);
H5S.select_hyperslab(fileSpace, 'H5S_SELECT_SET', [0, written], [], fliplr(size(data)), []);

% Create a memory dataspace of equal size.
memSpace = H5S.create_simple(2, fliplr(size(data)), []);

% And write the data
H5D.write(dataSet, 'H5ML_DEFAULT', memSpace, fileSpace, 'H5P_DEFAULT', data);

% Clean up
H5S.close(memSpace);
H5S.close(fileSpace);
written = size(data,1);



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


function out = decimatePackage(data, factor)

[m,n] = size(data);
% crop package at a multiple of decimation factor. this is important
% because otherwise decimate will cause random jitter of up to one sample
m = fix(m / factor) * factor; 
out = zeros(m/factor,n);
for col = 1:n
    out(:,col) = decimate(data(1:m,col), factor);
end

function StimImage = makeStimImage(s,ss)
%
%input: 
%s - struct array 
%s.matData - stimulation data / parameters for each trial
%ss.matData - stim session info.
%
%output: 
%
%StimImage - 2d/4d array representing a sequence of values/2d-images. 
%          - 2d vector: StimImage(trials , samples) = intensity;
%          - 4d matrix: StimImage(Nx,Ny,samples,trials) = color.

StimImage = struct; %

if ~isstruct(s); error('struct expected\n'); end
%length of array
n = length(s);
%convert the struct format if input is in new format
if isfield(s,'raw')
    for i = 1 : length(s)
        s(i) = s(i).raw;
    end
end

if isfield(ss,'raw')
    ss = ss.raw;
end
%experiment session info
expType = ss.matData.stim.params.constants.expType;
%trial params info
params = s(1).matData.params;
%
switch expType
    case {'DotMappingExperiment' , 'SquareMappingExperiment'}
        nSamples = length(params.dotLocations); %each trial has same number of sample points.
        %set 0 for gray background.
%         StimImage.data = 0.5 * ones(params.dotNumX,params.dotNumY,nSamples,n);
        StimImage.data = 128 * ones(params.dotNumX,params.dotNumY,nSamples,n);
        
%         %stim center in screen coordnate saved in stim params.(in pixels.)
         stimCenter = params.stimCenter;
        %stim center (in pixels.)
        
%         stimCenter = dim2pix(params.stimCenter,ss.matData.stim.params.constants.units,ss.matData.stim.params.constants.scrTargetDistance);
%         
%         %convert from view to screen coordinates.
%         cts = struct;
%         cts.units = ss.matData.stim.params.constants.units;
%         cts.distance = ss.matData.stim.params.constants.scrTargetDistance;
%         cts.size = ss.matData.stim.params.constants.resolution;
%         stimCenter = cotran(stimCenter,'vs',cts);
        stimCenter = round(stimCenter);
        %
        try
            dotSize = params.dotPixels;
        catch
            %older files
            dotSize = dim2pix(params.dotSize,ss.matData.stim.params.constants.units,ss.matData.stim.params.constants.scrTargetDistance);
            dotSize = round(dotSize);
        end
        
        %         
        for i = 1 : n %trial data in files will be merged into 4d matrix 
            dotLocIdx = cell(1,nSamples);
            dotColIdx = dotLocIdx;
            %imgPix = ones(params.dotNumX,params.dotNumY);
            %update params from each file
            params = s(i).matData.params;
            for j = 1 : nSamples
                %dot location index within the patch size (dotNumX,dotNumY)
                dotLocIdx{j} = bsxfun(@minus,params.dotLocations{j},stimCenter);
                dotLocIdx{j} = bsxfun(@plus,(dotLocIdx{j} / dotSize), [(params.dotNumX+1)/2; (params.dotNumY+1)/2]);
                %assume it's binary color value,i.e, either blk or white.
                %use 0-255 for color. 
                dotColIdx{j} = (params.dotColors{j}(1)); 
                %round up to integer type
                dotLocIdx{j} = round(dotLocIdx{j});
                dotColIdx{j} = round(dotColIdx{j});
                %use grayscale value if background is set to 128.
%                 %normalize color to [0 1]. %0-black; 1-white
%                 dotColIdx{j} = round(dotColIdx{j})/255;
                %imgPix(dotLocIdx{i}(1),dotLocIdx{i}(2)) = dotColIdx{i};
                %try
                    StimImage.data(dotLocIdx{j}(1),dotLocIdx{j}(2),j,i) = dotColIdx{j};
                %catch
                    %keyboard;
                %end
            end
        end
            %
    case 'NormLuminance'
            %same data dimensions for each trial
            siz = size(params.rndLumin);
            nSamples = siz(1); nNormStd = siz(2); nBlocks = siz(3);
            StimImage.data = zeros(n,prod(siz));
        for i = 1 : n
            %values of luminance in 3d matrix ---
            %(lum samples x nstd x nblocks)
            %for one trial,
            %stimulus time = stimFrames*nSamples*length(contrast)*nBlocks;
            params = s(i).matData.params;
            %reshape the matrix into (1,lum samples x nNormStd x nBlocks)
            A = reshape(params.rndLumin,1,[]); %index is the presentation sequence.
            %A contains RGB (normalized?) 
            StimImage.data(i,:) = A;
        end
        
    case 'NormGrating'
        siz = size(params.rndOrient);
        nSamples = siz(1); nNormStd = siz(2); nBlocks = siz(3);
         for i = 1 : n
            %values of orientation in 3d matrix ---
            %(lum samples x nstd x nblocks)
            %for one trial,
            %stimulus time = stimFrames*nSamples*length(contrast)*nBlocks;
            params = s(i).matData.params;
            %reshape the matrix into (1,lum samples x nNormStd x nBlocks)
            A = reshape(params.rndOrient,1,[]); %index is the presentation sequence.
            %A contains RGB (normalized?) 
            StimImage.data(i,:) = A;
        end
            
end

% %reduce data storage size.
% StimImage.data = int8(StimImage.data);
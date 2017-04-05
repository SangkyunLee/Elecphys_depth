function result = writeStimImageFile(s,outfile,writemode)
%generate the image file from DotMapping stimulation data for 
%receptive field mapping function (reverse correlation) in neuroexpoloer.

% %load stim parameters
% trialData = load(trialFile);

if ~exist('writemode','var')
    writemode = 'w';
end

%allow the multi-trial data appended to output file
fp = fopen(outfile,writemode);
params = s.matData.params;

if ~isempty(strfind(s.nevFile,'DotMappingExperiment'))

    nImages = length(params.dotLocations);
    dotLocIdx = cell(1,nImages);
    %dotColor index: 0 for black, 1 for mean background, 2 for white. 1-char
    %representation reduces the image data size.
    dotColIdx = dotLocIdx;
    for i = 1 : nImages
        %stim info(dot location index in the patch size (dotNumX,dotNumY)
        dotLocIdx{i} = bsxfun(@minus,params.dotLocations{i},params.stimCenter);
        dotLocIdx{i} = bsxfun(@plus,(dotLocIdx{i} / params.dotSize), [(params.dotNumX+1)/2; (params.dotNumY+1)/2]);
        %assume it's binary color value,i.e, either blk or white.
        dotColIdx{i} = 2*(params.dotColors{i}(1)/255);
        %round up here
        dotLocIdx{i} = round(dotLocIdx{i});
        dotColIdx{i} = round(dotColIdx{i});
    end
%     
%     %round up numbers
%     dotLocIdx = cellfun(@round,dotLocIdx);
%     dotColIdx = cellfun(@round,dotColIdx);

    %
    imgPix1 = ones(params.dotNumX,params.dotNumY);
    %dot matrix needs to be transposed for image pixels in nex file.
    nx = params.dotNumX;
    %data format string - [0,1]
    format = [repmat('%d',1,nx),'\n'];
    ny = params.dotNumY;

    for i = 1 : nImages %n
        imgPix = imgPix1;
        %reset the dot color value for each stimulus image
        imgPix(dotLocIdx{i}(1),dotLocIdx{i}(2)) = dotColIdx{i};
%         %transpose the imgPix so that the column matches the y-coordinates
%         imgPix = imgPix';
        %append blank line to seperate each image matrix
        if i > 1 ;  fprintf(fp,'\n'); end
        for j = 1 : ny
            fprintf(fp,format,imgPix(:,j));
        end
    end

elseif ~isempty(strfind(s.nevFile,'NormLuminance'))
    A = reshape(s.matData.params.rndLumin,1,[]);
    A = round(A);
    format = repmat('%03d%03d\n',1,2);
    for i = 1 : length(A)
        fprintf(fp,format,repmat(A(i),1,4));
    end

else
    %
end
fclose(fp);
result = true;


        
        
        
        
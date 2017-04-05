function checkSaturation(fd)
%check the NSx file saturation 
%

files = rdir(fullfile(fd,'**\*.ns5'));

for m = 1 : length(files)
    filename = files(m).name;
    h = openNSx(filename); %open the header info.
    
    N = h.MetaTags.DataPoints ;
    readDataPoints = 100*1e6; %chunk size
    nChunk = ceil(N/readDataPoints);
    readChunks = 1 : nChunk;
    
    Sat(m).Filename = filename;
    Sat(m).DataPoints = N;
    Sat(m).ChunkPoints = readDataPoints;
    Sat(m).nChunk = nChunk;
    %Sat(i).Index = index; 

    Index = cell(h.MetaTags.ChannelCount,nChunk);
    
    for i = 1 : h.MetaTags.ChannelCount
        
        chID = h.MetaTags.ChannelID(i);
        %if chID > 128; continue; end;
        fprintf('%d: read data in ch%d ...\n',i,chID);
        nSat = 0;
        for j = 1 : nChunk
            %index{i}{j} = []; 
            if ~any(j==readChunks); continue; end
            p = [1,readDataPoints]+(j-1)*readDataPoints;
            if p(1) > h.MetaTags.DataPoints ; break; end
            if p(2) > h.MetaTags.DataPoints ; p(2) = h.MetaTags.DataPoints; end;
            
            NSx = openNSx(filename,'read','channels',chID,'duration',p); %read individual channels.
                        
            x = find(abs(NSx.Data)==(2^15-1));
            
            Index{i}{j} = x;
            
            nSat = nSat + length(x);
        end
        
        if nSat > 0
            fprintf('%d|%d)%s,found %d pts\n', m,length(files),filename, i,nSat);
        end
        
    end
    
    Sat(m).Index = Index;
    
    %save to file.
    

end
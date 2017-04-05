function extractPTDRaw(filename)
%extract the continuous ptd signal from nsx file
%   
h = openNSx(filename);      %open the header info.
N = h.MetaTags.DataPoints ; 
readDataPoints = 100*1e6;   %chunk size
nChunk = ceil(N/readDataPoints);
readChunks = 1 : nChunk;

chID = 137; % 9th analog channel
if ~any(chID == h.MetaTags.ChannelID)
    return;
end

PTD.channel = chID;
PTD.data = zeros(1,N);

for j = 1 : nChunk
    %index{i}{j} = [];
    if ~any(j==readChunks); continue; end
    p = [1,readDataPoints]+(j-1)*readDataPoints;
    if p(1) > h.MetaTags.DataPoints ; break; end
    if p(2) > h.MetaTags.DataPoints ; p(2) = h.MetaTags.DataPoints; end;
    
    NSx = openNSx(filename,'read','channels',chID,'duration',p); %read individual channels.
    
    PTD.data(p(1):p(2)) = NSx.Data;
    %x = find(abs(NSx.Data)==(2^15-1));
end

%save to file.
[fpath,fname,fext] = fileparts(filename);
outfile = fullfile(fpath,'PTD.mat');
save(outfile,'PTD','-v7.3');

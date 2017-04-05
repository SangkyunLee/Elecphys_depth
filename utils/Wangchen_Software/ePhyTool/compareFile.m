fref = 'c:\CEREBUS\DataFile\CerebusData\acute\FlashingBar\2011-Oct-20\16-53-03\acute_FlashingBar016.ns5';
ftar = fref; ftar(1) = 'j';

NSref = openNSx(fref);
NStar = openNSx(ftar);

if NSref.MetaTags.DataPoints ~= NStar.MetaTags.DataPoints
    error('unequal datapoints');
end

N = NSref.MetaTags.DataPoints ;

readDataPoints = 100*1e6; %chunk size

nChunk = ceil(N/readDataPoints);

readChunks = 1 : nChunk;

h = NSref;

clear data;

for i = 1 : h.MetaTags.ChannelCount
    nref = 0;
    ntar = 0;
    index{i}=[];
    data{i} = [];
    nerr = 0;
    
    chID = h.MetaTags.ChannelID(i);
    %if chID > 128; continue; end;
    x = [];
    fprintf('%d: read data in ch%d ...\n',i,chID); 
    for j = 1 : nChunk
        if ~any(j==readChunks); continue; end
        p = [1,readDataPoints]+(j-1)*readDataPoints;
        if p(1) > h.MetaTags.DataPoints ; break; end
        if p(2) > h.MetaTags.DataPoints ; p(2) = h.MetaTags.DataPoints; end;
         href = openNSx(fref,'read','channels',chID,'duration',p); %read individual channels.
         htar = openNSx(ftar,'read','channels',chID,'duration',p); %read individual channels.
         nref = nref + length(href.Data);
         ntar = ntar + length(htar.Data);
         
         x = find(href.Data-htar.Data ~=0);
         if ~isempty(x)
             nerr = nerr + length(x);
             fprintf('Diff index %d, ch%d, chunk %d, ndiff %d\n',i, chID, j, length(x));
             data{i}{1} = zeros(length(x),50);
             data{i}{2} = zeros(length(x),50);
             for k = 1 : length(x)
                  if length(href.Data)-x(k)<30
                      L = length(href.Data)-x(k);
                  else
                      L = 30;
                  end
                  data{i}{1}=href.Data(x(k):x(k)+L);
                  data{i}{2}=htar.Data(x(k):x(k)+L);
             end
         end
    
    end
    
    if nref ~= ntar
        fprintf('%not eq with chan %d: Ref %d, Tar %d\n', chID,nref,ntar);
    end
   
end
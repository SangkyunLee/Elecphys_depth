function t = getNeuralEventTimeStamp(NEV,chan,unit)
%return spike timestamps for given channel 

I = (NEV.Data.Spikes.Electrode == chan) ;

M = ones(size(I));

if nargin ==3
    for i = 1 : length(unit)
        M = M & (NEV.Data.Spikes.Unit == unit(i));
    end
end

t = double(NEV.Data.Spikes.TimeStamp(I & M))/double(NEV.MetaTags.SampleRes) ;




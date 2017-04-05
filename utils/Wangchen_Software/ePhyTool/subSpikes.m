function s = subSpikes(s,spikeFile)
%substitute the spikes from blackrock nev files with rethreshold (Spikes.mat)

load(spikeFile);

M = cell(length(s.nevData.neurons),1);

for i = 1 : length(M)
    
    M{i}.name = s.nevData.neurons{i}.name;
    chID = str2num(strrep(M{i}.name,'chan',''));
    
    m = find(Spikes.Channel == chID);
        
    M{i}.timestamps = transpose(Spikes.Timestamp{m}/1000); %in sec
    M{i}.units = uint8(zeros(length(M{i}.timestamps),1));
    
end

s.nevData.neurons = M;
datapath = 'i:\';  %path to tetrode data
tetrode  = 1    ;  %tetrode number

clear model manual; 

load(fullfile(datapath,sprintf('model%d.mat',tetrode)));
load(fullfile(datapath,sprintf('manual%d.mat',tetrode)));

fields = fieldnames(manual);

for i = 1 : length(fields)
    if strcmp(fields{i},'SpikeTimes')
        continue;
    end
    model.(fields{i}) = manual.(fields{i});
end

manual = ManualClustering(model);

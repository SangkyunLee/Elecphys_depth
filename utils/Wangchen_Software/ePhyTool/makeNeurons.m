function neurons = makeNeurons(s,n)
%create cell struct to store the loaded neural data. 
%input : 
%s : struct from data file loaders.
%n : channel numbers. 
%neurons{}: 
%         .name  : channel name, string
%         .units : (removed), redudant 
%         .timestamps : 
%neurons{}.clusters{}: single neuron cluster 
%neurons{}.clusters{}.id : cluster id. 0 for unsorted. 255 for noise
%neurons{}.clusters{}.timestamps : timestamps of the cluster. (redutant 
%add 'channel' and 'electrode' fields
%
if nargin < 2
    n = length(s.nevData.neurons);
end

%column-wise for neurons, same structure as in s.
neurons = cell(n,1);
%central use 'chan' or 'elec'. try one or another if it crushes on line32.
chanToken = 'elec';
%chanToken = 'chan'; %cerebus version 6 and above.

for i = 1 : n
    neurons{i}.name = s.nevData.neurons{i}.name;
    %
%     neurons{i}.units = s.nevData.neurons{i}.units;
    %
    neurons{i}.timestamps = s.nevData.neurons{i}.timestamps;
    if i == 1 && isempty(regexpi(neurons{i}.name,chanToken,'match'))
        chanToken = 'chan';
    end
    elecname = regexpi(neurons{i}.name,chanToken,'split');%switch token if error
    elecnum = str2num(elecname{2});
    %
    neurons{i}.channel = elecnum;
    neurons{i}.electrode = elecnum;
    %
    %if isempty(elecname) || elecnum > 128
    if isempty(elecname)
        continue; %skip analog channel timestamps from thershold filtering
    end
    lu = unique(s.nevData.neurons{i}.units);
    nu = length(lu);
    neurons{i}.clusters = cell(nu,1);
    for j = 1 : nu
        %single unit sort uid. 0: unsorted.
        neurons{i}.clusters{j}.id = lu(j);
        %extract single unit timestamps
        ts = s.nevData.neurons{i}.timestamps(s.nevData.neurons{i}.units==lu(j));
        neurons{i}.clusters{j}.timestamps = ts;
    end
end


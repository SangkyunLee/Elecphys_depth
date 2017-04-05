function neurons = filtSpikes(neurons,refEvent,t)
%filter the spikes in neurons struct with the filter window given by the offset (t) referenced to
%timestamps of events (refEvent). Timestamps are in sec. 
%eg. neurons = filtSpikes(neurons,OnsetTimestamps,[-1 0])
%

for i = 1 : length(neurons)
    if isfield(neurons{i},'timestamps')
        x = neurons{i}.timestamps;
        x = filtSpikesInWindow(x,refEvent,t);
        neurons{i}.timestamps = x;
    end
    for j = 1 : length(neurons{i}.clusters)
        if isfield(neurons{i}.clusters{j},'timestamps')
            x = neurons{i}.clusters{j}.timestamps;
            x = filtSpikesInWindow(x,refEvent,t);
            neurons{i}.clusters{j}.timestamps = x;
        end
        for k = 1 : length(neurons{i}.clusters{j}.class)
            if isfield(neurons{i}.clusters{j}.class{k},'timestamps')
                x = neurons{i}.clusters{j}.class{k}.timestamps;
                x = filtSpikesInWindow(x,refEvent,t);
                neurons{i}.clusters{j}.class{k}.timestamps = x;
            end

            for m = 1 : length(neurons{i}.clusters{j}.class{k}.member)
                if isfield(neurons{i}.clusters{j}.class{k}.member{m},'timestamps')
                    x = neurons{i}.clusters{j}.class{k}.member{m}.timestamps;
                    x = filtSpikesInWindow(x,refEvent,t);
                    neurons{i}.clusters{j}.class{k}.member{m}.timestamps = x;
                end
            end
        end
    end
end

function y = filtSpikesInWindow(x,refEvent,t)
%filter the timestamps x with time window (refEvent + t);
fw1 = refEvent + t(1);
fw2 = refEvent + t(2);

M = false;
for i = 1 : length(refEvent)
    M = M | (x>=fw1(i) & x < fw2(i));
end

y = x(M);




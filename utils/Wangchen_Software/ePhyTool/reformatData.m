function t = reformatData(s,neurons)
%reformat the 'old' data structure to the new data structure, to seperate
%the trial info, trial data and the analysis result.
%s -- data struct
%s.nevFolder
%s.nevFile
%s.nevData
%
%if 'neurons' struct is given, incooprate the 'neurons' into the trial
%data struct

n = length(s);
t = struct;

for i = 1 : n
    t(i).raw.matData = s(i).matData;
    t(i).raw.nexData = s(i).nexData;
    t(i).raw.nevData = s(i).nevData;
    %
    t(i).info.matFile = s(i).matFile;
    t(i).info.matFolder = s(i).matFolder;
    t(i).info.nexFile = s(i).nexFile;
    t(i).info.nexFolder = s(i).nexFolder;
    t(i).info.nevFile = s(i).nevFile;
    t(i).info.nevFolder = s(i).nevFolder;
    %
end

if nargin < 2
    return;
end

%when 'neurons' is given, the s should be the single struct. 
%
%neurons: cell struct from makeNeurons function.
%neurons{}.name
%         .units (removed)
%         .timestamps
%         .clusters{}
%         .clusters{}.id 
%         .clusters{}.timestamps
%
%append new fields to neurons after classifying stim events. 
%neurons{}.clusters{}.class{}
%                             .name   --- e.g 'contrast'
%                             .values --- e.g [6 35]
%                             .member{}
%                             .member{}.value --- e.g 6
%                             .member{}.timestamps --- 
%

%trial.proc stores the processed result on the raw data. 
%trial.proc.neurons{}.name 
%                    .clusters{}
%                    .clusters{}.id    --- sorted unit id. 0 unsorted, [1-n] sorted units, 255
%                                          noise.
%                    .clusters{}.class{} 
%                    .clusters{}.class{}.name  --- classifier name, e.g, 'contrast'
%                                       .values --- classifier value, e.g, [6 35]
%                                       .member{} --- 
%                                       .member{}.value --- class member value, e.g, 6
%add fields for holding analysis results.
%                                       .member{}.name  --- analysis type 
%                                       .member{}.data  --- stores the analysis result, e.g, firing rate


for i = 1 : n
    for j = 1 : length(neurons)
        t(i).proc.neurons{j} = neurons{j};
        for k = 1 : length(neurons{j}.clusters)
            for m = 1 : length(neurons{j}.clusters{k}.class)
                    for c = 1 : length(neurons{j}.clusters{k}.class{m}.member)
                        t(i).proc.neurons{j}.clusters{k}.class{m}.member{c}.name = []; %variable name. e.g,'contrast'
                        %t(i).proc.neurons{j}.clusters{k}.class{m}.member{c}.value = [];%variable value. e.g, [5]
                        t(i).proc.neurons{j}.clusters{k}.class{m}.member{c}.data = []; %
                    end
            end
        end
    end
end


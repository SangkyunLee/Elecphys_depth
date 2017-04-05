function savemanout(model,fout)
% save the subfields in input variable that store the manual clustering result
%
% model: output variable from manual clustering that stores the manual clustering result  
% fout : filename to save the manual clustering result stripped from model.

saveField = {'ClusterAssignment',...
             'GroupingAssignment',...
             'ClusterTags',...
             'ContaminationMatrix'};

manual = struct;
for i = 1 : length(saveField)
    manual.(saveField{i}) = model.(saveField{i});
end

%save the spike timestamps into manual struct, so that most of analysis can be done
%with manual data file.
manual.('SpikeTimes') = model.('SpikeTimes');

save(fout,'manual');




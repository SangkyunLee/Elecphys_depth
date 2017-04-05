function saveManualResult(x,f)
%save the subfields in 'manual' variable that store the manual clustering result
%the 
%x: manual variable that saves the manual sorting  
%f: modelXX.mat file

saveField = {'ClusterAssignment',...
             'GroupingAssignment',...
             'ClusterTags',...
             'ContaminationMatrix'};

manual = struct;
for i = 1 : length(saveField)
    manual.(saveField{i}) = x.(saveField{i});
end

fout = strrep(f,'model','manual');
save(fout,'manual');


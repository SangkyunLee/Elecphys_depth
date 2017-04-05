function manual = loadManualResult(x,f)
%load the subfields in 'manual' variable that store the manual clustering result
%merge with 'model' to make the 'manual' variable.
%x: model variable that saves the manual sorting  
%f: manualXX.mat file

saveField = {'ClusterAssignment',...
             'GroupingAssignment',...
             'ClusterTags',...
             'ContaminationMatrix'};

fout = strrep(f,'model','manual');
r = load(fout); %load manual variable
manual = x;

for i = 1 : length(saveField)
    manual.(saveField{i}) = r.manual.(saveField{i});
end


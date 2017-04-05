function output = loadman2mod(model,manfile)
% load 'manual' variable that store the manual clustering result
% into the 'model' from auto clustering result. 
% model   :  model variable that saves the auto sorting  
% manfile :  manual filename. ('manualXX.mat')

saveField = {'ClusterAssignment',...
             'GroupingAssignment',...
             'ClusterTags',...
             'ContaminationMatrix'};

output = model;
%
load(manfile); %load manual variable

for i = 1 : length(saveField)
    output.(saveField{i}) = manual.(saveField{i});
end


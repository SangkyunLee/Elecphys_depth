function event = makeStimEvent(s)
%make event struct from nex data.
%

if isfield(s,'raw')
    marker = s.raw.nexData.markers{1};
else
    marker = s.nexData.markers{1};
end

% %show the encoding variables in the stim event LUT
%     marker = s_SETS.nexData.markers{1};
%------------------------------------------------------

encode_vars = cell(1,length(marker.values));

for j = 1 : length(marker.values)
    encode_vars{j} = marker.values{j}.name;
end
%
%fprintf('[File #%d %s] -- \tEncoding Variables : \n',i,s_SETS.nexFile);
%
event = struct; %reset event
for j = 1 : length(encode_vars)
    event(j).type = encode_vars{j};
    event(j).string = '>0';
    event(j).operator = '&';
end
% 
% %show the range of variables
% for j = 1 : length(encode_vars)
%     %the #values for each variable
%     %num = length(ss.nexData.contvars{i}.name)
%     if j ~= length(encode_vars)
%         fprintf('[%d]:\t%s - Min=%d,Max=%d  \n',...
%             j,event(j).type,min(StimEventLUT(:,j)),max(StimEventLUT(:,j)));
%     end
% end
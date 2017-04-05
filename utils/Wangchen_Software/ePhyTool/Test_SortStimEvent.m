ss = trimNEVData(s,1,1);
%show the encoding variables in the stim event LUT
marker = ss.nexData.markers{1};

for i = 1 : length(marker.values)
    encode_vars{i} = marker.values{i}.name;
end

for i = 1 : length(ss.nexData.contvars)
    cont_vars{i} = '';
end

fprintf('Encoding Variables : \n');

for i = 1 : length(encode_vars)
    event(i).type = encode_vars{i};
    event(i).string = '>0';
    event(i).operator = '&';
    %the #values for each variable
    %num = length(ss.nexData.contvars{i}.name)
    if i ~= length(encode_vars)
        fprintf('[%d]:\t%s - #Values  \n',i,event(i).type);
    end
end

event(3).string = '>180';

ss = filtSETS(ss,1,8/60);

[ timestamps, codes ] = sortStimEvent(ss,event);
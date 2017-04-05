function s = smNeurons(neurons,viewOption,act)
%smooth data field 'sta' in 'neurons' struct 
%sum data field in 'neurons' struct across channels/clusters.
%neurons: data struct by makeNeurons
%opt : view option struct
%act : 'smooth' or 'sum'
%

%copy  'neurons' struct.
s = neurons;
iClass = 1; %work on 1st class by default
%
%smooth 1d data
d = ndims(neurons{1}.clusters{1}.class{iClass}.member{1}.sta);
[xdim,ydim,zdim]= size(neurons{1}.clusters{1}.class{iClass}.member{1}.sta);

switch act
    case 'smooth'
        %
        for k = 1 : length(neurons)
            for kk = 1 : length(neurons{k}.clusters)
                for mm = 1 : length(neurons{k}.clusters{kk}.class{iClass}.member)
                    if d == 2 %vector 
                    s{k}.clusters{kk}.class{iClass}.member{mm}.sta = ...
                        smooth(neurons{k}.clusters{kk}.class{iClass}.member{mm}.sta);
                    elseif d == 3 %2d array
                        for i = 1 : zdim
                        s{k}.clusters{kk}.class{iClass}.member{mm}.sta(:,:,i) = ...
                        smooth2a(neurons{k}.clusters{kk}.class{iClass}.member{mm}.sta(:,:,i),viewOption.smoothSize(1),viewOption.smoothSize(2));
                        end
                    else
                        %
                    end
                end
            end
        end
        %
    case 'sum'
       %sum all clusters
       sta = 0;
       for k = 1 : length(neurons)
            for kk = 1 : length(neurons{k}.clusters)
                for mm = 1 : length(neurons{k}.clusters{kk}.class{iClass}.member)
                    sta = sta + (neurons{k}.clusters{kk}.class{iClass}.member{mm}.sta);
                end
            end
        end
       %assign the sta sum to the first entity in s, overwirting the orignal 'sta' data.
       s{1}.clusters{1}.class{iClass}.member{1}.sta = sta;
       s{1}.sta = sta;
        
end
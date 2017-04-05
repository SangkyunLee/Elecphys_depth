function M = SU2MU(neuron)
%convert the 'neuron' data structure to combine the single units into one unit for MUA.  
%M : 'neuron' structure with merged SU data. 

M = cell(length(neuron),1);
for i = 1 : length(neuron)
    %copy the common fields
    fns = fieldnames(neuron{i});
    M{i} = neuron{i};
    
    invalid = [];
    
    for j = 1 : length(M{i}.clusters)
        if M{i}.clusters{j}.id < 0 || M{i}.clusters{j}.id == 255 %invalid units (classified as artifacts)
            invalid = [invalid j];
        end
    end
    
    M{i}.clusters(invalid) =[]; %remove the invalid units
    neuron{i}.clusters(invalid) =[]; 
    
    if length(M{i}.clusters)==0
        continue;
    end
    %keep one 'clusters' only
    if length(M{i}.clusters) > 1
        M{i}.clusters(2:end) = [];
    end
    
    M{i}.clusters{1}.id = 0 ; %set the MU id.
    M{i}.clusters{1}.timestamps = [];
%     M{i}.clusters{1}.basefr = 0;
    for m = 1 : 2
        M{i}.clusters{1}.class{1}.member{m}.timestamps =[];
%         M{i}.clusters{1}.class{1}.member{m}.firingRate =[];
%         M{i}.clusters{1}.class{1}.member{m}.sta = [];
%         M{i}.clusters{1}.class{1}.member{m}.stc = [];
%         M{i}.clusters{1}.class{1}.member{m}.std = [];
%         M{i}.clusters{1}.class{1}.member{m}.fit = [];
%         M{i}.clusters{1}.class{1}.member{m}.fitcoeff = [];
%         M{i}.clusters{1}.class{1}.member{m}.fitgoodness = 0;
%         M{i}.clusters{1}.class{1}.member{m}.spikes = 0;
    end
        
    for j = 1 : length(neuron{i}.clusters)
        M{i}.clusters{1}.timestamps = cat(1,M{i}.clusters{1}.timestamps,neuron{i}.clusters{j}.timestamps); 
%         M{i}.clusters{1}.basefr = M{i}.clusters{1}.basefr + neuron{i}.clusters{j}.basefr;
        M{i}.clusters{1}.class{1}.member{1}.timestamps = cat(1,M{i}.clusters{1}.class{1}.member{1}.timestamps,...
            neuron{i}.clusters{j}.class{1}.member{1}.timestamps);
        M{i}.clusters{1}.class{1}.member{2}.timestamps = cat(1,M{i}.clusters{1}.class{1}.member{2}.timestamps,...
            neuron{i}.clusters{j}.class{1}.member{2}.timestamps);
    end
    
    M{i}.clusters{1}.timestamps = sort(M{i}.clusters{1}.timestamps);
    M{i}.clusters{1}.class{1}.member{1}.timestamps = sort(M{i}.clusters{1}.class{1}.member{1}.timestamps);
    M{i}.clusters{1}.class{1}.member{2}.timestamps = sort(M{i}.clusters{1}.class{1}.member{2}.timestamps);
end


    
    
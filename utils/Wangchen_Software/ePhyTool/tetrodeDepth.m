n = length(tet);

nsession = max(tet(1).turnStop);

ttdep = -1*ones(nsession,24);

for i = 1 : n
    if ~isempty(strfind(tet(i).id,'tt'))
        id = str2num(tet(i).id(3:end));
    else
        continue;
    end
    
    if isempty(tet(i).turnStop >0)
        continue;
    end

    %find the depths per tet
    K = tet(i).turnStop>0;
    
    ttdep(tet(i).turnStop(K),id) = tet(i).turnDepth(K);
    
end

depV = zeros(numel(ttdep),2);
depV(:,1) = repmat([1:24]', nsession, 1);
depV(:,2) = reshape(ttdep',[],1);        

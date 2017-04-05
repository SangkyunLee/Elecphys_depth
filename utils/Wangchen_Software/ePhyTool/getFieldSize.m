function n = getFieldSize(s,t,r)
%get the number of requested fields in 'trial' or 'neuron' struct.
%s --- input struct
%t --- input struct type, 'trials' or 'neurons'
%  --- trial struct: 
%      trial.(proc).neurons.clusters.class.member.(field)
%r --- index array for the request fields:  
%      [i,j,k,l,m] for fieldsize in 'i-th trial,j-th neuron,k-th clusters,l-th class,m-th
%      member' if 'trial' is specified. the indices are shifted accordingly
%      if 'neurons'.
%e.g., n = getFieldSize(s,'trials',[1 3 4])
%
%
%
switch t
    case 'trials'
        
    case 'neurons'
        
end


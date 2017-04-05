function yc = csum(y,m,n)
%recalculate the sum over combined bins. 
%y : spike counts matrix (events,times).  
%m : number of bins for summation
%n : number of bins to exculde at the start of series.

%number of events/bins
[ne,nb] = size(y);
%number of combined bins
nc = round(nb/m);
%
yc = zeros(ne,nc);
%
for i = 1 : nc
    
    if i == 1 
        c = (n+1) : m ;         %number of bins to sum up
    elseif i == nc
        c = ((i-1)*m+1) : nb;
    else
        c = (1:m) + (i-1)*m;
    end
    %sum in the combined bins
    yc(:,i) = sum(y(:,c),2) ;
end
    
       
    
    


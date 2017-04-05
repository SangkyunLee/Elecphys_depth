function data = padElement(s,v,fieldname)
%transform a struct array to 2d matrix and pad with specified element
%s - input struct array. s(i) where i trial index.
%v - padding element. default is 0.
%fieldname - data containing feild in s. default is 'data'
%data - output 2d matrix; data(i,j) where i trial index,j element index
%              
%WW2010
%

if ~isstruct(s)
    error('not a struct for padElement. quit\n');
end

if nargin == 1 
    v = 0;  %default is 0-padding
    fieldname = 'data'; 
elseif nargin == 2
    fieldname = 'data'; %default is in 'data' field 
else
    %
end

%fieldnames of input struct
fields = fieldnames(s);
%check if specified fieldname is found in s
d = strmatch(fieldname,fields,'exact');

if isempty(d)
    error('field %s not found in input struct\n',fieldname);
end

%length of struct array (number of trials in case of sta computation) 
nt = length(s);
%number of samples for each trial
ne = zeros(1,nt);
%find the length of each struct 
for i = 1 : nt
    if i == 1 
        dim = ndims(s(i).(fieldname));
        siz = size(s(i).(fieldname));
        if dim ==1 || (dim ==2 && min(siz)==1) %singleton or 1d vector
            sta = 1; %1d vector. input to sta1
        elseif (dim==2&& min(siz)>1) || dim ==3 %2d singleton or 3d matrix
            sta = 2; % input to sta2
        else
            sta = 0;
        end
    end
    
    switch sta
        case 1
            %number of samples in the vector
            ne(i) = length(s(i).(fieldname));
%         case 2
%             ne(i) = size(s(i).(fieldname),3); %(x,y,sample) 
    end
end

switch sta
    case 1
        %preset the data to the padding element.
        data = ones(nt,max(ne)) * v;
        for i = 1 : nt
            data(i,1:ne(i))= s(i).(fieldname);
        end
%     case 2
%         data = ones(siz(1),siz(2),max(ne),nt) * v;
%         for i = 1 : nt
%             data(:,:,1:ne(i),i)= reshape(s(i).(fieldname),[siz(1),siz(2),ne(i),1]);
%         end
     otherwise
        data = [];
end



    

    
    
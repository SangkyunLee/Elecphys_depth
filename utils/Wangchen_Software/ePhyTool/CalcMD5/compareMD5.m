function R = compareMD5(M,Mref,token)
%check the MD5 struct 'M' against the reference struct 'Mref'.
%
R = zeros(1,length(M));
if nargin < 3
    token = '\acute\';
end

for i = 1 : length(M)
    m = strfind(M(i).Filename,token);
    keyFilename = M(i).Filename(m : end);
    for j = 1 : length(Mref)
        mm = strfind(Mref(j).Filename,token);
        refFilename = Mref(j).Filename(mm : end);
        if strcmpi(keyFilename,refFilename)
            %compare the MD5
            if strcmp(M(i).MD5,Mref(j).MD5) && M(i).TYPE==Mref(j).TYPE
                R(i) = 1 ; 
            end
        end
    end
end

I = find(R==0);

fprintf('Difference found %d records -->\n',length(I));

for i = 1 : length(I)
    fprintf('%d %s\n', i, M(I(i)).Filename);
end

    

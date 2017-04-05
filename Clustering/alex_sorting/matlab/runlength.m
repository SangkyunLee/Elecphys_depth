% runlength(s) count contiguous ones since the last zero.
% Inputs: s is an array of logicals or doubles containing ones or zeros
% Output: s is the count of ones in s sinse the last zero.
% DY: 2010-09-05
function s=runlength(s)
i = find(s);
s = double(s);
for i=i(2:end)
    s(i)=s(i-1)+1;
end
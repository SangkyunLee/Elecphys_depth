function yi = interpLNN(x,y,xi)
%interpolate the stimulus vectors using lower-nearest-neighbor method instead of standard linear method 
%sampling array xi needs to be inside of x. and xi is up-sampling x
%

%translate the inputs to row vectors
if size(x,1) > size(x,2)
    x = x';
end

if size(y,1) > size(y,2)
    y = y';
end

if size(xi,1) > size(xi,2)
    xi = xi';
end

%find the lower-nearest neighbor indices
I = lnn(x,xi);
%find the upper nearest neighbor indices
%J = unn(x,xi); %less efficient
J = I + 1; 
%
J(J>length(x))=length(x);
%lnn elements in x
xL = x(I);
yL = y(I);
%Unn elements in x
xU = x(J);
yU = y(J);
%bins in x
dx = zeros(size(x));
dx(1:end-1) = diff(x);
%pad the trailing element so that each element in x has corresponding value.
dx(end) = (x(end)-x(1))/(length(x)-1); %average bin size
%bin size in xi
dxi = zeros(size(xi));
dxi(1:end-1) = diff(xi);
dxi(end) = (xi(end)-xi(1))/(length(xi)-1);
%dxi(end) = mean(dxi);
%bin size in x for lnn 
dxL = dx(I);
%bin size difference
dbin = dxL - dxi; 
%distance of xi elements from lnn elements in x
d = xi - xL;
%
yi = zeros(size(xi));
%indices for which dxi is inside dx
MI = d<=dbin;
%indices for which dxi is crossing dx
MC = ~MI;
%
yi(MI) = yL(MI);
%
offset = d(MC)-dbin(MC);
%
yi(MC) = (offset.*yU(MC) + (dxi(MC)-offset).*yL(MC))./dxi(MC);






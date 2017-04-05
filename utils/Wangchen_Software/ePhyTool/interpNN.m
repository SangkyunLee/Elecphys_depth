function yi = interpNN(x,y,xi)
%interpolate stimulus vectors with nearest-neighbors (lower bound)
%trim the input xi and call interpLNN to perform the interpolation

%
yi = zeros(size(xi));
I1 = xi < x(1) ;
I2 = xi > x(end);
%I = (xi < x(1)) | (xi > x(end));
I = I1 | I2; 
%trim the input
xr = xi(~I);
yr = interpLNN(x,y,xr);
%
yi(~I) = yr;
%pad the out-of-bound elements with zero or neighbor elements.
yi(I1) = yr(1);
%
yi(I2) = yr(end);
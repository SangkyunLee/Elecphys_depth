function [X,Y,gratingImage]=rfmDrawGrating(dim,loc,sfp,phase,orient)

%dia = min([screenWidth screenHeight]) - 1;
%radius = dia / 2;
%if isempty(numCycles); numCycles = 5; end
% % Create the matrix for the grating.
% gratingImage = ( cos( ( 0:dia ) * numCycles / dia * 2 * pi + phase ) + 1 ) * 254 / 2 + 1;
% gratingImage = repmat( gratingImage, [ ( dia + 1 ) 1 ] );
% % Cut out the circular window.
% for y = 0 : dia
%     ycentred = y - radius;
%     x = sqrt( radius * radius - ycentred * ycentred );
%     gratingImage( y + 1, 1 : floor( radius - x ) ) = 0;
%     gratingImage( y + 1, floor( radius + x + 1 ) : ( dia + 1 ) ) = 0;
% end;
dimX = dim(1);
try dimY = dim(2); catch dimY = dimX; end;
x0 = loc(1); y0 = loc(2);
x = -dimX:dimX; y = -dimY:dimY;
x = x + loc(1);
y = y + loc(2);
[X,Y]= meshgrid(x,y);

%R = sqrt(X.^2+Y.^2);

qx = sfp(1)*cos(orient);
qy = sfp(1)*sin(orient);

gratingImage = (1+cos(2*pi*qx*(X-x0) + 2*pi*qy*(Y-y0) + phase))/2; 

%sfp --- spatial frequency: number of cycles per pixel.(note ! : not per degree).




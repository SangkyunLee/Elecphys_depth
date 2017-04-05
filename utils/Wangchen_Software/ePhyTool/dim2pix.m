function pxs = dim2pix(dms,dmsUnits,dis)
%convert stimulus-related dimensions in arbituary units into pixel-base. 
%WW2010
%%screen pixel size in mm.
%units: 'pixel','mm','cm','degree','radian'
%Usage: dim2pix(5,'degree',600) --- 5 deg at 600mm distance 

whichScreen = 0;
%physical size of screen in mm
[w,h] = Screen(whichScreen,'DisplaySize');
%resolution of screen in pixels
[xr,yr] = Screen(whichScreen,'WindowSize');
%screen pixel pitch in mm. 
scrPixelPitch = h / yr ;
displaySize = [w; h];


%the units for the given dimensions.eg., mm,cm,degree,pixel.radian
%dmsUnits = getParam(e,'units');
%the screen to eye distance in mm (fixed units)
scrTargetDistance = dis;

%conversion factor 

switch lower(dmsUnits)
    case {'pixel','pixels','pix'}
        cvtFactor = 1;
    case 'mm'
        cvtFactor = 1 / scrPixelPitch ; 
    case 'cm'
        cvtFactor = 1*10 / scrPixelPitch;
    case {'degree','degrees','deg'}
        cvtFactor = (scrTargetDistance/scrPixelPitch) * tan(dms*pi/180) ./ (dms+eps); %
    case 'radian'
        cvtFactor = (scrTargetDistance/scrPixelPitch) * tan(dms) ./ (dms+eps); %
end

pxs = cvtFactor .* dms;
%
%pxs = round(pxs);

%fprintf('\n%f %s = %f %s \n @ %d(mm) Distance', dms, dmsUnits, pxs, 'pixel',dis);

fprintf('Dimension Conversion Table\n');
fprintf('X(%s)\t Y(pixel) \t @Distance(mm)\n',dmsUnits);
for i = 1 : length(pxs)
    fprintf('%f\t %f \t %d\n',dms(i),pxs(i),scrTargetDistance);
end
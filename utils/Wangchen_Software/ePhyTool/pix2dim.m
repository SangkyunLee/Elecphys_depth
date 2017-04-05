function dms = pix2dim(pix,dmsUnits,dis)
%convert stimulus-related dimensions in pixel into arbituary units
%WW2010
%%screen pixel size in mm.
%units: 'pixel','mm','cm','degree','radian'
%Usage: pix2dim(50,'degree',600) --- 50 pixel at 600mm distance in terms of degree 

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
        cvtFactor = 1 * scrPixelPitch ; 
    case 'cm'
        cvtFactor = 1 * scrPixelPitch / 10;
    case {'degree','degrees','deg'}
        %cvtFactor = (scrTargetDistance/scrPixelPitch) * tan(dms*pi/180) ./ (dms+eps); %
        %pixAng = 
        cvtFactor = (atan(pix*scrPixelPitch/scrTargetDistance) * 180/pi) ./ pix; %
    case 'radian'
        %cvtFactor = (scrTargetDistance/scrPixelPitch) * tan(dms) ./ (dms+eps); %
        cvtFactor = (atan(pix*scrPixelPitch/scrTargetDistance)) ./ pix; %
end

dms = cvtFactor .* pix;

%pxs = round(pxs);

%fprintf('\n%d %s = %f %s @ %d(mm) Distance\n', pix, 'pixel', dms,dmsUnits, dis);

fprintf('Dimension Conversion Table\n');
fprintf('X(pixel)\t Y(%s) \t @Distance(mm)\n',dmsUnits);
for i = 1 : length(pix)
    fprintf('%f\t %f \t %d\n',pix(i),dms(i),scrTargetDistance);
end
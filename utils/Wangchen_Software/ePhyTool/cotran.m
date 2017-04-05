function rt = cotran(r,to,s)
%cotran(r,to,scr)
%tranform cooridinates between 'view' and 'screen' frame of reference.
%screen coordinates : origin (1,1) at left top corner. 
%view coordinates   : usual math coordinate with (0,0) at screen center. 
%r -- coordinates vector
%to -- translation option. 
%      'vs' --- 'view' to 'screen'
%      'sv' --- 
%s.units -- units of input 'r'
%s.distance -- screen distance in mm
%s.size -- screen size in pixels.
%call dim2pix to convert r to pixels.
%return 'r' in pixels.
%%%%s -- screen properties.
% % %cotran([-5 5],'vs',s)
% % %      s.units
% % %where s.pixelPitch
% % %      s.scrTargetDistance

rInPixels = dim2pix(r,s.units,s.distance);
%
rt = [0 0];
switch to
    case 'sv' 
        %rt = rt - 1; %screen coord (1,1) based
        rt(1) = rInPixels(1) - s.size(1)/2;
        rt(2) = -rInPixels(2)+ s.size(2)/2;
    case 'vs'
        rt(1) = rInPixels(1) + s.size(1)/2;
        rt(2) = -rInPixels(2)+ s.size(2)/2;
        %rt = rt + 1;
end


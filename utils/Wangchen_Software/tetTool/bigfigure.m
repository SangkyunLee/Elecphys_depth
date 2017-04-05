function h = bigfigure(varargin)
%create a 'fullscreen' figure with scalable size.
%p : scaling factor. 1 for full screen.
%h : figure handle.

p = 0.85;

scrSize = get(0,'ScreenSize');
halfWidth   = scrSize(3)/2;
halfHeight  = scrSize(4)/2;

h = figure(varargin{:});
set(h,'Position',[halfWidth*(1-p), halfHeight*(1-p),  halfWidth*2*p, halfHeight*2*p]);


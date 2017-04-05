function savePlotAsPic(h,fn)
%
export_style = hgexport('readstyle','powerpoint');
export_style.Format = 'png';

export_style.Resolution = '300';

figure(h);
set(gcf,'PaperPositionMode','auto');
%print('-dpng', '-r300', savFigFile);
try ;hgexport(gcf,fn,export_style); end
%close(h);
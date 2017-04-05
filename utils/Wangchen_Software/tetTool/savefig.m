function savefig(h,outfile)
% save figure to image file
% h : handle of figure
% outfile : output image file. if extension is not given, the default
%         : is used. 

%default image file extension
defext = '.png';
[fpath,fname,fext] = fileparts(outfile);
%append the default ext 'png' to output file if it has no extension
if isempty(fext) 
    fext = defext; 
end
 
outfile = fullfile(fpath,[fname,fext]);

export_style = hgexport('readstyle','powerpoint');
export_style.Format = fext(2:end); %remove the leading .

set(h,'PaperPositionMode','auto');
%print('-dpng', '-r300', savFigFile);
try ; hgexport(h,outfile,export_style); end

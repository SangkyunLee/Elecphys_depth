function  savefigure(h,figname,axispar,varargin)

figpar.PaperPosition = [0 0 4 3];
figpar.PaperUnits = 'centimeters'; 

for i=1:2:length(varargin)
    figpar.(varargin{i}) = varargin{i+1};
end

fn = fieldnames(figpar);
for ifn = 1: length(fn)
    set(h,fn{ifn},figpar.(fn{ifn}));
end

figure(h);
fn = fieldnames(axispar);
for ifn = 1: length(fn)
    set(gca,fn{ifn},axispar.(fn{ifn}));
end



print(figname,'-r300','-dtiff')
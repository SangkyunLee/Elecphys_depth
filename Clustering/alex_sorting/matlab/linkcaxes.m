function linkcaxes(hdls)
% Link color range on multiple axes

cl = get(hdls,'CLim');
cl = cat(1,cl{:});
cl = [min(cl(:,1)) max(cl(:,2))];
set(hdls,'CLim',cl)

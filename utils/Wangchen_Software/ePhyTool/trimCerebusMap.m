function tmap = trimCerebusMap(col,row,chan,cmap)
%trim the cmap variable for plotting a subgroup of channels
%col --- layout column
%row ---
%chan --- list of channels from cmap
%format of cmap: (column index, row index, electrode id)
%index are 0-based.  (0,0) refers to left-bottom position
%Usage: tmap = trimCerebusMap(8,4,[1:32],cmap); %all chan from Bank A.
%            = trimCerebusMap(1,1,3*24+1,cmap); %1st from bank D, if 24ch on each bank,
%
if col*row ~= length(chan)
    error('wrong channel numbers');
end

tmap = zeros(col*row,3);

for i = 1 : row
    for j = 1 : col
        tmap(j+(i-1)*row,1) = j;
        tmap(j+(i-1)*row,2) = row - i + 1;
        chanID = chan(j+(i-1)*row);
        tmap(j+(i-1)*row,3) = cmap(chanID,3);
    end
end

%0-based row-columns.
tmap(:,1) = tmap(:,1)-1;
tmap(:,2) = tmap(:,2)-1;



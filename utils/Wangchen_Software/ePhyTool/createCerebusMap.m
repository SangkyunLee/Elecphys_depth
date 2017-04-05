function cmap = createCerebusMap(nChan,cBanks)
%create a default map variable if no map file specified
%nChan: number of channels to read from each bank
%cBanks: cerebus bank name 
%use: cmap = createCerebusMap(16,['AB']) -- read 16channels each from
%'A' and 'B'. 
%default layout --- 16 | 32 columns. 
%%
if nChan <= 16
    %fprintf('More than available. Reset to 32\n');
    c = nChan; %column# for layout 
elseif nChan>16 && nChan<=32
    c = 16;
else
    c = 32;
end


cBanks = upper(cBanks);

nb = length(cBanks);
%number of rows for each bank
nr = round(nChan/c);
%actual channels to map
mChan = nr * c;
%total number of rows
nRows = nr * nb;

cmap = zeros(nb*mChan,3);

for i = 1 : nb
    for j = 1 : nr
        for k = 1 : c
            cmap(k + (j-1)*c + (i-1)*nr*c, 1) = k + (j-1)*c;
            %bottom up order.
            cmap(k + (j-1)*c + (i-1)*nr*c, 2) = nRows - (j + (i-1)*nr) + 1;
            cmap(k + (j-1)*c + (i-1)*nr*c, 3) = k + (j-1)*c + (i-1)*32;
        end
    end
end

%keep 0-base index 
cmap(:,1) = cmap(:,1)-1;
cmap(:,2) = cmap(:,2)-1;

%
% figure;
% for i = 1 : size(cmap,1)
%     subplot(nr*nb,c,i);
%     plot(cmap(i,1),cmap(i,2),'ro');
% end



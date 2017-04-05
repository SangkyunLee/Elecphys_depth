function [CSD,pos] = getCSD(erpMat,el_pos, method)
%erp_data : event-related potential matrix (depth recordings x times)
%el_pos   : column vector of electrode position
%method   : csd computation method

CSD = []; pos = [];
%d = D(1:end,tid); % tetrode depth vector
if all(el_pos == -1); return; end
[nrec,npts] = size(erpMat);
%average the erp over recordings made at same depth. 
[uni_pos, uni_pid1] = unique(el_pos,'first');
[uni_pos, uni_pid2] = unique(el_pos,'last');
%
nuq = length(uni_pos); %unique number of depth
pot = zeros(nuq,npts);

for i = 1 : nuq
    pot(i,:) = mean(erpMat(uni_pid1(i):uni_pid2(i),:),1);
end

[CSD,pos] = iCSD(pot,uni_pos,method); 

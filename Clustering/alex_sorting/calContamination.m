function [FP,FN] = calContamination(manual)

pairwise = manual.ContaminationMatrix.data.pairwise;
n = manual.ContaminationMatrix.data.n;

FP = (sum(pairwise,2) - diag(pairwise))./n'; 
FN = 1 - diag(pairwise)./n'; 


function a = auc(tp,fp)
% Computes area under ROC curve
%
% a = auc(tp,fp)
%
% JC 2008-11-07

a = trapz(fp,tp);
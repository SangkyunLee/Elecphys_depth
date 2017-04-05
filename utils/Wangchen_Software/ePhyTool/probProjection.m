function r = probProjection(Ac,Ar,PCx,sigma,view)
% probability projection analysis on spike-conditioned stimulus
% distribution. 
% Ac : spike-triggered stimulus array (stim vectors before spike)
%    : dimension m x n = (trials,times) = (observations,variables)
% Ar : raw stimulus array (stimulus vectors after spike) dim=(trials,times)
%    : Row of Sr correponds to observations, Column to variables
% sigma : std of stimulus distribution
% PCA   : pca result

if ~exist('PCx','var') || isempty(PCx)
    PCx = [1 size(Ar,2)];
end

if ~exist('sigma','var') || isempty(sigma)
    sigma = std(reshape(Ar,1,[]));         %estimate sigma from input
end

if ~exist('view','var') || isempty(view)
    view = false;
end

%PCA on spike-conditioned stimulus
[pc,score,eigval] = princomp(Ac);
weight = Ac / pc';  %weight of uncentered data
%PCA on raw stimulus
[pc0,score0,eigval0] = princomp(Ar);
weight0 = Ar / pc0';
%projection of raw stimulus onto the spike-triggered stimulus space
weight_rp = Ar / pc' ; 
%pc -- each column represents one principal component.
%score -- row for observations, column for components (variables)

%
r.spike.preSpike.PCA.pc         = pc;
r.spike.preSpike.PCA.score      = score;
r.spike.preSpike.PCA.eigenvalue = eigval;
r.spike.preSpike.PCA.weight     = weight;
r.spike.postSpike.PCA.pc    = pc0;
r.spike.postSpike.PCA.score = score0;
r.spike.postSpike.PCA.eigenvalue = eigval0;
r.spike.postSpike.PCA.weight = weight0;
r.spike.project.PCA.weight        = weight_rp;       %project raw onto spike-triggered

if view 
    plotProjection(r,PCx,sigma);
end


function plotProjection(r,PCx,sigma)

pc    = r.spike.preSpike.PCA.pc;
score = r.spike.preSpike.PCA.score;
eigval= r.spike.preSpike.PCA.eigenvalue;
weight= r.spike.preSpike.PCA.weight;

pc0    = r.spike.postSpike.PCA.pc;
score0 = r.spike.postSpike.PCA.score;
eigval0= r.spike.postSpike.PCA.eigenvalue;
weight0= r.spike.postSpike.PCA.weight;

weight_rp = r.spike.project.PCA.weight;

%normalize the eigenvalues by variance
eigval = eigval / (sigma)^2 ; 
% %normalize the scores by sigma
% score  = score / sigma ;
%normalize the eigenvalues by variance
eigval0 = eigval0 / (sigma)^2 ; 
% %normalize the scores by sigma
% score0  = score0 / sigma ;
% %
% score_rp = score_rp / sigma; 

%PC index. -- PC are in decreasing order of variance.
PCx1 = PCx(1);
PCx2 = PCx(2);

%1d projection of stimulus.
[PJx1,xout] = hist(weight(:,PCx1),20);
PJx2 = hist(weight(:,PCx2),xout);
PJx1_rp = hist(weight_rp(:,PCx1),xout);
PJx2_rp = hist(weight_rp(:,PCx2),xout);

%plot the projections 
h = figure('name',sprintf('PCA Space [%d %d]',PCx1,PCx2));
%scatter plot of the distribution of stimulus
subplot(1,4,1); hold on;
plot(weight_rp(:,PCx1),weight_rp(:,PCx2),'k.'); %raw
plot(weight(:,PCx1),weight(:,PCx2),'b.');  %spike-conditioned
axis equal;
%
subplot(1,4,2); hold on;
plot(xout,PJx1_rp,'b'); plot(xout,PJx1,'r');
plot(xout,PJx2_rp,'k'); plot(xout,PJx2,'g');
legend(sprintf('Raw,PC%d',PCx1),sprintf('Spike,PC%d',PCx1),...
    sprintf('Raw,PC%d',PCx2),sprintf('Spike,PC%d',PCx2));

subplot(1,4,3); hold on;
plot(1:length(eigval0),sqrt(eigval0),'k-o');
plot(1:length(eigval),sqrt(eigval),'b-o');
title('Eigenvalue');
legend('Raw','Spike');

subplot(1,4,4); hold on;
plot(pc(:,PCx1),'b');
plot(pc(:,PCx2),'r');

Ac = weight * pc'; 

STA = mean(Ac,1);
STA = (STA-mean(STA))/max(STA);

plot(STA,'k');
legend('PC1','PC2','STA');








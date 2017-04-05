function plotAnalyzer(r)
%
%==========================================================================
% 1. Probability plot
%-------------------------------------------------------------------------
pc       = r.spike.preSpike.PCA.pc;
%score    = r.spike.preSpike.PCA.score;
eigval   = r.spike.preSpike.PCA.eigenvalue;
weight   = r.spike.preSpike.PCA.weight;
pc0      = r.spike.postSpike.PCA.pc;
%score0   = r.spike.postSpike.PCA.score;
eigval0  = r.spike.postSpike.PCA.eigenvalue;
weight0  = r.spike.postSpike.PCA.weight;
weight_rp= r.spike.project.PCA.weight;
sigma    = r.Param.sigma;
PCx      = r.Param.PCx;

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
h1 = figure('name',sprintf('PCA Space [%d %d]',PCx1,PCx2));
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
STA = (STA-mean(STA))/max(abs(STA));

plot(STA,'k');
legend('PC1','PC2','STA');

%==========================================================================
% 2. STA
h2 = figure('name','STA');hold on;
x = r.spike.preSpike.STA.x;
y = r.spike.preSpike.STA.y;
plot(x,y,'b');
plot(x,r.Param.sigma*ones(size(x)),'r.-');

%==========================================================================
% 3. Effective-Stimulus histogram
h3 = figure('name','eff-stim dist'); hold on
x = r.spike.preSpike.EFS.x;
y = r.spike.preSpike.EFS.y;
bar(x,y,'r');
x1 = r.spike.postSpike.EFS.x + mean(diff(r.spike.postSpike.EFS.x))/4;
y1 = r.spike.postSpike.EFS.y; 
bar(x1,y1,'b'); %set(findobj(gca,'Type','patch'),'EdgeColor','w','FaceAlpha',0.75);
legend('Before-Spike','After-Spike');

%==========================================================================
% 4. Response Function
x = r.Response.x;
y = r.Response.y;
e = r.Response.error;
h4 = figure('name','Repsonse Function');errorbar(x,y,e);

%==========================================================================
% 5. Probability 
h5 = figure('name','Bayes prob dist');hold on; 
x = r.Probability.prior.x;
y = r.Probability.prior.y;
x1= r.Probability.posterior.x;
y1= r.Probability.posterior.y;
x2= r.Probability.likelyhood.x;
y2= r.Probability.likelyhood.y;
plot(x,y,'b'); 
plot(x1,y1,'r');
plot(x2,y2,'k');
legend('P(stim)','P(stim|spike)','P(spike|stim)');

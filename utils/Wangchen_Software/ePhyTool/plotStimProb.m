function [x,y,yf] = plotStimProb(A)
%plot the stimulus probability distribution
%A : stimulus array (n x p) 
%T :  

A = reshape(A,1,[]);
m = mean(A);
e = std(A);

fprintf('Contrast %f\n',(e/m)*100);
%normalized by std
B = (A - m)/e ; 
%
bin = 1/4; 
%
x = floor(min(B))-bin : bin : ceil(max(B))+bin;

figure;
%pdf 
y = (hist(B,x)/numel(B))/bin;
%redraw the pdf.
bar(x,y);
hold on;
%
[mu,sigma] = normfit(B);

yf = normpdf(x,mu,sigma);

plot(x,yf,'r'); title(sprintf('Fit mu=%f,sigma=%f',mu,sigma));



function y = sigmoidFun(x,p)
% generate sigmoid function data given the fit parameters.
% x : x data
% p : fit params. SEE sigmoidFit

%f = @(p,x) p(1)^2 + p(2) ./ (1 + exp(-(x-p(3))/p(4)));

y =  p(1)^2 + p(2) ./ (1 + exp(-(x-p(3))/p(4)));



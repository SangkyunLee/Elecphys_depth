function y = expFun(x,a)
% generate exponential function data for given fit parameters
% y = a(1) + a(2)*exp(-a(3)*x)
% a(1) : steady constant
% a(2) : expontial amplitude
% a(3) : decay rate, i.e, 1/decay_constant 
%

y = a(1)+a(2)*exp(-a(3)*x) ;
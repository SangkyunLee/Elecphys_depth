function y=rms(x)
%return root-mean-square of x
%
err = std(x);
avg = mean(x);
y = sqrt(avg.^2 + err.^2);

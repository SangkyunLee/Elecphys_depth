function [r,se,xo] = pePSTH(x,ref,xo)
%compute peri-event-histogram. 
%ref: reference events
% %p : output range
% %bin: output bin size.
%xo: output vector
%r: firing rate
%se: standard error.

% %selected x by onset references and range.
% xs1 = ref + p(1);
% xs2 = ref + p(2);
%output time vector
%xo = p(1):bin:p(2);
p=[xo(1) xo(end)];
bin = xo(2)-xo(1);
%number of reference onsets
n = length(ref);
%number of output elements
m = length(xo);
%matrice of histogram
H = zeros(n,m);

%
for i = 1 : n
    xref = xo + ref(i);
    edges = [xref xref(end)+bin];
    %selected x data
    xs = x(x>=edges(1)& x<=edges(end));
    %compute hist on 
    h = histc(xs,edges);
    if ~isempty(h)
        H(i,:) = h(1:end-1);
    end
    %remove the last element of H which counts the elements x == edges(end)
    
end

%averaged hist
r = sum(H,1)/n;
%compute se
se = std(H,0,1)/sqrt(n);




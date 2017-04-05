function yi=interpLN(x,y,xi)
%interpolate the stimulus using linear-nearest neighbor rule. 
%the interpolated value yi(m) represents the average value of y(m') between x(m') and x(m'+1). 
%yi(m)=y(m') if x(m+1) <= x(m'+1). otherwise yi(m) is linearly interpolated b/w y(m') and y(m'+1)   
%  x(m')   x(m'+1)
%    |     |
%      |
%     xi(m) 

%
xb = mean(diff(x));
xb1= mean(diff(xi));
%find the left nearest index of x for xi 
I = zeros(size(xi));
% %the paring index for linear interpretation. (m' or m'+1) depending on the
% %xi(m) position in the bin of x(m')~x(m'+1) 
% J = zeros(size(xi));
for m = 1 : length(xi)
    R = find(x <= xi(m));
    if isempty(R); yi(m)=0; continue; end
    I(m) = R(end); %the largest element that's less than xi(m)
    xL = x(I(m)); yL = y(I(m));
    if I(m) == length(x) % xi(m) >= x(end)
        yi(m) = y(I(m));
    else  %xi(m) < x(end)
        if m == length(xi)
            xR = xi(m) + xb1;
        else
            xR = xi(m+1);
        end
        
        if xR <= x(I(m)+1)
            yi(m) = yL;
        else
            yR = y(I(m)+1);  
            dxL = x(I(m)+1) - xi(m);
            dxR = xR - x(I(m)+1);
            
            yi(m) = (dxL * yL + dxR * yR)/(dxL + dxR);
        end
    end 
end
 

    
    
    
function plotGaussian(mean, cov, plotOptions, color)
    if nargin < 3
        plotOptions = '-';
    end
    
    v = 0:0.01:2*pi;
    [V, D] = eig(cov);
    eigv = diag(D);
    %sqrt(eigv) corresponds to 1 SD; this gives half the axis lengths
    alpha = atan2(V(2, 1), V(1, 1)); %Amount to rotate the ellipse by
    Ralpha = [cos(alpha), -sin(alpha); sin(alpha), cos(alpha)];
    
    ind = 1;
    xtp = zeros(1, numel(v)); ytp = xtp;
    for i = v
        tempv = mean' + Ralpha*(2*sqrt(eigv).*[cos(i); sin(i)]);
        xtp2(ind) = tempv(1); ytp2(ind) = tempv(2);
        ind = ind+1;
    end
    
    hold on
    if nargin == 3
        plot(xtp2, ytp2, plotOptions, 'LineWidth', 2)
    else
        plot(xtp2, ytp2, plotOptions, 'color', color, 'LineWidth', 2)
    end
    hold off
end
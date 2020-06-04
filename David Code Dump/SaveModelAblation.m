close all
clear M

%Which files to build the model from
v = [0, 1, 2];
%Number of components
nclumps = 10;

niters = 1000;
nreps = 200;
filename = strcat('GMM_', num2str(nclumps), '_Components_Ablation');

for i = v
    filetoread = strcat('E', num2str(i), '.csv');
    if ~exist('M', 'var')
        M = readmatrix(filetoread);
    else
        M = [M; readmatrix(filetoread)];
    end
    filename = strcat(filename, '_', num2str(i));
end

X = M(:, [16:17, 20:22]);
time = (M(:, 1)-M(1, 1))*1e-9;
v = [4, 2]; %Indices of Y acc, Z ang vel

N = size(X, 1); %Size of data
GMM = fitgmdist(X,nclumps, 'Options', statset('MaxIter', niters), 'Replicates', nreps);
if ~exist(filename, 'dir')
    mkdir(filename)
end
save(strcat(filename, '/', filename), 'GMM')

plot(time, X(:, 3))
title('Raw Data')
xlabel('Time (sec)')
ylabel('Z Angular Velocity')

plotcolors = get(gca, 'colororder');

figure
indicator = cluster(GMM, X)';

for j = 1:nclumps
    hold on
    plot(X(indicator==j, v(1)), X(indicator==j, v(2)), 'o', 'color', plotcolors(mod(j-1, size(plotcolors, 1))+1, :));
    plotGaussian(GMM.mu(j, v), GMM.Sigma(v, v, j), '-', plotcolors(mod(j-1, size(plotcolors, 1))+1, :));
    hold off
end

title(strcat("Segmented, ", num2str(nclumps), " Components"));
xlabel('Y Acceleration')
ylabel('Z Angular Velocity')

figure
for j = 1:nclumps
    hold on
    plot(time(indicator==j), X(indicator==j, v(2)), 'o', 'color', plotcolors(mod(j-1, size(plotcolors, 1))+1, :));
    hold off
end

title(strcat("Time Data, Segmented, ", num2str(nclumps), " Components"));
xlabel('Time (sec)')
ylabel('Z Angular Velocity')

figure
for j = 1:nclumps
    hold on
    plot(time(indicator==j), X(indicator==j, v(1)), 'o', 'color', plotcolors(mod(j-1, size(plotcolors, 1))+1, :));
    hold off
end

title(strcat("Time Data, Segmented, ", num2str(nclumps), " Components"));
xlabel('Time (sec)')
ylabel('Y Acceleration')
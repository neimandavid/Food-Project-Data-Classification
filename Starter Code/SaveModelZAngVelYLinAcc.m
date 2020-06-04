close all
clear M

%Which files to build the model from
v = ["0", "1", "2", "0a", "0b"];
%Number of components
nclumps = 7;

niters = 1000;
nreps = 20;
filename = strcat('GMM_', num2str(nclumps), '_Components');

for i = 1:numel(v)
    filetoread = strcat('E', v(i), '.csv');
    if ~exist('M', 'var')
        M = readmatrix(filetoread);
    else
        M = [M; readmatrix(filetoread)];
    end
    filename = strcat(filename, '_', v(i));
end

X = M(:, [15:17, 20:22, 9:12]);
X = M(:, [17, 21]);
N = size(X, 1); %Size of data
GMM = fitgmdist(X,nclumps, 'Options', statset('MaxIter', niters), 'Replicates', nreps);
filename = strcat(filename, '_ZAngVelYLinAcc');
if ~exist(filename, 'dir')
    mkdir(filename)
end
save(strcat(filename, '/', filename), 'GMM')

time = (M(:, 1)-M(1, 1))*1e-9;
plot(time, X(:, 1), '.')
title('Raw Data')
xlabel('Time (sec)')
ylabel('Z Angular Velocity')

plotcolors = get(gca, 'colororder');

figure
indicator = cluster(GMM, X)';
v = [2, 1];
for j = 1:nclumps
    hold on
    plot(X(indicator==j, v(1)), X(indicator==j, v(2)), 'o', 'color', plotcolors(mod(j-1, size(plotcolors, 1))+1, :));
    plotGaussian(GMM.mu(j, v), GMM.Sigma(v, v, j), '-', plotcolors(mod(j-1, size(plotcolors, 1))+1, :));
    hold off
end

title(strcat("Segmented, ", num2str(nclumps), " Components"));
xlabel('Y Acceleration')
ylabel('Z Angular Velocity')

statespacefilename = strcat(filename, '/State_Space.jpg');
saveas(gcf, statespacefilename);

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
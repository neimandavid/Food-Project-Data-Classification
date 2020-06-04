close all
clear M

%Which files to build the model from
v = [0, 1, 2];
%Number of components
nclumps = 7;

niters = 1000;
nreps = 200;
filename = strcat('GMM_', num2str(nclumps), '_Components_Ablation_Force');

for i = v
    IMUfiletoread = strcat('E', num2str(i), '.csv');
    forcefiletoread = strcat('E', num2str(i), 'Force.csv');
    if ~exist('M', 'var')
        M = combineCSVs(IMUfiletoread, forcefiletoread);
    else
        M = [M; combineCSVs(IMUfiletoread, forcefiletoread)];
    end
    filename = strcat(filename, '_', num2str(i));
end

%Process force data
avewindow = 5; %Average over this many previous timesteps
forcevec = M(:, 14);
forceveclen = numel(M(:, 14));
tempavemat = zeros(forceveclen, avewindow);

for i = 1:avewindow
    tempavemat(1:i, i) = forcevec(1); %Pad start with first data value
    tempavemat(i+1:end, i) = forcevec(1:end-i);
end

forcerunningave = mean(tempavemat, 2);
newforcevec = forcevec-forcerunningave;

X = [M(:, 5:9), newforcevec];
v = [size(X, 2), 2]; %[4, 2]; %Indices of Y acc, Z ang vel

N = size(X, 1); %Size of data
GMM = fitgmdist(X,nclumps, 'Options', statset('MaxIter', niters), 'Replicates', nreps);
if ~exist(filename, 'dir')
    mkdir(filename)
end
save(strcat(filename, '/', filename), 'GMM')

time = (M(:, 1)-M(1, 1))*1e-9;
plot(time, X(:, v(2)))
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
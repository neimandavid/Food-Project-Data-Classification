close all
clear M

%Which files to build the model from
sourcedata = ["E2"];
%Files from the model we're seeding from (empty if not seeding)
%Recall that we seed from a MODEL (so make sure it exists, etc.)
seeddata = ["E0"];
%Number of components
nclumps = 5;

niters = 1000;
nreps = 20;
modelname = strcat('GMM_', num2str(nclumps), '_Components');

for i = 1:numel(sourcedata)
    filetoread = strcat(sourcedata(i), '.csv');
    if ~exist('M', 'var')
        M = readmatrix(filetoread);
    else
        M = [M; readmatrix(filetoread)];
    end
    modelname = strcat(modelname, '_', sourcedata(i));
end

if ~isempty(seeddata)
    modelname = strcat(modelname, '_Seeded');
end
for i = 1:numel(seeddata)
    modelname = strcat(modelname, '_', seeddata(i));
end

X = M(:, [15:17, 20:22, 9:12]);
X = M(:, [17, 21]);
N = size(X, 1); %Size of data
if ~isempty(seeddata)
    seedfilename = strcat('GMM_', num2str(nclumps), '_Components_');
    for wstring = seeddata
        seedfilename = strcat(seedfilename, wstring, '_');
    end
    seedfilename = strcat(seedfilename, 'ZAngVelYLinAcc');
    %Load the seed GMM, extract parameters
    load(strcat(seedfilename, '/', seedfilename, '.mat'));
    Mu = GMM.mu; Sigma = GMM.Sigma; PComp = GMM.PComponents;
    S = struct('mu', Mu, 'Sigma', Sigma, 'ComponentProportion', PComp);
    GMM = fitgmdist(X,nclumps, 'Options', statset('MaxIter', niters), 'Start', S, 'RegularizationValue', 1e-5);
else
    GMM = fitgmdist(X,nclumps, 'Options', statset('MaxIter', niters), 'Replicates', nreps);
end
modelname = strcat(modelname, '_ZAngVelYLinAcc');
if exist(modelname, 'dir') %Clear old data (in case of format changes, don't overwrite and keep old stuff)
    rmdir(modelname, 's')
end
mkdir(modelname)
save(strcat(modelname, '/', modelname), 'GMM')

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

statespacefilename = strcat(modelname, '/State_Space.jpg');
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


filestoread = ["E0", "E0a", "E0b", "E1", "E2", "N1", "N2", "N3", "N4", "N5"];
for filetoread = filestoread
    UseModelZAngVelYLinAcc(modelname, strcat(filetoread, '.csv'), nclumps);
end
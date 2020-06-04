close all

nclumps = 10; %Number of Gaussians to split into

modeltouse = strcat('GMM_', num2str(nclumps), '_Components_Ablation_0_1_2');
filetoread = 'E0.csv';

filepath = strcat(modeltouse, '/');
filepath = strcat(filepath, extractBetween(filetoread, 1, length(filetoread)-4), '/');
filepath = filepath{1};
if exist(filepath, 'dir') ~= 7
    mkdir(filepath)
end

fullM = readmatrix(filetoread);
startind = 1;
endind = size(fullM, 1);
M = fullM(startind:endind, :);
fullM(:, end+1) = 0; %Add a dummy column where I'll put the labels

starttime = datetime(M(1, 1)* 1e-9,'ConvertFrom','posixTime','Format','yyyy.MM.dd HH:mm:ss.SSSSSSSSS') %GMT, for EDT subtract 4 hours
endtime = datetime(M(end, 1)* 1e-9,'ConvertFrom','posixTime','Format','yyyy.MM.dd HH:mm:ss.SSSSSSSSS') %GMT, for EDT subtract 4 hours

time = (M(:, 1)-M(1, 1))*1e-9;

X = M(:, [16:17, 20:22]);
v = [4, 2]; %Y lin acc, Z ang vel
N = size(X, 1); %Size of data

plot(time, X(:, 3))
title('Raw Data')
xlabel('Time (sec)')
ylabel('Z Angular Velocity')
filename = strcat(filepath, 'Raw_Data.jpg');
saveas(gcf, filename);

filepath = strcat(filepath, num2str(nclumps), '_Components/');
if exist(filepath, 'dir') ~= 7
    mkdir(filepath)
end


plotcolors = ['r'; 'g'; 'b'; 'm'; 'c'; 'y'];
plotcolors = get(gca, 'colororder');

figure
load(strcat(modeltouse, '/', modeltouse, '.mat')); %Get the GMM
%save();
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

filename = strcat(filepath, 'State_Space.jpg');
saveas(gcf, filename);

figure
for j = 1:nclumps
    hold on
    plot(time(indicator==j), X(indicator==j, v(2)), 'o', 'color', plotcolors(mod(j-1, size(plotcolors, 1))+1, :));
    hold off
end

title(strcat("Time Data, Segmented, ", num2str(nclumps), " Components"));
xlabel('Time (sec)')
ylabel('Z Angular Velocity')

filename = strcat(filepath, 'ZAngVel.jpg');
saveas(gcf, filename);

figure
for j = 1:nclumps
    hold on
    plot(time(indicator==j), X(indicator==j, v(1)), 'o', 'color', plotcolors(mod(j-1, size(plotcolors, 1))+1, :));
    hold off
end

title(strcat("Time Data, Segmented, ", num2str(nclumps), " Components"));
xlabel('Time (sec)')
ylabel('Y Acceleration')

filename = strcat(filepath, 'YAcc.jpg');
saveas(gcf, filename);

if exist(strcat(filepath, 'Components/'), 'dir') ~= 7
    mkdir(strcat(filepath, 'Components/'))
end
for j = 1:nclumps
    figure
    plot(time(indicator==j), X(indicator==j, v(2)), 'o', 'color', plotcolors(mod(j-1, size(plotcolors, 1))+1, :));
    xlim([min(time), max(time)])
    ylim([min(X(:, 3)), max(X(:, 3))])
    xlabel('Time (sec)')
    ylabel('Z Angular Velocity')
    title(strcat("Time Data, Segmented, Component ", num2str(j), " of ", num2str(nclumps)));
    filename = strcat(filepath, 'Components/Component_', num2str(j), '.jpg');
    saveas(gcf, filename);
end

fullM(startind:endind, end) = indicator';
T = readtable(filetoread);
outT = array2table(fullM,'VariableNames', [T.Properties.VariableNames,{'Label'}]);
writetable(outT, strcat(filepath, filetoread, '_', num2str(nclumps), '_Components.csv'));
'Done'
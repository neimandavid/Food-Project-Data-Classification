function UseModelZAngVelYLinAcc(modeltouse, filetoread, nclumps)
close all

if nargin < 3
nclumps = 7; %Number of Gaussians to split into
end

if nargin < 1
    modeltouse = strcat('GMM_', num2str(nclumps), '_Components_0_1_2_ZAngVelYLinAcc_Archive');
end
if nargin < 2
    filetoread = 'N5.csv';
end

filepath = strcat(modeltouse, '/');
filepath = strcat(filepath, extractBetween(filetoread, 1, strlength(filetoread)-4), '/');
filepath = filepath{1};
if exist(filepath, 'dir') ~= 7
    mkdir(filepath)
end

fullM = readmatrix(filetoread);
startind = 1;
endind = size(fullM, 1);
M = fullM(startind:endind, :);
fullM(:, end+1) = 0;

starttime = datetime(M(1, 1)* 1e-9,'ConvertFrom','posixTime','Format','yyyy.MM.dd HH:mm:ss.SSSSSSSSS'); %GMT, for EDT subtract 4 hours
endtime = datetime(M(end, 1)* 1e-9,'ConvertFrom','posixTime','Format','yyyy.MM.dd HH:mm:ss.SSSSSSSSS'); %GMT, for EDT subtract 4 hours

time = (M(:, 1)-M(1, 1))*1e-9;

X = M(:, [17, 21]);
v = [2, 1]; %Y lin acc, Z ang vel

N = size(X, 1); %Size of data

plot(time, X(:, v(2)))
title('Raw Data')
xlabel('Time (sec)')
ylabel('Z Angular Velocity')
filename = strcat(filepath, 'Raw_Data.jpg');
saveas(gcf, filename);

% filepath = strcat(filepath, num2str(nclumps), '_Components/');
% if exist(filepath, 'dir') ~= 7
%     mkdir(filepath)
% end


plotcolors = ['r'; 'g'; 'b'; 'm'; 'c'; 'y'];
plotcolors = get(gca, 'colororder');

figure
load(strcat(modeltouse, '/', modeltouse, '.mat')); %Get the GMM
%save();
[indicator, nlogL] = cluster(GMM, X); indicator = indicator';
nlogL

fID = fopen(strcat(filepath, 'stats.txt'), 'w');
fprintf(fID, 'Negative log-likelihood: %8.3f\n', nlogL);
%nlogL is negative log-likelihood.
%"Likelihood" is a probability (barring continuity, PDFs, weird definitions, etc. as before), so between 0 and 1
%Log likelihood is then going to be between -inf (for p=0) and 0 (for p=1)
%Negate that because people hate negative numbers
%Bigger nlogL means WORSE fit

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

if exist(strcat(filepath, num2str(nclumps), " Components/"), 'dir') ~= 7
    mkdir(strcat(filepath, num2str(nclumps), " Components/"))
end
for j = 1:nclumps
    figure
    plot(time(indicator==j), X(indicator==j, v(2)), 'o', 'color', plotcolors(mod(j-1, size(plotcolors, 1))+1, :));
    xlim([min(time), max(time)])
    ylim([min(X(:, v(2))), max(X(:, v(2)))])
    xlabel('Time (sec)')
    ylabel('Z Angular Velocity')
    title(strcat("Time Data, Segmented, Component ", num2str(j), " of ", num2str(nclumps)));
    filename = strcat(filepath, num2str(nclumps), " Components/Component_", num2str(j), '.jpg');
    saveas(gcf, filename);
end

fullM(startind:endind, end) = indicator';
T = readtable(filetoread);
outT = array2table(fullM,'VariableNames', [T.Properties.VariableNames,{'Label'}]);

newcsvfilename = strcat(filepath, extractBetween(filetoread, 1, strlength(filetoread)-4), '_', num2str(nclumps), '_Components.csv');
newcsvfilename = newcsvfilename{1};

writetable(outT, newcsvfilename);
'Done'
end
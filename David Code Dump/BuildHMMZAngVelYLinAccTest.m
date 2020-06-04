close all

nclumps = 7; %Number of Gaussians to split into

modeltouse = strcat('GMM_', num2str(nclumps), '_Components_0_1_2_ZAngVelYLinAcc_Archive');
filestoread = ["E0.csv", "E1.csv", "E2.csv", "E0a.csv", "E0b.csv"];
filestoread = ["E2.csv"];

HMMdata = zeros(nclumps, nclumps, 10);

filepath = strcat(modeltouse, '/');
filepath = strcat(filepath, 'HMMTest/');
if exist(filepath, 'dir') ~= 7
    mkdir(filepath)
end

for filetoread = filestoread
    fullM = readmatrix(filetoread);
    startind = 1;
    endind = size(fullM, 1);
    M = fullM(startind:endind, :);
    fullM(:, end+1) = 0;

    starttime = datetime(M(1, 1)* 1e-9,'ConvertFrom','posixTime','Format','yyyy.MM.dd HH:mm:ss.SSSSSSSSS') %GMT, for EDT subtract 4 hours
    endtime = datetime(M(end, 1)* 1e-9,'ConvertFrom','posixTime','Format','yyyy.MM.dd HH:mm:ss.SSSSSSSSS') %GMT, for EDT subtract 4 hours

    time = (M(:, 1)-M(1, 1))*1e-9;

    X = M(:, [17, 21]);
    v = [2, 1]; %Y lin acc, Z ang vel

    N = size(X, 1); %Size of data

    load(strcat(modeltouse, '/', modeltouse, '.mat')); %Get the GMM
    indicator = cluster(GMM, X)';
    
    modeswitches = indicator;
    modeswitches([false, modeswitches(2:end)==modeswitches(1:end-1)]) = [];
    modeswitches

    for h = 1:10
        for i = h:numel(modeswitches)
            HMMdata(modeswitches(i-(h-1)), modeswitches(i), h) = HMMdata(modeswitches(i-(h-1)), modeswitches(i), h) + 1; %Seriously, why does Matlab not have a ++ operator?
        end
    end
end
HMMdata = HMMdata ./ sum(HMMdata, 2)

HMMdata(:, :, 3) - HMMdata(:, :, 2)^2
%save(strcat(filepath, 'HMMdata'), 'HMMdata');
return;

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
    ylim([min(X(:, v(2))), max(X(:, v(2)))])
    xlabel('Time (sec)')
    ylabel('Z Angular Velocity')
    title(strcat("Time Data, Segmented, Component ", num2str(j), " of ", num2str(nclumps)));
    filename = strcat(filepath, 'Components/Component_', num2str(j), '.jpg');
    saveas(gcf, filename);
end

fullM(startind:endind, end) = indicator';
T = readtable(filetoread);
outT = array2table(fullM,'VariableNames', [T.Properties.VariableNames,{'Label'}]);

newcsvfilename = strcat(filepath, extractBetween(filetoread, 1, length(filetoread)-4), '_', num2str(nclumps), '_Components.csv');
newcsvfilename = newcsvfilename{1};

writetable(outT, newcsvfilename);
'Done'
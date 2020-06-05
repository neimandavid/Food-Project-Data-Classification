close all

nclumps = 10; %Number of Gaussians to split into

modeltouse = strcat('GMM_', num2str(nclumps), '_Components_ZVelYAcc3d_All_50_1');
filetoread = 'E8.csv';

filepath = strcat(modeltouse, '/');
filepath = strcat(filepath, extractBetween(filetoread, 1, length(filetoread)-4), '/');
filepath = filepath{1};
if exist(filepath, 'dir') ~= 7
    mkdir(filepath)
end

fullM = combineOpenIMUcsv('E8imu.csv', 'E8_3d.csv');
startind = 1;
endind = size(fullM, 1);
M = fullM(startind:endind, :);
fullM(:, end+1) = 0;

starttime = datetime(M(1, 1)* 1e-9,'ConvertFrom','posixTime','Format','yyyy.MM.dd HH:mm:ss.SSSSSSSSS') %GMT, for EDT subtract 4 hours
endtime = datetime(M(end, 1)* 1e-9,'ConvertFrom','posixTime','Format','yyyy.MM.dd HH:mm:ss.SSSSSSSSS') %GMT, for EDT subtract 4 hours

time = (M(:, 1)-M(1, 1))*1e-9;

%grab wDist, wNDist, z vel, y acc
X = M(:, [13:14,17,19]);
v = [4,3];
N = size(X, 1); %Size of data

%raw data of z velocity against time
plot(time, X(:, v(2)))
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
indicator = cluster(GMM, X)'; %cluster based off of the GMM & plot what it would look like state space wise
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

%plot the state space of z velocity and wDist
a = [1,3];
figure
for j = 1:nclumps
    hold on
    plot(X(indicator==j, a(1)), X(indicator==j, a(2)), 'o', 'color', plotcolors(mod(j-1, size(plotcolors, 1))+1, :));
    plotGaussian(GMM.mu(j, a), GMM.Sigma(a, a, j), '-', plotcolors(mod(j-1, size(plotcolors, 1))+1, :));
    hold off
end

title(strcat("Segmented, ", num2str(nclumps), " Components"));
xlabel('Wrist Distance')
ylabel('Z Angular Velocity')

statespacefilename = strcat(filepath, '/State_Space_Z_wDist.jpg');
saveas(gcf, statespacefilename);

%plot the state space of y acc and wDist
a = [4,1];
figure
for j = 1:nclumps
    hold on
    plot(X(indicator==j, a(1)), X(indicator==j, a(2)), 'o', 'color', plotcolors(mod(j-1, size(plotcolors, 1))+1, :));
    plotGaussian(GMM.mu(j, a), GMM.Sigma(a, a, j), '-', plotcolors(mod(j-1, size(plotcolors, 1))+1, :));
    hold off
end

title(strcat("Segmented, ", num2str(nclumps), " Components"));
xlabel('Y Acceleration')
ylabel('Wrist Distance')

statespacefilename = strcat(filepath, '/State_Space_Y_wDist.jpg');
saveas(gcf, statespacefilename);

%plot the state space of z vel and wNDist
a = [3,2];
figure
for j = 1:nclumps
    hold on
    plot(X(indicator==j, a(1)), X(indicator==j, a(2)), 'o', 'color', plotcolors(mod(j-1, size(plotcolors, 1))+1, :));
    plotGaussian(GMM.mu(j, a), GMM.Sigma(a, a, j), '-', plotcolors(mod(j-1, size(plotcolors, 1))+1, :));
    hold off
end

title(strcat("Segmented, ", num2str(nclumps), " Components"));
xlabel('Z Angular Velocity')
ylabel('Wrist & Neck Distance')

statespacefilename = strcat(filepath, '/State_Space_Z_wNDist.jpg');
saveas(gcf, statespacefilename);

%plot the state space of z vel and wNDist
a = [1,2];
figure
for j = 1:nclumps
    hold on
    plot(X(indicator==j, a(1)), X(indicator==j, a(2)), 'o', 'color', plotcolors(mod(j-1, size(plotcolors, 1))+1, :));
    plotGaussian(GMM.mu(j, a), GMM.Sigma(a, a, j), '-', plotcolors(mod(j-1, size(plotcolors, 1))+1, :));
    hold off
end

title(strcat("Segmented, ", num2str(nclumps), " Components"));
xlabel('Wrist')
ylabel('Wrist & Neck Distance')

statespacefilename = strcat(filepath, '/State_Space_WDist_wNDist.jpg');
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
%plot each seperate component with just Z angular velocity
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
outT = array2table(fullM,'VariableNames', {'rosbagTimestamp', 'secs', 'nsecs', 'lwrist.x','lwrist.y', 'lwrist.z', 'rwrist.x', 'rwrist.y', 'rwrist.z', 'neck.x', 'neck.y', 'neck.z','wDist', 'wNDist', 'x', 'y', 'z', 'x.1', 'y.1', 'z.1','Label'});

%write everything to the new file
newcsvfilename = strcat(filepath, extractBetween(filetoread, 1, length(filetoread)-4), '_', num2str(nclumps), '_Components.csv');
newcsvfilename = newcsvfilename{1};

writetable(outT, newcsvfilename);
'Done'
close all
clear M

%Number of components
nclumps = 10;

niters = 1000;
nreps = 50;

filename = strcat('GMM_', num2str(nclumps), '_Components');
filename = strcat(filename, '_ZVelYAcc3d_All_std_',num2str(nreps), '_2');
M = combineOpenIMUcsv('E2.csv', 'E2_3d.csv');
M = [M; combineOpenIMUcsv('E1.csv', 'E1_3d.csv')];
M = [M; combineOpenIMUcsv('E6imu.csv', 'E6_3d.csv')];
M = [M; combineOpenIMUcsv('E8imu.csv', 'E8_3d.csv')];

%distance, angular velocity, linear acceleration
Y = M(:, [13:14,17,19]);
means = mean(Y,1);
stdev = std(Y);
Y = Y-means;
X = Y ./ stdev;

N = size(X, 1); %Size of data
GMM = fitgmdist(X,nclumps, 'Options', statset('MaxIter', niters), 'Replicates', nreps);

if ~exist(filename, 'dir')
    mkdir(filename)
end
save(strcat(filename, '/', filename), 'GMM')

%create txt file to document the covariance matrix, the eigenvecs/vals, and
%means of each component
fileID = fopen(strcat(filename, "/covariance.txt"), 'w');
for j = 1:nclumps
    fprintf(fileID, strcat("Component ", int2str(j), "\nCovariance\n"));
    fprintf(fileID, "%f %f %f %f \n", GMM.Sigma(:,:,j));
    [vec,val] = eig(GMM.Sigma(:,:,j));
    fprintf(fileID, "Eigenvalues\n");
    fprintf(fileID, "%f %f %f %f \n", val);
    fprintf(fileID, "Eigenvectors\n");
    fprintf(fileID, "%f %f %f %f \n", vec);
    fprintf(fileID, "Mean\n%f %f %f %f \n\n", GMM.mu(j,:));
end
fclose(fileID);

%get time, plot raw Z angular velocity, which is the 3rd column of X
time = (M(:, 1)-M(1, 1))*1e-9;
plot(time, X(:, 1), '.')
title('Raw Data')
xlabel('Time (sec)')
ylabel('Z Angular Velocity')

plotcolors = get(gca, 'colororder');

figure
indicator = cluster(GMM, X)';
%columns in X for y acceleration and z velocity if using just those 2
%v = [2, 1];
%columns in X for y acc and z velocity, distance
v = [4,3];

%plot the state space of x velocity and y acc
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

statespacefilename = strcat(filename, '/State_Space_Z_wDist.jpg');
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

statespacefilename = strcat(filename, '/State_Space_Y_wDist.jpg');
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

statespacefilename = strcat(filename, '/State_Space_Z_wNDist.jpg');
saveas(gcf, statespacefilename);

%plot the state space of wDist and wNDist
a = [1,2];
figure
for j = 1:nclumps
    hold on
    plot(X(indicator==j, a(1)), X(indicator==j, a(2)), 'o', 'color', plotcolors(mod(j-1, size(plotcolors, 1))+1, :));
    plotGaussian(GMM.mu(j, a), GMM.Sigma(a, a, j), '-', plotcolors(mod(j-1, size(plotcolors, 1))+1, :));
    hold off
end

title(strcat("Segmented, ", num2str(nclumps), " Components"));
xlabel('Wrist Distance')
ylabel('Wrist & Neck Distance')

statespacefilename = strcat(filename, '/State_Space_WDist_wNDist.jpg');
saveas(gcf, statespacefilename);

%plot the state space of y acc and wNDist
a = [4,2];
figure
for j = 1:nclumps
    hold on
    plot(X(indicator==j, a(1)), X(indicator==j, a(2)), 'o', 'color', plotcolors(mod(j-1, size(plotcolors, 1))+1, :));
    plotGaussian(GMM.mu(j, a), GMM.Sigma(a, a, j), '-', plotcolors(mod(j-1, size(plotcolors, 1))+1, :));
    hold off
end

title(strcat("Segmented, ", num2str(nclumps), " Components"));
xlabel('Y Acceleration')
ylabel('Wrist & Neck Distance')

statespacefilename = strcat(filename, '/State_Space_Y_wNDist.jpg');
saveas(gcf, statespacefilename);

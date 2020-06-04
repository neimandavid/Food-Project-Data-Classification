function outmat = combineCSVs(IMUfile, forcefile)
%Pass in filepaths. Hopefully nothing goes wrong with relative/absolute.

%Each file starts with a rosbagTimestamp in column 1
%2-4 are junk
%5 is seconds, 6 is nsecs. This is probably the time we care to use?
%Force data is in columns 10-13
%IMU has angular velocity in 15-17, linear acceleration in 20-22. (Orientation in 9-12, but that's probably also junk)

%Times aren't the same; the force sensor seems to get data
%about 4-5 times more often than the IMU.

%Idea: Loop through the times on the IMU file. For each, loop through the
%times on the force file (everything's sorted, don't have to start over
%each time). First thing we find after the IMU time gets concatenated
%(anything we skipped just gets ignored)

IMUmat = readmatrix(IMUfile);
forcemat = readmatrix(forcefile);
n = size(IMUmat, 1);
outmat = zeros(n, 3+3+3+4+1); %=14: Time, sec, nsec, angvel, linacc, force, sum(force)

IMUtimes = IMUmat(:, 5) + 1e-9*IMUmat(:, 6);
forcetimes = forcemat(:, 5) + 1e-9*forcemat(:, 6);

outmat(:, 1) = IMUtimes; %Time
outmat(:, 2:3) = IMUmat(:, 5:6); %Sec, nsec
outmat(:, 4:6) = IMUmat(:, 15:17); %Ang vel
outmat(:, 7:9) = IMUmat(:, 20:22); %Lin acc

forcetimeind = 1; %Everything's sorted, no need to restart from 0 each time
for i = 1:n
    for j = forcetimeind:numel(forcetimes)
        if forcetimes(j) > IMUtimes(i) || j == numel(forcetimes)
            forcetimeind = j; %Start from here next time
            outmat(i, 10:13) = forcemat(j, 10:13); %Individual force sensors
            outmat(i, 14) = sum(forcemat(j, 10:13), 2); %Total force
            break;
        end
    end
end

end


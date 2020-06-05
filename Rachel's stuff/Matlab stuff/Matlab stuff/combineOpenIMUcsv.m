function outmat = combineOpenIMUcsv(IMUfile, openposefile)
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
openposemat = readmatrix(openposefile);
%disp(IMUmat)
n = size(openposemat, 1);
outmat = NaN(n, 3+3+3+3); %=14: Time, sec, lwrist, rwrist, neck
IMUtimes = IMUmat(:, 5) + 1e-9*IMUmat(:, 6);
openposetimes = openposemat(:, 5) + 1e-9*openposemat(:, 6);

outmat(:, 1) = openposetimes; %Time
outmat(:, 2:3) = openposemat(:, 5:6); %Sec, nsec
outmat(:, 4:6) = openposemat(:, 8:10); %lwrist coord
outmat(:, 7:9) = openposemat(:, 11:13); %rwrist coord
outmat(:, 10:12) = openposemat(:, 14:16); %neck coord
outmat(any(isnan(outmat), 2), :) = []; %remove all that do not have left or right wrist
openposetimes = outmat(:, 2) + 1e-9*outmat(:, 3);


%calculate the distance between the lwrist & rwrist, and then calculate the
%distance between the right wrist & the neck
n = size(outmat,1);
outmat = [outmat zeros(n,2+3+3)]; %distance between wrists, distance between wrist & neck, velocity, lin acc

IMUtimeind = 1; %Everything's sorted, no need to restart from 0 each time
for i = 1:n
    for j = IMUtimeind:numel(IMUtimes)
        if IMUtimes(j) > openposetimes(i) || j == numel(IMUtimes)
            IMUtimeind = j; %Start from here next time
            outmat(i, 15:17) = IMUmat(j, 15:17); %Velocity
            outmat(i, 18:20) = IMUmat(j, 20:22); %Linear Acc
            outmat(i,13) = pdist([outmat(i, 4:6); outmat(i,7:9)]); %dist btw lwrist & rwrist
            outmat(i,14) = pdist([outmat(i, 7:9); outmat(i,10:12)]); %dist btw neck & rwrist
            break;
        end
    end
end
%disp(outmat)

end
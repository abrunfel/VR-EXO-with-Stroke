% VR_EXO experiment: VR kinematic analysis
% Current version coded on 1/20/21
% NOTE: This code is a partner to "vr_exo_kinematics_emg_bulk.m". As of now
% (4/5/21), changes to this code must be duplicated manually in the 'bulk'
% version. I don't have time to come up with an elegant "functionization"
% of the two...
% See lab book page 072

%% Load in both xdf and emg data
clear all
close all
if strcmp(computer, 'PCWIN64')
    cd('C:\Users\abrun\Dropbox\Catholic U\VR_EXO_Stroke\Data')
    file = uigetfile('*.xdf');
    cd(['C:\Users\abrun\Dropbox\Catholic U\VR_EXO_Stroke\Data\' file(1:11)])
    data = load_xdf(file);
    emg = delsysEMGimport2(['C:\Users\abrun\Dropbox\Catholic U\VR_EXO_Stroke\Data\' file(1:11) '\' file(1:end-4) '-emg.csv']); % This may take a few minutes
else
    cd('/Users/alexbrunfeldt/Dropbox/Catholic U/VR_EXO_Stroke/Data')
    file = uigetfile('*.xdf');
    cd(['/Users/alexbrunfeldt/Dropbox/Catholic U/VR_EXO_Stroke/Data/' file(1:11)])
    data = load_xdf(file);
    emg = delsysEMGimport2(['/Users/alexbrunfeldt/Dropbox/Catholic U/VR_EXO_Stroke/Data/' file(1:11) '/' file(1:end-4) '-emg.csv']); % This may take a few minutes
end

emg = emg(2:end,:); % cut out NaN row
%% Create arrays for each data stream's timeseries and timestamp data
% For centerEye, rh, lh, rows 1-3 are angles, rows 4-6 are x,y,z
% respectively. Row 7 is timestamp at which each measurement is made. There
% are issues with inconsistent sample rates, so timestamps might not be the
% same between each of these arrays.

% LabStreamLayer does not keep data stream number consistent. Need to
% search by name and apply case
for i = 1:length(data)
   streamName = data{i}.info.name;
   switch streamName % Read in stream name
       case{'SpawnTargets'}
           % SpawnTarget information
           for j = 1:length(data{i}.time_series)
               targetSpawn(j) = str2num(data{i}.time_series{j}(3:end)); % Convert from string cell array to vector w/ type 'double' and remove "TL"
           end
           % Concat target order and target timestamp
           targetSpawn = cat(1,targetSpawn,data{i}.time_stamps);
           
       case{'HandCollision'}
           % Target collision information
           for j = 1:length(data{i}.time_series)/2 % The "/2" is due to the double length of this stream. There is redundant data being recorded
               targetHit(j) = str2num(data{i}.time_series{2*j}(3:end)); % Convert from string cell array to vector w/ type 'double' and remove "TL"
           end
           % Concat target order and target timestamp
           targetHit = cat(1,targetHit,data{i}.time_stamps(2:2:end));
           
       case{'CenterEyeTranform'}
           centerEye = cat(1,double(data{i}.time_series),data{i}.time_stamps); % Midpoint between eyes
           
       case{'RightGrabberTransform'}
           rh = cat(1,double(data{i}.time_series),data{i}.time_stamps); % Right hand
           
       case{'LeftGrabberTransform'}
           lh = cat(1,double(data{i}.time_series),data{i}.time_stamps); % Left hand
           
       % Following cases only for data collected on or after 08/05/20.
       case{'RightGrabberTransform_FU'}
           rh_fu = cat(1,double(data{i}.time_series),data{i}.time_stamps); % Right hand fixed update (fixed sample rate)
           rh_fu = [rh_fu(1:3,:); rh_fu(5:8,:)]; % Remove 'rotation.w' (see LSLTransformDemoOutlet.cs)
           
       case{'LeftGrabberTransform_FU'}
           lh_fu = cat(1,double(data{i}.time_series),data{i}.time_stamps); % Left hand fixed update
           lh_fu = [lh_fu(1:3,:); lh_fu(5:8,:)]; % Remove 'rotation.w'
           
       case{'EMG'}
           emgData = cat(1,double(data{i}.time_series),data{i}.time_stamps); % EMG data from Delsys Trigno wireless system
           % data are 16xn, capable of up to 16 channels EMG, plus
           % timestamp for 17xn. Note, system only has 8 sensors, and as of
           % 10/06/20, we are only recording from sensors 1-4.
   end
end
%% Visual inspection of data
%Plot all data
figure;
plot3(rh_fu(4,:), rh_fu(5,:), rh_fu(6,:), '.r');
hold on
plot3(lh_fu(4,:), lh_fu(5,:), lh_fu(6,:), '.b');

% Plot timestamps for each kinematic variable to ensure similar timing.
% NOTE: These are perfectly matched!
figure;
plot(centerEye(7,:),'xb'); hold on;
plot(lh_fu(7,:),'or'); hold on;
plot(rh_fu(7,:),'+k');
% plot(lh_fu(7,:),'or'); hold on;
% plot(rh_fu(7,:),'+k');

%% Calculate Timing and Kinematics
fsVR = length(lh_fu(7,:))/(lh_fu(7,end) - lh_fu(7,1)); % sample rate (seems to be ~90 Hz). NOTE: lh and rh can be different legnths, however usually only by 1-2 samples out of 30,000+
% There is a chance that a participant does not finish a block; therefore,
% length(targetSpawn) > length(targetHit). If that is the case, you must
% delete the final targetSpawn from the dataset.
if length(targetSpawn) > length(targetHit)
    targetSpawn = targetSpawn(:,1:length(targetHit));
end
numTrials = length(targetSpawn);
indSpawn = zeros(numTrials,1);
indHit = zeros(numTrials,1);
for i = 1:length(targetSpawn)
    indSpawn(i) = find(lh_fu(7,:) > targetSpawn(2,i),1); % indicies in lh and rh data streams that signify the target spawns (n = numTrials)
    indHit(i) = find(lh_fu(7,:) > targetHit(2,i),1); % indicies in lh and rh data streams that signify the target spawns (n = numTrials)
end
% % Visual inspection of hand paths for any trial
% trial_num = 2;
% figure;
% plot3(rh(4,indSpawn(trial_num):indHit(trial_num)), rh(5,indSpawn(trial_num):indHit(trial_num)), rh(6,indSpawn(trial_num):indHit(trial_num)), '.r');
% hold on
% plot3(lh(4,indSpawn(trial_num):indHit(trial_num)), lh(5,indSpawn(trial_num):indHit(trial_num)), lh(6,indSpawn(trial_num):indHit(trial_num)), '.b');

% Kinematics
lhDisp = zeros(length(lh_fu(1,:)),1);
for i = 1:length(lh_fu(1,:))
    lhDisp(i) = sqrt((lh_fu(4,i) - lh_fu(4,1))^2 + (lh_fu(5,i) - lh_fu(5,1))^2 + (lh_fu(6,i) - lh_fu(6,1))^2);
end

rhDisp = zeros(length(rh_fu(1,:)),1);
for i = 1:length(rh_fu(1,:))
    rhDisp(i) = sqrt((rh_fu(4,i) - rh_fu(4,1))^2 + (rh_fu(5,i) - rh_fu(5,1))^2 + (rh_fu(6,i) - rh_fu(6,1))^2);
end

lhVel = diff(lhDisp);
rhVel = diff(rhDisp); % lh and rh velocities
lhAcc = diff(lhVel);
rhAcc = diff(rhVel); % lh and rh tangential accelerations

% Onset/Offset calculation based on Teasdale, 1991; Tresilian, 1997. This
% should do a better job than the marker stream from LSL... although it
% uses indSpawn to set the range of indicies for the calculations. Code was
% written in vr_exo_kinematics.m
% Any changes to this code should be made there first, then copied over to
% here. Also, you can check the onset/offset against the movements in other
% code.

% RH onset/offset
onsetRH = zeros(length(indSpawn),1);
offsetRH = zeros(length(indSpawn),1);
startLag = 10; % Increase this to get rid of movement artifacts from previous trial (remember fs ~ 50 Hz, so keep this under 25ish)
endLag = 1; % Keep this at 1... we are taking care of things in endPad
endPad = 20; % Increase this to get rid of movement artifacts from previous trial. See lab book pg 51.
for i = 1:length(indSpawn)
    if i == 1
        onsetRH(i) = vrOnset(rhDisp(1:indSpawn(2)),startLag,10,100);
        offsetRH(i) = vrOffset(rhDisp(1:indSpawn(2)+endPad),endLag,10,100,i);
    elseif i > 1 && i < length(indSpawn)
        onsetRH(i) = vrOnset(rhDisp(indSpawn(i):indSpawn(i+1)),startLag,10,100) + indSpawn(i);
        offsetRH(i) = vrOffset(rhDisp(indSpawn(i):indSpawn(i+1)+endPad),endLag,10,100,i) + indSpawn(i);
    elseif i == length(indSpawn)
        onsetRH(i) = vrOnset(rhDisp(indSpawn(i):end),startLag,10,100) + indSpawn(i);
        offsetRH(i) = vrOffset(rhDisp(indSpawn(i):end),endLag,10,100,i) + indSpawn(i);
    end
end

% LH onset/offset
onsetLH = zeros(length(indSpawn),1);
offsetLH = zeros(length(indSpawn),1);
for i = 1:length(indSpawn)
    if i == 1
        onsetLH(i) = vrOnset(lhDisp(1:indSpawn(2)),startLag,10,100);
        offsetLH(i) = vrOffset(lhDisp(1:indSpawn(2)+endPad),endLag,10,10,i);
    elseif i > 1 && i < length(indSpawn)
        onsetLH(i) = vrOnset(lhDisp(indSpawn(i):indSpawn(i+1)),startLag,10,100) + indSpawn(i);
        offsetLH(i) = vrOffset(lhDisp(indSpawn(i):indSpawn(i+1)+endPad),endLag,10,100,i) + indSpawn(i);
    elseif i == length(indSpawn)
        onsetLH(i) = vrOnset(lhDisp(indSpawn(i):end),startLag,10,100) + indSpawn(i);
        offsetLH(i) = vrOffset(lhDisp(indSpawn(i):end),endLag,10,100,i) + indSpawn(i);
    end
end

% % Visual inspection of lh displacement (including spawn and hit timepoints)
% figure;
% plot(lhDisp);
% for i = 1:length(indSpawn)
%     hold on;
%     plot(indSpawn(i),lhDisp(indSpawn(i)),'ro');
%     hold on;
%     plot(indHit(i),lhDisp(indHit(i)),'go');
% end

%% EMG timesync
% Note: Acc and EMG are sampled at different rates. EMG >> Acc. Therefore,
% the Acc data 'drops' out after a while and is padded with "0". Also, each
% data type (Acc or EMG) have the same timestamp for all channels,
% respectively.
emgAcc = emg(:,contains(emg.Properties.VariableNames, {'Xs1','Acc'}));
indAccEnd = find(isnan(emgAcc.Xs1), 1)-1; % "-1" is necessary to avoid NaN
emgAcc = emgAcc(1:indAccEnd,:); % subset to only include actual accel data (see note above)
emgRaw = emg(:,contains(emg.Properties.VariableNames, {'Xs4','EMG'})); % Note, the first 'time' column for EMG data is Xs, but a search using 'Xs' would wildcard all time columns... Xs4 is more unique and equally as valid
indEMGEnd = find(isnan(emg.Xs) & isnan(emg.Xs4) & isnan(emg.Xs8) & isnan(emg.Xs12),1); % Find the end of datastream by finding the NaN in ALL time vars

% if isnan(emg.Xs4(indEMGEnd) + 1) % Xs4 on one participant had a single NaN 1/4 way through testing
%     indEMGEnd = find(isnan(emg.Xs),1); % Try on different time column (will be within a few ms of eachother)
% end
indEMGEnd = indEMGEnd - 1;
if ~isempty(indEMGEnd)
    emgRaw = emgRaw(1:indEMGEnd,:); % subset to only include actual emg data (remove NaNs)
else
    emgRaw = emgRaw(1:end,:); % do nothing if no NaNs are encountered
end
fsEMG = length(emgRaw.Xs4)/(emgRaw.Xs4(end) - emgRaw.Xs4(1)); % emg sampling rate ~2k Hz
fsAcc = (indAccEnd)/(emgAcc.Xs1(end) - emgAcc.Xs1(1));
% Note: Xs1 is the time column for first emg sensor. Also, there is a mismatch between the end of EMG recording
% and the end of the time column. This will cause a fractional mismatch in sampling rate on the order of a fraction of a Hz
% although is matches the Trigno Sensor Specs exactly 148.1Hz

% I will be time syncing the kinematic and emg data by using alignsignals(). This
% works by taking two 1-D signals, in this case displacement from the
% Oculus TouchSensors and the acceleration from the Delsys Trigno sensors,
% and taking the cross correlation between the signals. The outputs to
% alignsignals() contain the two signals, adjusted in time to syncronize,
% but also D, which is the offset (in # samples) between them.
rDeltAccx = emgAcc.RDELTOIDAcc2X; % Right Delts Acceleration in X-direction
AccTime = emgAcc.Xs1;
% View original signals to demonstrate async
figure; plot((1:length(rhDisp))/fsVR,rhDisp,'b'); hold on; plot((1:length(rDeltAccx))/fsAcc,rDeltAccx,'r'); title('Async'); legend('rhDisp','rDeltAccx')

% Downsample rDeltAccx to match sampling rate of rhDisp, but preserve
% disperate signal lengths
x = 1:length(rDeltAccx); % Sample points (contains all points in original signal)
v = rDeltAccx; % original signal to be downsampled
xq = linspace(1,length(rDeltAccx),round(AccTime(end)*fsVR)); % projection of original sample into the length adjusted, resampled data (will have same sample rate as rhDisp, within 1Hz or so)
dsrDeltAccx = interp1(x,v,xq);
dsAccTime = interp1(x,AccTime,xq); % Downsample the Trigno Time vector to match
figure % check that downsampling worked, especially the downsampled time vector (important for xcorr)
plot(emgAcc.Xs1, rDeltAccx, 'bo'); hold on; plot(dsAccTime, dsrDeltAccx, 'rx'); legend('rDeltAccx', 'dsrDeltAccx'); title('Downsampling')

% Align signals
% Note, I reflect and zero-out the offset in the Trigno data. This gives
% best xcorr behavior
[Adisp, Aacc, D] = alignsignals(rhDisp, -dsrDeltAccx + mode(dsrDeltAccx));
figure; plot((1:length(Adisp))/fsVR, Adisp, 'b'); hold on; plot((1:length(Aacc))/fsVR, Aacc, 'r'); title('Synced');legend('rhDisp','dsrDeltAccx')
lag = D/fsVR; % Time lag (in seconds) between the two signals. Use this to project into sample space to figure out sample lag for each signal
lagIND = round(lag*fsEMG); % find index of timelag in emg data

% So now that we have the lag, we can take the emg data - lag to syncro the
% emg with kinematics.
if lag > 0 % EMG recording started AFTER VR recording. Therefore, we 'shift' EMG data leftward
    figure;
    plot((1:length(rhDisp))/fsVR,rhDisp,'b'); hold on;
    plot(emgRaw.Xs4(lagIND:end)-lag,500*emgRaw.RDELTOIDEMG2(lagIND:end),'r'); % Scale and shift
    title('Kinematics and EMG');
    hold on;
    for i = 1:length(onsetLH) % Plot vertical dashed lines at target spawn and target hit
        hold on;
        xline(onsetRH(i)/fsVR,'g--');
        hold on;
        xline(offsetRH(i)/fsVR,'c--');
    end
elseif lag < 0 % EMG recording started BEFORE VR recording. Therefore, we 'shift' EMG data rightward
    figure;
    plot((1:length(rhDisp))/fsVR,rhDisp,'b'); hold on;
    plot(emgRaw.Xs4 - lagIND/fsEMG, 500*emgRaw.RDELTOIDEMG2);
    title('Kinematics and EMG');
    hold on;
    for i = 1:length(onsetLH) % Plot vertical dashed lines at target spawn and target hit
        hold on;
        xline(onsetRH(i)/fsVR,'g--');
        hold on;
        xline(offsetRH(i)/fsVR,'c--');
    end
end

%% Outputs for Neurospec Analysis
% Trigger locations (start of each trial)
trig = ((onsetRH./fsVR)+lag)*fsEMG; % index of movemement start in EMG data. Correction is made w.r.t. lag btw signals
onsetoffsetRH = [((onsetRH./fsVR)+lag)*fsEMG ((offsetRH./fsVR)+lag)*fsEMG]; % onset and offset data combined into 1
onsetoffsetLH = [((onsetLH./fsVR)+lag)*fsEMG ((offsetLH./fsVR)+lag)*fsEMG]; % onset and offset data combined into 1
figure % Sanity check to make sure trigs hit the start of EMG pulses
plot(emgRaw.RDELTOIDEMG2)
hold on
for i = 1:numTrials
    xline(((onsetRH(i)/fsVR)+lag)*fsEMG);
    hold on;
end

% Signals to compare (NOTE: reference vs. response is important for phase,
% impulse-response, and cumulant density data... I don't think I'll need that)
ldelt = emgRaw.LDELTOIDEMG1; % sig1 is 'referece' signal
rdelt = emgRaw.RDELTOIDEMG2; % sig2 is 'response' signal
lbicep = emgRaw.LBICEPSBRACHIIEMG3;
rbicep = emgRaw.RBICEPSBRACHIIEMG4;
freq = round(fsEMG); % define sampling rate (as integer)
targets = targetHit(1,:)'; % pass along the target location data

% Export Data to then load into Matlab 2013 & Neurospec 2.0
kfggfkkfggkf % Remove comment to break code before writing data to file
formatIn = 'yy-mm-dd'; % Note, this is only unique when only one participant per day is run...
subID = str2num([num2str(datenum(file(1:8),formatIn)) file(10:11)]); % Convert yy-mm-dd of "file" into a datenum unique integer, then add participant order (if more than one person tested per day)
if strcmp(computer, 'PCWIN64')
    save(['C:\Users\abrun\Dropbox\Catholic U\VR_EXO_Stroke\Data\post_process\',[num2str(subID) '-' file(13:end-4)],'_emg.mat'], 'ldelt', 'rdelt', 'lbicep', 'rbicep', 'trig', 'freq', 'onsetoffsetLH', 'onsetoffsetRH', 'targets')
else
    save(['/Users/alexbrunfeldt/Dropbox/Catholic U/VR_EXO_Stroke/Data/post_process/',[num2str(subID) '-' file(13:end-4)],'_emg.mat'], 'ldelt', 'rdelt', 'lbicep', 'rbicep', 'trig', 'freq', 'onsetoffsetLH', 'onsetoffsetRH', 'targets')
end
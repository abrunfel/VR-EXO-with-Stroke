% VR_EXO experiment: VR kinematic analysis of UNLATERAL blocks (1,5)
% Current version coded on 1/30/23
% NOTE: This code is a partner to "vr_exo_stroke_indiv_uni.m". Changes to this code must be duplicated manually in the 'indiv'
% version. I don't have time to come up with an elegant "functionization"
% of the two...
clear all
close all
%% Start Here!!!
% NOTE: Unity is a left-handed coordinate frame. From the
% 'Scene' display in the Unity program, it appears the y- an
% z-axes are inverted. That is:
% X-axis = left/right
% Y-axis = up/down
% Z-axis = forward/backward
% Do you want to invert the y, z axes?
% 1 = YES
% 0 = NO
invert = 1;

%% File import
if strcmp(computer, 'PCWIN64')
    cd('C:\Users\Alex\Dropbox\Catholic U\VR_EXO_Stroke\Data')
    all_files = dir;
    is_dir = [all_files.isdir];
    dir_names = {all_files(is_dir).name};
    folders = dir_names(cellfun(@(x) strncmp(x, '2', 1), dir_names))';
    plist = importHandedness("C:\Users\Alex\Dropbox\Catholic U\VR_EXO_Stroke\Participants\VR_EXO_Stroke_Plist.xlsx");
else
    plist = importHandedness("C:\Users\Alex\Dropbox\Catholic U\VR_EXO_Stroke\Participants\VR_EXO_Stroke_Plist.xlsx");
end
%

%% Main Loop
for i = 1:length(folders)
    if strcmp(computer, 'PCWIN64')
        cd(['C:\Users\Alex\Dropbox\Catholic U\VR_EXO_Stroke\Data\', folders{i}])
        files = dir(['*uni*.xdf']);
        for j = 1:length(files)
            file = files(j);
            pathname = file.folder;
            file = file.name;
            DFexport = vr_exo_stroke_kin(file, pathname, invert, plist);
        end
    else
        cactus
    end
end
%
%%
%%%%%%%%%%% Turn the individual processing script into a function that gets
%%%%%%%%%%% looped in "Main Loop"
function DFexport = vr_exo_stroke_kin(file, pathname, invert, plist)
% %% Data import
% % Load in xdf file from LabStreamLayer Recorder in Unity
data = load_xdf([pathname '\' file]);
% Determine with hand is impaired. NOTE: 'handedness' is the the side (L/R)
% of impairment, not hand dominance!
pID = {plist(2:end,'ParticipantID')};
handedness = plist.SideAffected(find(strcmp(pID{1,1}.ParticipantID, file(1:11)))+1);
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

        case{'RedSphereTransform'}
            sphere = cat(1,double(data{i}.time_series),data{i}.time_stamps); % red sphere location
            sphere = sphere(4:6,1);
            
        case{'StartMarker'}
            tstart = data{i}.time_stamps;
    end
end
if exist('sphere', 'var') == 0 % This allows the code to work on data recorded before 2/10/21. In fact, this is a fixed value regardless of when data are collect, so long as the value is not manually changed in Unity.
    sphere = [0 0 -0.75]';
end
%% Remove recording artifacts
% See page 056 and 057 of labbook.
% Find index when the 'down-arrow' key is pressed, indicating the start of
% the actual program. This is critical for determining caliX and to remove
% recording artifacts.
if exist('tstart','var') == 1
    indStart = find(centerEye(7,:) > tstart(1), 1);
    % Remove all data before down-arrow key press
    centerEye = centerEye(:,indStart:end);
    rh = rh(:,indStart:end);
    lh = lh(:,indStart:end);
    rh_fu = rh_fu(:,indStart:end);
    lh_fu = lh_fu(:,indStart:end);
else
    tstart =1;
end

%% Axis Inversion
% This chunk swaps the y- and z-axes for any coordinate based measure.
% Note: the target information uses the var 'invert' to invert the target
% position axes as well.
if invert == 1
    centerEyetempY = centerEye(5,:); %temp store y-axis data
    centerEyetempZ = centerEye(6,:); %temp store z-axis data
    centerEye(5,:) = centerEyetempZ;
    centerEye(6,:) = centerEyetempY;
    clear centerEyetempY centerEyetempZ
    
    rhtempY = rh(5,:); %temp store y-axis data
    rhtempZ = rh(6,:); %temp store z-axis data
    rh(5,:) = rhtempZ;
    rh(6,:) = rhtempY;
    clear rhtempY rhtempZ
    
    lhtempY = lh(5,:); %temp store y-axis data
    lhtempZ = lh(6,:); %temp store z-axis data
    lh(5,:) = lhtempZ;
    lh(6,:) = lhtempY;
    clear lhtempY lhtempZ
    
    rh_futempY = rh_fu(5,:); %temp store y-axis data
    rh_futempZ = rh_fu(6,:); %temp store z-axis data
    rh_fu(5,:) = rh_futempZ;
    rh_fu(6,:) = rh_futempY;
    clear rh_futempY rh_futempZ
    
    lh_futempY = lh_fu(5,:); %temp store y-axis data
    lh_futempZ = lh_fu(6,:); %temp store z-axis data
    lh_fu(5,:) = lh_futempZ;
    lh_fu(6,:) = lh_futempY;
    clear lh_futempY lh_futempZ
    
    spheretempY = sphere(2); spheretempZ = sphere(3);
    sphere(2) = spheretempZ; sphere(3) = spheretempY;
    clear spheretempY spheretempZ
end
%% Calculate Timing and Kinematics
fs = length(lh_fu(7,:))/(lh_fu(7,end) - lh_fu(7,1)); % sample rate (seems to be ~50 Hz). NOTE: lh and rh can be different legnths, however usually only by 1-2 samples out of 30,000+
% There is a chance that a participant does not finish a block; therefore,
% length(targetSpawn) > length(targetHit). If that is the case, you must
% delete the final targetSpawn from the dataset.
if length(targetSpawn) > length(targetHit)
    targetSpawn = targetSpawn(:,1:length(targetHit));
end
indSpawn = zeros(length(targetSpawn),1);
indHit = zeros(length(targetSpawn),1);
for i = 1:length(targetSpawn)
    indSpawn(i) = find(lh_fu(7,:) > targetSpawn(2,i),1); % indicies in lh and rh data streams that signify the target spawns (n = length(targetSpawn))
    indHit(i) = find(lh_fu(7,:) > targetHit(2,i),1); % indicies in lh and rh data streams that signify the target spawns (n = length(targetSpawn))
end
% % Visual inspection of hand paths for any trial
% trial_num = 2;
% figure;
% plot3(rh(4,indSpawn(trial_num):indHit(trial_num)), rh(5,indSpawn(trial_num):indHit(trial_num)), rh(6,indSpawn(trial_num):indHit(trial_num)), '.r');
% hold on
% plot3(lh(4,indSpawn(trial_num):indHit(trial_num)), lh(5,indSpawn(trial_num):indHit(trial_num)), lh(6,indSpawn(trial_num):indHit(trial_num)), '.b');

% % Kinematics
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

% Simple filtering to better compute interlimb kinematics. Functions from: https://www.mathworks.com/matlabcentral/fileexchange/38584-butterworth-filters
lp_co = 1;
lhDisp_filt = lopass_butterworth(lhDisp,lp_co,fs,4);
rhDisp_filt = lopass_butterworth(rhDisp,lp_co,fs,4);

lhVel_filt = diff(lhDisp_filt);
rhVel_filt = diff(rhDisp_filt); % lh and rh velocities
% figure; plot(lhDisp,'b'); hold on; plot(rhDisp,'r'); hold on; plot(lhDisp_filt,'g'); hold on; plot(rhDisp_filt,'m'); title('Displacement')
% figure; plot(lhVel,'b'); hold on; plot(rhVel,'r'); hold on; plot(lhVel_filt,'g'); hold on; plot(rhVel_filt,'m'); title('Vel')

lp_co = 5;
lhVel_filt2 = lopass_butterworth(lhVel,lp_co,fs,4);
rhVel_filt2 = lopass_butterworth(rhVel,lp_co,fs,4);
%figure; plot(lhVel_filt,'b'); hold on; plot(rhVel_filt,'r'); hold on; plot(lhVel_filt2,'g'); hold on; plot(rhVel_filt2,'m'); title('Pre diff filt vs. post diff filt')


% Onset/Offset calculation based on Teasdale, 1991; Tresilian, 1997. This
% should do a better job than the marker stream from LSL... although it
% uses indSpawn to set the range of indicies for the calculations. Also
% note that the time from onset to offset includes the return-to-lap
% portion of the reach

% RH onset/offset
onsetRH = zeros(length(indSpawn),1);
offsetRH = zeros(length(indSpawn),1);
startLag = 10; % Increase this to get rid of movement artifacts from previous trial (remember fs ~ 50 Hz, so keep this under 25ish)
endLag = 1; % Keep this at 1... we are taking care of things in endPad
endPad = 20; % DEFAULT = 20. Increase this to get rid of movement artifacts from previous trial. See lab book pg 51.
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
        offsetLH(i) = vrOffset(lhDisp(1:indSpawn(2)+endPad),endLag,10,100);
    elseif i > 1 && i < length(indSpawn)
        onsetLH(i) = vrOnset(lhDisp(indSpawn(i):indSpawn(i+1)),startLag,10,100) + indSpawn(i);
        offsetLH(i) = vrOffset(lhDisp(indSpawn(i):indSpawn(i+1)+endPad),endLag,10,100) + indSpawn(i);
    elseif i == length(indSpawn)
        onsetLH(i) = vrOnset(lhDisp(indSpawn(i):end),startLag,10,100) + indSpawn(i);
        offsetLH(i) = vrOffset(lhDisp(indSpawn(i):end),endLag,10,100) + indSpawn(i);
    end
end

% Maximum reach loaction. NOTE: This is NOT the same as determining the
% hand displacement at indHit. The participant may punch through the target
% with Unity registering a 'hit', whereas the limbs may continue to move past
% the target.
rhDispMax = zeros(length(indSpawn),1);
indMaxRH = zeros(length(indSpawn),1);
lhDispMax = zeros(length(indSpawn),1);
indMaxLH = zeros(length(indSpawn),1);
rhPosMax = zeros(length(indSpawn),3);
lhPosMax = zeros(length(indSpawn),3);
for i = 1:length(indSpawn)
    [rhDispMax(i), indMaxRHtemp] = max(rhDisp(onsetRH(i):offsetRH(i)));
    indMaxRH(i) = indMaxRHtemp + onsetRH(i) - 1;
    [lhDispMax(i), indMaxLHtemp] = max(lhDisp(onsetLH(i):offsetLH(i)));
    indMaxLH(i) = indMaxLHtemp + onsetLH(i) - 1;
    
    %Now that we have the index of maximum displacement, we can use that to
    %determine the x,y,z location of each hand at that sample index.
    rhPosMax(i,:) = [rh_fu(4,indMaxRH(i)) rh_fu(5,indMaxRH(i)) rh_fu(6,indMaxRH(i))];
    lhPosMax(i,:) = [lh_fu(4,indMaxLH(i)) lh_fu(5,indMaxLH(i)) lh_fu(6,indMaxLH(i))];
    clear indMaxRHtemp indMaxLHtemp
end

% Check the onsets/offsets against indSpawn and indHit
% if handedness == 'R'
%     figure
%     plot(rhDisp); hold on;
%     title('Right (impaired) hand displacement')
%     for i = 1:length(indSpawn)
%         xline(indSpawn(i),'g-'); hold on;
%         xline(onsetRH(i), 'g--'); hold on;
%         xline(offsetRH(i), 'r--'); hold on;
%         plot(indMaxRH(i),rhDisp(indMaxRH(i)),'mx'); hold on;
%     end
% else
%     figure
%     plot(lhDisp); hold on;
%     title('Left (impaired) hand displacement')
%     for i = 1:length(indSpawn)
%         xline(indSpawn(i),'g-'); hold on;
%         xline(onsetLH(i), 'g--'); hold on;
%         xline(offsetLH(i), 'r--'); hold on;
%         plot(indMaxLH(i),lhDisp(indMaxLH(i)),'mx'); hold on;
%     end
% end
% Determine the maximum reaching position relative to a global origin. The
% two options are contained in a struct array. "*Rel.s" is relative to
% sphere, "*Rel.c" is relative to centerEye.
% at 'sphere'.
rhPosMaxRel.s = rhPosMax - sphere';
lhPosMaxRel.s = lhPosMax - sphere';

% at mean location of 'centerEye'.
rhPosMaxRel.c = rhPosMax - mean(centerEye(4:6,:),2)';
lhPosMaxRel.c = lhPosMax - mean(centerEye(4:6,:),2)';

for i = 1:length(lhPosMaxRel.s)
   rhNorm.s(i) = norm(rhPosMaxRel.s(i,:));
   lhNorm.s(i) = norm(lhPosMaxRel.s(i,:));
   rhNorm.c(i) = norm(rhPosMaxRel.c(i,:));
   lhNorm.c(i) = norm(lhPosMaxRel.c(i,:));
end

% Movement times (multiple styles, read carefully!)
mt = (indHit-indSpawn)/fs; % 'cursor' movement time
mtRH = (indMaxRH-onsetRH)/fs; % RH MT
mtLH = (indMaxLH-onsetLH)/fs; % LH MT
%
%% Reduce Data to individual trials
% Essential Data
% Only calculates trialData variables for impaired hand
if handedness == 'R' % Right impaired
    for i = 1:length(targetHit)
        trialData(i).trial = i; % trial number
        trialData(i).target = targetSpawn(1,i); % target number
        trialData(i).pos = rh_fu(4:6,indSpawn(i):indHit(i)); % x,y,z hand position (trajectory)
        trialData(i).eye = centerEye(4:6, indSpawn(i):indHit(i));
        trialData(i).NormS = rhNorm.s(i);
        trialData(i).NormC = rhNorm.c(i);
        trialData(i).mt = mtRH(i);
        trialData(i).RT = (onsetRH(i) - indSpawn(i))/fs;
    end
else % Left hand impaired
    for i = 1:length(targetHit)
        trialData(i).trial = i; % trial number
        trialData(i).target = targetSpawn(1,i); % target number
        trialData(i).pos = lh_fu(4:6,indSpawn(i):indHit(i)); % x,y,z hand position (trajectory)
        trialData(i).eye = centerEye(4:6, indSpawn(i):indHit(i));
        trialData(i).NormS = lhNorm.s(i);
        trialData(i).NormC = lhNorm.c(i);
        trialData(i).mt = mtLH(i);
        trialData(i).RT = (onsetLH(i) - indSpawn(i))/fs;
    end
end

% Remove data from trials with less than 10 samples of data (see lab book, page 105).
if ~isempty(trialData([trialData.mt]*fs < 10))
    rmTrials = trialData([trialData.mt]*fs < 10).trial; % These are the trials to be removed from data
    trialData(rmTrials) = [];
end

% Data derived from essential data
for i = 1:length(trialData)
    for k = 1:length(trialData(i).pos)
      trialData(i).Disp(1,k) = sqrt((trialData(i).pos(1,k) - trialData(i).pos(1,1))^2 + (trialData(i).pos(2,k) - trialData(i).pos(2,1))^2 + (trialData(i).pos(3,k) - trialData(i).pos(3,1))^2); % Right hand displacement  
    end
    
    % Peak velocity, time to peak velocity
    if handedness == 'R'     
        [velPeak, indVP] = max(rhVel_filt2(indSpawn(i):indHit(i)));
        trialData(i).velPeak = 100*velPeak; % Convert to cm/s
        trialData(i).t2pv = indVP/fs;
    else
        [velPeak, indVP] = max(lhVel_filt2(indSpawn(i):indHit(i)));
        trialData(i).velPeak = 100*velPeak; % Convert to cm/s
        trialData(i).t2pv = indVP/fs;        
    end
end

% figure
% for i = 1:length(trialData)
%     plot3(trialData(i).pos(1,:), trialData(i).pos(2,:), trialData(i).pos(3,:), 'r');
%     hold on;
% end
% % Add in each hand's position at maximum displacement
% if handedness == 'R'
%     hold on ;plot3(rhPosMax(1:end-1,1),rhPosMax(1:end-1,2),rhPosMax(1:end-1,3), 'rx') % Note: I'm not plotting the last max position because when personally doing the task, the movement offset code breaks because I need to stop the LSL recording after setting down the TouchSensors
% else
%     hold on ;plot3(lhPosMax(1:end-1,1),lhPosMax(1:end-1,2),lhPosMax(1:end-1,3), 'bx')
% end
% % Add sphere (indicates ground floor at participant location)
% hold on; plot3(sphere(1), sphere(2), sphere(3), 'ko') % plot the red 'sphere' from Unity. When running the task, this red sphere appears on the floor (ground level) just below the headset location (moves with headset).
% if invert == 0
%     xlabel('X Axis'); ylabel('Y Axis'); zlabel('Z Axis');
% elseif invert == 1
%     xlabel('X Axis'); ylabel('Z Axis'); zlabel('Y Axis');
% end

% Plot displacement vs. time
% Keep this suppresed during normal operation of this code. Use it to check
% data fidelity...
% figure
% for i = 1:length(trialData)
%     plot(trialData(i).lhDisp, 'b'); hold on;
%     plot(trialData(i).rhDisp, 'r'); hold on;
%     plot(trialData(i).cursorDisp, 'g'); hold on;
% end

%% Target information
percent = 0.8;
armLength = 0.61;
armAngle = 30;
shoulderHeight = 0.90;
%caliX = centerEye(4,1); % IMPORTANT: Since removing recording artifacts removes the first ~1000 samples or so, I changed the (4,indStart) to (4,1) to compensate for the new start of data
caliX = 0; % default. Use for pre- 2/10/21 data.

targetLoc = targetManager(percent, armLength, armAngle, shoulderHeight, caliX, invert);
% % plot target locations on handpath plots (NOTE: need to comment out
% % displacement vs. time graphs first)
% hold on;
% for i = 5:10 % Note, after November, 2020 testing, I changed protocol to only include targets 5-10
%     plot3(targetLoc(1,i), targetLoc(2,i), targetLoc(3,i), 's');
%     hold on
% end

%% Outcome Variables
[DVdataframe, mbTarget] = ExoVr_outcomeVars_stroke_uni(trialData); % This is the updated verion that calculates RT of the impaired hand

% In rare cases, # of rows in trialData < # of trials in experiment (see
% lab book pg 105). However, R code needs 54 (12 for uni blocks) trials per block in order to
% bin properly. My fix (11/29/21) is to NaN all rows of the output DVdataframe that
% don't have entries in trialData.
NaNrow = NaN(1,size(DVdataframe,2)); % create a row of NaN to insert
if length(DVdataframe) < length(indSpawn)
    for k = 1:length(rmTrials)
        DVdataframe = insertrows(DVdataframe, NaNrow, rmTrials(k)-1); % insert NaNrow into dataframe (-1 fixes indexing shift)
        DVdataframe(rmTrials(k),1) = rmTrials(k); % pass trial number back into DV
    end
end

%figure;bar(mbTarget(:,5));hold on;yline(0.5);ylim([0.25 0.75]) % bargraph of relative RIGHT hand contribution (column 5 of mbTarget dataframe)
%figure;plot(DVdataframe(:,6)) % timeseries of relative RIGHT hand contribution (column 6 in the ensemble dataframe)

%% Save data to file
formatIn = 'yy-mm-dd'; % Note, this is only unique when only one participant per day is run...
subID = str2num([num2str(datenum(file(1:8),formatIn)) file(10:11)]); % Convert yy-mm-dd of "file" into a datenum unique integer, then add participant order (if more than one person tested per day)
cond = file(13:15);
switch cond
    case{'uni'}
        condition = 1;
    case{'bil'}
        condition = 2;
    case{'exo'}
        condition = 3;
end

% If block has fewer than 54 trials (based on current setup 8/22), you must
% pad DVdataframe with NaN.
if condition == 1
    DVdataframe = padarray(DVdataframe, 12-size(DVdataframe,1), NaN, 'post');
else
    DVdataframe = padarray(DVdataframe, 54-size(DVdataframe,1), NaN, 'post');
end

subid = ones(size(DVdataframe,1),1)*subID; % subid vector
cond = ones(size(DVdataframe,1),1)*condition; % condition vector as numeric
block = ones(size(DVdataframe,1),1)*str2num(file(17:18)); % block (1-7 for controls, 1-3 for stroke)

% Insert subid and cond columns
DFexport = [subid cond block DVdataframe];
%vjfgkfldfjggkl % Remove comment to create natural codebreak to prevent writing data to file.
if strcmp(computer, 'PCWIN64')
    cd('C:\Users\Alex\Dropbox\Catholic U\VR_EXO_Stroke\Data\post_process')
    save([num2str(subID), '_', file(13:15), '_', file(17:18), '_vr', '.mat'], 'DFexport');
    cd('C:\Users\Alex\Dropbox\Catholic U\VR_EXO_Stroke\Data');
else
    cd('/Users/alexbrunfeldt/Dropbox/Catholic U/VR_EXO_Stroke/Data/post_process')
    save([num2str(subID), '_', file(13:15), '_', file(17:18), '_vr', '.mat'], 'DFexport');
    cd('/Users/alexbrunfeldt/Dropbox/Catholic U/VR_EXO_Stroke/Data');
end
end
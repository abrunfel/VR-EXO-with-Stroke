%% File import
clear all; close all
% Select desired folder (do not hit 'Enter' key. You must highlight the
% folder, then hit "Select Folder" button on popup.
if strcmp(computer, 'PCWIN64')
    selpath = uigetdir('C:\Users\abrun\Dropbox\Catholic U\VR_EXO_Stroke\Data\');
    subid = selpath(end-10:end);
    cd('C:\Users\abrun\Dropbox\Catholic U\VR_EXO_Stroke\Data\post_process\')
    % Get unique identifier
    formatIn = 'yy-mm-dd';
    subID = [num2str(datenum(subid,formatIn)) subid(10:11)];
    files = dir([subID '*_emg.mat']);
    savepath = 'C:\Users\abrun\Dropbox\Catholic U\VR_EXO_Stroke\Data\post_compile\';
    clear subid % remove this so as to not confuse with the datenum subid
else
    selpath = uigetdir('/Users/alexbrunfeldt/Dropbox/Catholic U/VR_EXO_Stroke/Data/');
    subid = selpath(end-10:end);
    cd('/Users/alexbrunfeldt/Dropbox/Catholic U/VR_EXO_Stroke/Data/post_process/')
    % Get unique identifier
    formatIn = 'yy-mm-dd';
    subID = [num2str(datenum(subid,formatIn)) subid(10:11)];
    files = dir([subID '*_emg.mat']);
    savepath = '/Users/alexbrunfeldt/Dropbox/Catholic U/VR_EXO_Stroke/Data/post_compile/';
    clear subid % remove this so as to not confuse with the datenum subid
end

%% Main loop
for i = 1:length(files)
    if strcmp(computer, 'PCWIN64')
        cd('C:\Users\abrun\Dropbox\Catholic U\VR_EXO_Stroke\Data\post_process\');
    else
        cd('/Users/alexbrunfeldt/Dropbox/Catholic U/VR_EXO_Stroke/Data/post_process/')
    end

    file = load(files(i).name); % Get one individual file
    cond = files(i).name(10:12);
    switch cond
        case{'uni'}
            condition = 1;
        case{'bil'}
            condition = 2;
        case{'exo'}
            condition = 3;
    end
    block = str2num(files(i).name(14:15));
    
    % Fix rare case where the onset for trial one is negative (ie: onsetoffsetLH/RH(1,1) = neg value)
    if find(file.onsetoffsetLH<0) == 1
        file.onsetoffsetLH(1,1) = 1;
        file.trig(1) = 1;
        warning('Trial 1 onset is negative value')
    end
    if find(file.onsetoffsetRH<0) == 1
        file.onsetoffsetRH(1,1) = 1;
        file.trig(1) = 1;
        warning('Trial 1 onset is negative value')
    end
    
    % Detrend data
    file.ldelt = detrend(file.ldelt);
    file.rdelt = detrend(file.rdelt);
    file.lbicep = detrend(file.lbicep);
    file.rbicep = detrend(file.rbicep);
    
    % Filter data
    bpfreq = [5 250];
    filtLdelt = bandpass(file.ldelt,bpfreq,file.freq);
    filtRdelt = bandpass(file.rdelt,bpfreq,file.freq);
    filtLbicep = bandpass(file.lbicep,bpfreq,file.freq);
    filtRbicep = bandpass(file.rbicep,bpfreq,file.freq);
    
    % RMSE calculation
    rmse = emgRMSE(filtLdelt, filtRdelt, filtLbicep, filtRbicep, file.onsetoffsetLH, file.onsetoffsetRH);
    % If block has fewer than 54 trials (based on current setup 8/22), you must
    % pad rmse with NaN.
    if condition == 1
        rmse = padarray(rmse, 11-size(rmse,1), NaN, 'post');
        file.targets = padarray(file.targets, 11-size(file.targets,1), NaN, 'post');
    else
        rmse = padarray(rmse, 54-size(rmse,1), NaN, 'post');
        file.targets = padarray(file.targets, 54-size(file.targets,1), NaN, 'post');
    end
    
    % MVC normalization
    if strcmp(files(1).name(1:11),'07_19_21_01') == 1 % (skip '07_19_21_01')
        rmse2 = NaN(size(rmse));
    else % MVC normalize then RMS
        [emgNorm, mvcs] = mvcNorm(selpath, filtLdelt, filtRdelt, filtLbicep, filtRbicep, bpfreq);
        rmse2 = emgRMSE(emgNorm(:,1), emgNorm(:,2), emgNorm(:,3), emgNorm(:,4), file.onsetoffsetLH, file.onsetoffsetRH);
    end
    % If block has fewer than 54 trials (based on current setup 8/22), you must
    % pad rmse with NaN.
    if condition == 1
        rmse2 = padarray(rmse2, 11-size(rmse2,1), NaN, 'post');
    else
        rmse2 = padarray(rmse2, 54-size(rmse2,1), NaN, 'post');
    end
 
    % Coherence Integral from Type0 analysis: see lab book pg 64.
    seg_pwr=10;
    opt_str = '';
    CI = coherence_integral(filtLdelt,filtRdelt,filtLbicep,filtRbicep,file.freq,seg_pwr,opt_str, file.onsetoffsetLH, file.onsetoffsetRH); % INTERlimb coherence
    CIintra = coherence_integral_intra(filtLdelt,filtRdelt,filtLbicep,filtRbicep,file.freq,seg_pwr,opt_str, file.onsetoffsetLH, file.onsetoffsetRH); %INTRAlimb coherence
    % If block has fewer than 54 trials (based on current setup 8/22), you must
    % pad CI and CIintra with NaN.
    if condition == 1
        CI = padarray(CI, 11-size(CI,1), NaN, 'post');
        CIintra = padarray(CIintra, 11-size(CIintra,1), NaN, 'post');  
    else
        CI = padarray(CI, 54-size(CI,1), NaN, 'post');
        CIintra = padarray(CIintra, 54-size(CIintra,1), NaN, 'post');        
    end
   
    % Convert RMSE to long format for R
    rmseLF = [rmse(:,1); rmse(:,2); rmse(:,3); rmse(:,4)];
    mvcLF = [rmse2(:,1); rmse2(:,2); rmse2(:,3); rmse2(:,4)];
    % Set up factors for RMSE
    subid = ones(size(rmse,2)*length(rmse),1)*str2num(subID);
    cond = ones(size(rmse,2)*length(rmse),1)*condition;
    block = ones(size(rmse,2)*length(rmse),1)*block;
    % NOTE: Number of EMG channels is fixed (N = 4). If this changes, so
    % too with the following line...
    muscle = [ones(length(rmse),1); 2*ones(length(rmse),1); 3*ones(length(rmse),1); 4*ones(length(rmse),1)]; % 1 = ldelt, 2 = rdelt, 3 = lbicep, 4 = rbicep
    trial = repmat(1:length(rmse)',1,4)';
    target = repmat(file.targets,4,1);
    % Export dataframe
    DFexportRMSE = [subid cond block trial muscle target rmseLF mvcLF];
    %asdklfj % uncomment to break code (prevents writing data to file)
    writematrix(DFexportRMSE, [savepath 'vrexo_stroke_emgRMSE.txt'], 'WriteMode', 'append', 'Delimiter', ',');
    
    % Convert CI to long format for R
    CILF = [CI(:,1); CI(:,2); CI(:,3); CI(:,4); CI(:,5); CI(:,6)];
    % Set up factors for CI
    subid = ones(size(CI,1)*size(CI,2),1)*subid(1);
    cond = ones(size(CI,1)*size(CI,2),1)*condition(1);
    block = ones(size(CI,1)*size(CI,2),1)*block(1);
    muscle = [ones(size(CI,1)*size(CI,2)/2,1); 2*ones(size(CI,1)*size(CI,2)/2,1)]; % 1 = deltoid, 2 = bicep. NOTE: Only have 2 levels of the 'muscle' factor here because its INTERmuscular 
    band = repmat([ones(size(CI,1),1); 2*ones(size(CI,1),1); 3*ones(size(CI,1),1)],2,1); % 1 = alpha, 2 = beta, 3 = gamma
    trial = repmat(1:length(rmse)',1,6)';
    target = repmat(file.targets,6,1);
    % Export dataframe
    DFexportCI = [subid cond block trial muscle band target CILF];
    %asdklfj % uncomment to break code (prevents writing data to file)
    writematrix(DFexportCI, [savepath 'vrexo_stroke_emgCI.txt'], 'WriteMode', 'append', 'Delimiter', ','); % Matlab 2020 or later
    
    % Convert CIintra to long format for R
    CILFintra = [CIintra(:,1); CIintra(:,2); CIintra(:,3); CIintra(:,4); CIintra(:,5); CIintra(:,6)];
    % Set up factors for CI
    subid = ones(size(CIintra,1)*size(CIintra,2),1)*subid(1);
    cond = ones(size(CIintra,1)*size(CIintra,2),1)*condition(1);
    block = ones(size(CIintra,1)*size(CIintra,2),1)*block(1);
    arm = [ones(size(CIintra,1)*size(CIintra,2)/2,1); 2*ones(size(CIintra,1)*size(CIintra,2)/2,1)]; % 1 = left, 2 = right. NOTE: Only have 2 levels of the 'arm' factor here because its INTRAmuscular 
    band = repmat([ones(size(CIintra,1),1); 2*ones(size(CIintra,1),1); 3*ones(size(CIintra,1),1)],2,1); % 1 = alpha, 2 = beta, 3 = gamma
    trial = repmat(1:length(rmse)',1,6)';
    target = repmat(file.targets,6,1);
    % Export dataframe
    DFexportCIintra = [subid cond block trial arm band target CILF];
    %asdklfj % uncomment to break code (prevents writing data to file)
    writematrix(DFexportCIintra, [savepath 'vrexo_stroke_emgCIintra.txt'], 'WriteMode', 'append', 'Delimiter', ','); % Matlab 2020 or later
    

clear file
end
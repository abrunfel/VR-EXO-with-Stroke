clear all; close all
%% Gunzip atlas file
%atlasfilepath = 'C:\Users\Alex\Box\BIOREC\CPASS\matlab\JHU-ICBM-labels-2mm.nii.gz';
%gunzip(atlasfilepath); Only need to do this once (or if you delete the
%gunzipped version). NOTE: if you did delete it, you'll have to "Coregister Reslice"
%using the SPMreslice.m file
% atlasfilepath = atlasfilepath(1:end-3);

%% Get File and Atlas Info
% Find the "Visage Exports & NIfTI" folder - this will change depending on platform, computer,
% user, etc...
p = matlab.desktop.editor.getActiveFilename;
indp = strfind(p, 'VR_EXO_Stroke');
path = fullfile(p(1:indp+13), 'Participants', 'Imaging');
cd(path);
files = dir(fullfile(path,'*','LesionTracing','w*')); % get all lesion files
allfiles = cellfun(@(x,y) fullfile(x,y),{files.folder},{files.name},'uni',false); % clean up filenames
% JHU atlas
atlasfilepath_jhu = fullfile(p(1:indp+13), 'Scripts', 'Atlases', 'rJHU-ICBM-labels-2mm.nii'); % get gunzipped and resliced atlas filepath
atlas_img_jhu = niftiread(atlasfilepath_jhu); % read in the atlas image file
% S-MATT atlas
atlasfilepath_smatt = fullfile(p(1:indp+13), 'Scripts', 'Atlases', 'rS-MATT.nii');
atlas_img_smatt = niftiread(atlasfilepath_smatt);
% PyT atlases (both left and right
atlasfilepath_pyt_L = fullfile(p(1:indp+13), 'Scripts', 'Atlases', 'rProbabilistic_Left_PyT_100_MNI1mm.nii');
atlas_img_pyt_L = niftiread(atlasfilepath_pyt_L);
atlasfilepath_pyt_R = fullfile(p(1:indp+13), 'Scripts', 'Atlases', 'rProbabilistic_Right_PyT_100_MNI1mm.nii');
atlas_img_pyt_R = niftiread(atlasfilepath_pyt_R);

% A handful of lesions are corrupted (namely, they have abberant voxel
% dimensions). Find and DESTROY (not really, just create bool so we can
% skip them)
for f = 1 : numel(allfiles)
    try
        imgs{f} = niftiread(allfiles{f});
    end
end
goodfiles = cellfun(@(x) size(x,1),imgs) == 79; % This 79 comes from the warped lesion files... it might change with different warp parameters

%% Overlap calculation (Main Loop)
jhuoverlap = zeros(numel(allfiles),48); % Initialize percent overlap (48 = number of distinct regions in JHU-ICBM mask)
smattoverlap = zeros(numel(allfiles),10); % Initialize percent overlap (9 = overlap with Left, Right, maxLorR, LmaxSliceWise, indLMSW, RMSW, indRMSW, MaxSE, indBMSW)
pytoverlap = zeros(numel(allfiles),11); % Initialize percent overlap (9 = overlap with Left, Right, maxLorR, LmaxSliceWise, indLMSW, RMSW, indRMSW, MaxSE, indBMSW)
lesionVolume = zeros(numel(allfiles),1); % Initialize lesion volume (1 = volume of lesion)
for i = 1:numel(goodfiles)
    if goodfiles(i) == 1
        patient_img = niftiread(string(allfiles(i))); % read in warped lesion mask for a patient
        hdr = niftiinfo(string(allfiles(i))); % get header info (will need for voxel size info)
        jhuoverlap(i,:) = JHUoverlap(patient_img, atlas_img_jhu); % percent overlap with the JHU atlas
        smattoverlap(i,:) = SMATToverlap(patient_img, atlas_img_smatt);
        pytoverlap(i,:) = PyToverlap(95, patient_img, atlas_img_pyt_L, atlas_img_pyt_R, atlasfilepath_pyt_R); % first number represents the threhold (i.e., 50 = pyt exists at a given voxel in 50% of participant scans used to create mask)
        lesionVolume(i,:) = nnz(patient_img)*prod(hdr.PixelDimensions(1:3))/1000; % in cubic-centimeters
    elseif goodfiles(i) == 0
        jhuoverlap(i,:) = NaN;
        smattoverlap(i,:) = NaN;
        pytoverlap(i,:) = NaN;
        lesionVolume(i,:) = NaN;
    end
end

%% Get JHU label names
% For JHU atlas mask
JHUlabels = vrexo_getLabels(fullfile(p(1:indp+13), 'Scripts', 'Atlases', 'JHU-labels.xml'));
JHUlabels = JHUlabels(1:48,:);
labels = cellfun(@(x) extractBetween(x,'>','<'), JHUlabels(:,2), 'UniformOutput',false)';
% Coerce labels to non-nested cell array
maxLength = max(cellfun(@numel,labels));
nnlabels = cellfun( @(x) [cell2mat(x), zeros(1,maxLength-numel(x))], labels, 'UniformOutput', false ); % "non-nested labels"

%% Get subject ID
subid = cell(numel(goodfiles),1); % Get subject identifier
for i = 1:numel(goodfiles)
    subid(i) = extractBetween(files(i).name, 'w', '_l');
end


%%  Write to Excel
% Label names for SMATT with ARAT labels
smattLabels = {'lesion_vol', 'L_vol_overlap', 'R_vol_overlap' 'max_vol_overlap',...
    'LmaxSliceWise_overlap', 'iLmaxSliceWise_overlap',...
    'RmaxSliceWise_overlap', 'iRmaxSliceWise_overlap',...
    'maxSliceWise_overlap', 'imaxSliceWise_overlap', 'wCSTLL'};

PyTLabels = {'lesion_vol', 'L_vol_overlap', 'R_vol_overlap' 'max_vol_overlap',...
    'LmaxSliceWise_overlap', 'iLmaxSliceWise_overlap',...
    'RmaxSliceWise_overlap', 'iRmaxSliceWise_overlap',...
    'maxSliceWise_overlap', 'imaxSliceWise_overlap', 'Vraw', 'wCSTLL'};

% Build  overlap dataframes
overlap_jhu = [nnlabels; num2cell(jhuoverlap)];
overlap_smatt = [smattLabels; num2cell(lesionVolume) num2cell(smattoverlap)];
overlap_pyt = [PyTLabels; num2cell(lesionVolume) num2cell(pytoverlap)];
subject = ['Subject'; subid]; % Create subject cell vector
overlap_jhu = [subject, overlap_jhu]; % concat
overlap_smatt = [subject, overlap_smatt]; % concat
overlap_pyt = [subject, overlap_pyt]; % concat

% Write to file
afgljkaslf % Hard codebreak to avoid overwritting. Comment out if you want to update data
cd(fullfile(p(1:indp+13), 'Data', 'post_compile'))
writecell(overlap_jhu, 'overlap_JHU.xlsx');
writecell(overlap_smatt, 'overlap_SMATT.xlsx');
writecell(overlap_pyt, 'overlap_PyT.xlsx');
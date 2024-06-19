% Compiling code to generate R dataframes
clear all
close all

% Select current directory
if strcmp(computer, 'PCWIN64')
    cd('C:\Users\abrun\Dropbox\Catholic U\VR_EXO_Stroke\Data\post_process');
else
    cd('/Users/alexbrunfeldt/Dropbox/Catholic U/VR_EXO_Stroke/Data/post_process');
end

dir_list = dir('*_vr.mat');    %Store subject *mat data file names in variable (struct array).
dir_list = {dir_list.name}'; % filenames
dir_list = dir_list(cellfun(@(x) contains(x, 'uni'), dir_list)); % Only include 'unilateral' blocks
dir_list = sort(dir_list);  % sorts files
numFiles = length(dir_list);

for i = 1:numFiles
   load(char(dir_list(i)));
   
   % Switch to post-compile folder
   if strcmp(computer, 'PCWIN64')
       cd('C:\Users\abrun\Dropbox\Catholic U\VR_EXO_Stroke\Data\post_compile');
   else
       cd('/Users/alexbrunfeldt/Dropbox/Catholic U/VR_EXO_Stroke/Data/post_compile');
   end
   
   % Write data to file, appending as loop runs
   dlmwrite('vrexo_stroke_kin_uni.txt', DFexport, '-append', 'delimiter', ',', 'precision', '%.6f');
   
   % Select current directory
   if strcmp(computer, 'PCWIN64')
       cd('C:\Users\abrun\Dropbox\Catholic U\VR_EXO_Stroke\Data\post_process');
   else
       cd('/Users/alexbrunfeldt/Dropbox/Catholic U/VR_EXO_Stroke/Data/post_process');
   end
end
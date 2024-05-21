%% Calculate evoked response tinnitus effect (using e_8, regardless of conditions)

close all;
clear;
clc;

% Set up directories
parent_folder = '/Volumes/gdrive4tb/IGNITE/tonotopy/surface/projected/';
output_folder = '/Volumes/gdrive4tb/IGNITE/tonotopy/surface/analysis/tinEffect';

% Ensure the output folder exists
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

hemispheres = {'lh', 'rh'};
groups = {'TT', 'NT'};  % TT for tinnitus and NT for noTin

lh_TT = [];
rh_TT = [];
lh_NT = [];
rh_NT = [];

% Get list of subject directories
subjectDirs = dir([parent_folder, '*']);

for sub = 1:length(subjectDirs)
    
    subjectID = subjectDirs(sub).name;
    e8folder = fullfile(parent_folder, subjectID, 'e_8.fsf');
    
    % Check the group by the subjectID
    if contains(subjectID, 'TT')
        group = 'TT';
    elseif contains(subjectID, 'NT')
        group = 'NT';
    else
        continue;  % Skip if the ID doesn't match expected groups
    end

    for hem = 1:length(hemispheres)
        
        % Construct filename
        filename = fullfile(e8folder, [hemispheres{hem}, '.sigch.avg.fsavg.smooth5.mgz']);
        
        % Load image
        img = MRIread(filename);

        % Take the mean across frames/timepoints
        mean_values = mean(img.vol, 4, 'omitnan');
        values = mean_values(:);

        % Store values based on hemisphere and group
        if strcmp(hemispheres{hem}, 'lh') && strcmp(group, 'TT')
            lh_TT = [lh_TT; values'];
        elseif strcmp(hemispheres{hem}, 'rh') && strcmp(group, 'TT')
            rh_TT = [rh_TT; values'];
        elseif strcmp(hemispheres{hem}, 'lh') && strcmp(group, 'NT')
            lh_NT = [lh_NT; values'];
        elseif strcmp(hemispheres{hem}, 'rh') && strcmp(group, 'NT')
            rh_NT = [rh_NT; values'];
        end
        
    end
end

%%
% Calculate tinnitus effect for each hemisphere
lh_tinEffect = mean(lh_TT, 1, 'omitnan') - mean(lh_NT, 1, 'omitnan');
rh_tinEffect = mean(rh_TT, 1, 'omitnan') - mean(rh_NT, 1, 'omitnan');

% Convert back to image format
lh_img = img;
lh_img.nframes=1;
rh_img = img;
rh_img.nframes=1;

lh_img.vol = lh_tinEffect;
rh_img.vol = rh_tinEffect;

% Write to output
MRIwrite(lh_img, fullfile(output_folder, 'tinEffect_lh.mgz'));
MRIwrite(rh_img, fullfile(output_folder, 'tinEffect_rh.mgz'));

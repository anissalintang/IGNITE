%% Calculate evoked response for condition effect (using e_16, regardless of tinnitus)

close all;
clear;
clc;

% Set up directories
parent_folder = '/Volumes/gdrive4tb/IGNITE/tonotopy/surface/projected/';
output_folder = '/Volumes/gdrive4tb/IGNITE/tonotopy/surface/analysis/stimEffect';

% Ensure the output folder exists
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

hemispheres = {'lh', 'rh'};

lh_rest = [];
rh_rest = [];
lh_vis = [];
rh_vis = [];

% Get list of subject directories
subjectDirs = dir([parent_folder, '*']);
subjectDirs = subjectDirs(~ismember({subjectDirs.name}, {'.', '..','.DS_Store'}));

for sub = 1:length(subjectDirs)
    
    subjectID = subjectDirs(sub).name;
    e16folder = fullfile(parent_folder, subjectID, 'e_16.fsf');
    
    for hem = 1:length(hemispheres)
        
        % Construct filename
        filename = fullfile(e16folder, [hemispheres{hem}, '.sigch.avg.fsavg.smooth5.mgz']);
        
        % Load image
        img = MRIread(filename);

        % Split into rest and vis frames and then take mean
        rest_values = mean(img.vol(:,:,:,1:8), 4, 'omitnan');
        vis_values = mean(img.vol(:,:,:,9:16), 4, 'omitnan');
        
        rest_values = rest_values(:);
        vis_values = vis_values(:);

        % Store values based on hemisphere
        if strcmp(hemispheres{hem}, 'lh')
            lh_rest = [lh_rest; rest_values'];
            lh_vis = [lh_vis; vis_values'];
        elseif strcmp(hemispheres{hem}, 'rh')
            rh_rest = [rh_rest; rest_values'];
            rh_vis = [rh_vis; vis_values'];
        end
        
    end
end

%%
% Calculate condition effect for each hemisphere
lh_stimEffect = mean(lh_vis, 1, 'omitnan') - mean(lh_rest, 1, 'omitnan');
rh_stimEffect = mean(rh_vis, 1, 'omitnan') - mean(rh_rest, 1, 'omitnan');

% Convert back to image format
lh_img = img;
lh_img.nframes=1;
rh_img = img;
rh_img.nframes=1;

lh_img.vol = lh_stimEffect;
rh_img.vol = rh_stimEffect;

% Write to output
MRIwrite(lh_img, fullfile(output_folder, 'stimEffect_lh.mgz'));
MRIwrite(rh_img, fullfile(output_folder, 'stimEffect_rh.mgz'));

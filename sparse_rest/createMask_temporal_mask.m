clc
clear

hemis = {'lh', 'rh'};

baseDir = '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/destrieux_fsavg/';

for h = 1:length(hemis)
    hemi = hemis{h};

    % Construct file paths based on hemisphere
    sensory_mask_path = fullfile(baseDir, ['sensory-motor_Yeo_' hemi '.mgh']);
    temporal_lobe_path = fullfile(baseDir, ['temporalLobe_mask_B12_' hemi '.mgh']);
    overlap_path = fullfile(baseDir, ['temporalLobe_mask_' hemi '.mgh']);

    % Load the mask images
    sensory_mask = MRIread(sensory_mask_path);
    temporal_lobe = MRIread(temporal_lobe_path);

    % Find the overlapping area
    overlap_data = sensory_mask.vol .* temporal_lobe.vol;

    % Save the overlapping area to a new image
    overlap_mask = sensory_mask; % Use the same header as the sensory mask
    overlap_mask.vol = overlap_data;
    MRIwrite(overlap_mask, overlap_path);
end

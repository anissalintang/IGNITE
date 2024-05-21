%% Calculate hearing effect (using e_8, regardless of tinnitus and conditions)

close all;
clear;
clc;

% Set up directories
parent_folder = '/Volumes/gdrive4tb/IGNITE/tonotopy/surface/projected/';
output_folder = '/Volumes/gdrive4tb/IGNITE/tonotopy/surface/analysis/hearingEffect';

% Ensure the output folder exists
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% Read the CSV file
csvData = readtable('/Volumes/gdrive4tb/IGNITE/data/ignite_main_data_ready.csv');

% Initialize storage arrays
lh_data = [];
rh_data = [];
hemispheres = {'lh', 'rh'};

% Get list of subject directories
subjectDirs = dir([parent_folder, '*']);
subjectDirs = subjectDirs(~ismember({subjectDirs.name}, {'.', '..','.DS_Store'}));

for sub = 1:length(subjectDirs)
    
    % Get subject ID from folder name
    subjId = subjectDirs(sub).name;
    
    % Find the row corresponding to the current subject
    subjIdx = find(strcmp(csvData.ID, subjId));
    
    % Get PTA data from CSV
    PTA_mean_R = csvData.PTA_mean_R(subjIdx);
    PTA_mean_L = csvData.PTA_mean_L(subjIdx);
    PTA_mean = (PTA_mean_R + PTA_mean_L) / 2;

    e8folder = fullfile(parent_folder, subjId, 'e_8.fsf');
    
    for hem = 1:length(hemispheres)
        % Construct filename
        filename = fullfile(e8folder, [hemispheres{hem}, '.sigch.avg.fsavg.smooth5.mgz']);
        
        % Read the file
        imgDataOri = MRIread(filename);
        imgData = mean(imgDataOri.vol, 4, 'omitnan');
        
        % Create subject data struct
        subjectData = struct();
        subjectData.Subject = subjId;
        subjectData.imgData = imgData(:)';
        subjectData.PTA_mean = PTA_mean;
        
        % Store subject data struct into the correct array
        if strcmp(hemispheres{hem}, 'lh')
            lh_data = [lh_data, subjectData];
        else
            rh_data = [rh_data, subjectData];
        end
    end
end

%%
% Split by PTA Percentiles
[lowerPercentile_lh, higherPercentile_lh] = splitByPTAPercentiles(lh_data);
[lowerPercentile_rh, higherPercentile_rh] = splitByPTAPercentiles(rh_data);

% Compute the differences between higher and lower percentiles for each hemisphere
diffPercentile_lh = mean(cat(1, higherPercentile_lh.imgData), 1) - mean(cat(1, lowerPercentile_lh.imgData), 1);
diffPercentile_rh = mean(cat(1, higherPercentile_rh.imgData), 1) - mean(cat(1, lowerPercentile_rh.imgData), 1);

% Convert back to image format
lh_percentile_img = imgDataOri;
rh_percentile_img = imgDataOri;

lh_percentile_img.vol = diffPercentile_lh;
rh_percentile_img.vol = diffPercentile_rh;

% Write to output
MRIwrite(lh_percentile_img, fullfile(output_folder, 'hearingEffectPercentile_lh.mgz'));
MRIwrite(rh_percentile_img, fullfile(output_folder, 'hearingEffectPercentile_rh.mgz'));


function [lower, higher] = splitByPTAPercentiles(subjects)
    motion = [subjects.PTA_mean];
    lower_quartile = quantile(motion, 0.25);
    upper_quartile = quantile(motion, 0.75);
    lower = subjects(motion <= lower_quartile);
    higher = subjects(motion >= upper_quartile);
end

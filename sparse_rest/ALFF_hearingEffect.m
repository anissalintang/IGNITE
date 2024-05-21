clc;
clear;
close all;

% Set directory and get list of subjects
dataDir = '/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ALFF';
subjects = dir(dataDir);
subjects = subjects(~ismember({subjects.name}, {'.', '..','merge_mean', ...
    'tinEffect','ageEffect','stimEffect','stimEffect_tin', '.DS_Store', 'meanValues', ...
    'hearingEffect','motionEffect'})); % Removed other unwanted directories

% Initialize arrays of structures
lh_data = [];
rh_data = [];

% Read the CSV file
csvData = readtable('/Volumes/gdrive4tb/IGNITE/data/ignite_main_data_ready.csv');

% Loop through subjects
for subj = 1:length(subjects)
    % Get subject ID from folder name
    subjId = subjects(subj).name;
    
    % Find the row corresponding to the current subject
    subjIdx = find(strcmp(csvData.ID, subjId));
    
    % Extract PTA values from the CSV data
    PTA_mean_R = csvData.PTA_mean_R(subjIdx);
    PTA_mean_L = csvData.PTA_mean_L(subjIdx);
    PTA_mean = (PTA_mean_R + PTA_mean_L) / 2;
    
    % Define file names for both hemispheres
    files = {
        fullfile(dataDir, subjId, [subjId '_lh_ALFF_vis_smooth5.mgz']),
        fullfile(dataDir, subjId, [subjId '_rh_ALFF_vis_smooth5.mgz']),
        fullfile(dataDir, subjId, [subjId '_lh_ALFF_rest_smooth5.mgz']),
        fullfile(dataDir, subjId, [subjId '_rh_ALFF_rest_smooth5.mgz'])
    };
    
    % Define corresponding hemispheres
    fileHemis = {'lh', 'rh', 'lh', 'rh'};
    
    % Loop through files for this subject
    for file = 1:4
        % Read the file
        imgDataOri = MRIread(files{file});
        imgData = imgDataOri.vol;
        
        % Create subject data struct
        subjectData = struct();
        subjectData.Subject = subjId;
        subjectData.imgData = imgData;
        subjectData.PTA_mean = PTA_mean; % Store the average PTA in the structure
        
        % Store subject data struct into the correct array based on hemisphere
        if strcmp(fileHemis{file}, 'lh')
            lh_data = [lh_data, subjectData];
        else
            rh_data = [rh_data, subjectData];
        end
    end
end

% Split subjects by PTA Percentiles for each hemisphere
[lowerPTA_lh, higherPTA_lh] = splitByPTAPercentiles(lh_data);
[lowerPTA_rh, higherPTA_rh] = splitByPTAPercentiles(rh_data);

% Compute the PTA effect for each hemisphere
PTAEffect_lh = mean(cat(1, higherPTA_lh.imgData), 1) - mean(cat(1, lowerPTA_lh.imgData), 1);
PTAEffect_rh = mean(cat(1, higherPTA_rh.imgData), 1) - mean(cat(1, lowerPTA_rh.imgData), 1);

% Save the PTA effect as images in .mgz
savePTAEffect(PTAEffect_lh, imgDataOri, '/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ALFF/hearingEffect/ALFF_lh_hearingEffect_pctl.mgz');
savePTAEffect(PTAEffect_rh, imgDataOri, '/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ALFF/hearingEffect/ALFF_rh_hearingEffect_pctl.mgz');

function [lowerPTA, higherPTA] = splitByPTAPercentiles(subjects)
    PTAs = [subjects.PTA_mean];
    lower_quartile = quantile(PTAs, 0.25);
    upper_quartile = quantile(PTAs, 0.75);
    lowerPTA = subjects(PTAs <= lower_quartile);
    higherPTA = subjects(PTAs >= upper_quartile);
end

function savePTAEffect(data, imgTemplate, outputPath)
    img = imgTemplate;
    img.vol = data;
    MRIwrite(img, outputPath);
end

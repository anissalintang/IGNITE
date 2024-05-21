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
    
    % Extract motion value from the CSV data
    motionAbsMean = csvData.MotionAbsMean_sparse_rest(subjIdx);
    
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
        subjectData.MotionAbsMean = motionAbsMean; % Store the motion value in the structure
        
        % Store subject data struct into the correct array based on hemisphere
        if strcmp(fileHemis{file}, 'lh')
            lh_data = [lh_data, subjectData];
        else
            rh_data = [rh_data, subjectData];
        end
    end
end

% Split subjects by Motion Percentiles for each hemisphere
[lowerMotion_lh, higherMotion_lh] = splitByMotionPercentiles(lh_data);
[lowerMotion_rh, higherMotion_rh] = splitByMotionPercentiles(rh_data);

% Compute the motion effect for each hemisphere
motionEffect_lh = mean(cat(1, higherMotion_lh.imgData), 1) - mean(cat(1, lowerMotion_lh.imgData), 1);
motionEffect_rh = mean(cat(1, higherMotion_rh.imgData), 1) - mean(cat(1, lowerMotion_rh.imgData), 1);

% Save the motion effect as images in .mgz
% saveMotionEffect(motionEffect_lh, imgDataOri, '/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ALFF/motionEffect/ALFF_lh_motionEffect_pctl.mgz');
% saveMotionEffect(motionEffect_rh, imgDataOri, '/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ALFF/motionEffect/ALFF_rh_motionEffect_pctl.mgz');

function [lowerMotion, higherMotion] = splitByMotionPercentiles(subjects)
    motions = [subjects.MotionAbsMean];
    lower_quartile = quantile(motions, 0.25);
    upper_quartile = quantile(motions, 0.75);
    lowerMotion = subjects(motions <= lower_quartile);
    higherMotion = subjects(motions >= upper_quartile);
end

function saveMotionEffect(data, imgTemplate, outputPath)
    img = imgTemplate;
    img.vol = data;
    MRIwrite(img, outputPath);
end

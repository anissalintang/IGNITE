clc;
clear;
close all;

% Set directory and get list of subjects
dataDir = '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR';
subjects = dir(dataDir);
subjects = subjects(~ismember({subjects.name}, {'.', '..', ...
    'hearingEffect', 'motionEffect', 'ageEffect','merge_mean','tinEffect', ...
    '.DS_Store','meanValues'}));

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
    
    % Get age and PTA from CSV data
    age = csvData.age(subjIdx);
    PTA_mean_R = csvData.PTA_mean_R(subjIdx);
    PTA_mean_L = csvData.PTA_mean_L(subjIdx);
    
    % Define file names
    files = {fullfile(dataDir, subjId, [subjId '_GCOR_wholeBrain_lh_smooth5.mgz']),...
        fullfile(dataDir, subjId, [subjId '_GCOR_wholeBrain_rh_smooth5.mgz'])};
    
    % Define corresponding hemispheres
    fileHemis = {'lh', 'rh'};
    
    % Loop through files for this subject
    for file = 1:2
        % Read the file
        imgDataOri = MRIread(files{file});
        imgData = imgDataOri.vol;
        
        % Create subject data struct
        subjectData = struct();
        subjectData.Subject = subjId;
        subjectData.imgData = imgData;
        subjectData.Age = age;
        subjectData.PTA_mean = (PTA_mean_R+PTA_mean_L)/2 ;

        
        % Store subject data struct into the correct array
        if strcmp(fileHemis{file}, 'lh')
            lh_data = [lh_data, subjectData];
        else
            rh_data = [rh_data, subjectData];
        end
    end
end

%%
% Extract age and hearing data for all subjects
ages = [lh_data.Age, rh_data.Age];
PTAs = [lh_data.PTA_mean, rh_data.PTA_mean];

% Scatter plot for Age vs PTA
figure;
scatter(ages, PTAs, 'filled');
xlabel('Age');
ylabel('PTA');
title('Age vs PTA');
grid on;

%%
% Split by PTA Percentiles
% Separate subjects by hemisphere and PTA percentiles
[lowerPercentile_lh, higherPercentile_lh] = splitByPTAPercentiles(lh_data);
[lowerPercentile_rh, higherPercentile_rh] = splitByPTAPercentiles(rh_data);

% Compute the differences between higher and lower percentiles for each hemisphere
diffPercentile_lh = mean(cat(1, higherPercentile_lh.imgData), 1) - mean(cat(1, lowerPercentile_lh.imgData), 1);
diffPercentile_rh = mean(cat(1, higherPercentile_rh.imgData), 1) - mean(cat(1, lowerPercentile_rh.imgData), 1);

% Save as images in .mgz
diffPercentile_lh_img = imgDataOri;
diffPercentile_rh_img = imgDataOri;

diffPercentile_lh_img.vol = diffPercentile_lh;
diffPercentile_rh_img.vol = diffPercentile_rh;

MRIwrite(diffPercentile_lh_img, '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR/hearingEffect/GCOR_lh_hearingEffect_percentiles.mgz');
MRIwrite(diffPercentile_rh_img, '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR/hearingEffect/GCOR_rh_hearingEffect_percentiles.mgz');

function [lower, higher] = splitByPTAPercentiles(subjects)
    motion = [subjects.PTA_mean];
    lower_quartile = quantile(motion, 0.25);
    upper_quartile = quantile(motion, 0.75);
    lower = subjects(motion <= lower_quartile);
    higher = subjects(motion >= upper_quartile);
end


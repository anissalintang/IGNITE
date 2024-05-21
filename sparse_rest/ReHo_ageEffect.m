clc;
clear;
close all;

% Set directory and get list of subjects
dataDir = '/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ReHo/temporal';
subjects = dir(dataDir);
subjects = subjects(~ismember({subjects.name}, {'.', '..','merge_mean', ...
    'tinEffect','ageEffect','stimEffect','stimEffect_tin', ...
    'hearingEffect','motionEffect','.DS_Store', 'meanValues'})); % Removed other unwanted directories

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
    age = csvData.age(subjIdx); % Extract age from the CSV data
    
    % Define file names for both hemispheres
    files = {
        fullfile(dataDir, subjId, [subjId '_ReHo_lh_temporal_vis_smooth5.mgz']),
        fullfile(dataDir, subjId, [subjId '_ReHo_rh_temporal_vis_smooth5.mgz']),
        fullfile(dataDir, subjId, [subjId '_ReHo_lh_temporal_rest_smooth5.mgz']),
        fullfile(dataDir, subjId, [subjId '_ReHo_rh_temporal_rest_smooth5.mgz'])
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
        subjectData.Age = age; % Store age in the structure
        
        % Store subject data struct into the correct array based on hemisphere
        if strcmp(fileHemis{file}, 'lh')
            lh_data = [lh_data, subjectData];
        else
            rh_data = [rh_data, subjectData];
        end
    end
end

% Split subjects by Age Percentiles for each hemisphere
[younger_lh, older_lh] = splitByAgePercentiles(lh_data);
[younger_rh, older_rh] = splitByAgePercentiles(rh_data);

% Compute the age effect for each hemisphere
ageEffect_lh = mean(cat(1, older_lh.imgData), 1,'omitnan') - mean(cat(1, younger_lh.imgData), 1,'omitnan');
ageEffect_rh = mean(cat(1, older_rh.imgData), 1,'omitnan') - mean(cat(1, younger_rh.imgData), 1,'omitnan');

% Save the age effect as images in .mgz
saveAgeEffect(ageEffect_lh, imgDataOri, '/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ReHo/temporal/ageEffect/ReHo_lh_ageEffect_pctl.mgz');
saveAgeEffect(ageEffect_rh, imgDataOri, '/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ReHo/temporal/ageEffect/ReHo_rh_ageEffect_pctl.mgz');

function [younger, older] = splitByAgePercentiles(subjects)
    ages = [subjects.Age];
    lower_quartile = quantile(ages, 0.25);
    upper_quartile = quantile(ages, 0.75);
    younger = subjects(ages <= lower_quartile);
    older = subjects(ages >= upper_quartile);
end

function saveAgeEffect(data, imgTemplate, outputPath)
    img = imgTemplate;
    img.vol = data;
    MRIwrite(img, outputPath);
end

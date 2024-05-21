clc;
clear;
close all;

% Set directory and get list of subjects
dataDir = '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR';
subjects = dir(dataDir);
subjects = subjects(~ismember({subjects.name}, {'.', '..', 'ageEffect','merge_mean','tinEffect','.DS_Store','meanValues'}));

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
    
    % Get age from CSV data
    age = csvData.age(subjIdx);
    
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
        
        % Store subject data struct into the correct array
        if strcmp(fileHemis{file}, 'lh')
            lh_data = [lh_data, subjectData];
        else
            rh_data = [rh_data, subjectData];
        end
    end
end

% Separate subjects by hemisphere and age
[younger_lh, older_lh] = splitByAge(lh_data);
[younger_rh, older_rh] = splitByAge(rh_data);

% Compute the differences between older and younger for each hemisphere
diff_lh = mean(cat(1, older_lh.imgData), 1,'omitnan') - mean(cat(1, younger_lh.imgData), 1,'omitnan');
diff_rh = mean(cat(1, older_rh.imgData), 1,'omitnan') - mean(cat(1, younger_rh.imgData), 1,'omitnan');

% Save as images in .mgz
diff_lh_img = imgDataOri;
diff_rh_img = imgDataOri;

diff_lh_img.vol = diff_lh;
diff_rh_img.vol = diff_rh;

MRIwrite(diff_lh_img, '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR/ageEffect/GCOR_lh_ageEffect.mgz');
MRIwrite(diff_rh_img, '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR/ageEffect/GCOR_rh_ageEffect.mgz');

% Split by Age Percentiles
% Separate subjects by hemisphere and age percentiles
[youngerPercentile_lh, olderPercentile_lh] = splitByAgePercentiles(lh_data);
[youngerPercentile_rh, olderPercentile_rh] = splitByAgePercentiles(rh_data);

% Compute the differences between older and younger percentiles for each hemisphere
diffPercentile_lh = mean(cat(1, olderPercentile_lh.imgData), 1,'omitnan') - mean(cat(1, youngerPercentile_lh.imgData), 1,'omitnan');
diffPercentile_rh = mean(cat(1, olderPercentile_rh.imgData), 1,'omitnan') - mean(cat(1, youngerPercentile_rh.imgData), 1,'omitnan');

% Save as images in .mgz
diffPercentile_lh_img = imgDataOri;
diffPercentile_rh_img = imgDataOri;

diffPercentile_lh_img.vol = diffPercentile_lh;
diffPercentile_rh_img.vol = diffPercentile_rh;

MRIwrite(diffPercentile_lh_img, '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR/ageEffect/GCOR_lh_ageEffect_percentiles.mgz');
MRIwrite(diffPercentile_rh_img, '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR/ageEffect/GCOR_rh_ageEffect_percentiles.mgz');

function [younger, older] = splitByAgePercentiles(subjects)
    ages = [subjects.Age];
    lower_quartile = quantile(ages, 0.25);
    upper_quartile = quantile(ages, 0.75);
    younger = subjects(ages <= lower_quartile);
    older = subjects(ages >= upper_quartile);
end

function [younger, older] = splitByAge(subjects)
    ages = [subjects.Age];
    median_age = median(ages);
    younger = subjects(ages <= median_age);
    older = subjects(ages > median_age);
end

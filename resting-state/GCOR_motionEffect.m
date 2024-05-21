clc;
clear;
close all;

% Set directory and get list of subjects
dataDir = '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR';
subjects = dir(dataDir);
subjects = subjects(~ismember({subjects.name}, {'.', '..', 'motionEffect', 'ageEffect','merge_mean','tinEffect','.DS_Store','meanValues'}));

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
    
    % Get age and motions from CSV data
    age = csvData.age(subjIdx);
    motionAbsMean = csvData.MotionAbsMean(subjIdx);
    motionRelMean = csvData.MotionRelMean(subjIdx);
    
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
        subjectData.MotionAbsMean = motionAbsMean;
        subjectData.MotionRelMean = motionRelMean;
        
        % Store subject data struct into the correct array
        if strcmp(fileHemis{file}, 'lh')
            lh_data = [lh_data, subjectData];
        else
            rh_data = [rh_data, subjectData];
        end
    end
end

%%
% Extract age and motion data for all subjects
ages = [lh_data.Age, rh_data.Age];
motionAbsMeans = [lh_data.MotionAbsMean, rh_data.MotionAbsMean];
motionRelMeans = [lh_data.MotionRelMean, rh_data.MotionRelMean];

% Scatter plot for Age vs MotionAbsMean
figure;
scatter(ages, motionAbsMeans, 'filled');
xlabel('Age');
ylabel('Motion Absolute Mean');
title('Age vs Motion Absolute Mean');
grid on;

% Scatter plot for Age vs MotionRelMean
figure;
scatter(ages, motionRelMeans, 'filled');
xlabel('Age');
ylabel('Motion Relative Mean');
title('Age vs Motion Relative Mean');
grid on;
%%
% Separate subjects by hemisphere and motion
[movLess_lh, movMore_lh] = splitByMotion(lh_data);
[movLess_rh, movMore_rh] = splitByMotion(rh_data);

% Compute the differences between movLess and movMore for each hemisphere
diff_lh = mean(cat(1, movMore_lh.imgData), 1,'omitnan') - mean(cat(1, movLess_lh.imgData), 1,'omitnan');
diff_rh = mean(cat(1, movMore_rh.imgData), 1,'omitnan') - mean(cat(1, movLess_rh.imgData), 1,'omitnan');

% Save as images in .mgz
diff_lh_img = imgDataOri;
diff_rh_img = imgDataOri;

diff_lh_img.vol = diff_lh;
diff_rh_img.vol = diff_rh;

MRIwrite(diff_lh_img, '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR/motionEffect/GCOR_lh_motionEffect.mgz');
MRIwrite(diff_rh_img, '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR/motionEffect/GCOR_rh_motionEffect.mgz');

% Split by Motion Percentiles
% Separate subjects by hemisphere and age percentiles
[movLessPercentile_lh, movMorePercentile_lh] = splitByMotionPercentiles(lh_data);
[movLessPercentile_rh, movMorePercentile_rh] = splitByMotionPercentiles(rh_data);

% Compute the differences between movMore and movLess percentiles for each hemisphere
diffPercentile_lh = mean(cat(1, movMorePercentile_lh.imgData), 1,'omitnan') - mean(cat(1, movLessPercentile_lh.imgData), 1,'omitnan');
diffPercentile_rh = mean(cat(1, movMorePercentile_rh.imgData), 1,'omitnan') - mean(cat(1, movLessPercentile_rh.imgData), 1,'omitnan');

% Save as images in .mgz
diffPercentile_lh_img = imgDataOri;
diffPercentile_rh_img = imgDataOri;

diffPercentile_lh_img.vol = diffPercentile_lh;
diffPercentile_rh_img.vol = diffPercentile_rh;

MRIwrite(diffPercentile_lh_img, '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR/motionEffect/GCOR_lh_motionEffect_percentiles.mgz');
MRIwrite(diffPercentile_rh_img, '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR/motionEffect/GCOR_rh_motionEffect_percentiles.mgz');

function [movLess, movMore] = splitByMotionPercentiles(subjects)
    motion = [subjects.MotionAbsMean];
    lower_quartile = quantile(motion, 0.25);
    upper_quartile = quantile(motion, 0.75);
    movLess = subjects(motion <= lower_quartile);
    movMore = subjects(motion >= upper_quartile);
end

function [movLess, movMore] = splitByMotion(subjects)
    motion = [subjects.MotionAbsMean];
    median_motion = median(motion);
    movLess = subjects(motion <= median_motion);
    movMore = subjects(motion > median_motion);
end

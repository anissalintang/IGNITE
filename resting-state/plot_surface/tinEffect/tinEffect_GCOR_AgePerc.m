clc;
clear;
close all;

% Set directory and get list of subjects
dataDir = '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR';
subjects = dir(dataDir);
subjects = subjects(~ismember({subjects.name}, {'.', '..', 'merge_mean','tinEffect','.DS_Store','meanValues'}));

% Initialize arrays of structures
lh_TT = [];
lh_NT = [];
rh_TT = [];
rh_NT = [];

% Read the CSV file
csvData = readtable('/Volumes/gdrive4tb/IGNITE/data/ignite_main_data_alff_reho_sparseRest.csv');

% Loop through subjects
for subj = 1:length(subjects)
    % Get subject ID from folder name
    subjId = subjects(subj).name;
    
    % Determine tinnitus status
    if contains(subjId, 'TT')
        currentStatus = 'yes';
    elseif contains(subjId, 'NT')
        currentStatus = 'no';
    else
        error('Subject ID does not contain TT or NT');
    end
    
    % Find the row corresponding to the current subject
    subjIdx = find(strcmp(csvData.ID, subjId));
    
    % Get age from CSV data
    age = csvData.age(subjIdx);
    
    % Define file names
    files = {fullfile(dataDir, subjId, [subjId '_GCOR_wholeBrain_lh_smooth5.mgz']),...
        fullfile(dataDir, subjId, [subjId '_GCOR_wholeBrain_rh_smooth5.mgz'])};
    
    % Define corresponding hemispheres and conditions
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
        subjectData.tinStatus = currentStatus;
        subjectData.Age = age;
        
        % Store subject data struct into the correct array
        if strcmp(fileHemis{file}, 'lh')
            if strcmp(currentStatus, 'yes')
                lh_TT = [lh_TT, subjectData];
            else
                lh_NT = [lh_NT, subjectData];
            end
        else
            if strcmp(currentStatus, 'yes')
                rh_TT = [rh_TT, subjectData];
            else
                rh_NT = [rh_NT, subjectData];
            end
        end
    end
end
%%
% Separate subjects by hemisphere
all_subjects_lh = [lh_TT, lh_NT];
all_subjects_rh = [rh_TT, rh_NT];

% Split by age
[younger_lh, older_lh] = splitByAge(all_subjects_lh);
[younger_rh, older_rh] = splitByAge(all_subjects_rh);

% Further split by hemisphere and tinnitus status
lh_TT_younger = filterSubjects(younger_lh, 'yes');
lh_NT_younger = filterSubjects(younger_lh, 'no');
rh_TT_younger = filterSubjects(younger_rh, 'yes');
rh_NT_younger = filterSubjects(younger_rh, 'no');

lh_TT_older = filterSubjects(older_lh, 'yes');
lh_NT_older = filterSubjects(older_lh, 'no');
rh_TT_older = filterSubjects(older_rh, 'yes');
rh_NT_older = filterSubjects(older_rh, 'no');

% Compute the differences between TT and NT for each age group and hemisphere
diff_younger_lh = mean(cat(1, lh_TT_younger.imgData), 1,'omitnan') - mean(cat(1, lh_NT_younger.imgData), 1,'omitnan');
diff_older_lh = mean(cat(1, lh_TT_older.imgData), 1,'omitnan') - mean(cat(1, lh_NT_older.imgData), 1,'omitnan');
diff_younger_rh = mean(cat(1, rh_TT_younger.imgData), 1,'omitnan') - mean(cat(1, rh_NT_younger.imgData), 1,'omitnan');
diff_older_rh = mean(cat(1, rh_TT_older.imgData), 1,'omitnan') - mean(cat(1, rh_NT_older.imgData), 1,'omitnan');

% .. and save as images in .mgz
diff_younger_lh_img=imgDataOri;
diff_older_lh_img=imgDataOri;
diff_younger_rh_img=imgDataOri;
diff_older_rh_img=imgDataOri;

diff_younger_lh_img.vol=diff_younger_lh;
diff_older_lh_img.vol=diff_older_lh;
diff_younger_rh_img.vol=diff_younger_rh;
diff_older_rh_img.vol=diff_older_rh;

MRIwrite(diff_younger_lh_img, '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR/tinEffect/smooth5/GCOR_lh_tinEffect_tin_noTin_smooth5_younger.mgz');
MRIwrite(diff_older_lh_img, '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR/tinEffect/smooth5/GCOR_lh_tinEffect_tin_noTin_smooth5_older.mgz');
MRIwrite(diff_younger_rh_img, '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR/tinEffect/smooth5/GCOR_rh_tinEffect_tin_noTin_smooth5_younger.mgz');
MRIwrite(diff_older_rh_img, '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR/tinEffect/smooth5/GCOR_rh_tinEffect_tin_noTin_smooth5_older.mgz');

%%
% Split by age
[younger_lh, older_lh] = splitByAgePctl(all_subjects_lh);
[younger_rh, older_rh] = splitByAgePctl(all_subjects_rh);

% Further split by hemisphere and tinnitus status
lh_TT_younger = filterSubjects(younger_lh, 'yes');
lh_NT_younger = filterSubjects(younger_lh, 'no');
rh_TT_younger = filterSubjects(younger_rh, 'yes');
rh_NT_younger = filterSubjects(younger_rh, 'no');

lh_TT_older = filterSubjects(older_lh, 'yes');
lh_NT_older = filterSubjects(older_lh, 'no');
rh_TT_older = filterSubjects(older_rh, 'yes');
rh_NT_older = filterSubjects(older_rh, 'no');

% Compute the differences between TT and NT for each age group and hemisphere
diff_younger_lh = mean(cat(1, lh_TT_younger.imgData), 1,'omitnan') - mean(cat(1, lh_NT_younger.imgData), 1,'omitnan');
diff_older_lh = mean(cat(1, lh_TT_older.imgData), 1,'omitnan') - mean(cat(1, lh_NT_older.imgData), 1,'omitnan');
diff_younger_rh = mean(cat(1, rh_TT_younger.imgData), 1,'omitnan') - mean(cat(1, rh_NT_younger.imgData), 1,'omitnan');
diff_older_rh = mean(cat(1, rh_TT_older.imgData), 1,'omitnan') - mean(cat(1, rh_NT_older.imgData), 1,'omitnan');

% .. and save as images in .mgz
diff_younger_lh_img=imgDataOri;
diff_older_lh_img=imgDataOri;
diff_younger_rh_img=imgDataOri;
diff_older_rh_img=imgDataOri;

diff_younger_lh_img.vol=diff_younger_lh;
diff_older_lh_img.vol=diff_older_lh;
diff_younger_rh_img.vol=diff_younger_rh;
diff_older_rh_img.vol=diff_older_rh;

MRIwrite(diff_younger_lh_img, '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR/tinEffect/smooth5/GCOR_lh_tinEffect_tin_noTin_smooth5_younger_25pctl.mgz');
MRIwrite(diff_older_lh_img, '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR/tinEffect/smooth5/GCOR_lh_tinEffect_tin_noTin_smooth5_older_75pctl.mgz');
MRIwrite(diff_younger_rh_img, '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR/tinEffect/smooth5/GCOR_rh_tinEffect_tin_noTin_smooth5_younger_25pctl.mgz');
MRIwrite(diff_older_rh_img, '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR/tinEffect/smooth5/GCOR_rh_tinEffect_tin_noTin_smooth5_older_75pctl.mgz');


function [younger, older] = splitByAge(subjects)
    % Assuming that 'Age' is a field in your struct
    ages = [subjects.Age];
    median_age = median(ages);
    younger = subjects(ages <= median_age);
    older = subjects(ages > median_age);
end

function [younger, older] = splitByAgePctl(subjects)
    % Assuming that 'Age' is a field in your struct
    ages = [subjects.Age];
    lower_quartile = quantile(ages, 0.25);
    upper_quartile = quantile(ages, 0.75);
    younger = subjects(ages <= lower_quartile);
    older = subjects(ages >= upper_quartile);
end


function filtered = filterSubjects(subjects, tinnitusStatus)
    is_match = strcmp({subjects.tinStatus}, tinnitusStatus);
    filtered = subjects(is_match);
end

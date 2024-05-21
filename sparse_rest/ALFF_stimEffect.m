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
lh_vis_data = [];
rh_vis_data = [];
lh_rest_data = [];
rh_rest_data = [];

% Loop through subjects
for subj = 1:length(subjects)
    % Get subject ID from folder name
    subjId = subjects(subj).name;
    
    % Define file names for both conditions and hemispheres
    files = {
        fullfile(dataDir, subjId, [subjId '_lh_ALFF_vis_smooth5.mgz']),
        fullfile(dataDir, subjId, [subjId '_rh_ALFF_vis_smooth5.mgz']),
        fullfile(dataDir, subjId, [subjId '_lh_ALFF_rest_smooth5.mgz']),
        fullfile(dataDir, subjId, [subjId '_rh_ALFF_rest_smooth5.mgz'])
    };
    
    % Define corresponding hemispheres and conditions
    fileConditions = {'lh_vis', 'rh_vis', 'lh_rest', 'rh_rest'};
    
    % Loop through files for this subject
    for file = 1:4
        % Read the file
        imgDataOri = MRIread(files{file});
        imgData = imgDataOri.vol;
        
        % Create subject data struct
        subjectData = struct();
        subjectData.Subject = subjId;
        subjectData.imgData = imgData;
        
        % Store subject data struct into the correct array based on condition and hemisphere
        switch fileConditions{file}
            case 'lh_vis'
                lh_vis_data = [lh_vis_data, subjectData];
            case 'rh_vis'
                rh_vis_data = [rh_vis_data, subjectData];
            case 'lh_rest'
                lh_rest_data = [lh_rest_data, subjectData];
            case 'rh_rest'
                rh_rest_data = [rh_rest_data, subjectData];
        end
    end
end

%%
% Compute the differences between 'vis' and 'rest' conditions for each hemisphere
diffCondition_lh = mean(cat(1, lh_vis_data.imgData), 1) - mean(cat(1, lh_rest_data.imgData), 1);
diffCondition_rh = mean(cat(1, rh_vis_data.imgData), 1) - mean(cat(1, rh_rest_data.imgData), 1);

% Save as images in .mgz
diffCondition_lh_img = imgDataOri;
diffCondition_rh_img = imgDataOri;

diffCondition_lh_img.vol = diffCondition_lh;
diffCondition_rh_img.vol = diffCondition_rh;

MRIwrite(diffCondition_lh_img, '/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ALFF/stimEffect/ALFF_lh_stimEffect_VS_NS.mgz');
MRIwrite(diffCondition_rh_img, '/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ALFF/stimEffect/ALFF_rh_stimEffect_VS_NS.mgz');



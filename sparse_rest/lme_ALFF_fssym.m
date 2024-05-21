%%
clc;
clear;
close all;

% Set directory and get list of subjects
dataDir = '/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ALFF_fssym';
subjects = dir(dataDir);
subjects = subjects(~ismember({subjects.name}, {'.', '..', 'merge_mean','stat'}));

% Initialize variables
allData = []; % will hold all the data from all subjects
subjIds = []; % will hold the subject IDs
hemis = []; % will hold hemisphere data
conds = []; % will hold condition data

% Load mask
maskFile = '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/colin27_fsavg/HO_HG_lh_mask_fsavg.mgz';
maskStruct = MRIread(maskFile);
mask = logical(maskStruct.vol');

% Loop through subjects
for subj = 1:length(subjects)
    % Get subject ID from folder name
    subjId = subjects(subj).name;
    
    % Define file names
    files = {fullfile(dataDir, subjId, [subjId '_lh_ALFF_rest_smooth5.mgz']),...
        fullfile(dataDir, subjId, [subjId '_lh_ALFF_vis_smooth5.mgz']),...
        fullfile(dataDir, subjId, [subjId '_rh_ALFF_rest_smooth5.mgz']),...
        fullfile(dataDir, subjId, [subjId '_rh_ALFF_vis_smooth5.mgz'])};
    
    % Define corresponding hemispheres and conditions
    fileHemis = {'lh', 'lh', 'rh', 'rh'};
    fileConds = {'Rest', 'Vis', 'Rest', 'Vis'};
    
    % Loop through files for this subject
    for file = 1:4
        % Read the file
        imgData = MRIread(files{file});
        imgDataMasked = imgData.vol(mask);
        
        % Store the data, subject ID, hemisphere, and condition
        allData = [allData; imgDataMasked']; % transpose the vector so that it is a column
        subjIds = [subjIds; repmat(subjId, numel(imgDataMasked), 1)];
        hemis = [hemis; repmat(fileHemis(file), numel(imgDataMasked), 1)];
        conds = [conds; repmat(fileConds(file), numel(imgDataMasked), 1)];
    end
end

% Create data table
dataTable = table(allData, subjIds, hemis, conds, 'VariableNames', {'Response', 'SubjectID', 'Hemisphere', 'Condition'});

disp(dataTable(1:4,1:4));

% Preallocate variables for p-values, t-values, and models
pValues = zeros(sum(mask(:)), 4);
tValues = zeros(sum(mask(:)), 4);
lmeModels = cell(sum(mask(:)), 1);

% Loop over vertices
for vertex = 1:sum(mask(:))
    % Run LME model for the current vertex
    lme = fitlme(dataTable(vertex:sum(mask(:)):end, :), 'Response ~ 1 + Hemisphere*Condition + (1|SubjectID)');
    
    % Store the model
    lmeModels{vertex} = lme;
    
    % Get and store p-values and t-values
    pValues(vertex, :) = lme.Coefficients.pValue(1:end);
    tValues(vertex, :) = lme.Coefficients.tStat(1:end);
end

% FDR correction
pFDR = mafdr(pValues(:), 'BHFDR', true);
pFDR = reshape(pFDR, size(pValues)); % reshape to the original shape

% Find significant results
alpha = 0.05; % significance level
sigIdx = pFDR <= alpha; % find significant results

% Adjust sigIdx to be true for any vertex that has a significant interaction effect
sigIdx = sigIdx(:,4);

% Initialize an output volume with all values set to -999
tValueVol = -999 * ones(size(imgData.vol));

% Find the indices of the mask
maskIdx = find(mask);

% Assign significant t-values to corresponding vertices in the mask
tValueVol(maskIdx(sigIdx)) = tValues(sigIdx);

% Save the significant t-values as an image
% The output will have the same dimensions as the original images
outputImg = imgData; % use the last read image as a template
outputImg.vol = tValueVol; % assign the t-values as the image values

mkdir(fullfile('/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ALFF_fssym'), 'stat');
MRIwrite(outputImg, '/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ALFF_fssym/stat/ALFF_intHemixCond_sigTval_map.mgz'); % save the image

% Display the results
sigPValues = pFDR(sigIdx); % get significant p-values
sigTValues = tValues(sigIdx); % get corresponding t-values
disp('Significant p-values after FDR correction:');
disp(sigPValues);
disp('Corresponding t-values:');
disp(sigTValues);

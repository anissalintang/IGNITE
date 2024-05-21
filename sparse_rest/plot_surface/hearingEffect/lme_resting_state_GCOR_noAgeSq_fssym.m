clc;
clear;
close all;

% Set directory and get list of subjects
dataDir = '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR_fssym';
subjects = dir(dataDir);
subjects = subjects(~ismember({subjects.name}, {'.', '..', 'merge_mean','stat','.DS_Store'}));

% Initialize variables
allData = [];
subjIds = [];
hemis = [];
vertexIDs = [];
tinStatus = [];
motionAbsData = []; % Initialize this variable
motionRelData = []; % Initialize this variable

% Read motion data
motionAbs = readtable('/Volumes/gdrive4tb/IGNITE/resting-state/IGNITE_resting-state_motionOrig_abs.txt');
motionRel = readtable('/Volumes/gdrive4tb/IGNITE/resting-state/IGNITE_resting-state_motionOrig_rel.txt');

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
    
    % Define file names
    files = {fullfile(dataDir, subjId, [subjId '_GCOR_wholeBrain_lh_smooth5.mgz']),...
        fullfile(dataDir, subjId, [subjId '_GCOR_wholeBrain_lh_smooth5.mgz'])};
    
    % Define corresponding hemispheres and conditions
    fileHemis = {'lh', 'rh'};

    % Get motion data for current subject
    motionAbsValue = motionAbs.MotionAbsMean(strcmp(motionAbs.SubjectID, subjId));
    motionRelValue = motionRel.MotionRelMean(strcmp(motionRel.SubjectID, subjId));
    
    % Loop through files for this subject
    for file = 1:2
        % Read the file
        imgData = MRIread(files{file});
        imgData = imgData.vol;
        
        % Store the data, subject ID, hemisphere, condition, vertexID, and tinnitus status
        allData = [allData; imgData']; % transpose the vector so that it is a column
        subjIds = [subjIds; repmat({subjId}, numel(imgData), 1)];
        hemis = [hemis; repmat({fileHemis{file}}, numel(imgData), 1)];
        vertexIDs = [vertexIDs; (1:numel(imgData))'];
        tinStatus = [tinStatus; repmat({currentStatus}, numel(imgData), 1)];
        motionAbsData = [motionAbsData; repmat(motionAbsValue, numel(imgData), 1)];
        motionRelData = [motionRelData; repmat(motionRelValue, numel(imgData), 1)];
    end
end

% Create data table
dataTable = table(allData, subjIds, hemis, vertexIDs, tinStatus, motionAbsData, motionRelData, 'VariableNames', {'Response', 'SubjectID', 'Hemisphere', 'VertexID', 'TinnitusStatus', 'MotionAbsMean', 'MotionRelMean'});

varTypes = varfun(@class, dataTable, 'OutputFormat', 'table')



%% Add demographic data
% Read the CSV file
csvData = readtable('/Volumes/gdrive4tb/IGNITE/data/ignite_main_data_alff_gcor_xtract.csv');

% Make sure 'SubjectID' is a cell array
dataTable.SubjectID = cellstr(dataTable.SubjectID);

% Get index of matching rows and indices for sorting 'dataTable' to match 'csvData'
[matching, idx] = ismember(dataTable.SubjectID, csvData.ID);

% Create Sex, Age, PTA_mean, and AgeSq columns with NaN or empty cell array
dataTable.Sex = cell(height(dataTable), 1);
dataTable.Age = nan(height(dataTable), 1);
dataTable.PTA_mean = nan(height(dataTable), 1);

% Assign values from csvData to dataTable at matching indices
dataTable.Sex(matching) = csvData.sex(idx(matching));
dataTable.Age(matching) = csvData.age(idx(matching));
dataTable.PTA_mean(matching) = mean([csvData.PTA_mean_L(idx(matching)), csvData.PTA_mean_R(idx(matching))], 2);

% Convert data back to categorical
dataTable.Sex = categorical(dataTable.Sex);

%%

dataTable.Hemisphere = categorical(cellstr(dataTable.Hemisphere));
dataTable.SubjectID = categorical(cellstr(dataTable.SubjectID));
dataTable.TinnitusStatus = categorical(cellstr(dataTable.TinnitusStatus));

varTypes = varfun(@class, dataTable, 'OutputFormat', 'table')

%% Check how long does it take to run fitlme for 1 vertex

% Get the unique VertexIDs
uniqueVertices = unique(dataTable.VertexID);

% Get the current VertexID
currentVertex = uniqueVertices(1);

% Select the data for the current VertexID
vertexData = dataTable(dataTable.VertexID == currentVertex, :);

% Define the formula for the LME model
lmeFormula = 'Response ~ 1 + Sex + Age + PTA_mean + Hemisphere + TinnitusStatus + MotionAbsMean + MotionRelMean + (1|SubjectID)';

% Start the timer
tic

% Fit the LME model to the data
lmeModel = fitlme(vertexData, lmeFormula);

% Stop the timer and display the elapsed time
elapsedTime = toc;
disp(['Elapsed time is ' num2str(elapsedTime) ' seconds'])
apprTime = elapsedTime * 163842;
apprHour = apprTime / 3600;
disp(['Approximate time to run for whole-brain is ' num2str(apprHour) ' hours'])

%%
% Convert categorical variables to dummy variables
Sex_dummy = double(dataTable.Sex == 'Male'); % Assuming 'Male' and 'Female' as categories, this will give 1 for Male and 0 for Female.
Hemisphere_dummy = double(dataTable.Hemisphere == 'Right'); % Assuming 'Left' and 'Right' as categories.
TinnitusStatus_dummy = double(dataTable.TinnitusStatus == 'Yes'); % Adjust based on the actual categories in your data.

% Construct matrix of predictors
predictorsData = [dataTable.Age, dataTable.PTA_mean, Sex_dummy, Hemisphere_dummy, TinnitusStatus_dummy];

% Now, you can compute and visualize the correlation matrix
corrMatrix = corr(predictorsData); % Kendall method is more robust

disp(corrMatrix);

% Using imagesc to plot heatmap as an alternative to corrplot
figure;
imagesc(corrMatrix);
colorbar;
title('Correlation Matrix Heatmap');
xlabel('Predictors');
ylabel('Predictors');
ax = gca;
ax.XTick = 1:6;
ax.YTick = 1:6;
ax.XTickLabel = {'Age', 'PTA_mean', 'Sex', 'Hemisphere', 'TinnitusStatus'};
ax.YTickLabel = {'Age', 'PTA_mean', 'Sex', 'Hemisphere', 'TinnitusStatus'};


%% Fitlme with parallel --only save the coefficients and p values to save memory

sum(isnan(dataTable.Response))  % Check for NaN values in the response
dataTable.Response(isnan(dataTable.Response)) = 0;

% Start a parallel pool with 6 workers
if isempty(gcp('nocreate'))
    parpool(6);
end

% Initialize parfor_progress. This will create a file to track progress.
parfor_progress(length(uniqueVertices));

% Initialize matrices to hold the coefficients and p-values
numCoefficients = size(fitlme(dataTable(dataTable.VertexID == uniqueVertices(1), :), 'Response ~ 1 + Sex + Age + PTA_mean + Hemisphere + TinnitusStatus + MotionAbsMean + MotionRelMean + Hemisphere:TinnitusStatus + Hemisphere:PTA_mean + (1|SubjectID)').Coefficients, 1);
coefficients = NaN(length(uniqueVertices), numCoefficients);
pValues = NaN(length(uniqueVertices), numCoefficients);

% Use parfor to loop over vertices
parfor i = 1:length(uniqueVertices)
    % Get the current VertexID
    currentVertex = uniqueVertices(i);
    
    % Select the data for the current VertexID
    vertexData = dataTable(dataTable.VertexID == currentVertex, :);

    % Check if all the responses for this vertex are zero
    if all(vertexData.Response == 0)
        coefficients(i, :) = NaN;
        pValues(i, :) = NaN;
        continue;
    end
    
    % Define the formula for the LME model
    lmeFormula = 'Response ~ 1 + Sex + Age + PTA_mean + Hemisphere + TinnitusStatus + MotionAbsMean + MotionRelMean + Hemisphere:TinnitusStatus + Hemisphere:PTA_mean + (1|SubjectID)';
    
    % Fit the LME model to the data
    lmeModel = fitlme(vertexData, lmeFormula);
    
    % Store only the coefficients and p-values
    coefficients(i, :) = lmeModel.Coefficients.Estimate;
    pValues(i, :) = lmeModel.Coefficients.pValue;

    % After finishing the calculations for each vertex, update the progress.
    parfor_progress;
end

% Clean up the progress monitor file.files
parfor_progress(0);

%% Save all analysis to mat files
% Define the filename for the .mat file
filename = '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR_fssym/stat/with_motionParam/GCOR_lme_noAgeSq.mat';

% Save all variables in the workspace to the .mat file
save(filename);
%% P values uncorrected
 lmeFormula = 'Response ~ 1 + Sex + Age + PTA_mean + Hemisphere + TinnitusStatus + MotionAbsMean + MotionRelMean + Hemisphere:TinnitusStatus + Hemisphere:PTA_mean + (1|SubjectID)';

% Set alpha values to the specified range
alpha_range = [0.01, 0.05, 0.1, 0.25 0.5];

% Get names of predictors from a model for reference
modelForNames = fitlme(dataTable(dataTable.VertexID == uniqueVertices(1), :), lmeFormula);
predictorNames = modelForNames.Coefficients.Name;

% Loop over each alpha value
for alpha = alpha_range
    fprintf('\nResults for alpha = %.2f\n', alpha);
    
    % Identify columns (predictors) in the matrix where all p-values are > alpha
    nonSignificantPredictors = all(pValues > alpha, 1);

    % Print names of non-significant predictors ACROSS ALL VERTICES
    nonSignificantPredictorNames = predictorNames(nonSignificantPredictors);
    disp('Predictors that are not significant across any vertices before FDR correction:');
    disp(nonSignificantPredictorNames);

    %% Get the numbers of significant vertices for each predictor --pre FDR
    % Create a matrix to hold binary values indicating significance for each vertex-predictor pair
    significantMatrix = pValues < alpha;

    % Display the number of vertices where each predictor is significant
    numSignificantVertices = sum(significantMatrix);
    disp('Number of vertices where each predictor is significant before FDR:');
    disp(table(predictorNames, numSignificantVertices(:), 'VariableNames', {'Predictor', 'Number_of_Significant_Vertices'}));
end

%% Do FDR correction -P values corrected
% Flatten the pValues matrix into a vector for FDR correction
pValuesVector = pValues(:);

% Apply FDR correction
fdrCorrectedPValuesVector = mafdr(pValuesVector, 'BHFDR', true);

% Reshape the corrected p-values back into the original matrix form
fdrCorrectedPValues = reshape(fdrCorrectedPValuesVector, size(pValues));

% Set alpha values to the specified range
alpha_range = [0.01, 0.05, 0.1, 0.25 0.5];

% Get names of predictors from a model for reference
modelForNames = fitlme(dataTable(dataTable.VertexID == uniqueVertices(1), :), lmeFormula);
predictorNames = modelForNames.Coefficients.Name;

% Loop over each alpha value
for alpha = alpha_range
    fprintf('\nResults for alpha = %.2f\n', alpha);
    
    % Identify columns (predictors) in the matrix where all p-values are > alpha
    nonSignificantPredictors = all(fdrCorrectedPValues > alpha, 1);

    % Print names of non-significant predictors ACROSS ALL VERTICES
    nonSignificantPredictorNames = predictorNames(nonSignificantPredictors);
    disp('Predictors that are not significant across any vertices after FDR correction:');
    disp(nonSignificantPredictorNames);

    %% Get the numbers of significant vertices for each predictor --post FDR
    % Create a matrix to hold binary values indicating significance for each vertex-predictor pair
    significantMatrix = fdrCorrectedPValues < alpha;

    % Display the number of vertices where each predictor is significant
    numSignificantVertices = sum(significantMatrix);
    disp('Number of vertices where each predictor is significant post FDR:');
    disp(table(predictorNames, numSignificantVertices(:), 'VariableNames', {'Predictor', 'Number_of_Significant_Vertices'}));
end

%% Save t-maps --tinnitusStatus
% Alpha thresholds to consider
alphas = [0.01, 0.05, 0.1, 0.25 0.5];

% Find the column corresponding to TinnitusStatus_yes
tinnitusStatusColumn = find(strcmp(predictorNames, 'TinnitusStatus_yes'));

% Loop over each alpha threshold
for idx = 1:length(alphas)
    alpha = alphas(idx);
    
    % Uncorrected
    significantVerticesUncorrected = pValues(:, tinnitusStatusColumn) < alpha;
    tinnitusTValuesSignificantUncorrected = coefficients(significantVerticesUncorrected, tinnitusStatusColumn);

    imgDataUncorrected = MRIread(files{file});
    imgDataUncorrected.vol(:) = 0;
    imgDataUncorrected.vol(significantVerticesUncorrected) = tinnitusTValuesSignificantUncorrected;
    MRIwrite(imgDataUncorrected, sprintf('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR_fssym/stat/with_motionParam/noAgeSq/GCOR_tmap_tinStat_noAgeSq_uncorrected_%g.mgz', alpha));
    
    % Corrected
    significantVerticesCorrected = fdrCorrectedPValues(:, tinnitusStatusColumn) < alpha;
    tinnitusTValuesSignificantCorrected = coefficients(significantVerticesCorrected, tinnitusStatusColumn);

    imgDataCorrected = MRIread(files{file});
    imgDataCorrected.vol(:) = 0;
    imgDataCorrected.vol(significantVerticesCorrected) = tinnitusTValuesSignificantCorrected;
    MRIwrite(imgDataCorrected, sprintf('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR_fssym/stat/with_motionParam/noAgeSq/GCOR_tmap_tinStat_noAgeSq_corrected_%g.mgz', alpha));
end

%% Save t-maps --PTA_mean
% Alpha thresholds to consider
alphas = [0.01, 0.05, 0.1, 0.25 0.5];

% Find the column corresponding to PTA_mean
PTA_meanColumn = find(strcmp(predictorNames, 'PTA_mean'));

% Loop over each alpha threshold
for idx = 1:length(alphas)
    alpha = alphas(idx);
    
    % Uncorrected
    significantVerticesUncorrected = pValues(:, PTA_meanColumn) < alpha;
    PTA_meanTValuesSignificantUncorrected = coefficients(significantVerticesUncorrected, PTA_meanColumn);

    imgDataUncorrected = MRIread(files{file});
    imgDataUncorrected.vol(:) = 0;
    imgDataUncorrected.vol(significantVerticesUncorrected) = PTA_meanTValuesSignificantUncorrected;
    MRIwrite(imgDataUncorrected, sprintf('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR_fssym/stat/with_motionParam/noAgeSq/GCOR_tmap_PTA_mean_noAgeSq_uncorrected_%g.mgz', alpha));
    
    % Corrected
    significantVerticesCorrected = fdrCorrectedPValues(:, PTA_meanColumn) < alpha;
    PTA_meanTValuesSignificantCorrected = coefficients(significantVerticesCorrected, PTA_meanColumn);

    imgDataCorrected = MRIread(files{file});
    imgDataCorrected.vol(:) = 0;
    imgDataCorrected.vol(significantVerticesCorrected) = PTA_meanTValuesSignificantCorrected;
    MRIwrite(imgDataCorrected, sprintf('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR_fssym/stat/with_motionParam/noAgeSq/GCOR_tmap_PTA_mean_noAgeSq_corrected_%g.mgz', alpha));
end


%% Save t-maps --Age
% Alpha thresholds to consider
alphas = [0.01, 0.05, 0.1, 0.25 0.5];

% Find the column corresponding to PTA_mean
AgeColumn = find(strcmp(predictorNames, 'Age'));

% Loop over each alpha threshold
for idx = 1:length(alphas)
    alpha = alphas(idx);
    
    % Uncorrected
    significantVerticesUncorrected = pValues(:, AgeColumn) < alpha;
    AgeTValuesSignificantUncorrected = coefficients(significantVerticesUncorrected, AgeColumn);

    imgDataUncorrected = MRIread(files{file});
    imgDataUncorrected.vol(:) = 0;
    imgDataUncorrected.vol(significantVerticesUncorrected) = AgeTValuesSignificantUncorrected;
    MRIwrite(imgDataUncorrected, sprintf('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR_fssym/stat/with_motionParam/noAgeSq/GCOR_tmap_Age_noAgeSq_uncorrected_%g.mgz', alpha));
    
    % Corrected
    significantVerticesCorrected = fdrCorrectedPValues(:, AgeColumn) < alpha;
    AgeTValuesSignificantCorrected = coefficients(significantVerticesCorrected, AgeColumn);

    imgDataCorrected = MRIread(files{file});
    imgDataCorrected.vol(:) = 0;
    imgDataCorrected.vol(significantVerticesCorrected) = AgeTValuesSignificantCorrected;
    MRIwrite(imgDataCorrected, sprintf('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR_fssym/stat/with_motionParam/noAgeSq/GCOR_tmap_Age_noAgeSq_corrected_%g.mgz', alpha));
end

%% Save t-maps --MotionAbsMean
% Alpha thresholds to consider
alphas = [0.01, 0.05, 0.1, 0.25 0.5];

% Find the column corresponding to PTA_mean
MotionAbsMeanColumn = find(strcmp(predictorNames, 'MotionAbsMean'));

% Loop over each alpha threshold
for idx = 1:length(alphas)
    alpha = alphas(idx);
    
    % Uncorrected
    significantVerticesUncorrected = pValues(:, MotionAbsMeanColumn) < alpha;
    MotionAbsMeanTValuesSignificantUncorrected = coefficients(significantVerticesUncorrected, MotionAbsMeanColumn);

    imgDataUncorrected = MRIread(files{file});
    imgDataUncorrected.vol(:) = 0;
    imgDataUncorrected.vol(significantVerticesUncorrected) = MotionAbsMeanTValuesSignificantUncorrected;
    MRIwrite(imgDataUncorrected, sprintf('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR_fssym/stat/with_motionParam/noAgeSq/GCOR_tmap_MotionAbsMean_noAgeSq_uncorrected_%g.mgz', alpha));
    
    % Corrected
    significantVerticesCorrected = fdrCorrectedPValues(:, MotionAbsMeanColumn) < alpha;
    MotionAbsMeanTValuesSignificantCorrected = coefficients(significantVerticesCorrected, MotionAbsMeanColumn);

    imgDataCorrected = MRIread(files{file});
    imgDataCorrected.vol(:) = 0;
    imgDataCorrected.vol(significantVerticesCorrected) = MotionAbsMeanTValuesSignificantCorrected;
    MRIwrite(imgDataCorrected, sprintf('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR_fssym/stat/with_motionParam/noAgeSq/GCOR_tmap_MotionAbsMean_noAgeSq_corrected_%g.mgz', alpha));
end

%% Save t-maps --MotionRelMean
% Alpha thresholds to consider
alphas = [0.01, 0.05, 0.1, 0.25 0.5];

% Find the column corresponding to PTA_mean
MotionRelMeanColumn = find(strcmp(predictorNames, 'MotionRelMean'));

% Loop over each alpha threshold
for idx = 1:length(alphas)
    alpha = alphas(idx);
    
    % Uncorrected
    significantVerticesUncorrected = pValues(:, MotionRelMeanColumn) < alpha;
    MotionRelMeanTValuesSignificantUncorrected = coefficients(significantVerticesUncorrected, MotionRelMeanColumn);

    imgDataUncorrected = MRIread(files{file});
    imgDataUncorrected.vol(:) = 0;
    imgDataUncorrected.vol(significantVerticesUncorrected) = MotionRelMeanTValuesSignificantUncorrected;
    MRIwrite(imgDataUncorrected, sprintf('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR_fssym/stat/with_motionParam/noAgeSq/GCOR_tmap_MotionRelMean_noAgeSq_uncorrected_%g.mgz', alpha));
    
    % Corrected
    significantVerticesCorrected = fdrCorrectedPValues(:, MotionRelMeanColumn) < alpha;
    MotionRelMeanTValuesSignificantCorrected = coefficients(significantVerticesCorrected, MotionRelMeanColumn);

    imgDataCorrected = MRIread(files{file});
    imgDataCorrected.vol(:) = 0;
    imgDataCorrected.vol(significantVerticesCorrected) = MotionRelMeanTValuesSignificantCorrected;
    MRIwrite(imgDataCorrected, sprintf('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR_fssym/stat/with_motionParam/noAgeSq/GCOR_tmap_MotionRelMean_noAgeSq_corrected_%g.mgz', alpha));
end



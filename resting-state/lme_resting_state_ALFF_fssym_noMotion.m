clc;
clear;
close all;

% Set directory and get list of subjects
dataDir = '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF_fssym';
subjects = dir(dataDir);
subjects = subjects(~ismember({subjects.name}, {'.', '..', 'merge_mean','stat','.DS_Store'}));

% Initialize variables
allData = [];
subjIds = [];
hemis = [];
vertexIDs = [];
tinStatus = [];

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
    files = {fullfile(dataDir, subjId, [subjId '_lh_fsavg_ALFF_smooth5.mgz']),...
        fullfile(dataDir, subjId, [subjId '_rh_fsavg_ALFF_smooth5.mgz'])};
    
    % Define corresponding hemispheres and conditions
    fileHemis = {'lh', 'rh'};

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
    end
end

% Create data table
dataTable = table(allData, subjIds, hemis, vertexIDs, tinStatus, 'VariableNames', {'Response', 'SubjectID', 'Hemisphere', 'VertexID', 'TinnitusStatus'});

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
dataTable.AgeSq = nan(height(dataTable), 1);

% Assign values from csvData to dataTable at matching indices
dataTable.Sex(matching) = csvData.sex(idx(matching));
dataTable.Age(matching) = csvData.age(idx(matching));
dataTable.PTA_mean(matching) = mean([csvData.PTA_mean_L(idx(matching)), csvData.PTA_mean_R(idx(matching))], 2);

% Calculate AgeSq and orthogonalize it against Age
dataTable.AgeSq(matching) = dataTable.Age(matching).^2 - dot(dataTable.Age(matching).^2, dataTable.Age(matching))/dot(dataTable.Age(matching), dataTable.Age(matching)) * dataTable.Age(matching);
% The orthogonalization is done by subtracting the projection of AgeSq onto Age from AgeSq.

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
lmeFormula = 'Response ~ 1 + Sex + Age + PTA_mean + AgeSq + Hemisphere + TinnitusStatus + (1|SubjectID)';

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

%% Is using cellfun speed up the whole fitting process? --Nope, 6 hours compared to 1hour
% numVertices = 1;
% dataPerVertex = cell(numVertices, 1);
% 
% % Start the timer
% tic
% 
% % Separate data for each vertex
% for i = 1:numVertices
%     currentVertex = uniqueVertices(i);
%     dataPerVertex{i} = dataTable(dataTable.VertexID == currentVertex, :);
% end
% 
% [coefficients pValues] = cellfun(@fitLMEForVertex, dataPerVertex, 'UniformOutput', false);
% 
% coefficients = cell2mat(coefficients);
% pValues = cell2mat(pValues);
% 
% % Stop the timer and display the elapsed time
% elapsedTime = toc;
% disp(['Elapsed time is ' num2str(elapsedTime) ' seconds'])
% apprTime = elapsedTime * 163842;
% apprHour = apprTime / 3600;
% disp(['Approximate time to run for whole-brain is ' num2str(apprHour) ' hours'])

%% Fitlme without parallel and saving all models -- this takes up lots of memory and matlab not happy about it
% 
% % Initialize a cell array to hold the fitted models
% lmeModels = cell(length(uniqueVertices), 1);
% 
% % Loop through each unique VertexID
% for i = 1:length(uniqueVertices)
%     % Get the current VertexID
%     currentVertex = uniqueVertices(i);
%     
%     % Select the data for the current VertexID
%     vertexData = dataTable(dataTable.VertexID == currentVertex, :);
% 
%     % Check if all the responses for this vertex are zero
%     if all(vertexData.Response == 0)
%         % If all responses are zero, assign 0 to the corresponding cell in
%         % lmeModels and continue with the next iteration
%         lmeModels{i} = 0;
%         continue
%     end
%     
%     % Define the formula for the LME model
%     lmeFormula = 'Response ~ 1 + Hemisphere + TinnitusStatus + (1|SubjectID)';
%     
%     % Fit the LME model to the data
%     lmeModels{i} = fitlme(vertexData, lmeFormula);
% end


%% Fitlme with parallel --only save the coefficients and p values to save memory
% Start a parallel pool with 6 workers
if isempty(gcp('nocreate'))
    parpool(6);
end

% Initialize parfor_progress. This will create a file to track progress.
parfor_progress(length(uniqueVertices));

% Initialize matrices to hold the coefficients and p-values
numCoefficients = size(fitlme(dataTable(dataTable.VertexID == uniqueVertices(1), :), 'Response ~ 1 + Sex + Age + PTA_mean + AgeSq + Hemisphere + TinnitusStatus + Hemisphere:TinnitusStatus + Hemisphere:PTA_mean + (1|SubjectID)').Coefficients, 1);
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
    lmeFormula = 'Response ~ 1 + Sex + Age + PTA_mean + AgeSq + Hemisphere + TinnitusStatus + Hemisphere:TinnitusStatus + Hemisphere:PTA_mean + (1|SubjectID)';
    
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
filename = '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF_fssym/stat/ALFF_lme_noMotion.mat';

% Save all variables in the workspace to the .mat file
save(filename);

%% P values uncorrected
% Set alpha values to the specified range
alpha_range = [0.01, 0.05, 0.1, 0.25 0.5];

lmeFormula = 'Response ~ 1 + Sex + Age + PTA_mean + AgeSq + Hemisphere + TinnitusStatus + Hemisphere:TinnitusStatus + Hemisphere:PTA_mean + (1|SubjectID)';

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

% To see the significant predictors for a specific vertex (let's say Vertex 10 as an example):
% vertexIndex = 10; % You can loop over all vertices to see this for each one
% significantPredictorsForVertex = predictorNames(significantMatrix(vertexIndex, :));
% disp(['Significant predictors for vertex ' num2str(vertexIndex) ' after FDR correction:']);
% disp(significantPredictorsForVertex);

%% Plot Residuals, QQ Plot, and Random Effects for significant vertices for TinnitusStatus_yes

tinnitusStatusColumn = find(strcmp(predictorNames, 'TinnitusStatus_yes'));

% Identify vertices where TinnitusStatus_yes is significant
significantVertices = find(fdrCorrectedPValues(:, tinnitusStatusColumn) < 0.05);

%--------------------------------------------------------------------------
% Get data for the first significant vertex
selectedVertex = significantVertices(1);
vertexData = dataTable(dataTable.VertexID == uniqueVertices(selectedVertex), :);

% Refit the LME model
lmeFormula = 'Response ~ 1 + Sex + Age + PTA_mean + AgeSq + Hemisphere + TinnitusStatus + Hemisphere:TinnitusStatus + Hemisphere:PTA_mean + (1|SubjectID)';
lmeModel = fitlme(vertexData, lmeFormula);
disp(lmeModel)

% Residuals vs Fitted values
figure;
plotResiduals(lmeModel, 'fitted');
title('Residuals vs Fitted Values');

% QQ Plot of residuals
figure;
plotResiduals(lmeModel, 'probability');
title('Normal Q-Q Plot of Residuals');

% Random effects plot
RE = randomEffects(lmeModel);
figure;
bar(RE);
xlabel('SubjectID');
ylabel('Random Effect Estimate');
title('Random Effects Plot');

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
    MRIwrite(imgDataUncorrected, sprintf('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF_fssym/stat/without_motionParam/fullmod/ALFF_tmap_tinStat_fullMod_uncorrected_%g.mgz', alpha));
    
    % Corrected
    significantVerticesCorrected = fdrCorrectedPValues(:, tinnitusStatusColumn) < alpha;
    tinnitusTValuesSignificantCorrected = coefficients(significantVerticesCorrected, tinnitusStatusColumn);

    imgDataCorrected = MRIread(files{file});
    imgDataCorrected.vol(:) = 0;
    imgDataCorrected.vol(significantVerticesCorrected) = tinnitusTValuesSignificantCorrected;
    MRIwrite(imgDataCorrected, sprintf('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF_fssym/stat/without_motionParam/fullmod/ALFF_tmap_tinStat_fullMod_corrected_%g.mgz', alpha));
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
    MRIwrite(imgDataUncorrected, sprintf('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF_fssym/stat/without_motionParam/fullmod/ALFF_tmap_PTA_mean_fullMod_uncorrected_%g.mgz', alpha));
    
    % Corrected
    significantVerticesCorrected = fdrCorrectedPValues(:, PTA_meanColumn) < alpha;
    PTA_meanTValuesSignificantCorrected = coefficients(significantVerticesCorrected, PTA_meanColumn);

    imgDataCorrected = MRIread(files{file});
    imgDataCorrected.vol(:) = 0;
    imgDataCorrected.vol(significantVerticesCorrected) = PTA_meanTValuesSignificantCorrected;
    MRIwrite(imgDataCorrected, sprintf('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF_fssym/stat/without_motionParam/fullmod/ALFF_tmap_PTA_mean_fullMod_corrected_%g.mgz', alpha));
end

%% Save t-maps --Age
% Alpha thresholds to consider
alphas = [0.01, 0.05, 0.1, 0.25 0.5];

% Find the column corresponding to Age
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
    MRIwrite(imgDataUncorrected, sprintf('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF_fssym/stat/without_motionParam/fullmod/ALFF_tmap_Age_fullMod_uncorrected_%g.mgz', alpha));
    
    % Corrected
    significantVerticesCorrected = fdrCorrectedPValues(:, AgeColumn) < alpha;
    AgeTValuesSignificantCorrected = coefficients(significantVerticesCorrected, AgeColumn);

    imgDataCorrected = MRIread(files{file});
    imgDataCorrected.vol(:) = 0;
    imgDataCorrected.vol(significantVerticesCorrected) = AgeTValuesSignificantCorrected;
    MRIwrite(imgDataCorrected, sprintf('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF_fssym/stat/without_motionParam/fullmod/ALFF_tmap_Age_fullMod_corrected_%g.mgz', alpha));
end


%% Save t-maps --Hemisphere_rh:PTA_mean
% Alpha thresholds to consider
alphas = [0.01, 0.05, 0.1, 0.25];

% Find the column corresponding to PTA_mean
hemisPTAColumn = find(strcmp(predictorNames, 'Hemisphere_rh:PTA_mean'));

% Loop over each alpha threshold
for idx = 1:length(alphas)
    alpha = alphas(idx);
    
    % Uncorrected
    significantVerticesUncorrected = pValues(:, hemisPTAColumn) < alpha;
    hemisPTATValuesSignificantUncorrected = coefficients(significantVerticesUncorrected, hemisPTAColumn);

    imgDataUncorrected = MRIread(files{file});
    imgDataUncorrected.vol(:) = 0;
    imgDataUncorrected.vol(significantVerticesUncorrected) = hemisPTATValuesSignificantUncorrected;
    MRIwrite(imgDataUncorrected, sprintf('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF_fssym/stat/without_motionParam/fullmod/ALFF_tmap_hemis-PTA_fullMod_uncorrected_%g.mgz', alpha));
    
    % Corrected
    significantVerticesCorrected = fdrCorrectedPValues(:, hemisPTAColumn) < alpha;
    hemisPTATValuesSignificantCorrected = coefficients(significantVerticesCorrected, hemisPTAColumn);

    imgDataCorrected = MRIread(files{file});
    imgDataCorrected.vol(:) = 0;
    imgDataCorrected.vol(significantVerticesCorrected) = hemisPTATValuesSignificantCorrected;
    MRIwrite(imgDataCorrected, sprintf('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF_fssym/stat/without_motionParam/fullmod/ALFF_tmap_hemis-PTA_fullMod_corrected_%g.mgz', alpha));
end
























%% Fitlme with parallel with only hemisphere, tinstat, age, pta_mean, hemis:pta_mean
%  --only save the coefficients and p values to save memory
% Start a parallel pool with 6 workers
if isempty(gcp('nocreate'))
    parpool(6);
end

% Initialize parfor_progress. This will create a file to track progress.
parfor_progress(length(uniqueVertices));

% Initialize matrices to hold the coefficients and p-values
numCoefficients = size(fitlme(dataTable(dataTable.VertexID == uniqueVertices(1), :), 'Response ~ 1 + Age + PTA_mean + Hemisphere + TinnitusStatus + Hemisphere:PTA_mean + (1|SubjectID)').Coefficients, 1);
coefficients_mod2 = NaN(length(uniqueVertices), numCoefficients);
pValues_mod2 = NaN(length(uniqueVertices), numCoefficients);

% Use parfor to loop over vertices
parfor i = 1:length(uniqueVertices)
    % Get the current VertexID
    currentVertex = uniqueVertices(i);
    
    % Select the data for the current VertexID
    vertexData = dataTable(dataTable.VertexID == currentVertex, :);

    % Check if all the responses for this vertex are zero
    if all(vertexData.Response == 0)
        coefficients_mod2(i, :) = NaN;
        pValues_mod2(i, :) = NaN;
        continue;
    end
    
    % Define the formula for the LME model
    lmeFormula_mod2 = 'Response ~ 1 + Age + PTA_mean + Hemisphere + TinnitusStatus + Hemisphere:PTA_mean + (1|SubjectID)';
    
    % Fit the LME model to the data
    lmeModel = fitlme(vertexData, lmeFormula_mod2);
    
    % Store only the coefficients and p-values
    coefficients_mod2(i, :) = lmeModel.Coefficients.Estimate;
    pValues_mod2(i, :) = lmeModel.Coefficients.pValue;

    % After finishing the calculations for each vertex, update the progress.
    parfor_progress;
end

% Clean up the progress monitor file.files
parfor_progress(0);

%% P values uncorrected
lmeFormula_mod2 = 'Response ~ 1 + Age + PTA_mean + Hemisphere + TinnitusStatus + Hemisphere:PTA_mean + (1|SubjectID)';
% Set alpha values to the specified range
alpha_range = [0.01, 0.05, 0.1, 0.25];

% Get names of predictors from a model for reference
modelForNames_mod2 = fitlme(dataTable(dataTable.VertexID == uniqueVertices(1), :), lmeFormula_mod2);
predictorNames_mod2 = modelForNames_mod2.Coefficients.Name;

% Loop over each alpha value
for alpha = alpha_range
    fprintf('\nResults for alpha = %.2f\n', alpha);
    
    % Identify columns (predictors) in the matrix where all p-values are > alpha
    nonSignificantPredictors_mod2 = all(pValues_mod2 > alpha, 1);

    % Print names of non-significant predictors ACROSS ALL VERTICES
    nonSignificantPredictorNames_mod2 = predictorNames_mod2(nonSignificantPredictors_mod2);
    disp('Predictors that are not significant across any vertices before FDR correction:');
    disp(nonSignificantPredictorNames_mod2);

    %% Get the numbers of significant vertices for each predictor --pre FDR
    % Create a matrix to hold binary values indicating significance for each vertex-predictor pair
    significantMatrix_mod2 = pValues_mod2 < alpha;

    % Display the number of vertices where each predictor is significant
    numSignificantVertices_mod2 = sum(significantMatrix_mod2);
    disp('Number of vertices where each predictor is significant before FDR:');
    disp(table(predictorNames_mod2, numSignificantVertices_mod2(:), 'VariableNames', {'Predictor', 'Number_of_Significant_Vertices'}));
end

%% Do FDR correction -P values corrected
% Flatten the pValues matrix into a vector for FDR correction
pValuesVector_mod2 = pValues_mod2(:);

% Apply FDR correction
fdrCorrectedPValuesVector_mod2 = mafdr(pValuesVector_mod2, 'BHFDR', true);

% Reshape the corrected p-values back into the original matrix form
fdrCorrectedPValues_mod2 = reshape(fdrCorrectedPValuesVector_mod2, size(pValues_mod2));

% Set alpha values to the specified range
alpha_range = [0.01, 0.05, 0.1, 0.25];

% Get names of predictors from a model for reference
modelForNames_mod2 = fitlme(dataTable(dataTable.VertexID == uniqueVertices(1), :), lmeFormula_mod2);
predictorNames_mod2 = modelForNames_mod2.Coefficients.Name;

% Loop over each alpha value
for alpha = alpha_range
    fprintf('\nResults for alpha = %.2f\n', alpha);
    
    % Identify columns (predictors) in the matrix where all p-values are > alpha
    nonSignificantPredictors_mod2 = all(fdrCorrectedPValues_mod2 > alpha, 1);

    % Print names of non-significant predictors ACROSS ALL VERTICES
    nonSignificantPredictorNames_mod2 = predictorNames_mod2(nonSignificantPredictors_mod2);
    disp('Predictors that are not significant across any vertices after FDR correction:');
    disp(nonSignificantPredictorNames_mod2);

    %% Get the numbers of significant vertices for each predictor --post FDR
    % Create a matrix to hold binary values indicating significance for each vertex-predictor pair
    significantMatrix_mod2 = fdrCorrectedPValues_mod2 < alpha;

    % Display the number of vertices where each predictor is significant
    numSignificantVertices_mod2 = sum(significantMatrix_mod2);
    disp('Number of vertices where each predictor is significant post FDR:');
    disp(table(predictorNames_mod2, numSignificantVertices_mod2(:), 'VariableNames', {'Predictor', 'Number_of_Significant_Vertices'}));
end

% To see the significant predictors for a specific vertex (let's say Vertex 10 as an example):
% vertexIndex = 10; % You can loop over all vertices to see this for each one
% significantPredictorsForVertex = predictorNames(significantMatrix(vertexIndex, :));
% disp(['Significant predictors for vertex ' num2str(vertexIndex) ' after FDR correction:']);
% disp(significantPredictorsForVertex);


%% Save t-maps --tinnitusStatus
% Alpha thresholds to consider
alphas = [0.01, 0.05, 0.1, 0.25];

% Find the column corresponding to TinnitusStatus_yes
tinnitusStatusColumn_mod2 = find(strcmp(predictorNames_mod2, 'TinnitusStatus_yes'));

% Loop over each alpha threshold
for idx = 1:length(alphas)
    alpha = alphas(idx);
    
    % Uncorrected
    significantVerticesUncorrected_mod2 = pValues_mod2(:, tinnitusStatusColumn_mod2) < alpha;
    tinnitusTValuesSignificantUncorrected_mod2 = coefficients_mod2(significantVerticesUncorrected_mod2, tinnitusStatusColumn_mod2);

    imgDataUncorrected = MRIread(files{file});
    imgDataUncorrected.vol(:) = 0;
    imgDataUncorrected.vol(significantVerticesUncorrected_mod2) = tinnitusTValuesSignificantUncorrected_mod2;
    MRIwrite(imgDataUncorrected, sprintf('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF_fssym/stat/mod2/ALFF_tmap_tinStat_mod2_uncorrected_%g.mgz', alpha));
    
    % Corrected
    significantVerticesCorrected_mod2 = fdrCorrectedPValues_mod2(:, tinnitusStatusColumn_mod2) < alpha;
    tinnitusTValuesSignificantCorrected_mod2 = coefficients_mod2(significantVerticesCorrected_mod2, tinnitusStatusColumn_mod2);

    imgDataCorrected = MRIread(files{file});
    imgDataCorrected.vol(:) = 0;
    imgDataCorrected.vol(significantVerticesCorrected_mod2) = tinnitusTValuesSignificantCorrected_mod2;
    MRIwrite(imgDataCorrected, sprintf('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF_fssym/stat/mod2/ALFF_tmap_tinStat_mod2_corrected_%g.mgz', alpha));
end

%% Save t-maps --PTA_mean
% Alpha thresholds to consider
alphas = [0.01, 0.05, 0.1, 0.25];

% Find the column corresponding to PTA_mean
PTA_meanColumn_mod2 = find(strcmp(predictorNames_mod2, 'PTA_mean'));

% Loop over each alpha threshold
for idx = 1:length(alphas)
    alpha = alphas(idx);
    
    % Uncorrected
    significantVerticesUncorrected_mod2 = pValues_mod2(:, PTA_meanColumn_mod2) < alpha;
    PTA_meanTValuesSignificantUncorrected_mod2 = coefficients_mod2(significantVerticesUncorrected_mod2, PTA_meanColumn_mod2);

    imgDataUncorrected = MRIread(files{file});
    imgDataUncorrected.vol(:) = 0;
    imgDataUncorrected.vol(significantVerticesUncorrected_mod2) = PTA_meanTValuesSignificantUncorrected_mod2;
    MRIwrite(imgDataUncorrected, sprintf('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF_fssym/stat/mod2/ALFF_tmap_PTA_mean_mod2_uncorrected_%g.mgz', alpha));
    
    % Corrected
    significantVerticesCorrected_mod2 = fdrCorrectedPValues_mod2(:, PTA_meanColumn_mod2) < alpha;
    PTA_meanTValuesSignificantCorrected_mod2 = coefficients_mod2(significantVerticesCorrected_mod2, PTA_meanColumn_mod2);

    imgDataCorrected = MRIread(files{file});
    imgDataCorrected.vol(:) = 0;
    imgDataCorrected.vol(significantVerticesCorrected_mod2) = PTA_meanTValuesSignificantCorrected_mod2;
    MRIwrite(imgDataCorrected, sprintf('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF_fssym/stat/mod2/ALFF_tmap_PTA_mean_mod2_corrected_%g.mgz', alpha));
end

%% Save t-maps --Age
% Alpha thresholds to consider
alphas = [0.01, 0.05, 0.1, 0.25];

% Find the column corresponding to Age
AgeColumn_mod2 = find(strcmp(predictorNames_mod2, 'Age'));

% Loop over each alpha threshold
for idx = 1:length(alphas)
    alpha = alphas(idx);
    
    % Uncorrected
    significantVerticesUncorrected_mod2 = pValues_mod2(:, AgeColumn_mod2) < alpha;
    AgeTValuesSignificantUncorrected_mod2 = coefficients_mod2(significantVerticesUncorrected_mod2, AgeColumn_mod2);

    imgDataUncorrected = MRIread(files{file});
    imgDataUncorrected.vol(:) = 0;
    imgDataUncorrected.vol(significantVerticesUncorrected_mod2) = AgeTValuesSignificantUncorrected_mod2;
    MRIwrite(imgDataUncorrected, sprintf('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF_fssym/stat/mod2/ALFF_tmap_Age_mod2_uncorrected_%g.mgz', alpha));
    
    % Corrected
    significantVerticesCorrected_mod2 = fdrCorrectedPValues_mod2(:, AgeColumn_mod2) < alpha;
    AgeTValuesSignificantCorrected_mod2 = coefficients_mod2(significantVerticesCorrected_mod2, AgeColumn_mod2);

    imgDataCorrected = MRIread(files{file});
    imgDataCorrected.vol(:) = 0;
    imgDataCorrected.vol(significantVerticesCorrected_mod2) = AgeTValuesSignificantCorrected_mod2;
    MRIwrite(imgDataCorrected, sprintf('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF_fssym/stat/mod2/ALFF_tmap_Age_mod2_corrected_%g.mgz', alpha));
end

%% Save t-maps --MotionAbsMean
% Alpha thresholds to consider
alphas = [0.01, 0.05, 0.1, 0.25 0.5];

% Find the column corresponding to Age
MotionAbsMeanColumn_mod2 = find(strcmp(predictorNames_mod2, 'MotionAbsMean'));

% Loop over each alpha threshold
for idx = 1:length(alphas)
    alpha = alphas(idx);
    
    % Uncorrected
    significantVerticesUncorrected_mod2 = pValues_mod2(:, MotionAbsMeanColumn_mod2) < alpha;
    MotionAbsMeanTValuesSignificantUncorrected_mod2 = coefficients_mod2(significantVerticesUncorrected_mod2, MotionAbsMeanColumn_mod2);

    imgDataUncorrected = MRIread(files{file});
    imgDataUncorrected.vol(:) = 0;
    imgDataUncorrected.vol(significantVerticesUncorrected_mod2) = MotionAbsMeanTValuesSignificantUncorrected_mod2;
    MRIwrite(imgDataUncorrected, sprintf('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF_fssym/stat/mod2/ALFF_tmap_MotionAbsMean_mod2_uncorrected_%g.mgz', alpha));
    
    % Corrected
    significantVerticesCorrected_mod2 = fdrCorrectedPValues_mod2(:, MotionAbsMeanColumn_mod2) < alpha;
    MotionAbsMeanTValuesSignificantCorrected_mod2 = coefficients_mod2(significantVerticesCorrected_mod2, MotionAbsMeanColumn_mod2);

    imgDataCorrected = MRIread(files{file});
    imgDataCorrected.vol(:) = 0;
    imgDataCorrected.vol(significantVerticesCorrected_mod2) = MotionAbsMeanTValuesSignificantCorrected_mod2;
    MRIwrite(imgDataCorrected, sprintf('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF_fssym/stat/mod2/ALFF_tmap_MotionAbsMean_mod2_corrected_%g.mgz', alpha));
end

%% Save t-maps --Hemisphere_rh:PTA_mean
% Alpha thresholds to consider
alphas = [0.01, 0.05, 0.1, 0.25];

% Find the column corresponding to PTA_mean
hemisPTAColumn_mod2 = find(strcmp(predictorNames_mod2, 'Hemisphere_rh:PTA_mean'));

% Loop over each alpha threshold
for idx = 1:length(alphas)
    alpha = alphas(idx);
    
    % Uncorrected
    significantVerticesUncorrected_mod2 = pValues_mod2(:, hemisPTAColumn_mod2) < alpha;
    hemisPTATValuesSignificantUncorrected_mod2 = coefficients_mod2(significantVerticesUncorrected_mod2, hemisPTAColumn_mod2);

    imgDataUncorrected = MRIread(files{file});
    imgDataUncorrected.vol(:) = 0;
    imgDataUncorrected.vol(significantVerticesUncorrected_mod2) = hemisPTATValuesSignificantUncorrected_mod2;
    MRIwrite(imgDataUncorrected, sprintf('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF_fssym/stat/mod2/ALFF_tmap_hemis-PTA_mod2_uncorrected_%g.mgz', alpha));
    
    % Corrected
    significantVerticesCorrected_mod2 = fdrCorrectedPValues_mod2(:, hemisPTAColumn_mod2) < alpha;
    hemisPTATValuesSignificantCorrected_mod2 = coefficients_mod2(significantVerticesCorrected_mod2, hemisPTAColumn_mod2);

    imgDataCorrected = MRIread(files{file});
    imgDataCorrected.vol(:) = 0;
    imgDataCorrected.vol(significantVerticesCorrected_mod2) = hemisPTATValuesSignificantCorrected_mod2;
    MRIwrite(imgDataCorrected, sprintf('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF_fssym/stat/mod2/ALFF_tmap_hemis-PTA_mod2_corrected_%g.mgz', alpha));
end






%% Save all analysis to mat files
% Define the filename for the .mat file
filename = '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF_fssym/stat/ALFF_lme.mat';

% Save all variables in the workspace to the .mat file
save(filename);

% This is a learning code for lme modelling in matlab
% with some simple dummy syntetic data 

clc
clear all
close all
%%
rng('default');  % For reproducibility >> Random Number Generator
% random numbers generated are the same, thus ensuring reproducibility of the results

% Generating the data
subjects = 20;  % Number of subjects
measurements = 50;  % Number of measurements per condition per hemisphere per subject

% Subject IDs
SubjectID = repelem((1:subjects)', measurements*2*2);

% Hemisphere and condition
Hemisphere = repmat(categorical(["Left","Right"])', subjects*measurements*2, 1);
Condition = repmat(categorical(repelem(["Rest","Visual"]', measurements)), subjects*2, 1);

% Response
trueEffects = [-2, 1, 3, -1, 2];  % True coefficients for the linear model
RandomEffect = normrnd(0, 0.5, [subjects, 1]);


X = [ones(length(SubjectID), 1), double(Hemisphere=='Right'), double(Condition=='Visual'), double(Hemisphere=='Right').*double(Condition=='Visual'), repelem(RandomEffect, measurements*2*2)];

% Response
Y = X*trueEffects' + normrnd(0, 0.5, [length(SubjectID), 1]);

% % Set 'Right' as reference level for Hemisphere >> if needed
% dataTable.Hemisphere = reorderlevels(dataTable.Hemisphere, {'Right', 'Left'});

% Putting all data in one table
dataTable = table(SubjectID, Hemisphere, Condition, Y, 'VariableNames', {'SubjectID', 'Hemisphere', 'Condition', 'Response'});

%%
% Create a formula for the model
formula = 'Response ~ Hemisphere*Condition + (1|SubjectID)';

% Create the linear mixed-effects model
lme = fitlme(dataTable, formula);

disp(lme);





















%%
% This is a learning code for lme modelling in matlab
% with some dummy syntetic data that reflect some vertices of fMRI data

clc
clear all
close all

% Set random seed for reproducibility
rng(1) % For reproducibility
nVertices = 50; % The number of vertices
nSubjects = 20; % The number of subjects
measurements = 200; % The number of measurements for each condition
conditions = ["Rest", "Visual"]; % The conditions
hemispheres = ["Left", "Right"]; % The hemispheres
trueEffects = [1, 2, 3, 4]; % The true effects

% Preallocation
pValues = zeros(nVertices, 1);
dataTable = table(); % Initialize empty table

for vertex = 1:nVertices
    % Creating data
    SubjectID = repelem((1:nSubjects)', measurements * 2 * 2);
    Hemisphere = repmat([repelem(hemispheres(1), measurements), repelem(hemispheres(2), measurements)]', nSubjects * 2, 1);
    Condition = repmat([repelem(conditions(1), measurements * 2), repelem(conditions(2), measurements * 2)]', nSubjects, 1);
    RandomEffect = normrnd(0, 1, [nSubjects, 1]);

    X = [ones(length(SubjectID), 1), double(Hemisphere=='Right'), double(Condition=='Visual'), double(Hemisphere=='Right').*double(Condition=='Visual')];
    Y_predicted = X * trueEffects';
    Y = Y_predicted + repelem(RandomEffect, measurements*2*2, 1) + normrnd(0, 0.5, [length(SubjectID), 1]);
    Response = Y;

    % Data table
    dataTableTemp = table(SubjectID, Hemisphere, Condition, Response);

    % Linear Mixed Effect Model
    lme = fitlme(dataTableTemp, 'Response ~ 1 + Hemisphere*Condition + (1|SubjectID)');

    % Store p-value
    pValues(vertex) = coefTest(lme);

    dataTable = [dataTable; dataTableTemp]; % Append data to the main table
end

% FDR correction
pFDR = mafdr(pValues, 'BHFDR', true);



alpha = 0.05; % set significance level
sig_indices = find(pFDR <= alpha); % get indices of significant pFDR values
sig_pFDR = pFDR(sig_indices); % get significant pFDR values

disp('Indices of significant pFDR values:');
disp(sig_indices);
disp('Significant pFDR values:');
disp(sig_pFDR);



%%
clc
clear
close all

% Set random seed for reproducibility
rng('default');  % For reproducibility >> Random Number Generator
% random numbers generated are the same, thus ensuring reproducibility of the results

nVertices = 50; % The number of vertices
nSubjects = 20; % The number of subjects
measurements = 200; % The number of measurements for each condition
conditions = ["Rest", "Visual"]; % The conditions
hemispheres = ["Left", "Right"]; % The hemispheres
trueEffects = [1, 2, 3, 4, 0.5, -0.5, 0.2];
age = randi([20,60],nSubjects,1); % Random ages between 20 and 60
sex = randi([0,1],nSubjects,1); % Random sex assignments (0 or 1)
hearingLevels = randi([0,1],nSubjects,1); % Random hearing levels (0 or 1)

% Preallocation
pValues = zeros(nVertices, 7); % One p-value for each coefficient
tValues = zeros(nVertices, 7); % One t-value for each coefficient
lmeModels = cell(nVertices, 1); % Cell array to hold the LME models
dataTable = table(); % Initialize empty table

for vertex = 1:nVertices
    % Creating data
    SubjectID = repelem((1:nSubjects)', measurements * 2 * 2);
    Hemisphere = repmat([repelem(hemispheres(1), measurements), repelem(hemispheres(2), measurements)]', nSubjects * 2, 1);
    Condition = repmat([repelem(conditions(1), measurements * 2), repelem(conditions(2), measurements * 2)]', nSubjects, 1);
    Age = repelem(age, measurements*2*2, 1);
    Sex = repelem(sex, measurements*2*2, 1);
    HearingLevel = repelem(hearingLevels, measurements*2*2, 1);
    RandomEffect = normrnd(0, 1, [nSubjects, 1]);

    X = [ones(length(SubjectID), 1), double(Hemisphere=='Right'), double(Condition=='Visual'), double(Hemisphere=='Right').*double(Condition=='Visual'), Age, Sex, HearingLevel];
    Y_predicted = X * trueEffects';
    Y = Y_predicted + repelem(RandomEffect, measurements*2*2, 1) + normrnd(0, 0.5, [length(SubjectID), 1]);
    Response = Y;

    % Data table
    dataTableTemp = table(SubjectID, Hemisphere, Condition, Age, Sex, HearingLevel, Response);

    % Linear Mixed Effect Model
    lme = fitlme(dataTableTemp, 'Response ~ 1 + Hemisphere*Condition + Age + Sex + HearingLevel + (1|SubjectID)');
    
    % Store the model
    lmeModels{vertex} = lme;
    
    % Store p-values
    pValues(vertex, :) = lme.Coefficients.pValue(1:end)';

    % Store t-values
    tValues(vertex, :) = lme.Coefficients.tStat(1:end)'; % Include the t-value for the intercept
    
    dataTable = [dataTable; dataTableTemp]; % Append data to the main table
end

% FDR correction for each predictor
pFDR = zeros(size(pValues));
for predictor = 1:size(pValues, 2)
    pFDR(:, predictor) = mafdr(pValues(:, predictor), 'BHFDR', true);
end

alpha = 0.05; % set significance level
sig_indices = cell(1, size(pFDR, 2)); % One cell array for each predictor
sig_pFDR = cell(1, size(pFDR, 2)); % One cell array for each predictor
for predictor = 1:size(pFDR, 2)
    sig_indices{predictor} = find(pFDR(:, predictor) <= alpha); % get indices of significant pFDR values for each predictor
    sig_pFDR{predictor} = pFDR(sig_indices{predictor}, predictor); % get significant pFDR values for each predictor
end

sig_tValues = cell(1, size(tValues, 2)); % One cell array for each predictor
for predictor = 1:size(tValues, 2)
    sig_tValues{predictor} = tValues(sig_indices{predictor}, predictor); % get significant t-values for each predictor
end


disp('Indices of significant pFDR values for each predictor:');
disp(sig_indices);
disp('Significant pFDR values for each predictor:');
disp(sig_pFDR);
disp('Significant t values for each predictor:');
disp(sig_tValues);

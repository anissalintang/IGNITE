clc
clear
close all

schavg = load('/Volumes/gdrive4tb/IGNITE/tonotopy/surface/patch/schavg.mat');

num_subjects = size(schavg.schavg.e_8, 1);
num_hemispheres = size(schavg.schavg.e_8, 2);
hemi_names = {'left', 'right'};

% Each row represents a subject, each column represents a hemisphere, 
% and the third dimension represents the frequency.
means_struct = struct();

for subj = 1:num_subjects
    for hemi = 1:num_hemispheres
        % Extract the cell array for this subject and hemisphere.
        current_matrix = schavg.schavg.e_8(subj, hemi); % Assuming 'data' is the field containing the 9409x8 cell array
        
            % Convert the cell column to a numeric array
            numeric_column = cell2mat(current_matrix);
            
            % Calculate the mean for this frequency
            mean_val = mean(numeric_column,1);
    
            % Store the means in the 3D array
            means_struct(subj).(hemi_names{hemi}) = mean_val;
    end
end

% To access the first row (i.e., the means for the first subject) for the left hemisphere from the means_struct
% means_struct(1).left(1);

% Initialize the means_ave structure
means_ave = struct();

for subj = 1:num_subjects
    % Calculate the average for each frequency between left and right hemispheres
    means_ave(subj).average = (means_struct(subj).left + means_struct(subj).right) / 2;
end


%% Overall bar plot showing signal change differences for each band -- all subjects
% Define band names
bands = {'Band 1', 'Band 2', 'Band 3', 'Band 4', 'Band 5', 'Band 6', 'Band 7', 'Band 8'};

% Extract average values for each subject
all_averages = vertcat(means_ave.average); % This will create a matrix where each row is a subject

% Calculate the average and SEM for each band
band_means = mean(all_averages, 1); % Average across subjects (rows)
band_SEM = std(all_averages, 0, 1) / sqrt(num_subjects); % Standard error of the mean

% Create a bar plot with error bars
figure;
bar(band_means);
hold on;
errorbar(1:8, band_means, band_SEM, 'k.', 'LineWidth', 1.5);
hold off;

% Set the x-axis labels to band names
set(gca, 'XTick', 1:8, 'XTickLabel', bands);

xlabel('Bands');
ylabel('Average Signal Change');
title('Average Values with SEM for Different Bands');
grid on;

%% Read the CSV file
csvData = readtable('/Volumes/gdrive4tb/IGNITE/data/ignite_main_data_ready.csv');

path = '/Volumes/gdrive4tb/IGNITE/tonotopy/surface/projected';
d = dir(path);
isub = [d(:).isdir]; % returns logical vector
subjects = {d(isub).name}';
subjects(ismember(subjects, {'.', '..'})) = []; % Remove . and .. from the list

% Initialize arrays of structures
data = [];
PTA_values_young = [];
PTA_values_mid = [];
PTA_values_older = [];

% Define frequencies and ears for loopings
frequencies = [250, 500, 1000, 2000, 3000, 4000, 6000, 8000, 9000, 10000, 11200, 12500, 14000, 16000];
ears = {'R', 'L'};

% Loop through subjects to gather PTA values by age group
for subj = 1:length(subjects)
    subjIdx = find(strcmp(csvData.ID, subjects(subj)));
    PTA_mean_R = csvData.PTA_mean_R(subjIdx);
    PTA_mean_L = csvData.PTA_mean_L(subjIdx);
    PTA_mean = (PTA_mean_R + PTA_mean_L) / 2;
    age = csvData.age(subjIdx);

    if age >= 20 && age <= 40
        PTA_values_young = [PTA_values_young, PTA_mean];
    elseif age >= 41 && age <= 60
        PTA_values_mid = [PTA_values_mid, PTA_mean];
    elseif age >= 61 && age <= 80
        PTA_values_older = [PTA_values_older, PTA_mean];
    end
end

% Get median values for each age group
median_PTA_young = median(PTA_values_young);
median_PTA_mid = median(PTA_values_mid);
median_PTA_older = median(PTA_values_older);

% Loop through subjects again to categorize based on hearing ability
for subj = 1:length(subjects)
    subjIdx = find(strcmp(csvData.ID, subjects(subj)));
    PTA_mean_R = csvData.PTA_mean_R(subjIdx);
    PTA_mean_L = csvData.PTA_mean_L(subjIdx);
    PTA_mean = (PTA_mean_R + PTA_mean_L) / 2;
    age = csvData.age(subjIdx);

    subjectData = struct();
    subjectData.Subject = subjects(subj);
    subjectData.PTA_mean = PTA_mean;
    subjectData.age = age;

    subjectData.is_HL = PTA_mean >= 20;

    % Categorize by hearing ability based on median PTA for age group
    if age >= 20 && age <= 40
        subjectData.age_group = 'young';
        subjectData.is_HL_ageDep = PTA_mean > median_PTA_young;
    elseif age >= 41 && age <= 60
        subjectData.age_group = 'mid';
        subjectData.is_HL_ageDep = PTA_mean > median_PTA_mid;
    elseif age >= 61 && age <= 80
        subjectData.age_group = 'older';
        subjectData.is_HL_ageDep = PTA_mean > median_PTA_older;
    end

    % Loop through each frequency and ear to gather PTA values
    for freq = frequencies
        for ear = ears
            ear = char(ear);
            columnName = strcat('f_', num2str(freq), '_', ear);
            PTA_value = csvData.(columnName)(subjIdx);
            fieldname = strcat('PTA_', num2str(freq), '_', ear);
            subjectData.(fieldname) = PTA_value;
        end
    end

    data = [data, subjectData];
end

is_HL = [data.is_HL];
is_NH = ~[data.is_HL];
count_HL = sum(is_HL)
count_NH = sum(is_NH)

is_TT = contains(subjects, 'TT');
is_NT = contains(subjects, 'NT');
num_HL_with_TT = sum(is_HL & is_TT')
num_HL_with_NT = sum(is_HL & ~is_TT')

num_NH_with_TT = sum(~is_HL & is_TT')
num_NH_with_NT = sum(~is_HL & ~is_TT')

count_TT = sum(is_TT)
count_NT = sum(is_NT)

%%%%%%%%%%%%%

is_HL_ageDep = [data.is_HL_ageDep];
is_NH_ageDep = ~[data.is_HL_ageDep];
count_HL_ageDep = sum(is_HL_ageDep)
count_NH_ageDep = sum(is_NH_ageDep)

is_TT = contains(subjects, 'TT');
count_HL_with_TT_ageDep = sum(is_HL_ageDep & is_TT')
count_HL_with_NT_ageDep = sum(is_HL_ageDep & ~is_TT')

count_NH_with_TT_ageDep = sum(~is_HL_ageDep & is_TT')
count_NH_with_NT_ageDep = sum(~is_HL_ageDep & ~is_TT')
for i = 1:size(all_averages, 1)
    data(i).band1 = all_averages(i, 1);
    data(i).band2 = all_averages(i, 2);
    data(i).band3 = all_averages(i, 3);
    data(i).band4 = all_averages(i, 4);
    data(i).band5 = all_averages(i, 5);
    data(i).band6 = all_averages(i, 6);
    data(i).band7 = all_averages(i, 7);
    data(i).band8 = all_averages(i, 8);
end

%% Interpolate PTA threshold to the band centre frequency
% Frequency bands
bands = [0.250 0.454; 0.454 0.746; 0.746 1.162; 1.162 1.756; 1.756 2.604; 2.604 3.813; 3.813 5.538; 5.538 8.000];

% Compute center frequency for each band in NERB
centre_frequency = zeros(size(bands,1), 1);
for i = 1:size(bands,1)
    nerb_edge1 = f2nerb(bands(i,1));
    nerb_edge2 = f2nerb(bands(i,2));
    centre_frequency(i) = (nerb_edge1 + nerb_edge2) / 2;
end

% Frequencies in kHz for interpolation
frequencies_kHz = frequencies / 1000;

% Convert frequencies_kHz to NERB
frequencies_NERB = arrayfun(@(f) f2nerb(f), frequencies_kHz);

% Number of subjects and bands
num_subjects = length(data);
num_bands = size(bands, 1);

% Create interpolated PTA values matrix
interp_PTA_values = zeros(num_subjects, num_bands);
orig_PTA_values = zeros(num_subjects, num_bands);

for subj = 1:num_subjects
    % Extract and average PTA values for the subject across both ears before interpolation
    averaged_thresholds = [];
    for freq = frequencies
        PTA_R = data(subj).(['PTA_', num2str(freq), '_R']);
        PTA_L = data(subj).(['PTA_', num2str(freq), '_L']);
        averaged_thresholds = [averaged_thresholds, (PTA_R + PTA_L) / 2];
    end
    
    orig_PTA_values(subj,:) = averaged_thresholds(1:8);
    % Interpolate to band center frequencies
    interp_PTA_values(subj, :) = interp1(frequencies_NERB, averaged_thresholds, centre_frequency, 'linear');
end


%% Extract the signal change values for each band for HEARING GROUPS (NH, HL)
signal_changes = zeros(num_subjects, num_bands);
for subj = 1:num_subjects
    for b = 1:num_bands
        signal_changes(subj, b) = data(subj).(['band', num2str(b)]);
    end
end

% Determine NH and HL groups based on PTA_mean using median value
% Calculate the median value of PTA_mean
% median_value = median([data.PTA_mean]);

% is_NH = [data.PTA_mean] <= median_value;
% is_HL = ~is_NH;

% Calculate means and SEM for NH and HL for each band
NH_means = zeros(1, num_bands);
HL_means = zeros(1, num_bands);
NH_SEM = zeros(1, num_bands);
HL_SEM = zeros(1, num_bands);
for b = 1:num_bands
    NH_means(b) = mean(signal_changes(is_NH, b));
    HL_means(b) = mean(signal_changes(is_HL, b));
    NH_SEM(b) = std(signal_changes(is_NH, b)) / sqrt(sum(is_NH));
    HL_SEM(b) = std(signal_changes(is_HL, b)) / sqrt(sum(is_HL));
end

figure('Position', [100, 100, 300, 300]);

% Bar plot
bar_positions = 1:num_bands;
bar_width = 0.35;
bars_NH = bar(bar_positions - bar_width/2, NH_means, bar_width, 'b');
hold on;
bars_HL = bar(bar_positions + bar_width/2, HL_means, bar_width, 'r');
ylim([0 2]);

% Adding error bars
errorbar(bar_positions - bar_width/2, NH_means, NH_SEM, 'k', 'linestyle', 'none', 'CapSize', 10);
errorbar(bar_positions + bar_width/2, HL_means, HL_SEM, 'k', 'linestyle', 'none', 'CapSize', 10);

% Customizations
xticks(1:num_bands);
xticklabels(arrayfun(@(x) sprintf('Band %d', x), 1:num_bands, 'UniformOutput', false));
xlabel('Frequency bands');
ylabel('Response size (%sc)');
% legend([bars_NH, bars_HL], {'NH (N= %d)', count_is_NH, 'HL'}, 'Location', 'northeastoutside');
% legend({sprintf('NH (N= %d)', count_NH), sprintf('HL (N= %d)', count_HL)}, ...
%        'Location', 'northeast');
% title('Signal change on Hearing difficulties group');
grid on;

hold off;
set(gca, 'FontSize', 14);

% Save the figure to the specified folder and filename
save_path = '/Volumes/gdrive4tb/IGNITE/tonotopy/surface/keyFigures/hearStat_ave_barPlot.png';
saveas(gcf, save_path);

%% Extract the signal change values for each band for TINNITUS GROUPS (Tin, NoTin)

% Extract the signal change values for each band for TINNITUS GROUPS (NT, TT)
signal_changes = zeros(num_subjects, num_bands);
for subj = 1:num_subjects
    for b = 1:num_bands
        signal_changes(subj, b) = data(subj).(['band', num2str(b)]);
    end
end

% Calculate means and SEM for NT and TT for each band
NT_means = zeros(1, num_bands);
TT_means = zeros(1, num_bands);
NT_SEM = zeros(1, num_bands);
TT_SEM = zeros(1, num_bands);
for b = 1:num_bands
    NT_means(b) = mean(signal_changes(is_NT, b));
    TT_means(b) = mean(signal_changes(is_TT, b));
    NT_SEM(b) = std(signal_changes(is_NT, b)) / sqrt(sum(is_NT));
    TT_SEM(b) = std(signal_changes(is_TT, b)) / sqrt(sum(is_TT));
end

figure('Position', [100,100, 300, 300]);

% Bar plot
bar_positions = 1:num_bands;
bar_width = 0.35;
bars_NT = bar(bar_positions - bar_width/2, NT_means, bar_width, 'b'); % Blue for NT
hold on;
bars_TT = bar(bar_positions + bar_width/2, TT_means, bar_width, 'r'); % Red for TT
ylim([0 2]);

% Adding error bars
errorbar(bar_positions - bar_width/2, NT_means, NT_SEM, 'k', 'linestyle', 'none', 'CapSize', 10);
errorbar(bar_positions + bar_width/2, TT_means, TT_SEM, 'k', 'linestyle', 'none', 'CapSize', 10);

% Customizations
xticks(1:num_bands);
xticklabels(arrayfun(@(x) sprintf('Band %d', x), 1:num_bands, 'UniformOutput', false));
xlabel('Frequency bands');
ylabel('Response size (%sc)');
% legend([bars_NT, bars_TT], {'NT', 'TT'}, 'Location', 'northeastoutside');
% legend({sprintf('NoTin (N= %d)', count_NT), sprintf('Tin (N= %d)', count_TT)}, ...
%        'Location', 'northeast');
% title('Signal change on Tinnitus status group');
grid on;

hold off;

set(gca, 'FontSize', 14);

% Save the figure to the specified folder and filename
save_path = '/Volumes/gdrive4tb/IGNITE/tonotopy/surface/keyFigures/tinStat_ave_barPlot.png';
saveas(gcf, save_path);


%% Grouped bar plot
NH_NT = is_NH_ageDep & is_NT';
NH_TT = is_NH_ageDep & is_TT';
HL_NT = is_HL_ageDep & is_NT';
HL_TT = is_HL_ageDep & is_TT';

NH_NT_means = zeros(1, num_bands);
NH_TT_means = zeros(1, num_bands);
HL_NT_means = zeros(1, num_bands);
HL_TT_means = zeros(1, num_bands);

% Calculate SEM for each subgroup
NH_NT_SEM = zeros(1, num_bands);
NH_TT_SEM = zeros(1, num_bands);
HL_NT_SEM = zeros(1, num_bands);
HL_TT_SEM = zeros(1, num_bands);

for b = 1:num_bands
    NH_NT_means(b) = mean(signal_changes(NH_NT, b), 'omitnan');
    NH_TT_means(b) = mean(signal_changes(NH_TT, b), 'omitnan');
    HL_NT_means(b) = mean(signal_changes(HL_NT, b), 'omitnan');
    HL_TT_means(b) = mean(signal_changes(HL_TT, b), 'omitnan');
    
    NH_NT_SEM(b) = std(signal_changes(NH_NT, b), 'omitnan') / sqrt(sum(NH_NT));
    NH_TT_SEM(b) = std(signal_changes(NH_TT, b), 'omitnan') / sqrt(sum(NH_TT));
    HL_NT_SEM(b) = std(signal_changes(HL_NT, b), 'omitnan') / sqrt(sum(HL_NT));
    HL_TT_SEM(b) = std(signal_changes(HL_TT, b), 'omitnan') / sqrt(sum(HL_TT));
end

figure('Position', [0, 0, 300, 300]);

% Bar plot
bar_positions = 1:num_bands;
bar_width = 0.2; % Adjusted width for four bars per band

curveColorNH_NT = [0.1 0.1 1]; % Darker Blue for NH_NT
curveColorNH_TT = [0.7 0.7 1]; % Lighter Blue for NH_TT
curveColorHL_NT = [1 0.1 0.1]; % Darker Red for HL_NT
curveColorHL_TT = [1 0.7 0.7]; % Lighter Red for HL_TT

% Bar plots
bars_NH_NT = bar(bar_positions - 3*bar_width/2, NH_NT_means, bar_width, 'FaceColor', curveColorNH_NT);
hold on;
bars_NH_TT = bar(bar_positions - bar_width/2, NH_TT_means, bar_width, 'FaceColor', curveColorNH_TT);
bars_HL_NT = bar(bar_positions + bar_width/2, HL_NT_means, bar_width, 'FaceColor', curveColorHL_NT);
bars_HL_TT = bar(bar_positions + 3*bar_width/2, HL_TT_means, bar_width, 'FaceColor', curveColorHL_TT);
ylim([0 2.5]);

% Adding error bars
errorbar(bar_positions - 3*bar_width/2, NH_NT_means, NH_NT_SEM, 'k', 'linestyle', 'none', 'CapSize', 10);
errorbar(bar_positions - bar_width/2, NH_TT_means, NH_TT_SEM, 'k', 'linestyle', 'none', 'CapSize', 10);
errorbar(bar_positions + bar_width/2, HL_NT_means, HL_NT_SEM, 'k', 'linestyle', 'none', 'CapSize', 10);
errorbar(bar_positions + 3*bar_width/2, HL_TT_means, HL_TT_SEM, 'k', 'linestyle', 'none', 'CapSize', 10);

% Customizations
xticks(1:num_bands);
xticklabels(arrayfun(@(x) sprintf('Band %d', x), 1:num_bands, 'UniformOutput', false));
xlabel('Frequency bands');
ylabel('Response size (%sc)');

% Updating legend with subject count
% legend([bars_NH_NT, bars_NH_TT, bars_HL_NT, bars_HL_TT], ...
%        {sprintf('NH NoTin (N= %d)', count_NH_with_NT_ageDep), sprintf('NH Tin (N= %d)', count_NH_with_TT_ageDep), sprintf('HL NoTin (N= %d)', count_HL_with_NT_ageDep), sprintf('HL Tin (N= %d)', count_HL_with_TT_ageDep)}, ...
%        'Location', 'northeast');

% title('Signal change for each subgroup of hearing and tinnitus status');
grid on;

hold off;

set(gca, 'FontSize', 14);

% Save the figure to the specified folder and filename
save_path = '/Volumes/gdrive4tb/IGNITE/tonotopy/surface/keyFigures/tinStat_hearStat_ave_barPlot.png';
saveas(gcf, save_path);


% %% Scatter Plot Across All Bands
% figure('Position', [100, 100, 800, 400]);
% 
% colors = lines(8); % This will generate 8 distinct colors
% 
% for b = 1:8 % Looping through each band
%     scatter(interp_PTA_values(:,b), signal_changes(:,b), 50, colors(b,:), 'filled'); % scatter plot
% 
% 
%     hold on;
% end
% 
% xlabel('Band-local Threshold');
% ylabel('Signal Change');
% legend(arrayfun(@(x) sprintf('Band %d', x), 1:8, 'UniformOutput', false), 'Location', 'northeastoutside');
% title('Relationship between Band-local Threshold and Signal Change for Each Band');
% grid on;
% 
% hold off;


%% Omnibus scatter plot plotted as binned MEDIAN with error bars --NORMALISED data --deming median
figure('Position', [100, 100, 400, 500]);

nBins = 10;

% Normalize signal_changes using NH_means
normalized_signal_changes = signal_changes ./ NH_means;  % Element-wise division

% Reshape data into one big vector
all_thresholds = reshape(interp_PTA_values, [], 1); % Converts 48x8 to 384x1
all_signals = reshape(normalized_signal_changes, [], 1); % Converts 48x8 to 384x1

% Determine global min and max for the entire dataset to define bin edges
global_min = min(all_thresholds);
global_max = max(all_thresholds);
binEdges = linspace(global_min, global_max, nBins+1);
binCenters = (binEdges(1:end-1) + binEdges(2:end)) / 2; % Centers of bins

binMedians = NaN(nBins, 1);

for k = 1:nBins
    idx = binEdges(k) <= all_thresholds & all_thresholds < binEdges(k+1);
    if any(idx)
        binMedians(k) = median(all_signals(idx));
    end
end

% Sort all_thresholds and use the same index sorting for all_signals
[sorted_thresholds, sort_idx] = sort(binCenters');
sorted_signals = binMedians(sort_idx);

% Construct the design matrix for linear regression
X = [ones(size(sorted_thresholds)), sorted_thresholds];

% Simple regression using matrix division
coefficients = X \ sorted_signals;
regression_y = X * coefficients;

% Define bootstrap parameters
nBootstraps = 1000;
lambdaValues = NaN(nBootstraps, 1);
bootSlopes_OLS = NaN(nBootstraps, 1); % for storing bootstrap OLS slopes
bootSlopes_Deming = NaN(nBootstraps, 1); % for storing bootstrap Deming slopes

% Bootstrap resampling to estimate lambda and calculate slopes
for i = 1:nBootstraps
    % Resample data with replacement
    bootIdx = randi(length(sorted_thresholds), length(sorted_thresholds), 1);
    boot_thresholds = sorted_thresholds(bootIdx);
    boot_signals = sorted_signals(bootIdx);

    % Simple regression using matrix division for bootstrapped samples
    coefficients_boot = [ones(size(boot_thresholds)), boot_thresholds] \ boot_signals;
    bootSlopes_OLS(i) = coefficients_boot(2);

    % Estimation of lambda using replicate measurements variance ratio
    lambdaValues(i) = var(boot_signals) / var(boot_thresholds);
    
    % Deming Regression using bootstrap estimated lambda for bootstrapped samples
    [b_deming_boot, ~, ~, ~, ~] = deming(boot_thresholds, boot_signals, lambdaValues(i));
    bootSlopes_Deming(i) = b_deming_boot(2);
end

% Choose lambda as the median of bootstrap estimates for stability
chosenLambda = median(lambdaValues);

% SEM calculation
SEM_OLS = std(bootSlopes_OLS) / sqrt(nBootstraps);
SEM_Deming = std(bootSlopes_Deming) / sqrt(nBootstraps);

% Deming Regression using chosen lambda
[b_deming, ~, ~, ~, ~] = deming(sorted_thresholds, sorted_signals, chosenLambda);
deming_y = [ones(size(sorted_thresholds)), sorted_thresholds] * b_deming;

% Calculate the total sum of squares (SST)
sst = sum((sorted_signals - mean(sorted_signals)).^2);

% Calculate the regression sum of squares (SSR)
ssr = sum((regression_y - mean(sorted_signals)).^2);

% Compute R^2
R2 = ssr / sst;

% Display R^2 value
disp(['R-squared value (OLS): ', num2str(R2)]);

% Slopes for a 10 dB change
slopePer10dB_OLS = coefficients(2) * 10;
slopePer10dB_Deming = b_deming(2) * 10;

% Display slopes for a 10 dB change
disp(['OLS Slope for a 10 dB change: ', num2str(slopePer10dB_OLS, '%.2f')]);
disp(['Deming Slope for a 10 dB change: ', num2str(slopePer10dB_Deming, '%.2f')]);

% Plotting section
scatter(all_thresholds, all_signals, 10, [0.7 0.7 0.7], 'filled', 'MarkerFaceAlpha', 0.7);
hold on;
hRegLine_OLS = plot(sorted_thresholds, regression_y, 'k--', 'LineWidth', 1.5);
hRegLine_Deming = plot(sorted_thresholds, deming_y, 'k', 'LineWidth', 1.5);
scatter(binCenters, binMedians, 80, 'b', 'o', 'LineWidth', 1.5);

xlabel('Hearing level (dB HL)');
ylabel('Auditory ROI signal change (%)');
% title('Omnibus Binned Relationship (normalised data)');
grid on;

% Update the legend with the slopes per 10 dB change
legend([hRegLine_OLS, hRegLine_Deming], ...
       {['OLS: R^2 = ' num2str(R2, '%.2f'), ' Slope/10dB = ' num2str(slopePer10dB_OLS, '%.2f')], ...
        ['Deming: Slope/10dB = ' num2str(slopePer10dB_Deming, '%.2f')]}, ...
       'Location', 'southeast');
hold off;

set(gca,'FontSize', 16);

% Save the figure to the specified folder and filename
save_path = '/Volumes/gdrive4tb/IGNITE/tonotopy/surface/keyFigures/signalCh_PTT_relationship.png';
saveas(gcf, save_path);

%% Audiogram of subject 1 with interpolated threshold
figure('Position', [100, 100, 600, 400]);
sub = 1;

% Create a storage for original PTA values for one subject
orig_PTA_values = zeros(1, 8);

% Extract original PTA values for one subject
for f_idx = 1:8
    PTA_R = data(sub).(['PTA_', num2str(frequencies(f_idx)), '_R']);
    PTA_L = data(sub).(['PTA_', num2str(frequencies(f_idx)), '_L']);
    orig_PTA_values(f_idx) = (PTA_R + PTA_L) / 2;
end

% Interpolate for a smooth curve
frequencies_dense = linspace(frequencies_NERB(1), frequencies_NERB(8), 500); % 500 points for smoothness
smooth_PTA_values = interp1(frequencies_NERB(1:8), orig_PTA_values, frequencies_dense, 'pchip');

hold on;

% Plot the interpolated values with blue 'o' not filled
h1 = scatter(centre_frequency, interp_PTA_values(sub,:), 50, 'b', 'o', 'LineWidth', 1.5);

% Plot the smooth curve
plot(frequencies_dense, smooth_PTA_values, 'k--', 'LineWidth', 1);

% Plot the original PTA values
h2 = scatter(frequencies_NERB(1:8), orig_PTA_values, 50, 'k', 'o','filled','LineWidth', 1.5);

xlabel('Frequency (in NERB)');
ylabel('Hearing level (dB HL)');
xticks(frequencies_NERB(1:8)); % This ensures that the x-axis ticks align with the frequencies in NERB
xticklabels(arrayfun(@num2str, frequencies_kHz(1:8), 'UniformOutput', false)); % Display the frequencies in kHz as tick labels

legend([h1, h2], {'Interpolated threshold', 'Original threshold'}, 'Location', 'northeastoutside');

% title('Audiogram of Subject 1: Band-local Threshold vs. Frequency in NERB');
grid on;

% Set y-axis limits
ylim([-10, 80]);

% Invert y-axis
set(gca, 'YDir', 'reverse', 'FontSize', 16);

hold off;

% Save the figure to the specified folder and filename
save_path = '/Volumes/gdrive4tb/IGNITE/tonotopy/surface/keyFigures/orig_and_interp_PTT.png';
saveas(gcf, save_path);


%% function list
function nerb = f2nerb(f)
    % Convert frequency to NERB
    nerb = 1000*log(10)/(24.67*4.37)*log10(4.37*f+1);
end


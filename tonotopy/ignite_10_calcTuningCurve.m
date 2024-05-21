clc
clear
close all

load scannerFFT.mat

% Define NH subjects

path = '/Volumes/gdrive4tb/IGNITE/tonotopy/surface/projected';
d = dir(path);
isub = [d(:).isdir]; % returns logical vector
subjects = {d(isub).name}';
subjects(ismember(subjects, {'.', '..'})) = []; % Remove . and .. from the list

% Filter subjects based on NH_subjs
% subjects = subjects(ismember(subjects, NH_subjs));

num_subjects = numel(subjects); % Adjusted number of subjects to NH_subjs
hemi = {'lh', 'rh'};
num_hemispheres = length(hemi);
num_frq = 8;

%% Load PFI maps and signal changes data for every subjects
path = '/Volumes/gdrive4tb/IGNITE/tonotopy/surface';
sigch_data = struct();

% Load pfi map data for HL subjects
nh_pfipath = fullfile(path, 'pfimax', 'NH_pfimax_8.lh.fssym.mgz');
nh_pfi_data = MRIread(nh_pfipath).vol;

% Jack-knife from each NH subject
jk_pfi_data = struct();

for subjId = 1:numel(subjects)
    s = subjects{subjId};
    
    % Load JK PFI data
    jk_pfipath = fullfile(path, 'projected', s, 'pfimax.lh.fssym.mgz');
    
    % Check if file exists for the subject
    if exist(jk_pfipath, 'file')
        jk_pfi_data.(s) = MRIread(jk_pfipath).vol;
    end
    
    % Load signal changes data for each hemisphere
    for hemiId = 1:num_hemispheres
        h = hemi{hemiId};
        
        sigchpath = fullfile(path, 'projected', s, 'e_8.fsf', strcat(h, '.sigch.avg.lh.fssym.mgz'));
        for i = 1:num_frq
            fieldname = sprintf('band%d', i);
            tmp = MRIread(sigchpath).vol;
            sigch_data.(h).(s).(fieldname) = squeeze(tmp(:,:,1,i));
        end
    end
end

% Load ROI mask
mri_probActMap = MRIread('/Volumes/gdrive4tb/IGNITE/tonotopy/surface/probActMap/probActMap.lh.fssym.mgz');
mri_mask = MRIread('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/destrieux_fsavg/temporalLobe_mask_lh_fssym.mgh');

% Find indices where probability activation map is greater than the threshold and masked
idx = find(mri_probActMap.vol .* mri_mask.vol >= 35);

%% Read the CSV file to get the PTT
csvData = readtable('/Volumes/gdrive4tb/IGNITE/data/ignite_main_data_ready.csv');

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


%% Tuning curves calculation

% Initialize tuning curve data structure
tunCurv_data = struct();

% Loop through each subject
for subjId = 1:num_subjects
    s = subjects{subjId};
    for hemiId = 1:num_hemispheres
        h = hemi{hemiId};

        % Determine which PFI data to use based on HL or NH
        if is_HL(subjId)
            current_pfi_data = nh_pfi_data;
        else
            if isfield(jk_pfi_data, s)
                current_pfi_data = jk_pfi_data.(s);
            else
                current_pfi_data = nh_pfi_data;
            end
        end
        
        % Loop through each frequency band to collect voxels in ROI that prefer this frequency
        for bandId = 1:num_frq
            % Find the indices of voxels in ROI with this preferred frequency
            voxels_idx = idx(current_pfi_data(idx) == bandId);
            
            % Extract the response of these voxels to each frequency band
            band_responses = zeros(length(voxels_idx), num_frq);
            for freqId = 1:num_frq
                fieldname = sprintf('band%d', freqId);
                band_responses(:, freqId) = sigch_data.(h).(s).(fieldname)(voxels_idx);
            end
            
            % Calculate the mean response for these voxels for each frequency band
            mean_responses = mean(band_responses, 1);
            
            % Save to the tuning curve data structure
            fieldname_tunCurv = sprintf('tunCurv_band%d', bandId);
            if ~isfield(tunCurv_data, fieldname_tunCurv)
                tunCurv_data.(fieldname_tunCurv) = struct();
            end
            tunCurv_data.(fieldname_tunCurv).(h).(s) = mean_responses;
        end
    end
end

% Store tuning curves averages (lh and rh)
for bandId = 1:num_frq
    fieldname_tunCurv = sprintf('tunCurv_band%d', bandId);
    
    % Create a sub-structure to store the average data
    tunCurv_data.(fieldname_tunCurv).ave = struct();
    
    % Loop through each subject to compute the average across hemispheres
    for subjId = 1:num_subjects
        s = subjects{subjId};
        
        % Fetch the tuning curve data for left and right hemispheres
        lh_data = tunCurv_data.(fieldname_tunCurv).lh.(s);
        rh_data = tunCurv_data.(fieldname_tunCurv).rh.(s);
        
        % Compute the average
        ave_data = (lh_data + rh_data) / 2;
        
        % Store the average data in the tuning curve data structure
        tunCurv_data.(fieldname_tunCurv).ave.(s) = ave_data;
    end
end

%% Plot 1a: tuning curve -- NH and HL

figure;

% Frequency bands
bands = [0.250 0.454; 0.454 0.746; 0.746 1.162; 1.162 1.756; 1.756 2.604; 2.604 3.813; 3.813 5.538; 5.538 8.000];

% Compute center frequency for each band in NERB
centre_frequency = zeros(size(bands,1), 1);
for i = 1:size(bands,1)
    nerb_edge1 = f2nerb(bands(i,1));
    nerb_edge2 = f2nerb(bands(i,2));
    centre_frequency(i) = (nerb_edge1 + nerb_edge2) / 2;
end

frq_nerb = nerb2f(centre_frequency);
f1 = nerb2f(f2nerb(0.3520)-0.5)
f2 = nerb2f(f2nerb(0.3520)+0.5)

edges = [0.250 0.454];
f3 = nerb2f(mean(f2nerb(edges)))

num_bands = numel(centre_frequency);

% Define colors for the plot
curveColorNH = [0 0 1]; % Blue for NH curve
curveColorHL = [1 0 0]; % Red for HL curve

% Max and min for Y axis
maxY = 2.5; 
minY = 0;

mean_curve_NH_all = [];
mean_curve_HL_all = [];

% Loop through each frequency band (i.e., each panel in your figure)
for bandId = 1:num_bands
    subplot(1, num_bands, bandId);
    
    % Extract tuning curve data for the current band
    fieldname_tunCurv = sprintf('tunCurv_band%d', bandId);
    
    % Initializing matrices to store data for NH and HL subjects separately
    data_NH = [];
    data_HL = [];
    
    for subjId = 1:num_subjects
        s = subjects{subjId};
        
        subject_data = zeros(1, num_bands);
        % For each band within the current band's panel
        for b = 1:num_bands
            band = sprintf('band%d', b);
            subject_data(b) = tunCurv_data.(fieldname_tunCurv).ave.(s)(b);
        end
        
        if is_HL(subjId)
            data_HL = [data_HL; subject_data];
        else
            data_NH = [data_NH; subject_data];
        end
    end
    
    % Average across subjects for NH and HL separately
    mean_curve_NH = mean(data_NH, 1);
    mean_curve_HL = mean(data_HL, 1);

    mean_curve_NH_all = [mean_curve_NH_all; mean_curve_NH];
    mean_curve_HL_all = [mean_curve_HL_all; mean_curve_HL];

    % Compute standard error of the mean (SEM) for NH and HL
    sem_NH = std(data_NH, 0, 1) / sqrt(size(data_NH, 1));
    sem_HL = std(data_HL, 0, 1) / sqrt(size(data_HL, 1));
    
    % % Plotting with error bars
    % errorbar(mean_curve_NH, sem_NH, 'Color', curveColorNH, 'LineWidth', 1.5); 
    % hold on; % Keep the NH plot to overlay the HL plot
    % errorbar(mean_curve_HL, sem_HL, 'Color', curveColorHL, 'LineWidth', 1.5);
 
    % Plotting WITHOUT error bars
    plot(mean_curve_NH, 'Color', curveColorNH, 'LineWidth', 1.5);
    hold on; % Keep the NH plot to overlay the HL plot
    plot(mean_curve_HL, 'Color', curveColorHL, 'LineWidth', 1.5);

     % Plot the custom error lines
    for b = 1:num_bands
        if mean_curve_NH(b) > mean_curve_HL(b)
            % NH error goes up
            plot([b b], [mean_curve_NH(b) mean_curve_NH(b)+sem_NH(b)], 'Color', curveColorNH, 'LineWidth', 0.8);
            % HL error goes down
            plot([b b], [mean_curve_HL(b) mean_curve_HL(b)-sem_HL(b)], 'Color', curveColorHL, 'LineWidth', 0.8);
        else
            % NH error goes down
            plot([b b], [mean_curve_NH(b) mean_curve_NH(b)-sem_NH(b)], 'Color', curveColorNH, 'LineWidth', 0.8);
            % HL error goes up
            plot([b b], [mean_curve_HL(b) mean_curve_HL(b)+sem_HL(b)], 'Color', curveColorHL, 'LineWidth', 0.8);
        end
    end
    
    % Add dashed black line for the current band
    line([bandId bandId], [minY maxY], 'Color', [0 0 0], 'LineStyle', '--','LineWidth', 1);
    
    hold off; % Release the hold to allow for other plotting operations
    
    % Set x-axis labels and title with modified requirements
    set(gca, 'XTick', [1, ceil(num_bands/2), num_bands], 'XTickLabel', ...
        {sprintf('%.1f kHz', frq_nerb(1)), sprintf('%.1f kHz', frq_nerb(ceil(num_bands/2))), ...
        sprintf('%.1f kHz', frq_nerb(num_bands))}, 'XTickLabelRotation', 45, ...
        'FontSize', 14);
    title(sprintf('%.1f kHz', frq_nerb(bandId)));

    
    % Set consistent Y-axis limits for all panels
    ylim([minY maxY]);
    
    % Display the Y-axis label only for the first panel
    if bandId > 1
        set(gca, 'YTickLabel', []);
    else
        ylabel('Response size (%sc)', 'FontSize', 14);
    end

    grid on;
    
end

% Add legend
% legend('NH', 'HL');
% legend({sprintf('NH (N= %d)', count_NH), sprintf('HL (N= %d)', count_HL)}, ...
%        'Location', 'southeast');

% Adjust axes positions
for ax = 1:num_bands
    pos = get(subplot(1, num_bands, ax), 'Position');
    set(subplot(1, num_bands, ax), 'Position', [pos(1) pos(2)+0.1 pos(3) pos(4)-0.1]);
end
    
% Add a centralized xlabel for the entire figure
figH = gcf;
axes('Parent',figH,'Position',[.1 .1 .8 .8],'Visible','off');
text(0.5, -0.09, 'Frequency (kHz)', 'FontSize', 14, 'HorizontalAlignment', 'center');

% Adjust the figure's size and layout for better visualization
set(gcf, 'Position', [100, 100, 800, 300]);

% Save the figure to the specified folder and filename
save_path = '/Volumes/gdrive4tb/IGNITE/tonotopy/surface/keyFigures/hearStat_tuning_curve_halferrb.png';
saveas(gcf, save_path);

%% Plot 1test: dual y axis with scanner noise magnitude
% 
% figure;
% 
% % Frequency bands
% bands = [0.250 0.454; 0.454 0.746; 0.746 1.162; 1.162 1.756; 1.756 2.604; 2.604 3.813; 3.813 5.538; 5.538 8.000];
% 
% % Compute center frequency for each band in NERB
% centre_frequency = zeros(size(bands,1), 1);
% for i = 1:size(bands,1)
%     nerb_edge1 = f2nerb(bands(i,1));
%     nerb_edge2 = f2nerb(bands(i,2));
%     centre_frequency(i) = (nerb_edge1 + nerb_edge2) / 2;
% end
% 
% frq_nerb = nerb2f(centre_frequency);
% 
% num_bands = numel(centre_frequency);
% 
% % Define colors for the plot
% curveColorNH = [0 0 1]; % Blue for NH curve
% curveColorHL = [1 0 0]; % Red for HL curve
% 
% % Max and min for Y axis
% maxY = 2.5; 
% minY = 0;
% 
% % Loop through each frequency band (i.e., each panel in your figure)
% for bandId = 1:num_bands
%     subplot(1, num_bands, bandId);
% 
%     % Extract tuning curve data for the current band
%     fieldname_tunCurv = sprintf('tunCurv_band%d', bandId);
% 
%     % Initializing matrices to store data for NH and HL subjects separately
%     data_NH = [];
%     data_HL = [];
% 
%     for subjId = 1:num_subjects
%         s = subjects{subjId};
% 
%         subject_data = zeros(1, num_bands);
%         % For each band within the current band's panel
%         for b = 1:num_bands
%             band = sprintf('band%d', b);
%             subject_data(b) = tunCurv_data.(fieldname_tunCurv).ave.(s)(b);
%         end
% 
%         if is_HL(subjId)
%             data_HL = [data_HL; subject_data];
%         else
%             data_NH = [data_NH; subject_data];
%         end
%     end
% 
%     % Average across subjects for NH and HL separately
%     mean_curve_NH = mean(data_NH, 1);
%     mean_curve_HL = mean(data_HL, 1);
% 
%     % Compute standard error of the mean (SEM) for NH and HL
%     sem_NH = std(data_NH, 0, 1) / sqrt(size(data_NH, 1));
%     sem_HL = std(data_HL, 0, 1) / sqrt(size(data_HL, 1));
% 
%     % Plotting WITHOUT error bars
%     yyaxis left;
%     pNH = plot(mean_curve_NH, 'Color', curveColorNH, 'LineWidth', 1.5);
%     hold on; % Keep the NH plot to overlay the HL plot
%     pHL = plot(mean_curve_HL, 'Color', curveColorHL, 'LineWidth', 1.5);
% 
%      % Plot the custom error lines
%     for b = 1:num_bands
%         if mean_curve_NH(b) > mean_curve_HL(b)
%             % NH error goes up
%             plot([b b], [mean_curve_NH(b) mean_curve_NH(b)+sem_NH(b)], 'Color', curveColorNH, 'LineWidth', 0.8, 'Marker', 'none');
%             % HL error goes down
%             plot([b b], [mean_curve_HL(b) mean_curve_HL(b)-sem_HL(b)], 'Color', curveColorHL, 'LineWidth', 0.8, 'Marker', 'none');
%         else
%             % NH error goes down
%             plot([b b], [mean_curve_NH(b) mean_curve_NH(b)-sem_NH(b)], 'Color', curveColorNH, 'LineWidth', 0.8, 'Marker', 'none');
%             % HL error goes up
%             plot([b b], [mean_curve_HL(b) mean_curve_HL(b)+sem_HL(b)], 'Color', curveColorHL, 'LineWidth', 0.8, 'Marker', 'none');
%         end
%     end
% 
%     % Add dashed black line for the current band
%     line([bandId bandId], [minY maxY], 'Color', [0 0 0], 'LineStyle', '--','LineWidth', 1);
% 
%     % hold off; % Release the hold to allow for other plotting operations
% 
%     % Set x-axis labels and title with modified requirements
%     set(gca, 'XTick', [1, ceil(num_bands/2), num_bands], 'XTickLabel', {sprintf('%.1f kHz', frq_nerb(1)), sprintf('%.1f kHz', frq_nerb(ceil(num_bands/2))), sprintf('%.1f kHz', frq_nerb(num_bands))}, 'XTickLabelRotation', 45);
%     title(sprintf('%.1f kHz', frq_nerb(bandId)));
% 
% 
%     % Set consistent Y-axis limits for all panels
%     ylim([minY maxY]);
% 
%     % Display the Y-axis label only for the first panel
%     if bandId == 1
%         ylabel('Response size (%sc)');
%     end
% 
%     % Turn off left y-axis tick labels for all but the first panel
%     if bandId ~= 1
%         set(gca, 'YTickLabel', []);
%     end
% 
%     yyaxis right;
%     % indices = nerb >= min(frq_nerb) & nerb <= 6.66;
%     f_scanNoise = nerb2f(nerb);
%     P1_dB_interpolated = interp1(f_scanNoise, P1_dB, frq_nerb, 'linear', 'extrap');
% 
%     scan_noise = plot(P1_dB_interpolated, 'Color', [0, 0.5, 0], 'LineWidth', 1);
% 
%     % If it's the last panel, set the right y-axis label
%     if bandId == num_bands
%         ylabel('Scanner Noise Magnitude (dB)');
%     end
% 
%     % Turn off right y-axis tick labels for all but the last panel
%     if bandId ~= num_bands
%         set(gca, 'YTickLabel', []);
%     end
% 
% 
%     grid on;
% 
% end
% 
% % Add legend
% % legend('NH', 'HL');
% legend([pNH, pHL, scan_noise], {sprintf('NH (N= %d)', count_NH), sprintf('HL (N= %d)', count_HL), 'Scanner noise'}, ...
%        'Location', 'northeastoutside');
% 
% % Adjust axes positions
% for ax = 1:num_bands
%     pos = get(subplot(1, num_bands, ax), 'Position');
%     set(subplot(1, num_bands, ax), 'Position', [pos(1) pos(2)+0.1 pos(3) pos(4)-0.1]);
% end
% 
% % Add a centralized xlabel for the entire figure
% figH = gcf;
% axes('Parent',figH,'Position',[0 .1 .8 .8],'Visible','off');
% text(0.5, -0.05, 'Frequency (kHz)', 'FontSize', 11, 'HorizontalAlignment', 'center');
% 
% % Adjust the figure's size and layout for better visualization
% set(gcf, 'Position', [100, 100, 1500, 400]);

%% Plot 1aa: tuning curve -- NH and HL --differences

figure;

% Frequency bands
bands = [0.250 0.454; 0.454 0.746; 0.746 1.162; 1.162 1.756; 1.756 2.604; 2.604 3.813; 3.813 5.538; 5.538 8.000];

% Compute center frequency for each band in NERB
centre_frequency = zeros(size(bands,1), 1);
for i = 1:size(bands,1)
    nerb_edge1 = f2nerb(bands(i,1));
    nerb_edge2 = f2nerb(bands(i,2));
    centre_frequency(i) = (nerb_edge1 + nerb_edge2) / 2;
end

frq_nerb = nerb2f(centre_frequency);

num_bands = numel(centre_frequency);

% Define colors for the plot
curveColorNH = [0 0 1]; % Blue for NH curve
curveColorHL = [1 0 0]; % Red for HL curve

% Max and min for Y axis
maxY = 2.5; 
minY = 0;

% Loop through each frequency band (i.e., each panel in your figure)
for bandId = 1:num_bands
    subplot(1, num_bands, bandId);
    
    % Extract tuning curve data for the current band
    fieldname_tunCurv = sprintf('tunCurv_band%d', bandId);
    
    % Initializing matrices to store data for NH and HL subjects separately
    data_NH = [];
    data_HL = [];
    
    for subjId = 1:num_subjects
        s = subjects{subjId};
        
        subject_data = zeros(1, num_bands);
        % For each band within the current band's panel
        for b = 1:num_bands
            band = sprintf('band%d', b);
            subject_data(b) = tunCurv_data.(fieldname_tunCurv).ave.(s)(b);
        end
        
        if is_HL(subjId)
            data_HL = [data_HL; subject_data];
        else
            data_NH = [data_NH; subject_data];
        end
    end
    
    % Average across subjects for NH and HL separately
    mean_curve_NH = mean(data_NH, 1);
    mean_curve_HL = mean(data_HL, 1);

     % Compute standard error of the mean (SEM) for NH and HL
    sem_NH = std(data_NH, 0, 1) / sqrt(size(data_NH, 1));
    sem_HL = std(data_HL, 0, 1) / sqrt(size(data_HL, 1));

    % Compute the difference between NH and HL
    difference_curve = mean_curve_HL - mean_curve_NH;
    
    % Compute the SEM for the difference
    sem_difference = sqrt(sem_NH.^2 + sem_HL.^2);
    
    % Plotting the difference curve WITHOUT error bars
    plot(difference_curve, 'k-', 'LineWidth', 1.5);
    
    hold on; % Keep the difference plot

    % Plot the custom error lines for the difference
    for b = 1:num_bands
        plot([b b], [difference_curve(b) difference_curve(b)+sem_difference(b)], 'k-', 'LineWidth', 0.8);
        plot([b b], [difference_curve(b) difference_curve(b)-sem_difference(b)], 'k-', 'LineWidth', 0.8);
    end
    
    % Add horizontal line at y=0
    line([1 num_bands], [0 0], 'Color', 'black', 'LineStyle', '--', 'LineWidth', 1);

    % Add dashed black line for the current band
    line([bandId bandId], [-1 1], 'Color', [0 0 0], 'LineStyle', '--','LineWidth', 1);
    
    hold off; % Release the hold to allow for other plotting operations
    
    % Set x-axis labels and title with modified requirements
    set(gca, 'XTick', [1, ceil(num_bands/2), num_bands], 'XTickLabel', ...
        {sprintf('%.1f kHz', frq_nerb(1)), sprintf('%.1f kHz', frq_nerb(ceil(num_bands/2))), ...
        sprintf('%.1f kHz', frq_nerb(num_bands))}, 'XTickLabelRotation', 45, ...
        'FontSize', 14);
    title(sprintf('%.1f kHz', frq_nerb(bandId)));
 
    % Set consistent Y-axis limits for all panels
    ylim([-1 1]);
    
     % Display the Y-axis label only for the first panel
    if bandId == 1
        ylabel('Tuning curve difference (HL - NH)', 'FontSize', 14);
    else
        set(gca, 'YTickLabel', [], 'FontSize', 14);
    end

    grid on;
end

% Adjust axes positions
for ax = 1:num_bands
    pos = get(subplot(1, num_bands, ax), 'Position');
    set(subplot(1, num_bands, ax), 'Position', [pos(1) pos(2)+0.1 pos(3) pos(4)-0.1]);
end
    
% Add a centralized xlabel for the entire figure
figH = gcf;
axes('Parent',figH,'Position',[.1 .1 .8 .8],'Visible','off');
text(0.5, -0.09, 'Frequency (kHz)', 'FontSize', 14, 'HorizontalAlignment', 'center');


% Adjust the figure's size and layout for better visualization
set(gcf, 'Position', [100, 100, 800, 300]);


% Save the figure to the specified folder and filename
save_path = '/Volumes/gdrive4tb/IGNITE/tonotopy/surface/keyFigures/hearStat_tuning_curve_diff.png';
saveas(gcf, save_path);

%% Difference of HL - NH in one plot + scanner noise spectrum
figure;

% Define a colormap for the number of bands
colors = jet(num_bands);

yyaxis left;

% Loop through each frequency band
for bandId = 1:num_bands
     % Extract tuning curve data for the current band
    fieldname_tunCurv = sprintf('tunCurv_band%d', bandId);
    
    % Initializing matrices to store data for NH and HL subjects separately
    data_NH = [];
    data_HL = [];
    
    for subjId = 1:num_subjects
        s = subjects{subjId};
        
        subject_data = zeros(1, num_bands);
        % For each band within the current band's panel
        for b = 1:num_bands
            band = sprintf('band%d', b);
            subject_data(b) = tunCurv_data.(fieldname_tunCurv).ave.(s)(b);
        end
        
        if is_HL(subjId)
            data_HL = [data_HL; subject_data];
        else
            data_NH = [data_NH; subject_data];
        end
    end
    
    % Average across subjects for NH and HL separately
    mean_curve_NH = mean(data_NH, 1);
    mean_curve_HL = mean(data_HL, 1);

     % Compute standard error of the mean (SEM) for NH and HL
    sem_NH = std(data_NH, 0, 1) / sqrt(size(data_NH, 1));
    sem_HL = std(data_HL, 0, 1) / sqrt(size(data_HL, 1));

    % Compute the difference between NH and HL
    difference_curve = mean_curve_HL - mean_curve_NH;
    
    % Compute the SEM for the difference
    sem_difference = sqrt(sem_NH.^2 + sem_HL.^2);

    % Plotting the difference curve with a color corresponding to the frequency band
    plot(difference_curve, 'Color', colors(bandId,:), 'LineWidth', 1.5, 'LineStyle', '-','Marker', 'none');
    hold on; % Keep the plot to overlay the next curves
end

% Set consistent Y-axis limits
ylim([-1 1]);

% Add x-axis and y-axis labels
xlabel('Frequency (kHz)');
h_ylabel = ylabel('Tuning curve difference (HL - NH)');

% Set the color of the ylabel to black
set(h_ylabel, 'Color', 'black');

% Set the current y-axis (left or right) color to black
set(gca, 'YColor', 'black');

% Add horizontal line at y=0
% line([1 num_bands], [0 0], 'Color', 'black', 'LineStyle', '--', 'LineWidth', 1);

yyaxis right;

f_scanNoise = nerb2f(nerb);
P1_dB_interpolated = interp1(f_scanNoise/1000, P1_dB, frq_nerb, 'linear', 'extrap');

scan_noise = plot(P1_dB_interpolated, 'Color', [0, 0, 0], 'LineWidth', 1,'LineStyle', '--');

h_ylabel = ylabel('Scanner Noise Magnitude (dB)');

% Set the color of the ylabel to black
set(h_ylabel, 'Color', 'black');

% Create a legend with labels indicating the frequency band
legendLabels = arrayfun(@(cf) sprintf('PF %.1f kHz', cf), frq_nerb, 'UniformOutput', false);

% Add the scan_noise label to the legend labels
legendLabels{end+1} = 'Scanner noise';

% Create the legend with all plot handles and the updated labels
legend(legendLabels, 'Location', 'northeastoutside');

% legend(legendLabels, 'Location', 'northeastoutside');

% Set the current y-axis (left or right) color to black
set(gca, 'YColor', 'black');

grid on;

% Set the x-axis to cover the range of bands
set(gca, 'XTick', 1:num_bands, 'XTickLabel', arrayfun(@(cf) sprintf('%.1f', cf), frq_nerb, 'UniformOutput', false));

% Adjust the figure's size and layout for better visualization
set(gcf, 'Position', [100, 100, 400, 500]);

% Save the figure to the specified folder and filename
save_path = '/Volumes/gdrive4tb/IGNITE/tonotopy/surface/keyFigures/tunCurv_scanNoise_HEAR_diff.png';
saveas(gcf, save_path);



%% Plot 1_scanner impact per each band: dual y axis with scanner noise magnitude

% figure;

% Frequency bands
bands = [0.250 0.454; 0.454 0.746; 0.746 1.162; 1.162 1.756; 1.756 2.604; 2.604 3.813; 3.813 5.538; 5.538 8.000];

% % Compute center frequency for each band in NERB
% centre_frequency = zeros(size(bands,1), 1);
% for i = 1:size(bands,1)
%     % nerb_edge1 = f2nerb(bands(i,1))
%     % nerb_edge2 = f2nerb(bands(i,2))
%     % centre_frequency(i) = (nerb_edge1 + nerb_edge2) / 2;
%     centre_frequency(i) = nerb2f(mean(f2nerb([bands(i,1) bands(i,2)])));
% end
% 
% % Calculating F1 and F2 for each BF
% F1 = zeros(size(centre_frequency,1), 1);
% F2 = zeros(size(centre_frequency,1), 1);
% for i = 1:size(centre_frequency,1)
%     F1(i) = nerb2f(f2nerb(centre_frequency(i,1)-0.5))
%     F2(i) = nerb2f(f2nerb(centre_frequency(i,1)+0.5))
% end

F1 = zeros(size(bands,1), 1);
F2 = zeros(size(bands,1), 1);
for i = 1:size(bands,1)
    F1(i) = bands(i,1)
    F2(i) = bands(i,2)
end


%%
% FFT spectrum
FS=51200;
repetitionLength = 3413;
N2 = 2^nextpow2(repetitionLength);
Psqr = avg_fft .^2; % Two-sided spectrum; power (squared magnitude)
% P2 = avg_fft / sqrt(N2); % Two-sided spectrum; linear
P1 = Psqr(1:N2/2+1); % Single-sided spectrum;
f = FS*(0:(N2/2))/N2; % Frequency vector

f_kHz = f/1000;

% Smooth the spectrum and convert to dB
P1_smooth = smoothdata(P1, 'movmean', 100);

% Normalize by dividing by the maximum magnitude in linear units
P1_normalized = P1_smooth / max(P1_smooth);

P1_dB = 10*log10(P1_normalized);

% Plot figure;
figure;
plot(f_kHz, P1_dB);
title('Magnitude of FFT of the Segment');
xlabel('Frequency (kHz)');
ylabel('Magnitude  (dB)'); %the magnitude of the FFT result
xlim([0 20]);

%%
% Frequency vector starting from 5 Hz
f = FS * (0:(N2/2)) / N2;
f(1) = 5;  % Set the first element to 5 Hz to avoid log of 0

% Convert to NERB scale
nerb = f2nerb(f);

% Plot the normalized magnitude spectrum in dB against NERB
figure;
plot(nerb, P1_dB);
title('Magnitude Spectrum');
xlabel('Frequency (kHz)');
ylabel('Magnitude (dB)');

% Set the x-axis ticks at octave-spaced frequencies
octave_freqs = [500, 1e3, 2e3, 4e3, 8e3, 16e3];  % Octave-spaced frequencies in Hz
octave_nerbs = f2nerb(octave_freqs);  % Convert to NERB scale

% Set the x-ticks and x-tick labels
set(gca, 'XTick', octave_nerbs, 'XTickLabel', arrayfun(@(f) sprintf('%.1f', f/1000), octave_freqs, 'UniformOutput', false));

%%
power_integrated = zeros(1, length(F1));
power_dB = zeros(1, length(F1));

% Find the nearest frequencies in the FFT spectrum to F1 and F2
for i = 1:size(F1,1)
    [~,idxF1] = min(abs(f_kHz-F1(i,1)))
    [~,idxF2] = min(abs(f_kHz-F2(i,1)))

    % Integrate the power spectrum across the band
    power_ERB(i) = sum(P1(idxF1:idxF2));

    % Convert integrated power to decibels
    power_dB(i) = 10 * log10(power_ERB(i));
end

power_ERB;
max_power_dB = max(power_dB)
power_dB
norm_power_dB = power_dB - max_power_dB

%%
figure;

% Define a colormap for the number of bands
colors = jet(num_bands);

yyaxis left;

% Loop through each frequency band
for bandId = 1:num_bands
     % Extract tuning curve data for the current band
    fieldname_tunCurv = sprintf('tunCurv_band%d', bandId);
    
    % Initializing matrices to store data for NH and HL subjects separately
    data_NH = [];
    data_HL = [];
    
    for subjId = 1:num_subjects
        s = subjects{subjId};
        
        subject_data = zeros(1, num_bands);
        % For each band within the current band's panel
        for b = 1:num_bands
            band = sprintf('band%d', b);
            subject_data(b) = tunCurv_data.(fieldname_tunCurv).ave.(s)(b);
        end
        
        if is_HL(subjId)
            data_HL = [data_HL; subject_data];
        else
            data_NH = [data_NH; subject_data];
        end
    end
    
    % Average across subjects for NH and HL separately
    mean_curve_NH = mean(data_NH, 1);
    mean_curve_HL = mean(data_HL, 1);

     % Compute standard error of the mean (SEM) for NH and HL
    sem_NH = std(data_NH, 0, 1) / sqrt(size(data_NH, 1));
    sem_HL = std(data_HL, 0, 1) / sqrt(size(data_HL, 1));

    % Compute the difference between NH and HL
    difference_curve = mean_curve_HL - mean_curve_NH;
    
    % Compute the SEM for the difference
    sem_difference = sqrt(sem_NH.^2 + sem_HL.^2);

    % Plotting the difference curve with a color corresponding to the frequency band
    plot(difference_curve, 'Color', colors(bandId,:), 'LineWidth', 1.5, 'LineStyle', '-','Marker', 'none');
    hold on; % Keep the plot to overlay the next curves
end

% Set consistent Y-axis limits
ylim([-1 1]);

% Add x-axis and y-axis labels
xlabel('Frequency (kHz)');
h_ylabel = ylabel('Tuning curve difference (HL - NH)');

% Set the color of the ylabel to black
set(h_ylabel, 'Color', 'black');

% Set the current y-axis (left or right) color to black
set(gca, 'YColor', 'black');

% Add horizontal line at y=0
% line([1 num_bands], [0 0], 'Color', 'black', 'LineStyle', '--', 'LineWidth', 1);

yyaxis right;

scan_noise = plot(norm_power_dB, 'Color', [0, 0, 0], 'LineWidth', 1,'LineStyle', '--');

h_ylabel = ylabel('Scanner Noise Magnitude (dB)');

% Set the color of the ylabel to black
set(h_ylabel, 'Color', 'black');

% Create a legend with labels indicating the frequency band
legendLabels = arrayfun(@(cf) sprintf('PF %.1f kHz', cf), frq_nerb, 'UniformOutput', false);

% Add the scan_noise label to the legend labels
legendLabels{end+1} = 'Scanner noise';

% Create the legend with all plot handles and the updated labels
legend(legendLabels, 'Location', 'northeastoutside');

% legend(legendLabels, 'Location', 'northeastoutside');

% Set the current y-axis (left or right) color to black
set(gca, 'YColor', 'black');

grid on;

% Set the x-axis to cover the range of bands
set(gca, 'XTick', 1:num_bands, 'XTickLabel', arrayfun(@(cf) sprintf('%.1f', cf), frq_nerb, 'UniformOutput', false));

% Adjust the figure's size and layout for better visualization
set(gcf, 'Position', [100, 100, 400, 500]);

% Save the figure to the specified folder and filename
save_path = '/Volumes/gdrive4tb/IGNITE/tonotopy/surface/keyFigures/tunCurv_POWER_scanNoise_HEAR_diff.png';
saveas(gcf, save_path);





%% Plot 1b: threshold values -- NH and HL

figure('Position', [100, 100, 400, 300]);

% Define the relevant frequencies and ears
frequencies = [250, 500, 1000, 2000, 3000, 4000, 6000, 8000, 9000, 10000, 11200, 12500, 14000, 16000];

% Frequencies in kHz for interpolation
frequencies_kHz = frequencies / 1000;

% Convert frequencies_kHz to NERB
frequencies_NERB = arrayfun(@(f) f2nerb(f), frequencies_kHz);
ears = {'R', 'L'};

% Initialize arrays to store averaged PTA values
HL_avg = zeros(1, length(frequencies));
NH_avg = zeros(1, length(frequencies));

HL_avg_all = [];
NH_avg_all = [];

% Loop over each frequency
for i = 1:length(frequencies)
    freq = frequencies(i);
    
    % Initialize temporary arrays to store PTA values for current frequency
    HL_values = [];
    NH_values = [];
    
    % Loop over each subject
    for subj = 1:length(data)
        % Compute the average PTA value across both ears for the current subject and frequency
        PTA_avg = (data(subj).(['PTA_', num2str(freq), '_R']) + data(subj).(['PTA_', num2str(freq), '_L'])) / 2;
        
        % Check if the subject has hearing loss or not and store the value accordingly
        if data(subj).is_HL
            HL_values = [HL_values, PTA_avg];
        else
            NH_values = [NH_values, PTA_avg];
        end
    end
    
    % Compute the average PTA value across all HL and NH subjects for the current frequency
    HL_avg(i) = mean(HL_values,"omitnan");
    NH_avg(i) = mean(NH_values,"omitnan");
    HL_sem(i) = std(HL_values,"omitnan") / sqrt(length(HL_values));
    NH_sem(i) = std(NH_values,"omitnan") / sqrt(length(NH_values));


end

% Plot the data with error bars and mean markers
errorbar(frequencies_NERB, NH_avg, NH_sem, 'bo-', 'LineWidth', 1.5, 'MarkerSize', 8, 'CapSize', 10); hold on;
errorbar(frequencies_NERB, HL_avg, HL_sem, 'ro-', 'LineWidth', 1.5, 'MarkerSize', 8, 'CapSize', 10);

% % Plot the data
% figure;
% plot(frequencies_kHz, HL_avg, 'r-', 'LineWidth', 1.5); hold on;
% plot(frequencies_kHz, NH_avg, 'b-', 'LineWidth', 1.5);
legend({sprintf('NH (N= %d)', count_NH), sprintf('HL (N= %d)', count_HL)}, ...
       'Location', 'southeastoutside');
xlabel('Frequency (kHz)');
ylabel('Hearing Level (dB HL)');

% Frequencies to be labeled (removed 10.0000, 11.2000, and 14.0000)
label_frequencies_kHz = [0.2500, 0.5000, 1.0000, 2.0000, 3.0000, 4.0000, 6.0000, 8.0000, 9.0000, 12.5000, 16.0000];

xticklabels_array = arrayfun(@(x) getLabel(x, label_frequencies_kHz), frequencies_kHz, 'UniformOutput', false);

xticks(frequencies_NERB);
xticklabels(xticklabels_array);

% Set y-axis limits
ylim([-10, 80]);

% Invert y-axis
set(gca, 'YDir', 'reverse');
set(gca, 'XTickLabelRotation', 45, 'FontSize', 14);

% title('Average hearing threshold');
grid on;
hold off;

% Save the figure to the specified folder and filename
save_path = '/Volumes/gdrive4tb/IGNITE/tonotopy/surface/keyFigures/hearStat_thres.png';
saveas(gcf, save_path);


%% Plot 1bb: threshold values -- NH and HL --differences

figure('Position', [100, 100, 500, 400]);

% Define the relevant frequencies and ears
frequencies = [250, 500, 1000, 2000, 3000, 4000, 6000, 8000, 9000, 10000, 11200, 12500, 14000, 16000];

% Frequencies in kHz for interpolation
frequencies_kHz = frequencies / 1000;

% Convert frequencies_kHz to NERB
frequencies_NERB = arrayfun(@(f) f2nerb(f), frequencies_kHz);
ears = {'R', 'L'};

% Initialize arrays to store averaged PTA values
HL_avg = zeros(1, length(frequencies));
NH_avg = zeros(1, length(frequencies));

% Loop over each frequency
for i = 1:length(frequencies)
    freq = frequencies(i);
    
    % Initialize temporary arrays to store PTA values for current frequency
    HL_values = [];
    NH_values = [];
    
    % Loop over each subject
    for subj = 1:length(data)
        % Compute the average PTA value across both ears for the current subject and frequency
        PTA_avg = (data(subj).(['PTA_', num2str(freq), '_R']) + data(subj).(['PTA_', num2str(freq), '_L'])) / 2;
        
        % Check if the subject has hearing loss or not and store the value accordingly
        if data(subj).is_HL
            HL_values = [HL_values, PTA_avg];
        else
            NH_values = [NH_values, PTA_avg];
        end
    end
    
    % Compute the average PTA value across all HL and NH subjects for the current frequency
    HL_avg(i) = mean(HL_values,"omitnan");
    NH_avg(i) = mean(NH_values,"omitnan");
    HL_sem(i) = std(HL_values,"omitnan") / sqrt(length(HL_values));
    NH_sem(i) = std(NH_values,"omitnan") / sqrt(length(NH_values));
end

% Compute the difference between NH and HL values and the combined SEM
difference_avg = HL_avg - NH_avg;
difference_sem = sqrt(NH_sem.^2 + HL_sem.^2);

% Plot the data with error bars for the difference
errorbar(frequencies_NERB, difference_avg, difference_sem, 'ko-', 'LineWidth', 1.5, 'MarkerSize', 8, 'CapSize', 10);

xlabel('Frequency (kHz)');
ylabel('Difference in Hearing Level (dB HL)');

% Frequencies to be labeled (removed 10.0000, 11.2000, and 14.0000)
label_frequencies_kHz = [0.2500, 0.5000, 1.0000, 2.0000, 3.0000, 4.0000, 6.0000, 8.0000, 9.0000, 12.5000, 16.0000];

xticklabels_array = arrayfun(@(x) getLabel(x, label_frequencies_kHz), frequencies_kHz, 'UniformOutput', false);

xticks(frequencies_NERB);
xticklabels(xticklabels_array);

% Set y-axis limits
ylim([0, 60]);

% Invert y-axis if you want to keep the format consistent with the original plot
set(gca, 'YDir', 'reverse');
set(gca, 'XTickLabelRotation', 45);

title('Hearing threshold differences NH and HL');

grid on;
hold off;



% Save the figure to the specified folder and filename
save_path = '/Volumes/gdrive4tb/IGNITE/tonotopy/surface/keyFigures/hearStat_thres_diff.png';
saveas(gcf, save_path);

%% Difference of HL - NH in one plot + threshold differences
figure;

% Define a colormap for the number of bands
colors = jet(num_bands);

yyaxis left;

% Loop through each frequency band
for bandId = 1:num_bands
     % Extract tuning curve data for the current band
    fieldname_tunCurv = sprintf('tunCurv_band%d', bandId);
    
    % Initializing matrices to store data for NH and HL subjects separately
    data_NH = [];
    data_HL = [];
    
    for subjId = 1:num_subjects
        s = subjects{subjId};
        
        subject_data = zeros(1, num_bands);
        % For each band within the current band's panel
        for b = 1:num_bands
            band = sprintf('band%d', b);
            subject_data(b) = tunCurv_data.(fieldname_tunCurv).ave.(s)(b);
        end
        
        if is_HL(subjId)
            data_HL = [data_HL; subject_data];
        else
            data_NH = [data_NH; subject_data];
        end
    end
    
    % Average across subjects for NH and HL separately
    mean_curve_NH = mean(data_NH, 1);
    mean_curve_HL = mean(data_HL, 1);

     % Compute standard error of the mean (SEM) for NH and HL
    sem_NH = std(data_NH, 0, 1) / sqrt(size(data_NH, 1));
    sem_HL = std(data_HL, 0, 1) / sqrt(size(data_HL, 1));

    % Compute the difference between NH and HL
    difference_curve = mean_curve_HL - mean_curve_NH;
    
    % Compute the SEM for the difference
    sem_difference = sqrt(sem_NH.^2 + sem_HL.^2);

    % Plotting the difference curve with a color corresponding to the frequency band
    plot(difference_curve, 'Color', colors(bandId,:), 'LineWidth', 1.5, 'LineStyle', '-','Marker', 'none');
    hold on; % Keep the plot to overlay the next curves
end

% Set consistent Y-axis limits
ylim([-1 1]);

% Add x-axis and y-axis labels
xlabel('Frequency (kHz)');
h_ylabel = ylabel('Tuning curve difference (HL - NH)');

% Set the color of the ylabel to black
set(h_ylabel, 'Color', 'black');

% Set the current y-axis (left or right) color to black
set(gca, 'YColor', 'black');

% Add horizontal line at y=0
% line([1 num_bands], [0 0], 'Color', 'black', 'LineStyle', '--', 'LineWidth', 1);

yyaxis right;

thresh_diff = plot(difference_avg(1:8), 'Color', [0, 0, 0], 'LineWidth', 1,'LineStyle', '--');

h_ylabel = ylabel('Hearing Threshold Difference (NH - HL)');

% Set the color of the ylabel to black
set(h_ylabel, 'Color', 'black');

% Create a legend with labels indicating the frequency band
legendLabels = arrayfun(@(cf) sprintf('PF %.1f kHz', cf), frq_nerb, 'UniformOutput', false);

% Add the scan_noise label to the legend labels
legendLabels{end+1} = 'Hearing Threshold (dB HL)';

% Create the legend with all plot handles and the updated labels
legend(legendLabels, 'Location', 'northeastoutside');

% Set y-axis limits
ylim([0, 50]);

% Set the current y-axis (left or right) color to black
set(gca, 'YColor', 'black');

% set(gca, 'YDir', 'reverse');

grid on;

% Set the x-axis to cover the range of bands
set(gca, 'XTick', 1:num_bands, 'XTickLabel', arrayfun(@(cf) sprintf('%.1f', cf), frq_nerb, 'UniformOutput', false));

% Adjust the figure's size and layout for better visualization
set(gcf, 'Position', [100, 100, 450, 500]);

% Save the figure to the specified folder and filename
save_path = '/Volumes/gdrive4tb/IGNITE/tonotopy/surface/keyFigures/tunCurv_thresh_HEAR_diff.png';
saveas(gcf, save_path);


%% Plot 2a: tuning curve -- TIN and noTIN

% Determine NT and TT groups based on subjectID
is_NT = contains(subjects, 'NT');
is_TT = contains(subjects, 'TT');

% Setting up the figure
figure;

% Frequency bands
bands = [0.250 0.454; 0.454 0.746; 0.746 1.162; 1.162 1.756; 1.756 2.604; 2.604 3.813; 3.813 5.538; 5.538 8.000];

% Compute center frequency for each band in NERB
centre_frequency = zeros(size(bands,1), 1);
for i = 1:size(bands,1)
    nerb_edge1 = f2nerb(bands(i,1));
    nerb_edge2 = f2nerb(bands(i,2));
    centre_frequency(i) = (nerb_edge1 + nerb_edge2) / 2;
end

frq_nerb = nerb2f(centre_frequency);
num_bands = numel(centre_frequency);

% Define colors for the plot
curveColorNT = [0 0 1]; % Blue for NT curve
curveColorTT = [1 0 0]; % Red for TT curve

% Max and min for Y axis
maxY = 2.5; 
minY = 0;

% Loop through each frequency band (i.e., each panel in your figure)
for bandId = 1:num_bands
    subplot(1, num_bands, bandId);
    
    % Extract tuning curve data for the current band
    fieldname_tunCurv = sprintf('tunCurv_band%d', bandId);
    
    % Initializing matrices to store data for NT and TT subjects separately
    data_NT = [];
    data_TT = [];
    
    for subjId = 1:num_subjects
        s = subjects{subjId};
        
        subject_data = zeros(1, num_bands);
        % For each band within the current band's panel
        for b = 1:num_bands
            band = sprintf('band%d', b);
            subject_data(b) = tunCurv_data.(fieldname_tunCurv).ave.(s)(b);
        end
        
        if is_TT(subjId)
            data_TT = [data_TT; subject_data];
        else
            data_NT = [data_NT; subject_data];
        end
    end
    
    % Average across subjects for NT and TT separately
    mean_curve_NT = mean(data_NT, 1);
    mean_curve_TT = mean(data_TT, 1);

    % Compute standard error of the mean (SEM) for NT and TT
    sem_NT = std(data_NT, 0, 1) / sqrt(size(data_NT, 1));
    sem_TT = std(data_TT, 0, 1) / sqrt(size(data_TT, 1));
    
    % Plotting with error bars
    % errorbar(mean_curve_NT, sem_NT, 'Color', curveColorNT, 'LineWidth', 1.5); 
    % hold on; % Keep the NT plot to overlay the TT plot
    % errorbar(mean_curve_TT, sem_TT, 'Color', curveColorTT, 'LineWidth', 1.5);

    % Plotting WITHOUT error bars
    plot(mean_curve_NT, 'Color', curveColorNT, 'LineWidth', 1.5);
    hold on; % Keep the NH plot to overlay the HL plot
    plot(mean_curve_TT, 'Color', curveColorTT, 'LineWidth', 1.5);

    % Plot the custom error lines
    for b = 1:num_bands
        if mean_curve_NT(b) > mean_curve_TT(b)
            % NH error goes up
            plot([b b], [mean_curve_NT(b) mean_curve_NT(b)+sem_NT(b)], 'Color', curveColorNT, 'LineWidth', 0.8);
            % HL error goes down
            plot([b b], [mean_curve_TT(b) mean_curve_HL(b)-sem_TT(b)], 'Color', curveColorTT, 'LineWidth', 0.8);
        else
            % NH error goes down
            plot([b b], [mean_curve_NT(b) mean_curve_NT(b)-sem_NT(b)], 'Color', curveColorNT, 'LineWidth', 0.8);
            % HL error goes up
            plot([b b], [mean_curve_TT(b) mean_curve_HL(b)+sem_TT(b)], 'Color', curveColorTT, 'LineWidth', 0.8);
        end
    end
    
    % Add dashed black line for the current band
    line([bandId bandId], [minY maxY], 'Color', [0 0 0], 'LineStyle', '--','LineWidth', 1);
    
    hold off; % Release the hold to allow for other plotting operations
    
    % Set x-axis labels and title with modified requirements
    set(gca, 'XTick', [1, ceil(num_bands/2), num_bands], 'XTickLabel', ...
        {sprintf('%.1f kHz', frq_nerb(1)), sprintf('%.1f kHz', frq_nerb(ceil(num_bands/2))), ...
        sprintf('%.1f kHz', frq_nerb(num_bands))}, 'XTickLabelRotation', 45, ...
        'FontSize', 14);
    title(sprintf('%.1f kHz', frq_nerb(bandId)));
    
    % Set consistent Y-axis limits for all panels
    ylim([minY maxY]);
    
    % Display the Y-axis label only for the first panel
    if bandId > 1
        set(gca, 'YTickLabel', [],'FontSize', 14);
    else
        ylabel('Response size (%sc)');
    end

    grid on;
end

% Add legend
% legend('NT', 'TT');
% legend({sprintf('NoTin (N= %d)', count_NT), sprintf('Tin (N= %d)', count_TT)}, ...
%        'Location', 'southeast');

% Adjust axes positions
for ax = 1:num_bands
    pos = get(subplot(1, num_bands, ax), 'Position');
    set(subplot(1, num_bands, ax), 'Position', [pos(1) pos(2)+0.1 pos(3) pos(4)-0.1]);
end
    
% Add a centralized xlabel for the entire figure
figH = gcf;
axes('Parent',figH,'Position',[.1 .1 .8 .8],'Visible','off');
text(0.5, -0.09, 'Frequency (kHz)', 'FontSize', 14, 'HorizontalAlignment', 'center');

% Adjust the figure's size and layout for better visualization
set(gcf, 'Position', [100, 100, 800, 300]);

% Save the figure to the specified folder and filename
save_path = '/Volumes/gdrive4tb/IGNITE/tonotopy/surface/keyFigures/tinStat_tuning_curve_halferrb.png';
saveas(gcf, save_path);


%% Plot 2aa: tuning curve -- TIN and noTIN --differences

% Setting up the figure
figure;

% Frequency bands
bands = [0.250 0.454; 0.454 0.746; 0.746 1.162; 1.162 1.756; 1.756 2.604; 2.604 3.813; 3.813 5.538; 5.538 8.000];

% Compute center frequency for each band in NERB
centre_frequency = zeros(size(bands,1), 1);
for i = 1:size(bands,1)
    nerb_edge1 = f2nerb(bands(i,1));
    nerb_edge2 = f2nerb(bands(i,2));
    centre_frequency(i) = (nerb_edge1 + nerb_edge2) / 2;
end

frq_nerb = nerb2f(centre_frequency);
num_bands = numel(centre_frequency);

% Define colors for the plot
curveColorNT = [0 0 1]; % Blue for NT curve
curveColorTT = [1 0 0]; % Red for TT curve

% Max and min for Y axis
maxY = 2.5; 
minY = 0;

% Loop through each frequency band (i.e., each panel in your figure)
for bandId = 1:num_bands
    subplot(1, num_bands, bandId);
    
    % Extract tuning curve data for the current band
    fieldname_tunCurv = sprintf('tunCurv_band%d', bandId);
    
    % Initializing matrices to store data for NT and TT subjects separately
    data_NT = [];
    data_TT = [];
    
    for subjId = 1:num_subjects
        s = subjects{subjId};
        
        subject_data = zeros(1, num_bands);
        % For each band within the current band's panel
        for b = 1:num_bands
            band = sprintf('band%d', b);
            subject_data(b) = tunCurv_data.(fieldname_tunCurv).ave.(s)(b);
        end
        
        if is_TT(subjId)
            data_TT = [data_TT; subject_data];
        else
            data_NT = [data_NT; subject_data];
        end
    end
    
    % Average across subjects for NT and TT separately
    mean_curve_NT = mean(data_NT, 1);
    mean_curve_TT = mean(data_TT, 1);

    % Compute standard error of the mean (SEM) for NT and TT
    sem_NT = std(data_NT, 0, 1) / sqrt(size(data_NT, 1));
    sem_TT = std(data_TT, 0, 1) / sqrt(size(data_TT, 1));

    % Compute the difference between NT and TT
    difference_curve = mean_curve_TT - mean_curve_NT;
    
    % Compute the SEM for the difference
    sem_difference = sqrt(sem_NT.^2 + sem_TT.^2);
    
    % Plotting the difference curve WITHOUT error bars
    plot(difference_curve, 'k-', 'LineWidth', 1.5);
    
    hold on; % Keep the difference plot

    % Plot the custom error lines for the difference
    for b = 1:num_bands
        plot([b b], [difference_curve(b) difference_curve(b)+sem_difference(b)], 'k-', 'LineWidth', 0.8);
        plot([b b], [difference_curve(b) difference_curve(b)-sem_difference(b)], 'k-', 'LineWidth', 0.8);
    end
    
    % Add horizontal line at y=0
    line([1 num_bands], [0 0], 'Color', 'black', 'LineStyle', '--', 'LineWidth', 1);

    % Add dashed black line for the current band
    line([bandId bandId], [-1 1], 'Color', [0 0 0], 'LineStyle', '--','LineWidth', 1);
    
    hold off; % Release the hold to allow for other plotting operations
    
    % Set x-axis labels and title with modified requirements
    set(gca, 'XTick', [1, ceil(num_bands/2), num_bands], 'XTickLabel', ...
        {sprintf('%.1f kHz', frq_nerb(1)), sprintf('%.1f kHz', frq_nerb(ceil(num_bands/2))), ...
        sprintf('%.1f kHz', frq_nerb(num_bands))}, 'XTickLabelRotation', 45, ...
        'FontSize', 14);
    title(sprintf('%.1f kHz', frq_nerb(bandId)));

    
    % Set consistent Y-axis limits for all panels
    ylim([-1 1]);
    
     % Display the Y-axis label only for the first panel
    if bandId == 1
        ylabel('Tuning curve difference (TT - NT)','FontSize', 14);
    else
        set(gca, 'YTickLabel', []);
    end

    grid on;
end

% Adjust axes positions
for ax = 1:num_bands
    pos = get(subplot(1, num_bands, ax), 'Position');
    set(subplot(1, num_bands, ax), 'Position', [pos(1) pos(2)+0.1 pos(3) pos(4)-0.1]);
end
    
% Add a centralized xlabel for the entire figure
figH = gcf;
axes('Parent',figH,'Position',[.1 .1 .8 .8],'Visible','off');
text(0.5, -0.09, 'Frequency (kHz)', 'FontSize', 14, 'HorizontalAlignment', 'center');


% Adjust the figure's size and layout for better visualization
set(gcf, 'Position', [100, 100, 800, 300]);

% Save the figure to the specified folder and filename
save_path = '/Volumes/gdrive4tb/IGNITE/tonotopy/surface/keyFigures/tinStat_tuning_curve_diff.png';
saveas(gcf, save_path);


%% Plot 2b: threshold values -- TT and NT

figure('Position', [100, 100, 400, 300]);

% Define the relevant frequencies and ears
frequencies = [250, 500, 1000, 2000, 3000, 4000, 6000, 8000, 9000, 10000, 11200, 12500, 14000, 16000];

% Frequencies in kHz for interpolation
frequencies_kHz = frequencies / 1000;

% Convert frequencies_kHz to NERB
frequencies_NERB = arrayfun(@(f) f2nerb(f), frequencies_kHz);
ears = {'R', 'L'};

% Initialize arrays to store averaged PTA values
HL_avg = zeros(1, length(frequencies));
NH_avg = zeros(1, length(frequencies));

% Loop over each frequency
for i = 1:length(frequencies)
    freq = frequencies(i);
    
    % Initialize temporary arrays to store PTA values for current frequency
    TT_values = [];
    NT_values = [];
    
    % Loop over each subject
    for subj = 1:length(data)
        % Compute the average PTA value across both ears for the current subject and frequency
        PTA_avg = (data(subj).(['PTA_', num2str(freq), '_R']) + data(subj).(['PTA_', num2str(freq), '_L'])) / 2;
        
        % Check if the subject has hearing loss or not and store the value accordingly
        if is_TT(subj)
            TT_values = [TT_values, PTA_avg];
        else
            NT_values = [NT_values, PTA_avg];
        end
    end
    
    % Compute the average PTA value across all HL and NH subjects for the current frequency
    TT_avg(i) = mean(TT_values,"omitnan");
    NT_avg(i) = mean(NT_values,"omitnan");
    TT_sem(i) = std(TT_values,"omitnan") / sqrt(length(TT_values));
    NT_sem(i) = std(NT_values,"omitnan") / sqrt(length(NT_values));
end

% Plot the data with error bars and mean markers
errorbar(frequencies_NERB, NT_avg, NT_sem, 'bo-', 'LineWidth', 1.5, 'MarkerSize', 8, 'CapSize', 10); hold on;
errorbar(frequencies_NERB, TT_avg, TT_sem, 'ro-', 'LineWidth', 1.5, 'MarkerSize', 8, 'CapSize', 10);

% % Plot the data
% figure;
% plot(frequencies_kHz, HL_avg, 'r-', 'LineWidth', 1.5); hold on;
% plot(frequencies_kHz, NH_avg, 'b-', 'LineWidth', 1.5);
legend({sprintf('NT (N= %d)', count_NT), sprintf('TT (N= %d)', count_TT)}, ...
       'Location', 'southeastoutside');
xlabel('Frequency (kHz)');
ylabel('Hearing Level (dB HL)');

% Frequencies to be labeled (removed 10.0000, 11.2000, and 14.0000)
label_frequencies_kHz = [0.2500, 0.5000, 1.0000, 2.0000, 3.0000, 4.0000, 6.0000, 8.0000, 9.0000, 12.5000, 16.0000];

xticklabels_array = arrayfun(@(x) getLabel(x, label_frequencies_kHz), frequencies_kHz, 'UniformOutput', false);

xticks(frequencies_NERB);
xticklabels(xticklabels_array);

% Set y-axis limits
ylim([-10, 80]);

% Invert y-axis
set(gca, 'YDir', 'reverse');
set(gca, 'XTickLabelRotation', 45, 'FontSize', 14);

% title('Average hearing threshold');
grid on;
hold off;

% Save the figure to the specified folder and filename
save_path = '/Volumes/gdrive4tb/IGNITE/tonotopy/surface/keyFigures/tinStat_thres.png';
saveas(gcf, save_path);

%% Plot 2bb: threshold values -- TT and NT --differences

figure('Position', [100, 100, 500, 400]);

% Define the relevant frequencies and ears
frequencies = [250, 500, 1000, 2000, 3000, 4000, 6000, 8000, 9000, 10000, 11200, 12500, 14000, 16000];

% Frequencies in kHz for interpolation
frequencies_kHz = frequencies / 1000;

% Convert frequencies_kHz to NERB
frequencies_NERB = arrayfun(@(f) f2nerb(f), frequencies_kHz);
ears = {'R', 'L'};

% Initialize arrays to store averaged PTA values
HL_avg = zeros(1, length(frequencies));
NH_avg = zeros(1, length(frequencies));

% Loop over each frequency
for i = 1:length(frequencies)
    freq = frequencies(i);
    
    % Initialize temporary arrays to store PTA values for current frequency
    TT_values = [];
    NT_values = [];
    
    % Loop over each subject
    for subj = 1:length(data)
        % Compute the average PTA value across both ears for the current subject and frequency
        PTA_avg = (data(subj).(['PTA_', num2str(freq), '_R']) + data(subj).(['PTA_', num2str(freq), '_L'])) / 2;
        
        % Check if the subject has hearing loss or not and store the value accordingly
        if is_TT(subj)
            TT_values = [TT_values, PTA_avg];
        else
            NT_values = [NT_values, PTA_avg];
        end
    end
    
    % Compute the average PTA value across all HL and NH subjects for the current frequency
    TT_avg(i) = mean(TT_values,"omitnan");
    NT_avg(i) = mean(NT_values,"omitnan");
    TT_sem(i) = std(TT_values,"omitnan") / sqrt(length(TT_values));
    NT_sem(i) = std(NT_values,"omitnan") / sqrt(length(NT_values));
end

% Compute the difference between NT and TT values and the combined SEM
difference_avg = NT_avg - TT_avg;
difference_sem = sqrt(NT_sem.^2 + TT_sem.^2);

% Plot the data with error bars for the difference
errorbar(frequencies_NERB, difference_avg, difference_sem, 'ko-', 'LineWidth', 1.5, 'MarkerSize', 8, 'CapSize', 10);

xlabel('Frequency (kHz)');
ylabel('Difference in Hearing Level (dB HL)');

% Frequencies to be labeled (removed 10.0000, 11.2000, and 14.0000)
label_frequencies_kHz = [0.2500, 0.5000, 1.0000, 2.0000, 3.0000, 4.0000, 6.0000, 8.0000, 9.0000, 12.5000, 16.0000];

xticklabels_array = arrayfun(@(x) getLabel(x, label_frequencies_kHz), frequencies_kHz, 'UniformOutput', false);

xticks(frequencies_NERB);
xticklabels(xticklabels_array);

% Set y-axis limits
ylim([-60, 0]);

% Invert y-axis if you want to keep the format consistent with the original plot
set(gca, 'YDir', 'reverse');
set(gca, 'XTickLabelRotation', 45);

title('Hearing threshold differences Tin and NoTin');

grid on;
hold off;
% Save the figure to the specified folder and filename
save_path = '/Volumes/gdrive4tb/IGNITE/tonotopy/surface/keyFigures/tinStat_thres_diff.png';
saveas(gcf, save_path);


%% Plot 3a: tuning curve -- TIN and noTIN with NH and HL

% Frequency bands
bands = [0.250 0.454; 0.454 0.746; 0.746 1.162; 1.162 1.756; 1.756 2.604; 2.604 3.813; 3.813 5.538; 5.538 8.000];

% Compute center frequency for each band in NERB
centre_frequency = zeros(size(bands,1), 1);
for i = 1:size(bands,1)
    nerb_edge1 = f2nerb(bands(i,1));
    nerb_edge2 = f2nerb(bands(i,2));
    centre_frequency(i) = (nerb_edge1 + nerb_edge2) / 2;
end

frq_nerb = nerb2f(centre_frequency);
num_bands = numel(centre_frequency);

is_NH_NT = is_NH_ageDep & is_NT';
is_NH_TT = is_NH_ageDep & is_TT';
is_HL_NT = is_HL_ageDep & is_NT';
is_HL_TT = is_HL_ageDep & is_TT';

% Setting up the figure
figure;

% Define colors for each group
curveColorNH_NT = [0.1 0.1 1]; % Darker Blue for NH_NT
curveColorNH_TT = [0.7 0.7 1]; % Lighter Blue for NH_TT
curveColorHL_NT = [1 0.1 0.1]; % Darker Red for HL_NT
curveColorHL_TT = [1 0.7 0.7]; % Lighter Red for HL_TT

% Max and min for Y axis
maxY = 3; 
minY = 0;

for bandId = 1:num_bands
    subplot(1, num_bands, bandId);

    % Extract tuning curve data for the current band
    fieldname_tunCurv = sprintf('tunCurv_band%d', bandId);

    % Separate the data for each group
    data_NH_NT = [];
    data_NH_TT = [];
    data_HL_NT = [];
    data_HL_TT = [];

    for subjId = 1:num_subjects
        s = subjects{subjId};

        subject_data = zeros(1, num_bands);
        % For each band within the current band's panel
        for b = 1:num_bands
            band = sprintf('band%d', b);
            subject_data(b) = tunCurv_data.(fieldname_tunCurv).ave.(s)(b);
        end

        if is_NH_NT(subjId)
            data_NH_NT = [data_NH_NT; subject_data];
        elseif is_NH_TT(subjId)
            data_NH_TT = [data_NH_TT; subject_data];
        elseif is_HL_NT(subjId)
            data_HL_NT = [data_HL_NT; subject_data];
        else % if is_HL_TT
            data_HL_TT = [data_HL_TT; subject_data];
        end
    end

    % Calculate means and SEMs for each group
    mean_curve_NH_NT = mean(data_NH_NT, 1);
    sem_NH_NT = std(data_NH_NT, 0, 1) / sqrt(size(data_NH_NT, 1));

    mean_curve_NH_TT = mean(data_NH_TT, 1);
    sem_NH_TT = std(data_NH_TT, 0, 1) / sqrt(size(data_NH_TT, 1));

    mean_curve_HL_NT = mean(data_HL_NT, 1);
    sem_HL_NT = std(data_HL_NT, 0, 1) / sqrt(size(data_HL_NT, 1));

    mean_curve_HL_TT = mean(data_HL_TT, 1);
    sem_HL_TT = std(data_HL_TT, 0, 1) / sqrt(size(data_HL_TT, 1));

    % % Plot each group with error bars
    % errorbar(mean_curve_NH_NT, sem_NH_NT, 'Color', curveColorNH_NT, 'LineWidth', 1.5); hold on;
    % errorbar(mean_curve_NH_TT, sem_NH_TT, 'Color', curveColorNH_TT, 'LineWidth', 1.5); hold on;
    % errorbar(mean_curve_HL_NT, sem_HL_NT, 'Color', curveColorHL_NT, 'LineWidth', 1.5); hold on;
    % errorbar(mean_curve_HL_TT, sem_HL_TT, 'Color', curveColorHL_TT, 'LineWidth', 1.5); hold on;

    % Plotting WITHOUT error bars
    plot(mean_curve_NH_NT, 'Color', curveColorNH_NT, 'LineWidth', 1.5);
    hold on; % Keep the NH plot to overlay the HL plot
    plot(mean_curve_NH_TT, 'Color', curveColorNH_TT, 'LineWidth', 1.5);
    plot(mean_curve_HL_NT, 'Color', curveColorHL_NT, 'LineWidth', 1.5);
    plot(mean_curve_HL_TT, 'Color', curveColorHL_TT, 'LineWidth', 1.5);

    % Add dashed black line for the current band
    line([bandId bandId], [minY maxY], 'Color', [0 0 0], 'LineStyle', '--','LineWidth', 1);
    
    hold off; % Release the hold to allow for other plotting operations
    
    % Set x-axis labels and title with modified requirements
    set(gca, 'XTick', [1, ceil(num_bands/2), num_bands], 'XTickLabel', ...
        {sprintf('%.1f kHz', frq_nerb(1)), sprintf('%.1f kHz', frq_nerb(ceil(num_bands/2))), ...
        sprintf('%.1f kHz', frq_nerb(num_bands))}, 'XTickLabelRotation', 45, ...
        'FontSize', 14);
    title(sprintf('%.1f kHz', frq_nerb(bandId)));
    
    % Set consistent Y-axis limits for all panels
    ylim([minY maxY]);
    
    % Display the Y-axis label only for the first panel
    if bandId > 1
        set(gca, 'YTickLabel', [], 'FontSize', 14);
    else
        ylabel('Response size (%sc)');
    end

    grid on;

end

% Add a legend for the four groups
% legend('NH NT', 'NH TT', 'HL NT', 'HL TT');

% legend({sprintf('NH NoTin (N= %d)', count_NH_with_NT_ageDep), sprintf('NH Tin (N= %d)', count_NH_with_TT_ageDep), sprintf('HL NoTin (N= %d)', count_HL_with_NT_ageDep), sprintf('HL Tin (N= %d)', count_HL_with_TT_ageDep)}, ...
%        'Location', 'northeast');

% Adjust axes positions
for ax = 1:num_bands
    pos = get(subplot(1, num_bands, ax), 'Position');
    set(subplot(1, num_bands, ax), 'Position', [pos(1) pos(2)+0.1 pos(3) pos(4)-0.1]);
end
    
% Add a centralized xlabel for the entire figure
figH = gcf;
axes('Parent',figH,'Position',[.1 .1 .8 .8],'Visible','off');
text(0.5, -0.09, 'Frequency (kHz)', 'FontSize', 14, 'HorizontalAlignment', 'center');

% Adjust the figure's size and layout for better visualization
set(gcf, 'Position', [100, 100, 800, 300]);

% Save the figure to the specified folder and filename
save_path = '/Volumes/gdrive4tb/IGNITE/tonotopy/surface/keyFigures/hearStat_tinStat_tuning_curve.png';
saveas(gcf, save_path);


%% Plot 3b: threshold values -- NH and HL -- TT and NT

figure('Position', [100, 100, 400, 300]);

curveColorNH_NT = [0.1 0.1 1]; % Darker Blue for NH_NT
curveColorNH_TT = [0.7 0.7 1]; % Lighter Blue for NH_TT
curveColorHL_NT = [1 0.1 0.1]; % Darker Red for HL_NT
curveColorHL_TT = [1 0.7 0.7]; % Lighter Red for HL_TT

is_NH_NT = is_NH_ageDep & is_NT';
is_NH_TT = is_NH_ageDep & is_TT';
is_HL_NT = is_HL_ageDep & is_NT';
is_HL_TT = is_HL_ageDep & is_TT';

% Define the relevant frequencies and ears
frequencies = [250, 500, 1000, 2000, 3000, 4000, 6000, 8000, 9000, 10000, 11200, 12500, 14000, 16000];

% Frequencies in kHz for interpolation
frequencies_kHz = frequencies / 1000;

% Convert frequencies_kHz to NERB
frequencies_NERB = arrayfun(@(f) f2nerb(f), frequencies_kHz);
ears = {'R', 'L'};

% Initialize arrays to store averaged PTA values
HL_avg = zeros(1, length(frequencies));
NH_avg = zeros(1, length(frequencies));

% Loop over each frequency
for i = 1:length(frequencies)
    freq = frequencies(i);
    
    % Initialize temporary arrays to store PTA values for current frequency
    data_NH_NT = [];
    data_NH_TT = [];
    data_HL_NT = [];
    data_HL_TT = [];
    
    % Loop over each subject
    for subj = 1:length(data)
        % Compute the average PTA value across both ears for the current subject and frequency
        PTA_avg = (data(subj).(['PTA_', num2str(freq), '_R']) + data(subj).(['PTA_', num2str(freq), '_L'])) / 2;
        
        % Check if the subject has hearing loss or not and store the value accordingly
        if is_NH_NT(subj)
            data_NH_NT = [data_NH_NT; PTA_avg];
        elseif is_NH_TT(subj)
            data_NH_TT = [data_NH_TT; PTA_avg];
        elseif is_HL_NT(subj)
            data_HL_NT = [data_HL_NT; PTA_avg];
        else % if is_HL_TT
            data_HL_TT = [data_HL_TT; PTA_avg];
        end
    end
    
    % Compute the average PTA value across all HL and NH subjects for the current frequency
    NH_NT_avg(i) = mean(data_NH_NT,"omitnan");
    NH_TT_avg(i) = mean(data_NH_TT,"omitnan");
    HL_NT_avg(i) = mean(data_HL_NT,"omitnan");
    HL_TT_avg(i) = mean(data_HL_TT,"omitnan");
    NH_NT_sem(i) = std(data_NH_NT,"omitnan") / sqrt(length(data_NH_NT));
    NH_TT_sem(i) = std(data_NH_TT,"omitnan") / sqrt(length(data_NH_TT));
    HL_NT_sem(i) = std(data_HL_NT,"omitnan") / sqrt(length(data_HL_NT));
    HL_TT_sem(i) = std(data_HL_TT,"omitnan") / sqrt(length(data_HL_TT));
end

% Plot the data with error bars and mean markers using the new colors
errorbar(frequencies_NERB, NH_NT_avg, NH_NT_sem, 'o-', 'LineWidth', 1.5, 'MarkerSize', 8, 'CapSize', 10, 'Color', curveColorNH_NT); hold on;
errorbar(frequencies_NERB, NH_TT_avg, NH_TT_sem, 'o-', 'LineWidth', 1.5, 'MarkerSize', 8, 'CapSize', 10, 'Color', curveColorNH_TT);
errorbar(frequencies_NERB, HL_NT_avg, HL_NT_sem, 'o-', 'LineWidth', 1.5, 'MarkerSize', 8, 'CapSize', 10, 'Color', curveColorHL_NT);
errorbar(frequencies_NERB, HL_TT_avg, HL_TT_sem, 'o-', 'LineWidth', 1.5, 'MarkerSize', 8, 'CapSize', 10, 'Color', curveColorHL_TT);

% % Plot the data
% figure;
% plot(frequencies_kHz, HL_avg, 'r-', 'LineWidth', 1.5); hold on;
% plot(frequencies_kHz, NH_avg, 'b-', 'LineWidth', 1.5);
legend({sprintf('NH NoTin (N= %d)', count_NH_with_NT_ageDep), sprintf('NH Tin (N= %d)', count_NH_with_TT_ageDep), ...
    sprintf('HL NoTin (N= %d)', count_HL_with_NT_ageDep), sprintf('HL Tin (N= %d)', count_HL_with_TT_ageDep)}, ...
       'Location', 'southeastoutside');
xlabel('Frequency (kHz)');
ylabel('Hearing Level (dB HL)');

% Frequencies to be labeled (removed 10.0000, 11.2000, and 14.0000)
label_frequencies_kHz = [0.2500, 0.5000, 1.0000, 2.0000, 3.0000, 4.0000, 6.0000, 8.0000, 9.0000, 12.5000, 16.0000];

xticklabels_array = arrayfun(@(x) getLabel(x, label_frequencies_kHz), frequencies_kHz, 'UniformOutput', false);

xticks(frequencies_NERB);
xticklabels(xticklabels_array);

% Set y-axis limits
ylim([-10, 80]);

% Invert y-axis
set(gca, 'YDir', 'reverse');
set(gca, 'XTickLabelRotation', 45, 'FontSize', 14);

% title('Average hearing threshold');
grid on;
hold off;

% Save the figure to the specified folder and filename
save_path = '/Volumes/gdrive4tb/IGNITE/tonotopy/surface/keyFigures/hearStat_tinStat_thres.png';
saveas(gcf, save_path);

%% Plot 3c: threshold values -- NH and HL -- age group

figure('Position', [100, 100, 400, 300]);

% Definitions
colors = struct('young', 'k', 'mid', 'b', 'older', 'r');
lineStyles = struct('NH', '-', 'HL', '--');

is_young_NH = strcmp({data.age_group}, 'young') & ([data.is_HL_ageDep] == 0);
is_mid_NH = strcmp({data.age_group}, 'mid') & ([data.is_HL_ageDep] == 0);
is_older_NH = strcmp({data.age_group}, 'older') & ([data.is_HL_ageDep] == 0);
is_young_HL = strcmp({data.age_group}, 'young') & ([data.is_HL_ageDep] == 1);
is_mid_HL = strcmp({data.age_group}, 'mid') & ([data.is_HL_ageDep] == 1);
is_older_HL = strcmp({data.age_group}, 'older') & ([data.is_HL_ageDep] == 1);

% Define the relevant frequencies and ears
frequencies = [250, 500, 1000, 2000, 3000, 4000, 6000, 8000, 9000, 10000, 11200, 12500, 14000, 16000];

% Frequencies in kHz for interpolation
frequencies_kHz = frequencies / 1000;

% Convert frequencies_kHz to NERB
frequencies_NERB = arrayfun(@(f) f2nerb(f), frequencies_kHz);
ears = {'R', 'L'};

% Initialize arrays to store averaged PTA values
HL_avg = zeros(1, length(frequencies));
NH_avg = zeros(1, length(frequencies));

% Loop over each frequency
for i = 1:length(frequencies)
    freq = frequencies(i);
    
    % Initialize temporary arrays to store PTA values for current frequency
    data_young_NH = [];
    data_mid_NH = [];
    data_older_NH = [];
    data_young_HL = [];
    data_mid_HL = [];
    data_older_HL = [];
    
    % Loop over each subject
    for subj = 1:length(data)
        % Compute the average PTA value across both ears for the current subject and frequency
        PTA_avg = (data(subj).(['PTA_', num2str(freq), '_R']) + data(subj).(['PTA_', num2str(freq), '_L'])) / 2;
        
        % Check if the subject has hearing loss or not and store the value accordingly
        if is_young_NH(subj)
            data_young_NH = [data_young_NH; PTA_avg];
        elseif is_mid_NH(subj)
            data_mid_NH = [data_mid_NH; PTA_avg];
        elseif is_older_NH(subj)
            data_older_NH = [data_older_NH; PTA_avg];
        elseif is_young_HL(subj)
            data_young_HL = [data_young_HL; PTA_avg];
        elseif is_mid_HL(subj)
            data_mid_HL = [data_mid_HL; PTA_avg];
        else
            data_older_HL = [data_older_HL; PTA_avg];
        end
    end
    
    % Compute the average PTA value across all HL and NH subjects for the current frequency
    young_NH_avg(i) = mean(data_young_NH,"omitnan");
    mid_NH_avg(i) = mean(data_mid_NH,"omitnan");
    older_NH_avg(i) = mean(data_older_NH,"omitnan");
    young_HL_avg(i) = mean(data_young_HL,"omitnan");
    mid_HL_avg(i) = mean(data_mid_HL,"omitnan");
    older_HL_avg(i) = mean(data_older_HL,"omitnan");

    young_NH_sem(i) = std(data_young_NH,"omitnan") / sqrt(length(data_young_NH));
    mid_NH_sem(i) = std(data_mid_NH,"omitnan") / sqrt(length(data_mid_NH));
    older_NH_sem(i) = std(data_older_NH,"omitnan") / sqrt(length(data_older_NH));
    young_HL_sem(i) = std(data_young_HL,"omitnan") / sqrt(length(data_young_HL));
    mid_HL_sem(i) = std(data_mid_HL,"omitnan") / sqrt(length(data_mid_HL));
    older_HL_sem(i) = std(data_older_HL,"omitnan") / sqrt(length(data_older_HL));
end

% Plot the data with error bars and mean markers using the new colors
errorbar(frequencies_NERB, young_NH_avg, young_NH_sem, 'o-', 'LineWidth', 1.5, 'MarkerSize', 8, 'CapSize', 10, 'Color', colors.young, 'LineStyle', lineStyles.NH); hold on;
errorbar(frequencies_NERB, mid_NH_avg, mid_NH_sem, 'o-', 'LineWidth', 1.5, 'MarkerSize', 8, 'CapSize', 10, 'Color', colors.mid, 'LineStyle', lineStyles.NH);
errorbar(frequencies_NERB, older_NH_avg, older_NH_sem, 'o-', 'LineWidth', 1.5, 'MarkerSize', 8, 'CapSize', 10, 'Color', colors.older, 'LineStyle', lineStyles.NH);
errorbar(frequencies_NERB, young_HL_avg, young_HL_sem, 'o-', 'LineWidth', 1.5, 'MarkerSize', 8, 'CapSize', 10, 'Color', colors.young, 'LineStyle', lineStyles.HL);
errorbar(frequencies_NERB, mid_HL_avg, mid_HL_sem, 'o-', 'LineWidth', 1.5, 'MarkerSize', 8, 'CapSize', 10, 'Color', colors.mid, 'LineStyle', lineStyles.HL);
errorbar(frequencies_NERB, older_HL_avg, older_HL_sem, 'o-', 'LineWidth', 1.5, 'MarkerSize', 8, 'CapSize', 10, 'Color', colors.older, 'LineStyle', lineStyles.HL);

% % Plot the data
% figure;
% plot(frequencies_kHz, HL_avg, 'r-', 'LineWidth', 1.5); hold on;
% plot(frequencies_kHz, NH_avg, 'b-', 'LineWidth', 1.5);
count_young_NH = sum(is_young_NH);
count_mid_NH = sum(is_mid_NH);
count_older_NH = sum(is_older_NH);
count_young_HL = sum(is_young_HL);
count_mid_HL = sum(is_mid_HL);
count_older_HL = sum(is_older_HL);

legend({sprintf('Young NH (N= %d)', count_young_NH), sprintf('Mid NH (N= %d)', count_mid_NH), ...
    sprintf('Older NH (N= %d)', count_older_NH), sprintf('Young HL (N= %d)', count_young_HL) ...
    , sprintf('Mid HL (N= %d)', count_mid_HL), sprintf('Older HL (N= %d)', count_older_HL)}, ...
       'Location', 'southeastoutside');
xlabel('Frequency (kHz)');
ylabel('Hearing Level (dB HL)');

% Frequencies to be labeled (removed 10.0000, 11.2000, and 14.0000)
label_frequencies_kHz = [0.2500, 0.5000, 1.0000, 2.0000, 3.0000, 4.0000, 6.0000, 8.0000, 9.0000, 12.5000, 16.0000];

xticklabels_array = arrayfun(@(x) getLabel(x, label_frequencies_kHz), frequencies_kHz, 'UniformOutput', false);

xticks(frequencies_NERB);
xticklabels(xticklabels_array);

% Set y-axis limits
ylim([-10, 80]);

% Invert y-axis
set(gca, 'YDir', 'reverse');
set(gca, 'XTickLabelRotation', 45, 'FontSize', 14);

% title('Average hearing threshold');
grid on;
hold off;

% Save the figure to the specified folder and filename
save_path = '/Volumes/gdrive4tb/IGNITE/tonotopy/surface/keyFigures/hearStat_ageDep_thres.png';
saveas(gcf, save_path);


%% function list
function nerb = f2nerb(f)
    % Convert frequency to NERB
    nerb = 1000*log(10)/(24.67*4.37)*log10(4.37*f+1);
end

function f = nerb2f(nerb)
    % nerb2f = inv(f2nerb)!
    
    f = (10.^(nerb*24.67*4.37/(1000*log(10)))-1)/4.37;
end

function label = getLabel(x, label_frequencies)
    if ismember(x, label_frequencies)
        if mod(x, 1) == 0  % Check if it's a whole number
            label = sprintf('%d', x);
        else
            label = sprintf('%.2f', x);
        end
    else
        label = '';
    end
end

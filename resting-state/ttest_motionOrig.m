clc
clear
close all

% Read data from files
NT_motion_abs = load('/Volumes/gdrive4tb/IGNITE/resting-state/IGNITE_resting-state_motionOrig_abs_NT.txt');
TT_motion_abs = load('/Volumes/gdrive4tb/IGNITE/resting-state/IGNITE_resting-state_motionOrig_abs_TT.txt');
NT_motion_rel = load('/Volumes/gdrive4tb/IGNITE/resting-state/IGNITE_resting-state_motionOrig_rel_NT.txt');
TT_motion_rel = load('/Volumes/gdrive4tb/IGNITE/resting-state/IGNITE_resting-state_motionOrig_rel_TT.txt');

% Perform the Independent-Samples t-test for absolute motion values
[h_abs, p_abs, ci_abs, stats_abs] = ttest2(NT_motion_abs, TT_motion_abs);

% Pad NT_motion_abs with NaN to match the size of TT_motion_abs
NT_motion_abs_padded = [NT_motion_abs; NaN(size(TT_motion_abs, 1) - size(NT_motion_abs, 1), 1)];

% Boxplots for Absolute Motion Values
figure;
boxplot([NT_motion_abs_padded, TT_motion_abs], 'Labels', {'NT', 'TT'});
title('Absolute Motion Values');
ylabel('Value'); % Replace with appropriate unit/measurement name
xlabel('Group');


% Perform the Independent-Samples t-test for relative motion values
[h_rel, p_rel, ci_rel, stats_rel] = ttest2(NT_motion_rel, TT_motion_rel);

% Display the results for relative motion values
disp('Results for Relative Motion Values:')
disp(['p-value: ', num2str(p_rel)]);
if p_rel < 0.05
    disp('The difference between groups is statistically significant.')
else
    disp('The difference between groups is not statistically significant.')
end

% Pad NT_motion_rel with NaN to match the size of TT_motion_rel
NT_motion_rel_padded = [NT_motion_rel; NaN(size(TT_motion_rel, 1) - size(NT_motion_rel, 1), 1)];

% Boxplots for Relative Motion Values
figure;
boxplot([NT_motion_rel_padded, TT_motion_rel], 'Labels', {'NT', 'TT'});
title('Relative Motion Values');
ylabel('Value'); % Replace with appropriate unit/measurement name
xlabel('Group');
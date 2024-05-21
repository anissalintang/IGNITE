%% Calculate ALFF from sparse AVERAGE ALL (from all time frame, rest and vis) scans
clear
clc

mkdir(fullfile('/Volumes/gdrive4tb/IGNITE/sparse_rest/surface'), 'analysis');

% specify the parent folder
parent_folder = '/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/projected/nonSmoothed/filt_0.01-0.1/';

% list the subjects' directories
sub_dirs = dir(fullfile(parent_folder, 'IG*'));
sub_dirs = {sub_dirs([sub_dirs.isdir]).name};  % get only directories

for i = 1:length(sub_dirs)
    % get the subject's directory
    sub_dir = sub_dirs{i};
    
    % list the .mgz files for this subject
    mgz_files = dir(fullfile(parent_folder, sub_dir, '*fsavg.mgz'));
    mgz_files = {mgz_files.name};  % get only file names
    
    % initialize cell arrays to store the matrices for this subject
    lh_matrix_sub = {};
    rh_matrix_sub = {};

    % loop through each .mgz file
    for j = 1:length(mgz_files)
        % get the file name
        mgz_file = mgz_files{j};
        
        % load the .mgz file as a matrix using MRIread
        img = MRIread(fullfile(parent_folder, sub_dir, mgz_file));
        U = squeeze(img.vol)';
        
        % determine the hemisphere, condition and add them to the appropriate cell array
        if contains(mgz_file, '_lh_')
            id = extractBetween(mgz_file, '_', 'lh');
            lh_matrix_sub{end + 1} = {id, U};
        elseif contains(mgz_file, '_rh_')
            id = extractBetween(mgz_file, '_', 'rh');
            rh_matrix_sub{end + 1} = {id, U};
        end
    end

    % add the matrices for this subject to the overall cell arrays
    lh_matrix{i} = lh_matrix_sub;
    rh_matrix{i} = rh_matrix_sub;
end

%%
% initialize cell arrays to store the calculated matrices for each subject
ALFF_lh = cell(1, length(sub_dirs));
ALFF_lh = cell(1, length(sub_dirs));

% names of the output images
output_names = {'ALFFall'};

% initialize containers to hold the matrices for each condition
ALFF_lh = [];
ALFF_rh = [];

% loop through each subject
for i = 1:length(sub_dirs)
    % get the matrices for this subject
    lh_matrices_sub = lh_matrix{i};
    rh_matrices_sub = rh_matrix{i};


    % loop through the matrices for the left hemisphere and sort them by
    % the rest and vis frames
    for j = 1:length(lh_matrices_sub)
        ALFF_lh{i}=std(lh_matrices_sub{j}{2});
    end

    % repeat for the right hemisphere
    for j = 1:length(rh_matrices_sub)
        ALFF_rh{i}=std(rh_matrices_sub{j}{2});
    end

end
%% Save ALFF images

mkdir(fullfile('/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis'), 'ALFFall');
% Rest
for i = 1:length(sub_dirs)
    sub_dir = sub_dirs{i};
    mkdir(fullfile('/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ALFFall/'), sub_dir);

        save_path_lh = fullfile('/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ALFFall/', sub_dir, '/', [sprintf(sub_dir), '_lh_', output_names{1}, '.mgz']);
        save_path_rh = fullfile('/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ALFFall/', sub_dir, '/',  [sprintf(sub_dir), '_rh_', output_names{1}, '.mgz']);
        
        lh_img = img;
        lh_img.nframes = 1;
        lh_img.vol = ALFF_lh{i}';
    
        rh_img = img;
        rh_img.vol = ALFF_rh{i}';
    
        MRIwrite(lh_img, save_path_lh);
        MRIwrite(rh_img, save_path_rh);
end
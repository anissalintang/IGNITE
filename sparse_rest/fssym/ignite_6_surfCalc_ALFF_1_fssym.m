%% Calculate ALFF from sparse rest scans --fssym
clear
clc

mkdir(fullfile('/Volumes/gdrive4tb/IGNITE/sparse_rest/surface'), 'analysis');

% specify the parent folder
parent_folder = '/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/projected/fssym/nonSmoothed/filt_0.01-0.1/';

% list the subjects' directories
sub_dirs = dir(fullfile(parent_folder, 'IG*'));
sub_dirs = {sub_dirs([sub_dirs.isdir]).name};  % get only directories

for i = 1:length(sub_dirs)
    % get the subject's directory
    sub_dir = sub_dirs{i};
    
    % list the .mgz files for this subject
    mgz_files = dir(fullfile(parent_folder, sub_dir, '*fsavg*fssym.mgz'));
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
ALFFrest_lh = cell(1, length(sub_dirs));
ALFFvis_lh = cell(1, length(sub_dirs));

ALFFrest_rh = cell(1, length(sub_dirs));
ALFFvis_rh = cell(1, length(sub_dirs));

% names of the output images
output_names = {'ALFF_rest', 'ALFF_vis'};

% loop through each subject
for i = 1:length(sub_dirs)
    % get the matrices for this subject
    lh_matrices_sub = lh_matrix{i};
    rh_matrices_sub = rh_matrix{i};

    % initialize containers to hold the matrices for each condition
    rest1_lh = [];
    rest2_lh = [];
    rest_lh = [];
    vis1_lh = [];
    vis2_lh = [];
    vis_lh = [];

    rest1_rh = [];
    rest2_rh = [];
    rest_rh = [];
    vis1_rh = [];
    vis2_rh = [];
    vis_rh = [];

    % loop through the matrices for the left hemisphere and sort them by
    % the rest and vis frames
    for j = 1:length(lh_matrices_sub)
        rest1_lh = lh_matrices_sub{j}{2}(1:20,:);
        rest2_lh = lh_matrices_sub{j}{2}(41:60,:);
        rest_lh = [rest1_lh; rest2_lh];

        ALFFrest_lh{i}=std(rest_lh);

        vis1_lh = lh_matrices_sub{j}{2}(21:40,:);
        vis2_lh = lh_matrices_sub{j}{2}(61:80,:);
        vis_lh = [vis1_lh; vis2_lh];

        ALFFvis_lh{i}=std(vis_lh);

    end

    % repeat for the right hemisphere
    for j = 1:length(rh_matrices_sub)
        rest1_rh = rh_matrices_sub{j}{2}(1:20,:);
        rest2_rh = rh_matrices_sub{j}{2}(41:60,:);
        rest_rh = [rest1_rh; rest2_rh];

        ALFFrest_rh{i}=std(rest_rh);

        vis1_rh = rh_matrices_sub{j}{2}(21:40,:);
        vis2_rh = rh_matrices_sub{j}{2}(61:80,:);
        vis_rh = [vis1_rh; vis2_rh];

        ALFFvis_rh{i}=std(vis_rh);
    end

end
%% Save ALFF images

% Rest
for i = 1:length(sub_dirs)
    sub_dir = sub_dirs{i};
    mkdir(fullfile('/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/'), 'ALFF_fssym');
    mkdir(fullfile('/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ALFF_fssym/'), sub_dir);

        save_path_lh = fullfile('/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ALFF_fssym/', sub_dir, '/', [sprintf(sub_dir), '_lh_', output_names{1}, '.mgz']);
        save_path_rh = fullfile('/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ALFF_fssym/', sub_dir, '/',  [sprintf(sub_dir), '_rh_', output_names{1}, '.mgz']);
        
        lh_img = img;
        lh_img.nframes = 1;
        lh_img.vol = ALFFrest_lh{i}';
    
        rh_img = img;
        rh_img.vol = ALFFrest_rh{i}';
    
        MRIwrite(lh_img, save_path_lh);
        MRIwrite(rh_img, save_path_rh);
end
%%
% Visual
for i = 1:length(sub_dirs)
    sub_dir = sub_dirs{i};
        save_path_lh = fullfile('/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ALFF_fssym/', sub_dir, '/', [sprintf(sub_dir), '_lh_', output_names{2}, '.mgz']);
        save_path_rh = fullfile('/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ALFF_fssym/', sub_dir, '/', [sprintf(sub_dir), '_rh_', output_names{2}, '.mgz']);
        
        lh_img = img;
        lh_img.nframes = 1;
        lh_img.vol = ALFFvis_lh{i}';
    
        rh_img = img;
        rh_img.vol = ALFFvis_rh{i}';
    
        MRIwrite(lh_img, save_path_lh);
        MRIwrite(rh_img, save_path_rh);
end
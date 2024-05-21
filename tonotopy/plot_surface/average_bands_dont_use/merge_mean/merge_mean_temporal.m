clc;
clear;
close all;

% Path to fsaverage directory
subject_dir = '/Volumes/gdrive4tb/IGNITE/resting-state/surface/recon/fsaverage';

% Read the surface
[lh_vertices, lh_faces] = read_surf(fullfile(subject_dir, 'surf', 'lh.inflated'));
[rh_vertices, rh_faces] = read_surf(fullfile(subject_dir, 'surf', 'rh.inflated'));

% Read the curvature data
lh_curv = read_curv(fullfile(subject_dir, 'surf', 'lh.curv'));
rh_curv = read_curv(fullfile(subject_dir, 'surf', 'rh.curv'));

% Read the masks
temporal_mask_lh = MRIread('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/destrieux_fsavg/temporalLobe_mask_lh.mgh');
temporal_mask_rh = MRIread('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/destrieux_fsavg/temporalLobe_mask_rh.mgh');

%%
% Get subjects list from the preprocessed directory
subjects = '/Volumes/gdrive4tb/IGNITE/tonotopy/preprocessed';
subjects = dir(subjects);
subjects = {subjects([subjects.isdir]).name};  % Get folder names

% Remove "." and ".." directories
subjects = subjects(~ismember(subjects, {'.', '..','.DS_Store'}));

lh_TT = [];
rh_TT = [];
lh_NT = [];
rh_NT = [];

% Segregate the subjects into TT and NT groups based on their subject IDs
for s = 1:length(subjects)
    subj = subjects{s};
    
    lh_data_path = ['/Volumes/gdrive4tb/IGNITE/tonotopy/surface/projected/', subj, '/e_8.fsf/lh.sigch.avg.fsavg.smooth5.mgz'];
    rh_data_path = ['/Volumes/gdrive4tb/IGNITE/tonotopy/surface/projected/', subj, '/e_8.fsf/rh.sigch.avg.fsavg.smooth5.mgz'];

    lh_data = MRIread(lh_data_path);
    rh_data = MRIread(rh_data_path);
    
    % Assuming the subject ID contains either 'TT' or 'NT' to indicate the group
    if contains(subj, 'TT')
        lh_TT = cat(4, lh_TT, lh_data.vol);
        rh_TT = cat(4, rh_TT, rh_data.vol);
    elseif contains(subj, 'NT')
        lh_NT = cat(4, lh_NT, lh_data.vol);
        rh_NT = cat(4, rh_NT, rh_data.vol);
    end
end

groups = {'TT', 'NT'};
for idx = 1:2
    group = groups{idx};
    
    if strcmp(group, 'TT')
        data1 = mean(lh_TT, 4)';
        data2 = mean(rh_TT, 4)';
    else
        data1 = mean(lh_NT, 4)';
        data2 = mean(rh_NT, 4)';
    end

    % Apply the masks to the data
    masked_data1 = data1 .* temporal_mask_lh.vol;
    masked_data2 = data2 .* temporal_mask_rh.vol;

    n_steps = 50;

    % Cyan to blue
    r1 = linspace(0, 0, n_steps)';
    g1 = linspace(1, 0, n_steps)';
    b1 = linspace(1, 1, n_steps)';
    
    % Blue to red with smoother transition
    x = [1, n_steps];
    r_values = [0, 1];
    g_values = [0, 0];
    b_values = [1, 0];
    
    r2 = interp1(x, r_values, 1:n_steps, 'pchip');
    g2 = interp1(x, g_values, 1:n_steps, 'pchip');
    b2 = interp1(x, b_values, 1:n_steps, 'pchip');
    
    % Red to yellow
    r3 = linspace(1, 1, n_steps)';
    g3 = linspace(0, 1, n_steps)';
    b3 = linspace(0, 0, n_steps)';
    
    cmap_custom = [r1, g1, b1; r2', g2', b2'; r3, g3, b3];
    
    % Create a new figure
    figure('Position', [0, 0, 700, 300]);
    
    % Define the curvature colormap
    cmap_curv = colormap('gray');
    RANGE = 0.5; OFFSET = min(1-RANGE,0.2);
    
    % Calculate the color index for the curvature
    cidx_lh = round((RANGE/(max(lh_curv)-min(lh_curv))*(lh_curv-min(lh_curv))+OFFSET)*(size(cmap_curv,1)-1))+1;
    cidx_rh = round((RANGE/(max(rh_curv)-min(rh_curv))*(rh_curv-min(rh_curv))+OFFSET)*(size(cmap_curv,1)-1))+1;
    
    % Plot the left hemisphere
    ax1 = subplot(1,2,1);
    patch('Faces',lh_faces+1,'Vertices',lh_vertices,'FaceVertexCData',cmap_curv(cidx_lh,:),'FaceColor','interp','EdgeColor','none');
    
    
    % Map data to a color
    cmap_roi = colormap(cmap_custom);
    all_data = [data1(:); data2(:)];
    scaled_data = (min(max(all_data, -0.2), 0.2) + 0.2) / (0.2*2);
    cidx_roi = round(scaled_data * (size(cmap_roi,1)-1)) + 1;
    
    % Set transparency for data less than 0
    alpha_lhs = ones(size(masked_data1));
    alpha_lhs(masked_data1 == 0 | isnan(masked_data1)) = 0;
    patch('Faces',lh_faces+1,'Vertices',lh_vertices,'FaceVertexCData',cmap_roi(cidx_roi(1:numel(masked_data1)),:),'FaceColor','interp','EdgeColor','none','FaceAlpha','interp','FaceVertexAlphaData',alpha_lhs,'AlphaDataMapping','none');
    
    title('Left Hemisphere');
    view([-90, 0]);
    lh1 = camlight('left'); set(lh1, 'Color', [0.8 0.8 0.8]);
    lh2 = camlight('right'); set(lh2, 'Color', [0.8 0.8 0.8]);
    material dull;
    axis off;
    
    % Plot the right hemisphere
    ax2 = subplot(1,2,2);
    patch('Faces',rh_faces+1,'Vertices',rh_vertices,'FaceVertexCData',cmap_curv(cidx_rh,:),'FaceColor','interp','EdgeColor','none');
    
    
    % Map data to a color
    % Set transparency for data less than 0
    alpha_rhs = ones(size(masked_data2));
    alpha_rhs(masked_data2 == 0 | isnan(masked_data2)) = 0;
    patch('Faces',rh_faces+1,'Vertices',rh_vertices,'FaceVertexCData',cmap_roi(cidx_roi(numel(masked_data1)+1:end),:),'FaceColor','interp','EdgeColor','none','FaceAlpha','interp','FaceVertexAlphaData',alpha_rhs,'AlphaDataMapping','none');
    
    
    title('Right Hemisphere');
    view([90, 0]);
    lh1 = camlight('left'); set(lh1, 'Color', [0.8 0.8 0.8]);
    lh2 = camlight('right'); set(lh2, 'Color', [0.8 0.8 0.8]);
    material dull;
    axis off;
    
    % Adjust the position of the axes
    set(ax1, 'Position', [0 0.1 0.55 0.7]);
    set(ax2, 'Position', [0.45 0.1 0.55 0.7]);
    
    % Set the same color limits for both axes
    clim = [-0.2, 0.2];
    ax1.CLim = clim;
    ax2.CLim = clim;
    
    % Create a single shared colorbar
    c = colorbar('Orientation', 'horizontal');
    set(c, 'Position', [0.4 0.05 0.2 0.03]);
    
    sgtitle(sprintf('Averaged stimuli evoked response in temporal region, for %s group', group))

    % Ensure keyFigures directory exists
    outputDir = '/Volumes/gdrive4tb/IGNITE/tonotopy/surface/analysis/keyFigures/';
    if ~exist(outputDir, 'dir')
       mkdir(outputDir);
    end

    % Save the figure
    saveas(gcf, [outputDir, 'allSubj_merge_mean_', group, '_temporal_smooth5.png']);
end

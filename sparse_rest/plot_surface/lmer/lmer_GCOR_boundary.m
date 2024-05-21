clc
clear
close all

% Path to your subject's directory
subject_dir = '/Volumes/gdrive4tb/IGNITE/resting-state/surface/recon/fsaverage_sym';

% Read the surface
[lh_vertices, lh_faces] = read_surf(fullfile(subject_dir, 'surf', 'lh.inflated'));

% Read the curvature data
lh_curv = read_curv(fullfile(subject_dir, 'surf', 'lh.curv'));

% Load fsaverage_sym surfaces and create surface graph
surf = struct;
[~, tri] = read_surf(fullfile(subject_dir, 'surf', 'lh.white'));
surf.tri = tri + 1;
surf.vtc.infl = read_surf(fullfile(subject_dir, 'surf', 'lh.inflated'));
vtc = surf.vtc.infl;

% Get boundary vertices for each mask
sensory_motor_boundary = getBoundaryVertices('/Volumes/gdrive4tb/IGNITE/code/resting-state/plot_surface/lmer/sensory-motor_Yeo_lh_fsaverage_sym.mgh', surf);

%% GCOR tmap tinStat - Uncorrected

% List of images
images = {'GCOR_tmap_tinStat_fullMod_uncorrected_0.01.mgz', 
          'GCOR_tmap_tinStat_fullMod_uncorrected_0.05.mgz',
          'GCOR_tmap_tinStat_fullMod_uncorrected_0.1.mgz',
          'GCOR_tmap_tinStat_fullMod_uncorrected_0.25.mgz',
          'GCOR_tmap_tinStat_fullMod_uncorrected_0.5.mgz'};

for i = 1:length(images)
    img_path = fullfile('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR_fssym/stat/with_motionParam/fullmod/', images{i});
    img = MRIread(img_path);
    data = img.vol';

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
    figure('Position', [0, 0, 400, 300]);
    
    % Define the curvature colormap
    cmap_curv = colormap('gray');
    RANGE = 0.5; OFFSET = min(1-RANGE,0.2);
    
    % Calculate the color index for the curvature
    cidx_lh = round((RANGE/(max(lh_curv)-min(lh_curv))*(lh_curv-min(lh_curv))+OFFSET)*(size(cmap_curv,1)-1))+1;
    
    % Plot the left hemisphere
    ax1 = subplot(1,2,1);
    patch('Faces',lh_faces+1,'Vertices',lh_vertices,'FaceVertexCData',cmap_curv(cidx_lh,:),'FaceColor','interp','EdgeColor','none');
    
    % Map data to a color
    cmap_roi = colormap(cmap_custom);
%     scaled_data = (min(max(data, (max(data)*-1)), max(data)) + max(data)) / (max(data)*2);
    scaled_data = (min(max(data, -0.015), 0.015) + 0.015) / (0.015*2);
    cidx_roi = round(scaled_data * (size(cmap_roi,1)-1)) + 1;
    
    % Set transparency for data less than 0
    alpha_lhs = ones(size(data));
    alpha_lhs(data == 0) = 0; % Set alpha to 0 for data < 0
    patch('Faces',lh_faces+1,'Vertices',lh_vertices,'FaceVertexCData',cmap_roi(cidx_roi(1:numel(data)),:),'FaceColor','interp','EdgeColor','none','FaceAlpha','interp','FaceVertexAlphaData',alpha_lhs,'AlphaDataMapping','none');
    
    % Plot the boundaries on the existing plot
    hold on;
    plot3(vtc(sensory_motor_boundary, 1), vtc(sensory_motor_boundary, 2), vtc(sensory_motor_boundary, 3), 'k.', 'MarkerSize', 12);
   
    view([-90, 0]);
    lh1 = camlight('left'); set(lh1, 'Color', [0.8 0.8 0.8]);
    lh2 = camlight('right'); set(lh2, 'Color', [0.8 0.8 0.8]);
    material dull;
    axis off;
    
    % Adjust the position of the axes
    set(ax1, 'Position', [0 0.15 0.95 0.7]);
    
    % Set the same color limits for both axes
    clim = [-0.015, 0.015];
    ax1.CLim = clim;
    
    % Create a single shared colorbar
    c = colorbar('Orientation', 'horizontal');
    set(c, 'Position', [0.4 0.05 0.2 0.03]);

    % Adjust the title
    value = strsplit(images{i}, '_');
    value = value{end};
    value = value(1:end-4);
    sgtitle(['GCOR t-values map of tinnitus status. Uncorrected (' value ')'])

    % Save the figure
    saveas_name = fullfile('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/keyFigures/lmer_tmaps/GCOR/lmer_tmaps_bdry/', ['GCOR_tmap_tinStat_uncorrected_' value '.png']);
    saveas(gcf, saveas_name);
    
end

%% GCOR tmap tinStat - Corrected

% List of images
images = {'GCOR_tmap_tinStat_fullMod_corrected_0.01.mgz', 
          'GCOR_tmap_tinStat_fullMod_corrected_0.05.mgz',
          'GCOR_tmap_tinStat_fullMod_corrected_0.1.mgz',
          'GCOR_tmap_tinStat_fullMod_corrected_0.25.mgz',
          'GCOR_tmap_tinStat_fullMod_corrected_0.5.mgz'};

for i = 1:length(images)
    img_path = fullfile('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR_fssym/stat/with_motionParam/fullmod/', images{i});
    img = MRIread(img_path);
    data = img.vol';

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
    figure('Position', [0, 0, 400, 300]);
    
    % Define the curvature colormap
    cmap_curv = colormap('gray');
    RANGE = 0.5; OFFSET = min(1-RANGE,0.2);
    
    % Calculate the color index for the curvature
    cidx_lh = round((RANGE/(max(lh_curv)-min(lh_curv))*(lh_curv-min(lh_curv))+OFFSET)*(size(cmap_curv,1)-1))+1;
    
    % Plot the left hemisphere
    ax1 = subplot(1,2,1);
    patch('Faces',lh_faces+1,'Vertices',lh_vertices,'FaceVertexCData',cmap_curv(cidx_lh,:),'FaceColor','interp','EdgeColor','none');
    
    % Map data to a color
    cmap_roi = colormap(cmap_custom);
%     scaled_data = (min(max(data, (max(data)*-1)), max(data)) + max(data)) / (max(data)*2);
    scaled_data = (min(max(data, -0.015), 0.015) + 0.015) / (0.015*2);
    cidx_roi = round(scaled_data * (size(cmap_roi,1)-1)) + 1;
    
    % Set transparency for data less than 0
    alpha_lhs = ones(size(data));
    alpha_lhs(data == 0) = 0; % Set alpha to 0 for data < 0
    patch('Faces',lh_faces+1,'Vertices',lh_vertices,'FaceVertexCData',cmap_roi(cidx_roi(1:numel(data)),:),'FaceColor','interp','EdgeColor','none','FaceAlpha','interp','FaceVertexAlphaData',alpha_lhs,'AlphaDataMapping','none');
    
    % Plot the boundaries on the existing plot
    hold on;
    plot3(vtc(sensory_motor_boundary, 1), vtc(sensory_motor_boundary, 2), vtc(sensory_motor_boundary, 3), 'k.', 'MarkerSize', 12);
   
    view([-90, 0]);
    lh1 = camlight('left'); set(lh1, 'Color', [0.8 0.8 0.8]);
    lh2 = camlight('right'); set(lh2, 'Color', [0.8 0.8 0.8]);
    material dull;
    axis off;
    
    % Adjust the position of the axes
    set(ax1, 'Position', [0 0.15 0.95 0.7]);
    
    % Set the same color limits for both axes
    clim = [-0.015, 0.015];
    ax1.CLim = clim;
    
    % Create a single shared colorbar
    c = colorbar('Orientation', 'horizontal');
    set(c, 'Position', [0.4 0.05 0.2 0.03]);

    % Adjust the title
    value = strsplit(images{i}, '_');
    value = value{end};
    value = value(1:end-4);
    sgtitle(['GCOR t-values map of tinnitus status. FDR corrected (' value ')'])

    % Save the figure
    saveas_name = fullfile('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/keyFigures/lmer_tmaps/GCOR/lmer_tmaps_bdry/', ['GCOR_tmap_tinStat_corrected_' value '.png']);
    saveas(gcf, saveas_name);
    
end

%% GCOR tmap PTA_mean - Uncorrected

% List of images
images = {'GCOR_tmap_PTA_mean_fullMod_uncorrected_0.01.mgz', 
          'GCOR_tmap_PTA_mean_fullMod_uncorrected_0.05.mgz',
          'GCOR_tmap_PTA_mean_fullMod_uncorrected_0.1.mgz',
          'GCOR_tmap_PTA_mean_fullMod_uncorrected_0.25.mgz',
          'GCOR_tmap_PTA_mean_fullMod_uncorrected_0.5.mgz'};

for i = 1:length(images)
    img_path = fullfile('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR_fssym/stat/with_motionParam/fullmod/', images{i});
    img = MRIread(img_path);
    data = img.vol';

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
    figure('Position', [0, 0, 400, 300]);
    
    % Define the curvature colormap
    cmap_curv = colormap('gray');
    RANGE = 0.5; OFFSET = min(1-RANGE,0.2);
    
    % Calculate the color index for the curvature
    cidx_lh = round((RANGE/(max(lh_curv)-min(lh_curv))*(lh_curv-min(lh_curv))+OFFSET)*(size(cmap_curv,1)-1))+1;
    
    % Plot the left hemisphere
    ax1 = subplot(1,2,1);
    patch('Faces',lh_faces+1,'Vertices',lh_vertices,'FaceVertexCData',cmap_curv(cidx_lh,:),'FaceColor','interp','EdgeColor','none');
    
    % Map data to a color
    cmap_roi = colormap(cmap_custom);
%     scaled_data = (min(max(data, (max(data)*-1)), max(data)) + max(data)) / (max(data)*2);
    scaled_data = (min(max(data, -0.0005), 0.0005) + 0.0005) / (0.0005*2);
    cidx_roi = round(scaled_data * (size(cmap_roi,1)-1)) + 1;
    
    % Set transparency for data less than 0
    alpha_lhs = ones(size(data));
    alpha_lhs(data == 0) = 0; % Set alpha to 0 for data < 0
    patch('Faces',lh_faces+1,'Vertices',lh_vertices,'FaceVertexCData',cmap_roi(cidx_roi(1:numel(data)),:),'FaceColor','interp','EdgeColor','none','FaceAlpha','interp','FaceVertexAlphaData',alpha_lhs,'AlphaDataMapping','none');
    
    % Plot the boundaries on the existing plot
    hold on;
    plot3(vtc(sensory_motor_boundary, 1), vtc(sensory_motor_boundary, 2), vtc(sensory_motor_boundary, 3), 'k.', 'MarkerSize', 12);
   
    view([-90, 0]);
    lh1 = camlight('left'); set(lh1, 'Color', [0.8 0.8 0.8]);
    lh2 = camlight('right'); set(lh2, 'Color', [0.8 0.8 0.8]);
    material dull;
    axis off;
    
    % Adjust the position of the axes
    set(ax1, 'Position', [0 0.15 0.95 0.7]);
    
    % Set the same color limits for both axes
    clim = [-0.0005, 0.0005];
    ax1.CLim = clim;
    
    % Create a single shared colorbar
    c = colorbar('Orientation', 'horizontal');
    set(c, 'Position', [0.4 0.05 0.2 0.03]);

    % Adjust the title
    value = strsplit(images{i}, '_');
    value = value{end};
    value = value(1:end-4);
    sgtitle(['GCOR t-values map of PTA. Uncorrected (' value ')'])

    % Save the figure
    saveas_name = fullfile('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/keyFigures/lmer_tmaps/GCOR/lmer_tmaps_bdry/', ['GCOR_tmap_PTA_mean_uncorrected_' value '.png']);
    saveas(gcf, saveas_name);
    
end

%% GCOR tmap PTA_mean - Corrected

% List of images
images = {'GCOR_tmap_PTA_mean_fullMod_corrected_0.01.mgz', 
          'GCOR_tmap_PTA_mean_fullMod_corrected_0.05.mgz',
          'GCOR_tmap_PTA_mean_fullMod_corrected_0.1.mgz',
          'GCOR_tmap_PTA_mean_fullMod_corrected_0.25.mgz',
          'GCOR_tmap_PTA_mean_fullMod_corrected_0.5.mgz'};

for i = 1:length(images)
    img_path = fullfile('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR_fssym/stat/with_motionParam/fullmod/', images{i});
    img = MRIread(img_path);
    data = img.vol';

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
    figure('Position', [0, 0, 400, 300]);
    
    % Define the curvature colormap
    cmap_curv = colormap('gray');
    RANGE = 0.5; OFFSET = min(1-RANGE,0.2);
    
    % Calculate the color index for the curvature
    cidx_lh = round((RANGE/(max(lh_curv)-min(lh_curv))*(lh_curv-min(lh_curv))+OFFSET)*(size(cmap_curv,1)-1))+1;
    
    % Plot the left hemisphere
    ax1 = subplot(1,2,1);
    patch('Faces',lh_faces+1,'Vertices',lh_vertices,'FaceVertexCData',cmap_curv(cidx_lh,:),'FaceColor','interp','EdgeColor','none');
    
    % Map data to a color
    cmap_roi = colormap(cmap_custom);
%     scaled_data = (min(max(data, (max(data)*-1)), max(data)) + max(data)) / (max(data)*2);
    scaled_data = (min(max(data, -0.0005), 0.0005) + 0.0005) / (0.0005*2);
    cidx_roi = round(scaled_data * (size(cmap_roi,1)-1)) + 1;
    
    % Set transparency for data less than 0
    alpha_lhs = ones(size(data));
    alpha_lhs(data == 0) = 0; % Set alpha to 0 for data < 0
    patch('Faces',lh_faces+1,'Vertices',lh_vertices,'FaceVertexCData',cmap_roi(cidx_roi(1:numel(data)),:),'FaceColor','interp','EdgeColor','none','FaceAlpha','interp','FaceVertexAlphaData',alpha_lhs,'AlphaDataMapping','none');
    
    % Plot the boundaries on the existing plot
    hold on;
    plot3(vtc(sensory_motor_boundary, 1), vtc(sensory_motor_boundary, 2), vtc(sensory_motor_boundary, 3), 'k.', 'MarkerSize', 12);
   
    view([-90, 0]);
    lh1 = camlight('left'); set(lh1, 'Color', [0.8 0.8 0.8]);
    lh2 = camlight('right'); set(lh2, 'Color', [0.8 0.8 0.8]);
    material dull;
    axis off;
    
    % Adjust the position of the axes
    set(ax1, 'Position', [0 0.15 0.95 0.7]);
    
    % Set the same color limits for both axes
    clim = [-0.0005, 0.0005];
    ax1.CLim = clim;
    
    % Create a single shared colorbar
    c = colorbar('Orientation', 'horizontal');
    set(c, 'Position', [0.4 0.05 0.2 0.03]);

    % Adjust the title
    value = strsplit(images{i}, '_');
    value = value{end};
    value = value(1:end-4);
    sgtitle(['GCOR t-values map of PTA. FDR corrected (' value ')'])

    % Save the figure
    saveas_name = fullfile('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/keyFigures/lmer_tmaps/GCOR/lmer_tmaps_bdry/', ['GCOR_tmap_PTA_mean_corrected_' value '.png']);
    saveas(gcf, saveas_name);
    
end

%% GCOR tmap AgeSq - Uncorrected

% List of images
images = {'GCOR_tmap_AgeSq_fullMod_uncorrected_0.01.mgz', 
          'GCOR_tmap_AgeSq_fullMod_uncorrected_0.05.mgz',
          'GCOR_tmap_AgeSq_fullMod_uncorrected_0.1.mgz',
          'GCOR_tmap_AgeSq_fullMod_uncorrected_0.25.mgz',
          'GCOR_tmap_AgeSq_fullMod_uncorrected_0.5.mgz'};

for i = 1:length(images)
    img_path = fullfile('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR_fssym/stat/with_motionParam/fullmod/', images{i});
    img = MRIread(img_path);
    data = img.vol';

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
    figure('Position', [0, 0, 400, 300]);
    
    % Define the curvature colormap
    cmap_curv = colormap('gray');
    RANGE = 0.5; OFFSET = min(1-RANGE,0.2);
    
    % Calculate the color index for the curvature
    cidx_lh = round((RANGE/(max(lh_curv)-min(lh_curv))*(lh_curv-min(lh_curv))+OFFSET)*(size(cmap_curv,1)-1))+1;
    
    % Plot the left hemisphere
    ax1 = subplot(1,2,1);
    patch('Faces',lh_faces+1,'Vertices',lh_vertices,'FaceVertexCData',cmap_curv(cidx_lh,:),'FaceColor','interp','EdgeColor','none');
    
    % Map data to a color
    cmap_roi = colormap(cmap_custom);
%     scaled_data = (min(max(data, (max(data)*-1)), max(data)) + max(data)) / (max(data)*2);
    scaled_data = (min(max(data, -0.00004), 0.00004) + 0.00004) / (0.00004*2);
    cidx_roi = round(scaled_data * (size(cmap_roi,1)-1)) + 1;
    
    % Set transparency for data less than 0
    alpha_lhs = ones(size(data));
    alpha_lhs(data == 0) = 0; % Set alpha to 0 for data < 0
    patch('Faces',lh_faces+1,'Vertices',lh_vertices,'FaceVertexCData',cmap_roi(cidx_roi(1:numel(data)),:),'FaceColor','interp','EdgeColor','none','FaceAlpha','interp','FaceVertexAlphaData',alpha_lhs,'AlphaDataMapping','none');
    
    % Plot the boundaries on the existing plot
    hold on;
    plot3(vtc(sensory_motor_boundary, 1), vtc(sensory_motor_boundary, 2), vtc(sensory_motor_boundary, 3), 'k.', 'MarkerSize', 12);
   
    view([-90, 0]);
    lh1 = camlight('left'); set(lh1, 'Color', [0.8 0.8 0.8]);
    lh2 = camlight('right'); set(lh2, 'Color', [0.8 0.8 0.8]);
    material dull;
    axis off;
    
    % Adjust the position of the axes
    set(ax1, 'Position', [0 0.15 0.95 0.7]);
    
    % Set the same color limits for both axes
    clim = [-0.00004, 0.00004];
    ax1.CLim = clim;
    
    % Create a single shared colorbar
    c = colorbar('Orientation', 'horizontal');
    set(c, 'Position', [0.4 0.05 0.2 0.03]);

    % Adjust the title
    value = strsplit(images{i}, '_');
    value = value{end};
    value = value(1:end-4);
    sgtitle(['GCOR t-values map of AgeSq. Uncorrected (' value ')'])

    % Save the figure
    saveas_name = fullfile('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/keyFigures/lmer_tmaps/GCOR/lmer_tmaps_bdry/', ['GCOR_tmap_AgeSq_uncorrected_' value '.png']);
    saveas(gcf, saveas_name);
    
end

%% GCOR tmap AgeSq - Corrected

% List of images
images = {'GCOR_tmap_AgeSq_fullMod_corrected_0.01.mgz', 
          'GCOR_tmap_AgeSq_fullMod_corrected_0.05.mgz',
          'GCOR_tmap_AgeSq_fullMod_corrected_0.1.mgz',
          'GCOR_tmap_AgeSq_fullMod_corrected_0.25.mgz',
          'GCOR_tmap_AgeSq_fullMod_corrected_0.5.mgz'};

for i = 1:length(images)
    img_path = fullfile('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR_fssym/stat/with_motionParam/fullmod/', images{i});
    img = MRIread(img_path);
    data = img.vol';

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
    figure('Position', [0, 0, 400, 300]);
    
    % Define the curvature colormap
    cmap_curv = colormap('gray');
    RANGE = 0.5; OFFSET = min(1-RANGE,0.2);
    
    % Calculate the color index for the curvature
    cidx_lh = round((RANGE/(max(lh_curv)-min(lh_curv))*(lh_curv-min(lh_curv))+OFFSET)*(size(cmap_curv,1)-1))+1;
    
    % Plot the left hemisphere
    ax1 = subplot(1,2,1);
    patch('Faces',lh_faces+1,'Vertices',lh_vertices,'FaceVertexCData',cmap_curv(cidx_lh,:),'FaceColor','interp','EdgeColor','none');
    
    % Map data to a color
    cmap_roi = colormap(cmap_custom);
%     scaled_data = (min(max(data, (max(data)*-1)), max(data)) + max(data)) / (max(data)*2);
    scaled_data = (min(max(data, -0.00004), 0.00004) + 0.00004) / (0.00004*2);
    cidx_roi = round(scaled_data * (size(cmap_roi,1)-1)) + 1;
    
    % Set transparency for data less than 0
    alpha_lhs = ones(size(data));
    alpha_lhs(data == 0) = 0; % Set alpha to 0 for data < 0
    patch('Faces',lh_faces+1,'Vertices',lh_vertices,'FaceVertexCData',cmap_roi(cidx_roi(1:numel(data)),:),'FaceColor','interp','EdgeColor','none','FaceAlpha','interp','FaceVertexAlphaData',alpha_lhs,'AlphaDataMapping','none');
    
    % Plot the boundaries on the existing plot
    hold on;
    plot3(vtc(sensory_motor_boundary, 1), vtc(sensory_motor_boundary, 2), vtc(sensory_motor_boundary, 3), 'k.', 'MarkerSize', 12);
   
    view([-90, 0]);
    lh1 = camlight('left'); set(lh1, 'Color', [0.8 0.8 0.8]);
    lh2 = camlight('right'); set(lh2, 'Color', [0.8 0.8 0.8]);
    material dull;
    axis off;
    
    % Adjust the position of the axes
    set(ax1, 'Position', [0 0.15 0.95 0.7]);
    
    % Set the same color limits for both axes
    clim = [-0.00004, 0.00004];
    ax1.CLim = clim;
    
    % Create a single shared colorbar
    c = colorbar('Orientation', 'horizontal');
    set(c, 'Position', [0.4 0.05 0.2 0.03]);

    % Adjust the title
    value = strsplit(images{i}, '_');
    value = value{end};
    value = value(1:end-4);
    sgtitle(['GCOR t-values map of AgeSq. FDR corrected (' value ')'])

    % Save the figure
    saveas_name = fullfile('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/keyFigures/lmer_tmaps/GCOR/lmer_tmaps_bdry/', ['GCOR_tmap_AgeSq_corrected_' value '.png']);
    saveas(gcf, saveas_name);
    
end
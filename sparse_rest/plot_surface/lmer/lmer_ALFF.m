clc
clear
close all

% Path to your subject's directory
subject_dir = '/Volumes/gdrive4tb/IGNITE/resting-state/surface/recon/fsaverage_sym';

% Read the surface
[lh_vertices, lh_faces] = read_surf(fullfile(subject_dir, 'surf', 'lh.inflated'));

% Read the curvature data
lh_curv = read_curv(fullfile(subject_dir, 'surf', 'lh.curv'));

%% ALFF tmap Age - Uncorrected -with_motionParam

% List of images
images = {'ALFF_tmap_Age_fullMod_uncorrected_0.01.mgz', 
          'ALFF_tmap_Age_fullMod_uncorrected_0.05.mgz',
          'ALFF_tmap_Age_fullMod_uncorrected_0.1.mgz',
          'ALFF_tmap_Age_fullMod_uncorrected_0.25.mgz',
          'ALFF_tmap_Age_fullMod_uncorrected_0.5.mgz'};

for i = 1:length(images)
    img_path = fullfile('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF_fssym/stat/with_motionParam/fullmod/', images{i});
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
    scaled_data = (min(max(data, -0.5), 0.5) + 0.5) / (0.5*2);
    cidx_roi = round(scaled_data * (size(cmap_roi,1)-1)) + 1;
    
    % Set transparency for data less than 0
    alpha_lhs = ones(size(data));
    alpha_lhs(data == 0) = 0; % Set alpha to 0 for data < 0
    patch('Faces',lh_faces+1,'Vertices',lh_vertices,'FaceVertexCData',cmap_roi(cidx_roi(1:numel(data)),:),'FaceColor','interp','EdgeColor','none','FaceAlpha','interp','FaceVertexAlphaData',alpha_lhs,'AlphaDataMapping','none');
    
    
    view([-90, 0]);
    lh1 = camlight('left'); set(lh1, 'Color', [0.8 0.8 0.8]);
    lh2 = camlight('right'); set(lh2, 'Color', [0.8 0.8 0.8]);
    material dull;
    axis off;
    
    % Adjust the position of the axes
    set(ax1, 'Position', [0 0.15 0.95 0.7]);
    
    % Set the same color limits for both axes
    clim = [-0.5, 0.5];
    ax1.CLim = clim;
    
    % Create a single shared colorbar
    c = colorbar('Orientation', 'horizontal');
    set(c, 'Position', [0.4 0.05 0.2 0.03]);

    % Adjust the title
    value = strsplit(images{i}, '_');
    value = value{end};
    value = value(1:end-4);
    sgtitle(['ALFF t-values map of Age. Uncorrected (' value ')'])

    % Save the figure
    saveas_name = fullfile('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/keyFigures/lmer_tmaps/ALFF/with_motionParam/', ['ALFF_tmap_Age_uncorrected_' value '.png']);
    saveas(gcf, saveas_name);
    
end

%% ALFF tmap Age - corrected -with_motionParam

% List of images
images = {'ALFF_tmap_Age_fullMod_corrected_0.01.mgz', 
          'ALFF_tmap_Age_fullMod_corrected_0.05.mgz',
          'ALFF_tmap_Age_fullMod_corrected_0.1.mgz',
          'ALFF_tmap_Age_fullMod_corrected_0.25.mgz',
          'ALFF_tmap_Age_fullMod_corrected_0.5.mgz'};

for i = 1:length(images)
    img_path = fullfile('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF_fssym/stat/with_motionParam/fullmod/', images{i});
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
    scaled_data = (min(max(data, -0.5), 0.5) + 0.5) / (0.5*2);
    cidx_roi = round(scaled_data * (size(cmap_roi,1)-1)) + 1;
    
    % Set transparency for data less than 0
    alpha_lhs = ones(size(data));
    alpha_lhs(data == 0) = 0; % Set alpha to 0 for data < 0
    patch('Faces',lh_faces+1,'Vertices',lh_vertices,'FaceVertexCData',cmap_roi(cidx_roi(1:numel(data)),:),'FaceColor','interp','EdgeColor','none','FaceAlpha','interp','FaceVertexAlphaData',alpha_lhs,'AlphaDataMapping','none');
    
    
    view([-90, 0]);
    lh1 = camlight('left'); set(lh1, 'Color', [0.8 0.8 0.8]);
    lh2 = camlight('right'); set(lh2, 'Color', [0.8 0.8 0.8]);
    material dull;
    axis off;
    
    % Adjust the position of the axes
    set(ax1, 'Position', [0 0.15 0.95 0.7]);
    
    % Set the same color limits for both axes
    clim = [-0.5, 0.5];
    ax1.CLim = clim;
    
    % Create a single shared colorbar
    c = colorbar('Orientation', 'horizontal');
    set(c, 'Position', [0.4 0.05 0.2 0.03]);

    % Adjust the title
    value = strsplit(images{i}, '_');
    value = value{end};
    value = value(1:end-4);
    sgtitle(['ALFF t-values map of Age. FDR corrected (' value ')'])

    % Save the figure
    saveas_name = fullfile('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/keyFigures/lmer_tmaps/ALFF/with_motionParam/', ['ALFF_tmap_Age_corrected_' value '.png']);
    saveas(gcf, saveas_name);
    
end

%% ALFF tmap TinnitusStatus - Uncorrected -with_motionParam

% List of images
images = {'ALFF_tmap_tinStat_fullMod_uncorrected_0.01.mgz', 
          'ALFF_tmap_tinStat_fullMod_uncorrected_0.05.mgz',
          'ALFF_tmap_tinStat_fullMod_uncorrected_0.1.mgz',
          'ALFF_tmap_tinStat_fullMod_uncorrected_0.25.mgz',
          'ALFF_tmap_tinStat_fullMod_uncorrected_0.5.mgz'};

for i = 1:length(images)
    img_path = fullfile('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF_fssym/stat/with_motionParam/fullmod/', images{i});
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
    scaled_data = (min(max(data, -0.5), 0.5) + 0.5) / (0.5*2);
    cidx_roi = round(scaled_data * (size(cmap_roi,1)-1)) + 1;
    
    % Set transparency for data less than 0
    alpha_lhs = ones(size(data));
    alpha_lhs(data == 0) = 0; % Set alpha to 0 for data < 0
    patch('Faces',lh_faces+1,'Vertices',lh_vertices,'FaceVertexCData',cmap_roi(cidx_roi(1:numel(data)),:),'FaceColor','interp','EdgeColor','none','FaceAlpha','interp','FaceVertexAlphaData',alpha_lhs,'AlphaDataMapping','none');
    
    
    view([-90, 0]);
    lh1 = camlight('left'); set(lh1, 'Color', [0.8 0.8 0.8]);
    lh2 = camlight('right'); set(lh2, 'Color', [0.8 0.8 0.8]);
    material dull;
    axis off;
    
    % Adjust the position of the axes
    set(ax1, 'Position', [0 0.15 0.95 0.7]);
    
    % Set the same color limits for both axes
    clim = [-0.5, 0.5];
    ax1.CLim = clim;
    
    % Create a single shared colorbar
    c = colorbar('Orientation', 'horizontal');
    set(c, 'Position', [0.4 0.05 0.2 0.03]);

    % Adjust the title
    value = strsplit(images{i}, '_');
    value = value{end};
    value = value(1:end-4);
    sgtitle(['ALFF t-values map of TinnitusStatus. Uncorrected (' value ')'])

    % Save the figure
    saveas_name = fullfile('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/keyFigures/lmer_tmaps/ALFF/with_motionParam/', ['ALFF_tmap_tinStat_uncorrected_' value '.png']);
    saveas(gcf, saveas_name);
    
end

%% ALFF tmap TinnitusStatus - corrected -with_motionParam

% List of images
images = {'ALFF_tmap_tinStat_fullMod_corrected_0.01.mgz', 
          'ALFF_tmap_tinStat_fullMod_corrected_0.05.mgz',
          'ALFF_tmap_tinStat_fullMod_corrected_0.1.mgz',
          'ALFF_tmap_tinStat_fullMod_corrected_0.25.mgz',
          'ALFF_tmap_tinStat_fullMod_corrected_0.5.mgz'};

for i = 1:length(images)
    img_path = fullfile('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF_fssym/stat/with_motionParam/fullmod/', images{i});
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
    scaled_data = (min(max(data, -0.5), 0.5) + 0.5) / (0.5*2);
    cidx_roi = round(scaled_data * (size(cmap_roi,1)-1)) + 1;
    
    % Set transparency for data less than 0
    alpha_lhs = ones(size(data));
    alpha_lhs(data == 0) = 0; % Set alpha to 0 for data < 0
    patch('Faces',lh_faces+1,'Vertices',lh_vertices,'FaceVertexCData',cmap_roi(cidx_roi(1:numel(data)),:),'FaceColor','interp','EdgeColor','none','FaceAlpha','interp','FaceVertexAlphaData',alpha_lhs,'AlphaDataMapping','none');
    
    
    view([-90, 0]);
    lh1 = camlight('left'); set(lh1, 'Color', [0.8 0.8 0.8]);
    lh2 = camlight('right'); set(lh2, 'Color', [0.8 0.8 0.8]);
    material dull;
    axis off;
    
    % Adjust the position of the axes
    set(ax1, 'Position', [0 0.15 0.95 0.7]);
    
    % Set the same color limits for both axes
    clim = [-0.5, 0.5];
    ax1.CLim = clim;
    
    % Create a single shared colorbar
    c = colorbar('Orientation', 'horizontal');
    set(c, 'Position', [0.4 0.05 0.2 0.03]);

    % Adjust the title
    value = strsplit(images{i}, '_');
    value = value{end};
    value = value(1:end-4);
    sgtitle(['ALFF t-values map of TinnitusStatus. FDR corrected (' value ')'])

    % Save the figure
    saveas_name = fullfile('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/keyFigures/lmer_tmaps/ALFF/with_motionParam/', ['ALFF_tmap_tinStat_corrected_' value '.png']);
    saveas(gcf, saveas_name);
    
end

%% ALFF tmap MotionAbsMean - Uncorrected -with_motionParam

% List of images
images = {'ALFF_tmap_MotionAbsMean_fullMod_uncorrected_0.01.mgz', 
          'ALFF_tmap_MotionAbsMean_fullMod_uncorrected_0.05.mgz',
          'ALFF_tmap_MotionAbsMean_fullMod_uncorrected_0.1.mgz',
          'ALFF_tmap_MotionAbsMean_fullMod_uncorrected_0.25.mgz',
          'ALFF_tmap_MotionAbsMean_fullMod_uncorrected_0.5.mgz'};

for i = 1:length(images)
    img_path = fullfile('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF_fssym/stat/with_motionParam/fullmod/', images{i});
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
    scaled_data = (min(max(data, -0.5), 0.5) + 0.5) / (0.5*2);
    cidx_roi = round(scaled_data * (size(cmap_roi,1)-1)) + 1;
    
    % Set transparency for data less than 0
    alpha_lhs = ones(size(data));
    alpha_lhs(data == 0) = 0; % Set alpha to 0 for data < 0
    patch('Faces',lh_faces+1,'Vertices',lh_vertices,'FaceVertexCData',cmap_roi(cidx_roi(1:numel(data)),:),'FaceColor','interp','EdgeColor','none','FaceAlpha','interp','FaceVertexAlphaData',alpha_lhs,'AlphaDataMapping','none');
    
    
    view([-90, 0]);
    lh1 = camlight('left'); set(lh1, 'Color', [0.8 0.8 0.8]);
    lh2 = camlight('right'); set(lh2, 'Color', [0.8 0.8 0.8]);
    material dull;
    axis off;
    
    % Adjust the position of the axes
    set(ax1, 'Position', [0 0.15 0.95 0.7]);
    
    % Set the same color limits for both axes
    clim = [-0.5, 0.5];
    ax1.CLim = clim;
    
    % Create a single shared colorbar
    c = colorbar('Orientation', 'horizontal');
    set(c, 'Position', [0.4 0.05 0.2 0.03]);

    % Adjust the title
    value = strsplit(images{i}, '_');
    value = value{end};
    value = value(1:end-4);
    sgtitle(['ALFF t-values map of MotionAbsMean. Uncorrected (' value ')'])

    % Save the figure
    saveas_name = fullfile('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/keyFigures/lmer_tmaps/ALFF/with_motionParam/', ['ALFF_tmap_MotionAbsMean_uncorrected_' value '.png']);
    saveas(gcf, saveas_name);
    
end

%% ALFF tmap MotionAbsMean - corrected -with_motionParam

% List of images
images = {'ALFF_tmap_MotionAbsMean_fullMod_corrected_0.01.mgz', 
          'ALFF_tmap_MotionAbsMean_fullMod_corrected_0.05.mgz',
          'ALFF_tmap_MotionAbsMean_fullMod_corrected_0.1.mgz',
          'ALFF_tmap_MotionAbsMean_fullMod_corrected_0.25.mgz',
          'ALFF_tmap_MotionAbsMean_fullMod_corrected_0.5.mgz'};

for i = 1:length(images)
    img_path = fullfile('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF_fssym/stat/with_motionParam/fullmod/', images{i});
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
    scaled_data = (min(max(data, -0.5), 0.5) + 0.5) / (0.5*2);
    cidx_roi = round(scaled_data * (size(cmap_roi,1)-1)) + 1;
    
    % Set transparency for data less than 0
    alpha_lhs = ones(size(data));
    alpha_lhs(data == 0) = 0; % Set alpha to 0 for data < 0
    patch('Faces',lh_faces+1,'Vertices',lh_vertices,'FaceVertexCData',cmap_roi(cidx_roi(1:numel(data)),:),'FaceColor','interp','EdgeColor','none','FaceAlpha','interp','FaceVertexAlphaData',alpha_lhs,'AlphaDataMapping','none');
    
    
    view([-90, 0]);
    lh1 = camlight('left'); set(lh1, 'Color', [0.8 0.8 0.8]);
    lh2 = camlight('right'); set(lh2, 'Color', [0.8 0.8 0.8]);
    material dull;
    axis off;
    
    % Adjust the position of the axes
    set(ax1, 'Position', [0 0.15 0.95 0.7]);
    
    % Set the same color limits for both axes
    clim = [-0.5, 0.5];
    ax1.CLim = clim;
    
    % Create a single shared colorbar
    c = colorbar('Orientation', 'horizontal');
    set(c, 'Position', [0.4 0.05 0.2 0.03]);

    % Adjust the title
    value = strsplit(images{i}, '_');
    value = value{end};
    value = value(1:end-4);
    sgtitle(['ALFF t-values map of MotionAbsMean. FDR corrected (' value ')'])

    % Save the figure
    saveas_name = fullfile('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/keyFigures/lmer_tmaps/ALFF/with_motionParam/', ['ALFF_tmap_MotionAbsMean_corrected_' value '.png']);
    saveas(gcf, saveas_name);
    
end

%% ALFF tmap MotionRelMean - Uncorrected -with_motionParam

% List of images
images = {'ALFF_tmap_MotionRelMean_fullMod_uncorrected_0.01.mgz', 
          'ALFF_tmap_MotionRelMean_fullMod_uncorrected_0.05.mgz',
          'ALFF_tmap_MotionRelMean_fullMod_uncorrected_0.1.mgz',
          'ALFF_tmap_MotionRelMean_fullMod_uncorrected_0.25.mgz',
          'ALFF_tmap_MotionRelMean_fullMod_uncorrected_0.5.mgz'};

for i = 1:length(images)
    img_path = fullfile('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF_fssym/stat/with_motionParam/fullmod/', images{i});
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
    scaled_data = (min(max(data, -3), 3) + 3) / (3*2);
    cidx_roi = round(scaled_data * (size(cmap_roi,1)-1)) + 1;
    
    % Set transparency for data less than 0
    alpha_lhs = ones(size(data));
    alpha_lhs(data == 0) = 0; % Set alpha to 0 for data < 0
    patch('Faces',lh_faces+1,'Vertices',lh_vertices,'FaceVertexCData',cmap_roi(cidx_roi(1:numel(data)),:),'FaceColor','interp','EdgeColor','none','FaceAlpha','interp','FaceVertexAlphaData',alpha_lhs,'AlphaDataMapping','none');
    
    
    view([-90, 0]);
    lh1 = camlight('left'); set(lh1, 'Color', [0.8 0.8 0.8]);
    lh2 = camlight('right'); set(lh2, 'Color', [0.8 0.8 0.8]);
    material dull;
    axis off;
    
    % Adjust the position of the axes
    set(ax1, 'Position', [0 0.15 0.95 0.7]);
    
    % Set the same color limits for both axes
    clim = [-3, 3];
    ax1.CLim = clim;
    
    % Create a single shared colorbar
    c = colorbar('Orientation', 'horizontal');
    set(c, 'Position', [0.4 0.05 0.2 0.03]);

    % Adjust the title
    value = strsplit(images{i}, '_');
    value = value{end};
    value = value(1:end-4);
    sgtitle(['ALFF t-values map of MotionRelMean. Uncorrected (' value ')'])

    % Save the figure
    saveas_name = fullfile('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/keyFigures/lmer_tmaps/ALFF/with_motionParam/', ['ALFF_tmap_MotionRelMean_uncorrected_' value '.png']);
    saveas(gcf, saveas_name);
    
end

%% ALFF tmap MotionRelMean - Corrected -with_motionParam

% List of images
images = {'ALFF_tmap_MotionRelMean_fullMod_corrected_0.01.mgz', 
          'ALFF_tmap_MotionRelMean_fullMod_corrected_0.05.mgz',
          'ALFF_tmap_MotionRelMean_fullMod_corrected_0.1.mgz',
          'ALFF_tmap_MotionRelMean_fullMod_corrected_0.25.mgz',
          'ALFF_tmap_MotionRelMean_fullMod_corrected_0.5.mgz'};

for i = 1:length(images)
    img_path = fullfile('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF_fssym/stat/with_motionParam/fullmod/', images{i});
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
    scaled_data = (min(max(data, -3), 3) + 3) / (3*2);
    cidx_roi = round(scaled_data * (size(cmap_roi,1)-1)) + 1;
    
    % Set transparency for data less than 0
    alpha_lhs = ones(size(data));
    alpha_lhs(data == 0) = 0; % Set alpha to 0 for data < 0
    patch('Faces',lh_faces+1,'Vertices',lh_vertices,'FaceVertexCData',cmap_roi(cidx_roi(1:numel(data)),:),'FaceColor','interp','EdgeColor','none','FaceAlpha','interp','FaceVertexAlphaData',alpha_lhs,'AlphaDataMapping','none');
    
    
    view([-90, 0]);
    lh1 = camlight('left'); set(lh1, 'Color', [0.8 0.8 0.8]);
    lh2 = camlight('right'); set(lh2, 'Color', [0.8 0.8 0.8]);
    material dull;
    axis off;
    
    % Adjust the position of the axes
    set(ax1, 'Position', [0 0.15 0.95 0.7]);
    
    % Set the same color limits for both axes
    clim = [-3, 3];
    ax1.CLim = clim;
    
    % Create a single shared colorbar
    c = colorbar('Orientation', 'horizontal');
    set(c, 'Position', [0.4 0.05 0.2 0.03]);

    % Adjust the title
    value = strsplit(images{i}, '_');
    value = value{end};
    value = value(1:end-4);
    sgtitle(['ALFF t-values map of MotionRelMean. FDR corrected (' value ')'])

    % Save the figure
    saveas_name = fullfile('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/keyFigures/lmer_tmaps/ALFF/with_motionParam/', ['ALFF_tmap_MotionRelMean_corrected_' value '.png']);
    saveas(gcf, saveas_name);
    
end





































%% ALFF tmap Age - Uncorrected -without_motionParam

% List of images
images = {'ALFF_tmap_Age_fullMod_uncorrected_0.01.mgz', 
          'ALFF_tmap_Age_fullMod_uncorrected_0.05.mgz',
          'ALFF_tmap_Age_fullMod_uncorrected_0.1.mgz',
          'ALFF_tmap_Age_fullMod_uncorrected_0.25.mgz',
          'ALFF_tmap_Age_fullMod_uncorrected_0.5.mgz'};

for i = 1:length(images)
    img_path = fullfile('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF_fssym/stat/without_motionParam/fullmod/', images{i});
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
    scaled_data = (min(max(data, -0.5), 0.5) + 0.5) / (0.5*2);
    cidx_roi = round(scaled_data * (size(cmap_roi,1)-1)) + 1;
    
    % Set transparency for data less than 0
    alpha_lhs = ones(size(data));
    alpha_lhs(data == 0) = 0; % Set alpha to 0 for data < 0
    patch('Faces',lh_faces+1,'Vertices',lh_vertices,'FaceVertexCData',cmap_roi(cidx_roi(1:numel(data)),:),'FaceColor','interp','EdgeColor','none','FaceAlpha','interp','FaceVertexAlphaData',alpha_lhs,'AlphaDataMapping','none');
    
    
    view([-90, 0]);
    lh1 = camlight('left'); set(lh1, 'Color', [0.8 0.8 0.8]);
    lh2 = camlight('right'); set(lh2, 'Color', [0.8 0.8 0.8]);
    material dull;
    axis off;
    
    % Adjust the position of the axes
    set(ax1, 'Position', [0 0.15 0.95 0.7]);
    
    % Set the same color limits for both axes
    clim = [-0.5, 0.5];
    ax1.CLim = clim;
    
    % Create a single shared colorbar
    c = colorbar('Orientation', 'horizontal');
    set(c, 'Position', [0.4 0.05 0.2 0.03]);

    % Adjust the title
    value = strsplit(images{i}, '_');
    value = value{end};
    value = value(1:end-4);
    sgtitle(['ALFF t-values map of Age. Uncorrected (' value ')'])

    % Save the figure
    saveas_name = fullfile('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/keyFigures/lmer_tmaps/ALFF/without_motionParam/', ['ALFF_tmap_Age_uncorrected_' value '.png']);
    saveas(gcf, saveas_name);
    
end

%% ALFF tmap Age - corrected -without_motionParam

% List of images
images = {'ALFF_tmap_Age_fullMod_corrected_0.01.mgz', 
          'ALFF_tmap_Age_fullMod_corrected_0.05.mgz',
          'ALFF_tmap_Age_fullMod_corrected_0.1.mgz',
          'ALFF_tmap_Age_fullMod_corrected_0.25.mgz',
          'ALFF_tmap_Age_fullMod_corrected_0.5.mgz'};

for i = 1:length(images)
    img_path = fullfile('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF_fssym/stat/without_motionParam/fullmod/', images{i});
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
    scaled_data = (min(max(data, -0.5), 0.5) + 0.5) / (0.5*2);
    cidx_roi = round(scaled_data * (size(cmap_roi,1)-1)) + 1;
    
    % Set transparency for data less than 0
    alpha_lhs = ones(size(data));
    alpha_lhs(data == 0) = 0; % Set alpha to 0 for data < 0
    patch('Faces',lh_faces+1,'Vertices',lh_vertices,'FaceVertexCData',cmap_roi(cidx_roi(1:numel(data)),:),'FaceColor','interp','EdgeColor','none','FaceAlpha','interp','FaceVertexAlphaData',alpha_lhs,'AlphaDataMapping','none');
    
    
    view([-90, 0]);
    lh1 = camlight('left'); set(lh1, 'Color', [0.8 0.8 0.8]);
    lh2 = camlight('right'); set(lh2, 'Color', [0.8 0.8 0.8]);
    material dull;
    axis off;
    
    % Adjust the position of the axes
    set(ax1, 'Position', [0 0.15 0.95 0.7]);
    
    % Set the same color limits for both axes
    clim = [-0.5, 0.5];
    ax1.CLim = clim;
    
    % Create a single shared colorbar
    c = colorbar('Orientation', 'horizontal');
    set(c, 'Position', [0.4 0.05 0.2 0.03]);

    % Adjust the title
    value = strsplit(images{i}, '_');
    value = value{end};
    value = value(1:end-4);
    sgtitle(['ALFF t-values map of Age. FDR corrected (' value ')'])

    % Save the figure
    saveas_name = fullfile('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/keyFigures/lmer_tmaps/ALFF/without_motionParam/', ['ALFF_tmap_Age_corrected_' value '.png']);
    saveas(gcf, saveas_name);
    
end

%% ALFF tmap TinnitusStatus - Uncorrected -without_motionParam

% List of images
images = {'ALFF_tmap_tinStat_fullMod_uncorrected_0.01.mgz', 
          'ALFF_tmap_tinStat_fullMod_uncorrected_0.05.mgz',
          'ALFF_tmap_tinStat_fullMod_uncorrected_0.1.mgz',
          'ALFF_tmap_tinStat_fullMod_uncorrected_0.25.mgz',
          'ALFF_tmap_tinStat_fullMod_uncorrected_0.5.mgz'};

for i = 1:length(images)
    img_path = fullfile('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF_fssym/stat/without_motionParam/fullmod/', images{i});
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
    scaled_data = (min(max(data, -0.5), 0.5) + 0.5) / (0.5*2);
    cidx_roi = round(scaled_data * (size(cmap_roi,1)-1)) + 1;
    
    % Set transparency for data less than 0
    alpha_lhs = ones(size(data));
    alpha_lhs(data == 0) = 0; % Set alpha to 0 for data < 0
    patch('Faces',lh_faces+1,'Vertices',lh_vertices,'FaceVertexCData',cmap_roi(cidx_roi(1:numel(data)),:),'FaceColor','interp','EdgeColor','none','FaceAlpha','interp','FaceVertexAlphaData',alpha_lhs,'AlphaDataMapping','none');
    
    
    view([-90, 0]);
    lh1 = camlight('left'); set(lh1, 'Color', [0.8 0.8 0.8]);
    lh2 = camlight('right'); set(lh2, 'Color', [0.8 0.8 0.8]);
    material dull;
    axis off;
    
    % Adjust the position of the axes
    set(ax1, 'Position', [0 0.15 0.95 0.7]);
    
    % Set the same color limits for both axes
    clim = [-0.5, 0.5];
    ax1.CLim = clim;
    
    % Create a single shared colorbar
    c = colorbar('Orientation', 'horizontal');
    set(c, 'Position', [0.4 0.05 0.2 0.03]);

    % Adjust the title
    value = strsplit(images{i}, '_');
    value = value{end};
    value = value(1:end-4);
    sgtitle(['ALFF t-values map of TinnitusStatus. Uncorrected (' value ')'])

    % Save the figure
    saveas_name = fullfile('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/keyFigures/lmer_tmaps/ALFF/without_motionParam/', ['ALFF_tmap_tinStat_uncorrected_' value '.png']);
    saveas(gcf, saveas_name);
    
end

%% ALFF tmap TinnitusStatus - corrected -without_motionParam

% List of images
images = {'ALFF_tmap_tinStat_fullMod_corrected_0.01.mgz', 
          'ALFF_tmap_tinStat_fullMod_corrected_0.05.mgz',
          'ALFF_tmap_tinStat_fullMod_corrected_0.1.mgz',
          'ALFF_tmap_tinStat_fullMod_corrected_0.25.mgz',
          'ALFF_tmap_tinStat_fullMod_corrected_0.5.mgz'};

for i = 1:length(images)
    img_path = fullfile('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF_fssym/stat/without_motionParam/fullmod/', images{i});
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
    scaled_data = (min(max(data, -0.5), 0.5) + 0.5) / (0.5*2);
    cidx_roi = round(scaled_data * (size(cmap_roi,1)-1)) + 1;
    
    % Set transparency for data less than 0
    alpha_lhs = ones(size(data));
    alpha_lhs(data == 0) = 0; % Set alpha to 0 for data < 0
    patch('Faces',lh_faces+1,'Vertices',lh_vertices,'FaceVertexCData',cmap_roi(cidx_roi(1:numel(data)),:),'FaceColor','interp','EdgeColor','none','FaceAlpha','interp','FaceVertexAlphaData',alpha_lhs,'AlphaDataMapping','none');
    
    
    view([-90, 0]);
    lh1 = camlight('left'); set(lh1, 'Color', [0.8 0.8 0.8]);
    lh2 = camlight('right'); set(lh2, 'Color', [0.8 0.8 0.8]);
    material dull;
    axis off;
    
    % Adjust the position of the axes
    set(ax1, 'Position', [0 0.15 0.95 0.7]);
    
    % Set the same color limits for both axes
    clim = [-0.5, 0.5];
    ax1.CLim = clim;
    
    % Create a single shared colorbar
    c = colorbar('Orientation', 'horizontal');
    set(c, 'Position', [0.4 0.05 0.2 0.03]);

    % Adjust the title
    value = strsplit(images{i}, '_');
    value = value{end};
    value = value(1:end-4);
    sgtitle(['ALFF t-values map of TinnitusStatus. FDR corrected (' value ')'])

    % Save the figure
    saveas_name = fullfile('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/keyFigures/lmer_tmaps/ALFF/without_motionParam/', ['ALFF_tmap_tinStat_corrected_' value '.png']);
    saveas(gcf, saveas_name);
    
end
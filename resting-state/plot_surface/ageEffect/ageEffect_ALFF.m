clc;
clear;
close all;
% Path to your subject's directory (replace with your own)
subject_dir = '/Volumes/gdrive4tb/IGNITE/resting-state/surface/recon/fsaverage';

% Read the surface
[lh_vertices, lh_faces] = read_surf(fullfile(subject_dir, 'surf', 'lh.inflated'));
[rh_vertices, rh_faces] = read_surf(fullfile(subject_dir, 'surf', 'rh.inflated'));

% Read the curvature data
lh_curv = read_curv(fullfile(subject_dir, 'surf', 'lh.curv'));
rh_curv = read_curv(fullfile(subject_dir, 'surf', 'rh.curv'));

%% ALFF ageEffect median
img1 = MRIread('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF/ageEffect/ALFF_lh_ageEffect.mgz');
img2 = MRIread('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF/ageEffect/ALFF_rh_ageEffect.mgz');
data1 = img1.vol';
data2 = img2.vol';

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
scaled_data = (min(max(all_data, -0.5), 0.5) + 0.5) / (0.5*2);
cidx_roi = round(scaled_data * (size(cmap_roi,1)-1)) + 1;
patch('Faces',lh_faces+1,'Vertices',lh_vertices,'FaceVertexCData',cmap_roi(cidx_roi(1:numel(data1)),:),'FaceColor','interp','EdgeColor','none','FaceAlpha',0.7);

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
patch('Faces',rh_faces+1,'Vertices',rh_vertices,'FaceVertexCData',cmap_roi(cidx_roi(numel(data1)+1:end),:),'FaceColor','interp','EdgeColor','none','FaceAlpha',0.7);
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
clim = [-0.5, 0.5];
ax1.CLim = clim;
ax2.CLim = clim;

% Create a single shared colorbar
c = colorbar('Orientation', 'horizontal');
set(c, 'Position', [0.4 0.05 0.2 0.03]);

sgtitle('ALFF Age Effect (older-younger)')

saveas(gcf, '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/keyFigures/ALFF_ageEffect_older_younger_median.png');


%% ALFF ageEffect pctl
img1 = MRIread('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF/ageEffect/ALFF_lh_ageEffect_percentiles.mgz');
img2 = MRIread('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF/ageEffect/ALFF_rh_ageEffect_percentiles.mgz');
data1 = img1.vol';
data2 = img2.vol';

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
scaled_data = (min(max(all_data, -0.5), 0.5) + 0.5) / (0.5*2);
cidx_roi = round(scaled_data * (size(cmap_roi,1)-1)) + 1;
patch('Faces',lh_faces+1,'Vertices',lh_vertices,'FaceVertexCData',cmap_roi(cidx_roi(1:numel(data1)),:),'FaceColor','interp','EdgeColor','none','FaceAlpha',0.7);

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
patch('Faces',rh_faces+1,'Vertices',rh_vertices,'FaceVertexCData',cmap_roi(cidx_roi(numel(data1)+1:end),:),'FaceColor','interp','EdgeColor','none','FaceAlpha',0.7);
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
clim = [-0.5, 0.5];
ax1.CLim = clim;
ax2.CLim = clim;

% Create a single shared colorbar
c = colorbar('Orientation', 'horizontal');
set(c, 'Position', [0.4 0.05 0.2 0.03]);

sgtitle('ALFF Age Effect Percentile (older-younger)')

saveas(gcf, '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/keyFigures/ALFF_ageEffect_older_younger_pctl.png');

clc
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

% Read the masks
temporal_mask_lh = MRIread('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/destrieux_fsavg/temporalLobe_mask_lh.mgh');
temporal_mask_rh = MRIread('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/destrieux_fsavg/temporalLobe_mask_rh.mgh');

%% ReHo noTin
img1 = MRIread('/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ReHoall/temporal/merge_mean/allSubj_lh_ReHoall_merged_mean_noTin_smooth5.mgz');
img2 = MRIread('/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ReHoall/temporal/merge_mean/allSubj_rh_ReHoall_merged_mean_noTin_smooth5.mgz');
data1 = img1.vol';
data2 = img2.vol';

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
scaled_data = (min(max(all_data, -0.1), 0.1) + 0.1) / (0.1*2);
cidx_roi = round(scaled_data * (size(cmap_roi,1)-1)) + 1;

% Set transparency for data less than 0
alpha_lhs_masked = ones(size(masked_data1));
alpha_lhs_masked(masked_data1 == 0 | isnan(masked_data1)) = 0;
patch('Faces',lh_faces+1,'Vertices',lh_vertices,'FaceVertexCData',cmap_roi(cidx_roi(1:numel(masked_data1)),:),'FaceColor','interp','EdgeColor','none','FaceAlpha','interp','FaceVertexAlphaData',alpha_lhs_masked,'AlphaDataMapping','none');

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
alpha_rhs_masked = ones(size(masked_data2));
alpha_rhs_masked(masked_data2 == 0 | isnan(masked_data2)) = 0;
patch('Faces',rh_faces+1,'Vertices',rh_vertices,'FaceVertexCData',cmap_roi(cidx_roi(numel(masked_data1)+1:end),:),'FaceColor','interp','EdgeColor','none','FaceAlpha','interp','FaceVertexAlphaData',alpha_rhs_masked,'AlphaDataMapping','none');

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
clim = [-0.1, 0.1];
ax1.CLim = clim;
ax2.CLim = clim;

% Create a single shared colorbar
c = colorbar('Orientation', 'horizontal');
set(c, 'Position', [0.4 0.05 0.2 0.03]);

sgtitle('ReHo noTin')

saveas(gcf, '/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/keyFigures/allSubj_ReHo_merge_mean_noTin_smooth5_temporal.png');


%% ReHo tin
img1 = MRIread('/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ReHoall/temporal/merge_mean/allSubj_lh_ReHoall_merged_mean_tin_smooth5.mgz');
img2 = MRIread('/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ReHoall/temporal/merge_mean/allSubj_rh_ReHoall_merged_mean_tin_smooth5.mgz');
data1 = img1.vol';
data2 = img2.vol';

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
scaled_data = (min(max(all_data, -0.1), 0.1) + 0.1) / (0.1*2);
cidx_roi = round(scaled_data * (size(cmap_roi,1)-1)) + 1;

% Set transparency for data less than 0
alpha_lhs_masked = ones(size(masked_data1));
alpha_lhs_masked(masked_data1 == 0 | isnan(masked_data1)) = 0;
patch('Faces',lh_faces+1,'Vertices',lh_vertices,'FaceVertexCData',cmap_roi(cidx_roi(1:numel(masked_data1)),:),'FaceColor','interp','EdgeColor','none','FaceAlpha','interp','FaceVertexAlphaData',alpha_lhs_masked,'AlphaDataMapping','none');

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
alpha_rhs_masked = ones(size(masked_data2));
alpha_rhs_masked(masked_data2 == 0 | isnan(masked_data2)) = 0;
patch('Faces',rh_faces+1,'Vertices',rh_vertices,'FaceVertexCData',cmap_roi(cidx_roi(numel(masked_data1)+1:end),:),'FaceColor','interp','EdgeColor','none','FaceAlpha','interp','FaceVertexAlphaData',alpha_rhs_masked,'AlphaDataMapping','none');

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
clim = [-0.1, 0.1];
ax1.CLim = clim;
ax2.CLim = clim;

% Create a single shared colorbar
c = colorbar('Orientation', 'horizontal');
set(c, 'Position', [0.4 0.05 0.2 0.03]);

sgtitle('ReHo tin')

saveas(gcf, '/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/keyFigures/allSubj_ReHo_merge_mean_tin_smooth5_temporal.png');


%% ReHo noTin -rest
img1 = MRIread('/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ReHo/temporal/merge_mean/allSubj_lh_ReHo_merged_mean_noTin_rest_smooth5.mgz');
img2 = MRIread('/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ReHo/temporal/merge_mean/allSubj_rh_ReHo_merged_mean_noTin_rest_smooth5.mgz');
data1 = img1.vol';
data2 = img2.vol';

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
scaled_data = (min(max(all_data, -0.1), 0.1) + 0.1) / (0.1*2);
cidx_roi = round(scaled_data * (size(cmap_roi,1)-1)) + 1;

% Set transparency for data less than 0
alpha_lhs_masked = ones(size(masked_data1));
alpha_lhs_masked(masked_data1 == 0 | isnan(masked_data1)) = 0;
patch('Faces',lh_faces+1,'Vertices',lh_vertices,'FaceVertexCData',cmap_roi(cidx_roi(1:numel(masked_data1)),:),'FaceColor','interp','EdgeColor','none','FaceAlpha','interp','FaceVertexAlphaData',alpha_lhs_masked,'AlphaDataMapping','none');

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
alpha_rhs_masked = ones(size(masked_data2));
alpha_rhs_masked(masked_data2 == 0 | isnan(masked_data2)) = 0;
patch('Faces',rh_faces+1,'Vertices',rh_vertices,'FaceVertexCData',cmap_roi(cidx_roi(numel(masked_data1)+1:end),:),'FaceColor','interp','EdgeColor','none','FaceAlpha','interp','FaceVertexAlphaData',alpha_rhs_masked,'AlphaDataMapping','none');

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
clim = [-0.1, 0.1];
ax1.CLim = clim;
ax2.CLim = clim;

% Create a single shared colorbar
c = colorbar('Orientation', 'horizontal');
set(c, 'Position', [0.4 0.05 0.2 0.03]);

sgtitle('ReHo noTin-rest')

saveas(gcf, '/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/keyFigures/allSubj_ReHo_merge_mean_noTin_rest_smooth5_temporal.png');

%% ReHo noTin -vis
img1 = MRIread('/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ReHo/temporal/merge_mean/allSubj_lh_ReHo_merged_mean_noTin_vis_smooth5.mgz');
img2 = MRIread('/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ReHo/temporal/merge_mean/allSubj_rh_ReHo_merged_mean_noTin_vis_smooth5.mgz');
data1 = img1.vol';
data2 = img2.vol';

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
scaled_data = (min(max(all_data, -0.1), 0.1) + 0.1) / (0.1*2);
cidx_roi = round(scaled_data * (size(cmap_roi,1)-1)) + 1;

% Set transparency for data less than 0
alpha_lhs_masked = ones(size(masked_data1));
alpha_lhs_masked(masked_data1 == 0 | isnan(masked_data1)) = 0;
patch('Faces',lh_faces+1,'Vertices',lh_vertices,'FaceVertexCData',cmap_roi(cidx_roi(1:numel(masked_data1)),:),'FaceColor','interp','EdgeColor','none','FaceAlpha','interp','FaceVertexAlphaData',alpha_lhs_masked,'AlphaDataMapping','none');

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
alpha_rhs_masked = ones(size(masked_data2));
alpha_rhs_masked(masked_data2 == 0 | isnan(masked_data2)) = 0;
patch('Faces',rh_faces+1,'Vertices',rh_vertices,'FaceVertexCData',cmap_roi(cidx_roi(numel(masked_data1)+1:end),:),'FaceColor','interp','EdgeColor','none','FaceAlpha','interp','FaceVertexAlphaData',alpha_rhs_masked,'AlphaDataMapping','none');

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
clim = [-0.1, 0.1];
ax1.CLim = clim;
ax2.CLim = clim;

% Create a single shared colorbar
c = colorbar('Orientation', 'horizontal');
set(c, 'Position', [0.4 0.05 0.2 0.03]);

sgtitle('ReHo noTin-vis')

saveas(gcf, '/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/keyFigures/allSubj_ReHo_merge_mean_noTin_vis_smooth5_temporal.png');

%% ReHo Tin -rest
img1 = MRIread('/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ReHo/temporal/merge_mean/allSubj_lh_ReHo_merged_mean_tin_rest_smooth5.mgz');
img2 = MRIread('/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ReHo/temporal/merge_mean/allSubj_rh_ReHo_merged_mean_tin_rest_smooth5.mgz');
data1 = img1.vol';
data2 = img2.vol';

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
scaled_data = (min(max(all_data, -0.1), 0.1) + 0.1) / (0.1*2);
cidx_roi = round(scaled_data * (size(cmap_roi,1)-1)) + 1;

% Set transparency for data less than 0
alpha_lhs_masked = ones(size(masked_data1));
alpha_lhs_masked(masked_data1 == 0 | isnan(masked_data1)) = 0;
patch('Faces',lh_faces+1,'Vertices',lh_vertices,'FaceVertexCData',cmap_roi(cidx_roi(1:numel(masked_data1)),:),'FaceColor','interp','EdgeColor','none','FaceAlpha','interp','FaceVertexAlphaData',alpha_lhs_masked,'AlphaDataMapping','none');

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
alpha_rhs_masked = ones(size(masked_data2));
alpha_rhs_masked(masked_data2 == 0 | isnan(masked_data2)) = 0;
patch('Faces',rh_faces+1,'Vertices',rh_vertices,'FaceVertexCData',cmap_roi(cidx_roi(numel(masked_data1)+1:end),:),'FaceColor','interp','EdgeColor','none','FaceAlpha','interp','FaceVertexAlphaData',alpha_rhs_masked,'AlphaDataMapping','none');

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
clim = [-0.1, 0.1];
ax1.CLim = clim;
ax2.CLim = clim;

% Create a single shared colorbar
c = colorbar('Orientation', 'horizontal');
set(c, 'Position', [0.4 0.05 0.2 0.03]);

sgtitle('ReHo Tin-rest')

saveas(gcf, '/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/keyFigures/allSubj_ReHo_merge_mean_tin_rest_smooth5_temporal.png');


%% ReHo Tin -vis
img1 = MRIread('/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ReHo/temporal/merge_mean/allSubj_lh_ReHo_merged_mean_tin_vis_smooth5.mgz');
img2 = MRIread('/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ReHo/temporal/merge_mean/allSubj_rh_ReHo_merged_mean_tin_vis_smooth5.mgz');
data1 = img1.vol';
data2 = img2.vol';

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
scaled_data = (min(max(all_data, -0.1), 0.1) + 0.1) / (0.1*2);
cidx_roi = round(scaled_data * (size(cmap_roi,1)-1)) + 1;

% Set transparency for data less than 0
alpha_lhs_masked = ones(size(masked_data1));
alpha_lhs_masked(masked_data1 == 0 | isnan(masked_data1)) = 0;
patch('Faces',lh_faces+1,'Vertices',lh_vertices,'FaceVertexCData',cmap_roi(cidx_roi(1:numel(masked_data1)),:),'FaceColor','interp','EdgeColor','none','FaceAlpha','interp','FaceVertexAlphaData',alpha_lhs_masked,'AlphaDataMapping','none');

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
alpha_rhs_masked = ones(size(masked_data2));
alpha_rhs_masked(masked_data2 == 0 | isnan(masked_data2)) = 0;
patch('Faces',rh_faces+1,'Vertices',rh_vertices,'FaceVertexCData',cmap_roi(cidx_roi(numel(masked_data1)+1:end),:),'FaceColor','interp','EdgeColor','none','FaceAlpha','interp','FaceVertexAlphaData',alpha_rhs_masked,'AlphaDataMapping','none');

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
clim = [-0.1, 0.1];
ax1.CLim = clim;
ax2.CLim = clim;

% Create a single shared colorbar
c = colorbar('Orientation', 'horizontal');
set(c, 'Position', [0.4 0.05 0.2 0.03]);

sgtitle('ReHo Tin-vis')

saveas(gcf, '/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/keyFigures/allSubj_ReHo_merge_mean_tin_vis_smooth5_temporal.png');

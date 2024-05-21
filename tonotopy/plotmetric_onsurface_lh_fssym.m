function plotmetric_onsurface_lh_fssym(subject_dir, metric_file, outp)

    % Create a new figure window of a specific size
    fig = figure('Position', [0, 0, 800, 450]);

    % ---- Left Hemisphere ---- %
    plotmetric_onlh(subject_dir, metric_file);
    
    % Remove axis
    axis off

    % ---- Shared colorbar ---- %
    colormap('jet');
    cb = colorbar('Orientation', 'horizontal');
    clim([1, 8]);  % Set the limits of the colorbar
    set(cb, 'Position', [0.4 0.05 0.2 0.03]);
    % Set ticks of the colorbar
    set(cb, 'XTick', 1:1:8);

    % Remove axis
    axis off
    
    % Save figure
    saveas(gcf, outp)

end

function plotmetric_onlh(subject_dir, metric_file)
    % Read the surface
    [lh_vertices, lh_faces] = read_surf(fullfile(subject_dir, 'surf', 'lh.inflated'));

    % Read the curvature data
    lh_curv = read_curv(fullfile(subject_dir, 'surf', 'lh.curv'));

    % Read metric data
    mgh = MRIread(metric_file);
    metric = mgh.vol(:);

    % Read the probability activation map and mask
    mri_probActMap = MRIread('/Volumes/gdrive4tb/IGNITE/tonotopy/surface/probActMap/probActMap.lh.fssym.mgz');
    mri_mask = MRIread('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/destrieux_fsavg/temporalLobe_mask_lh_fssym.mgh');
    
    % Find indices where probability activation map is greater than the threshold and masked
    idx = find(mri_probActMap.vol .* mri_mask.vol >= 35);
    
    % Set transparency values (FaceAlpha) for each vertex
    transparency = zeros(size(metric));
    transparency(idx) = 1;

    hold on

    % Map curvature data to a color
    cmap = colormap('gray');
    RANGE = 0.5; OFFSET = min(1-RANGE,0.2);
    cidx = round((RANGE/(max(lh_curv)-min(lh_curv))*(lh_curv-min(lh_curv))+OFFSET)*(size(cmap,1)-1))+1;
    patch('vertices', lh_vertices, 'faces', lh_faces+1, 'FaceVertexCData', cmap(cidx,:), 'FaceColor', 'interp', 'Edgecolor', 'none');

    % Map metric data to a color
    cmap_metric = colormap('turbo');
    metric = metric/8;
    cidx_metric = round((1/(max(metric)-min(metric))*(metric-min(metric)))*(size(cmap_metric,1)-1))+1;
    patch('vertices', lh_vertices, 'faces', lh_faces+1, 'FaceVertexCData', cmap_metric(cidx_metric,:), 'FaceColor', 'interp', 'Edgecolor', 'none', 'FaceVertexAlphaData', transparency, 'FaceAlpha', 'interp');
    view([-90, 0]);
    lh1 = camlight('left'); set(lh1, 'Color', [0.8 0.8 0.8]);
    lh2 = camlight('right'); set(lh2, 'Color', [0.8 0.8 0.8]);
    material dull;
    axis off;

    hold off
end

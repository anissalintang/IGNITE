function plot_probactmap_fssym(subject_dir, outp)

    % Create a new figure window of a specific size
    fig = figure('Position', [0, 0, 800, 450]);

    % ---- Left Hemisphere ---- %
    plotprobactmap_onlh(subject_dir);
    
    % Remove axis
    axis off
    
    % Save figure
    saveas(gcf, outp)

end

function plotprobactmap_onlh(subject_dir)
    % Read the surface
    [lh_vertices, lh_faces] = read_surf(fullfile(subject_dir, 'surf', 'lh.inflated'));

    % Read the curvature data
    lh_curv = read_curv(fullfile(subject_dir, 'surf', 'lh.curv'));

    % Read the probability activation map and mask
    mri_probActMap = MRIread('/Volumes/gdrive4tb/IGNITE/tonotopy/surface/probActMap/probActMap_sm.lh.fssym.mgz');
    mri_mask = MRIread('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/destrieux_fsavg/temporalLobe_mask_lh_fssym.mgh');
    
    % Find indices where probability activation map is greater than the threshold and masked
    idx = find(mri_probActMap.vol .* mri_mask.vol >= 35);
    
   % Create a colors array that's fully transparent by default
    colors = zeros(size(lh_vertices, 1), 4);
    colors(:, 4) = 0; % Set alpha (transparency) to 0
    
    % Set the color and opacity for the region of interest
    colors(idx, 1:3) = repmat([1, 1, 0], length(idx), 1); % set RGB to yellow
    colors(idx, 4) = 1; % Set alpha (transparency) to 1 (opaque)
    
    % Map curvature data to a color
    cmap = colormap('gray');
    RANGE = 0.5; OFFSET = min(1-RANGE,0.2);
    cidx = round((RANGE/(max(lh_curv)-min(lh_curv))*(lh_curv-min(lh_curv))+OFFSET)*(size(cmap,1)-1))+1;
    patch('vertices', lh_vertices, 'faces', lh_faces+1, 'FaceVertexCData', cmap(cidx,:), 'FaceColor', 'interp', 'Edgecolor', 'none');
    
    % Plot the region of interest with the yellow color
    patch('vertices', lh_vertices, 'faces', lh_faces+1, 'FaceVertexCData', colors(:, 1:3), 'FaceColor', 'interp', 'Edgecolor', 'none', 'FaceVertexAlphaData', colors(:, 4), 'FaceAlpha', 'interp');
    
    view([-90, 0]);
    lh1 = camlight('left'); set(lh1, 'Color', [0.8 0.8 0.8]);
    lh2 = camlight('right'); set(lh2, 'Color', [0.8 0.8 0.8]);
    material dull;
    axis off;

    hold off
end

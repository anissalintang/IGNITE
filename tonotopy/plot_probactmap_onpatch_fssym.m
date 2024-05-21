function plot_probactmap_onpatch_fssym(pth, AZ, FLIPX, FLIPY, outp)
    clc
    close all
    % Create a new figure window of a specific size
    fig = figure('Position', [0, 0, 600, 530]);

    % ---- Left Hemisphere ---- %
    plotmetric_onpatch(fullfile(pth, 'patch_fssym.mat'), AZ, FLIPX, FLIPY);
    
    % Remove axis
    axis off
    
    % Save figure
    saveas(gcf, outp)
end

function plotmetric_onpatch(patch_file, AZ, FLIPX, FLIPY)
    load(patch_file, 'ptch')
    load(patch_file, 'roi')

    vtc = ptch.flat;
    if FLIPX, vtc(:,1) = -vtc(:,1); end
    if FLIPY, vtc(:,2) = -vtc(:,2); end
    tri = ptch.tri;
    curv = -fthrcurv(ptch.curv, 25);
    pbdry = vtc(ptch.bdry, :);

    % Get ROI indices
    roi_idx = roi.map2ptch;
    vtc_roi = vtc(roi_idx, :);
    tri_roi = roi.tri;

    % Re-index the 'Faces' to match the ROI vertices
    [~, loc] = ismember(tri_roi, roi_idx);
    tri_roi = reshape(loc, size(tri_roi));

    hold on
    xlim([min(vtc(:,1)) max(vtc(:,1))]);
    ylim([min(vtc(:,2)) max(vtc(:,2))]);

    % Map curvature data to a color
    cmap = colormap('gray');
    RANGE = 0.5; OFFSET = min(1 - RANGE, 0.2);
    cidx = round((RANGE / (max(curv) - min(curv)) * (curv - min(curv)) + OFFSET) * (size(cmap, 1) - 1)) + 1;
    patch('vertices', vtc, 'faces', tri, 'FaceVertexCData', cmap(cidx, :), 'FaceColor', 'interp', 'Edgecolor', 'none');
    plot(pbdry(:, 1), pbdry(:, 2), 'Color', 'blue', 'LineWidth', 3);

    % Plot ROI with yellow color
    patch('vertices', vtc_roi, 'faces', tri_roi, 'FaceColor', 'yellow', 'Edgecolor', 'none', 'FaceAlpha', 0.7);

    hold off
end

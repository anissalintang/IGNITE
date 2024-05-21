function plotmetric_onpatch_lh_fssym(pth, AZ, FLIPX, FLIPY, metric_file, outp)
    clc
    close all
    % Create a new figure window of a specific size
    fig = figure('Position', [0, 0, 600, 530]);

    % ---- Left Hemisphere ---- %
    plotmetric_onpatch(fullfile(pth, 'patch_fssym.mat'), AZ, FLIPX, FLIPY, metric_file);
    
    % Remove axis
    axis off

    % ---- Shared colorbar ---- %
    colormap('jet');
    cb = colorbar('Orientation', 'horizontal');
    clim([1, 8]);  % Set the limits of the colorbar
    % Position format [left, bottom, width, height]
    %set(cb, 'Position', [0.92 0.1 0.01 0.8]);  % Positioning the colorbar at the center
    set(cb, 'Position', [0.4 0.05 0.2 0.03]);
    % Set ticks of the colorbar
    set(cb, 'XTick', 1:1:8);


    % Remove axis
    axis off
    
    % Save figure
    saveas(gcf, outp)

end

function plotmetric_onpatch(patch_file, AZ, FLIPX, FLIPY, metric_file)
    load(patch_file,'ptch')
    load(patch_file,'roi')

    vtc = ptch.flat;
    if FLIPX, vtc(:,1) = -vtc(:,1); end
    if FLIPY, vtc(:,2) = -vtc(:,2); end
    tri = ptch.tri;
    curv = -fthrcurv(ptch.curv,25);
    pbdry = vtc(ptch.bdry,:);

    % Read metric data
    mgh = MRIread(metric_file);
    metric = mgh.vol(:);

    % Define metric for the patch
    metric_ptch = metric(ptch.map2surf);

    % Get ROI indices
    roi_idx = roi.map2ptch;
    vtc_roi = vtc(roi_idx, :);
    tri_roi = roi.tri;
    metric_roi = metric_ptch(roi_idx);

    % Re-index the 'Faces' to match the ROI vertices
    [~, loc] = ismember(tri_roi, roi_idx);
    tri_roi = reshape(loc, size(tri_roi));

    hold on
    xlim = [min(vtc(:,1)) max(vtc(:,1))];
    ylim = [min(vtc(:,2)) max(vtc(:,2))];

    % Map curvature data to a color
    cmap = colormap('gray');
    RANGE = 0.5; OFFSET = min(1-RANGE,0.2);
    cidx = round((RANGE/(max(curv)-min(curv))*(curv-min(curv))+OFFSET)*(size(cmap,1)-1))+1;
    patch('vertices',vtc,'faces',tri,'FaceVertexCData',cmap(cidx,:),'FaceColor','interp','Edgecolor','none')
    plot(pbdry(:,1),pbdry(:,2),'Color','blue','LineWidth',3)

%     % Map metric in ROI to a color
%     cmap_roi = colormap('jet');  % Change the colormap if needed
%     cidx_roi = round((1/(max(metric_roi)-min(metric_roi))*(metric_roi-min(metric_roi)))*(size(cmap_roi,1)-1))+1;
%     patch('vertices',vtc_roi,'faces',tri_roi,'FaceVertexCData',cmap_roi(cidx_roi,:),'FaceColor','interp','Edgecolor','none','FaceAlpha',0.7);

    % Map metric in ROI to a color
    cmap_roi = colormap('turbo');  % Change the colormap if needed
    
    % Clip metric_roi to be within [-0.1, 0.1]
    % metric_roi = max(min(metric_roi, 0.5), 0);
    
    % cidx_roi = round((1/(0.5-(0)))*(metric_roi-(0))*(size(cmap_roi,1)-1))+1;  % Change the scaling to -0.1 - 0.1
    cidx_roi = round((1/(max(metric_roi)-min(metric_roi))*(metric_roi-min(metric_roi)))*(size(cmap_roi,1)-1))+1;
    patch('vertices',vtc_roi,'faces',tri_roi,'FaceVertexCData',cmap_roi(cidx_roi,:),'FaceColor','interp','Edgecolor','none','FaceAlpha',0.7);
    
%     % plot ROI boundary
%     rbdr = vtc(roi.bdry,:);
%     plot(rbdr(:,1),rbdr(:,2),'Color','blue','LineWidth',3) 

    hold off
end
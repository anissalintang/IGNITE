function check_patch_lh_3d(AZ,FLIPX,FLIPY)

    pth=('/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis');
    load(fullfile(pth,'patch','patch_lh.mat'),'ptch')
    load(fullfile(pth,'patch','patch_lh.mat'),'roi')

    vtc = ptch.vtc;  % Changed ptch.flat to ptch.vtc
    if FLIPX, vtc(:,1) = -vtc(:,1); end
    if FLIPY, vtc(:,2) = -vtc(:,2); end
    tri = ptch.tri;
    curv = -fthrcurv(ptch.curv,25);
    pbdry = vtc(ptch.bdry,:);

    figure, hold on
    % Use axis command for 3D plot limit
    axis([min(vtc(:,1)) max(vtc(:,1)) min(vtc(:,2)) max(vtc(:,2)) min(vtc(:,3)) max(vtc(:,3))])

    cmap = colormap('gray'); RANGE = 0.5; OFFSET = min(1-RANGE,0.2);
    cidx = round((RANGE/(max(curv)-min(curv))*(curv-min(curv))+OFFSET)*(size(cmap,1)-1))+1;
    patch('vertices',vtc,'faces',tri,'FaceVertexCData',cmap(cidx,:),'FaceColor','interp','Edgecolor','none')
    plot3(pbdry(:,1),pbdry(:,2),pbdry(:,3),'Color','blue','LineWidth',3) % 3D plot

    % plot ROI
    rvtx = vtc(roi.map2ptch,:);
    rtri = roi.tri;
    
    % Find the mapping from original vertex indices to roi vertex indices
    [~, idx_map] = ismember(rtri, roi.map2ptch);
    
    % plot the ROI with yellow color and 50% opacity
    patch('vertices',rvtx,'faces',idx_map,'FaceColor','y', 'FaceAlpha', 0.5, 'EdgeColor','none') 

     % plot ROI boundary
    rbdr = vtc(roi.bdry,:);
    plot3(rbdr(:,1),rbdr(:,2),rbdr(:,3),'Color','red','LineWidth',3) % 3D plot

    % New lines to plot Jordan centre and mesh

    % plot Jordan centre
    plot3(vtc(ptch.IDX, 1), vtc(ptch.IDX, 2), vtc(ptch.IDX, 3), 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r'); % 3D plot
     
    % plot mesh
    % for i = 1:size(tri, 1) 
    %     vert = vtc(tri(i,:), :);
    %     plot3([vert(:,1); vert(1,1)], [vert(:,2); vert(1,2)], [vert(:,3); vert(1,3)], 'b-', 'LineWidth', 0.1, 'Color', [0 0 1 0.2]);
    % end

    % Adjust viewing angle
    view(AZ, 90) 

    [x,y,z] = ginput(1)

    plot3(x,y,z)

end

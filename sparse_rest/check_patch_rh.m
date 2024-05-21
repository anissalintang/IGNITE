function check_patch_rh(AZ,FLIPX,FLIPY)

    %pth = fullfile(filesep,'Volumes','gdrive','mri','ProcData','SimHL',opt);   
    pth=('/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis');
    load(fullfile(pth,'patch','patch_rh.mat'),'ptch')
    load(fullfile(pth,'patch','patch_rh.mat'),'roi')

    vtc = ptch.flat;
    if FLIPX, vtc(:,1) = -vtc(:,1); end
    if FLIPY, vtc(:,2) = -vtc(:,2); end
    tri = ptch.tri;
    curv = -fthrcurv(ptch.curv,25);
    pbdry = vtc(ptch.bdry,:);


    figure, hold on
    xlim = [min(vtc(:,1)) max(vtc(:,1))];
    ylim = [min(vtc(:,2)) max(vtc(:,2))];

    cmap = colormap('gray'); RANGE = 0.5; OFFSET = min(1-RANGE,0.2);
    cidx = round((RANGE/(max(curv)-min(curv))*(curv-min(curv))+OFFSET)*(size(cmap,1)-1))+1;
    patch('vertices',vtc,'faces',tri,'FaceVertexCData',cmap(cidx,:),'FaceColor','interp','Edgecolor','none')
    plot(pbdry(:,1),pbdry(:,2),'Color','blue','LineWidth',3) 

    % plot ROI
    rvtx = vtc(roi.map2ptch,:);
    rtri = roi.tri;
    
    % Find the mapping from original vertex indices to roi vertex indices
    [~, idx_map] = ismember(rtri, roi.map2ptch);
    
    % plot the ROI with yellow color and 50% opacity
    patch('vertices',rvtx,'faces',idx_map,'FaceColor','y', 'FaceAlpha', 0.5, 'EdgeColor','none') 

     % plot ROI boundary
    rbdr = vtc(roi.bdry,:);
    plot(rbdr(:,1),rbdr(:,2),'Color','red','LineWidth',3) 

    % plot Jordan centre
    plot(vtc(ptch.IDX, 1), vtc(ptch.IDX, 2), 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r'); 

%     % plot mesh
%     for i = 1:size(tri, 1) 
%         vert = vtc(tri(i,:), :);
%         plot([vert(:,1); vert(1,1)], [vert(:,2); vert(1,2)], 'b-', 'LineWidth', 0.1, 'Color', [0 0 1 0.2]);
%     end

    set(gca,'XLim',xlim,'YLim',ylim,'View',[AZ 90]) 
end



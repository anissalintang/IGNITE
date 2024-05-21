function make_patch_rh_man(pth,AZ,FLIPX,FLIPY)
%     AZ = 0;
%     FLIPX = 0;
%     FLIPY = 0;

    subjs_dir = fullfile(pth,'recon');
    pth = fullfile(pth);

    % 1. Create surf;
    % Load fsaverage_sym surfaces and create surface graph;    
    surf = struct;
    [~,tri] = read_surf(fullfile(subjs_dir,'fsaverage','surf','rh.white'));
    surf.tri = tri+1;
    surf.vtc.white = read_surf(fullfile(subjs_dir,'fsaverage','surf','rh.smoothwm'));
    surf.vtc.pial = read_surf(fullfile(subjs_dir,'fsaverage','surf','rh.pial'));
    surf.vtc.infl = read_surf(fullfile(subjs_dir,'fsaverage','surf','rh.inflated'));
    surf.vtc.med = (surf.vtc.white+surf.vtc.pial)/2;
    vtc = surf.vtc.med;

    surf.graph = fsurf2graph(vtc,surf.tri); 
    surf.curv = read_curv(fullfile(subjs_dir,'fsaverage','surf','rh.curv')); 
    
    pth_o = ('/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis');
    save(fullfile(pth_o,'patch','surf_rh.mat'),'surf')

    % 2. Create patch;  
    mri = MRIread('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/colin27_fsavg/HO_HG_rh_mask_fsavg.mgz');
    idx = find(mri.vol>0);

    tmp = subgraph(surf.graph,idx);
    [comp,compsiz] = conncomp(tmp); 
    [~,IDX] = max(compsiz); idx = idx(comp==IDX); 
    mask = zeros(size(mri.vol)); mask(idx) = 1;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Modified code to get the centre of the mask defined manually using
    % ginput
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This is the manual part that needs to be done FIRST
    %
    % Below code will plot the vertices of the mask (from the medial
    % surface) and ask you to click on the plot to define the center of the
    % mask.
    % The line >> [~, IDX] = min(dist_sq) << will print the index of the
    % center that you choose. Please write it down.

    % If the location of the center is good and we are happy with the angulation 
    % of the patch (both (can be checked using check_patch function) then we 
    % can comment these codes.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%     % Get the vertices of the mask
%     mask_vertices = surf.vtc.med(logical(mask),:);
%     
%     Display only the mask area
%     figure; hold on;
%     plot3(mask_vertices(:,1), mask_vertices(:,2), mask_vertices(:,3), 'r.');
%     view(2); % or adjust this to view the surface from the best angle
%     
%     Wait for a click
%     [x, y] = ginput(1);
%     
%     Transform the selected 2D coordinates back to the 3D world
%     picked_point = [x, y, 0]; 
%     
%     Search for the nearest vertex within the mask
%     diff = bsxfun(@minus, mask_vertices(:,1:2), picked_point(1:2));
%     dist_sq = sum(diff.^2,2); 
%     [~, IDX] = min(dist_sq)


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This is the manual part that needs to be done SECOND
    %
    % After above comments are commented, please uncomment below code of
    % line and change the value of IDX to the index that we write down
    % earlier. This makes sure we are choosing the same center before
    % redoing the patch making with the right angulation.
    %
    % eg below my index is 703 for angulation parameter of -70,1,1
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Do it manually now for rh using (-70,1,1) IDX is 703
    IDX = 703;
    


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Below here onwards, continue as it is ...

    % Use subgraph to create a new graph object containing only the nodes in mask
    mask_as_logical = ismember(1:numnodes(surf.graph), idx);

    % Then we create the subgraph correspo
    % nding to these vertices
    subgrph = subgraph(surf.graph, mask_as_logical);

    % Calculate RAD, max distance * 0.75 (can be changed)
    RAD = max(distances(subgrph, IDX))*0.75;
    
    % Convert IDX back to be relative to the original set of vertices
    IDX = idx(IDX);

    idx = nearest(surf.graph,IDX,RAD); idx = sort([idx;IDX]);
    tri = surf.tri(cellfun(@(x) any([any(x(1)==idx) any(x(2)==idx) any(x(3)==idx)]),num2cell(surf.tri,2)),:);
    idx = unique(tri(:)); 

    ptch = struct;
    ptch.map2surf = idx;
    ptch.IDX = find(ptch.map2surf==IDX);
    ptch.tri = cell2mat(cellfun(@(x) [find(idx==x(1)) find(idx==x(2)) find(idx==x(3))],num2cell(tri,2),'UniformOutput',false));        
    ptch.vtc = vtc(ptch.map2surf,:);
    
    ptch.graph = fsurf2graph(ptch.vtc,ptch.tri);     
    ptch.curv = surf.curv(ptch.map2surf);
    ptch.d = distances(ptch.graph,ptch.IDX);

     % 3.) Create flattened vertices;
    M = eye(2);
    if FLIPX, M = [-1 0; 0 1]*M; end
    if FLIPY, M = [1 0; 0 -1]*M; end
    if AZ~=0, THETA = AZ/180*pi; M = [cos(THETA) sin(THETA);-sin(THETA) cos(THETA)]*M; end
    ptch.flat = (M*RAD*TutteMap(ptch.tri)')';    
    ptch.bdry = boundary(ptch.flat(:,1),ptch.flat(:,2),0);    
            
    % 4.) Create ROI; 
    roi = struct;    
    idx = find(mask(ptch.map2surf));
    k = boundary(ptch.flat(idx,1),ptch.flat(idx,2),0.5);
    roi.bdry = idx(k);
    
    idx = find(inpolygon(ptch.flat(:,1),ptch.flat(:,2),ptch.flat(idx(k),1),ptch.flat(idx(k),2)));
    roi.map2ptch = idx;
    roi.tri = ptch.tri(cellfun(@(x) and(and(any(x(1)==idx),any(x(2)==idx)),any(x(3)==idx)),num2cell(ptch.tri,2)),:);

    save(fullfile(pth_o,'patch','patch_rh.mat'),'ptch','roi')   

    mri.vol = zeros(size(mri.vol)); mri.vol(ptch.map2surf) = 1;
    MRIwrite(mri,fullfile(fullfile(pth_o,'patch','patch.rh.fsavg.mgz')));
    
    mri.vol = zeros(size(mri.vol)); mri.vol(ptch.map2surf(roi.map2ptch)) = 1;
    MRIwrite(mri,fullfile(fullfile(pth_o,'patch','roi.rh.fssym.mgz')));     
end




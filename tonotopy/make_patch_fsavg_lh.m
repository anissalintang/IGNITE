function make_patch_fsavg_lh(pth,THR,AZ,FLIPX,FLIPY)
%     AZ = 0;
%     THR = 50;
%     FLIPX = 0;
%     FLIPY = 0;

    subjs_dir = fullfile('/Volumes/gdrive4tb/IGNITE/resting-state/surface','recon');
    pth = fullfile(pth);

    % 1. Create surf;
    % Load fsaverage_sym surfaces and create surface graph;    
    surf = struct;
    [~,tri] = read_surf(fullfile(subjs_dir,'fsaverage','surf','lh.white'));
    surf.tri = tri+1;
    surf.vtc.white = read_surf(fullfile(subjs_dir,'fsaverage','surf','lh.smoothwm'));
    surf.vtc.pial = read_surf(fullfile(subjs_dir,'fsaverage','surf','lh.pial'));
    surf.vtc.infl = read_surf(fullfile(subjs_dir,'fsaverage','surf','lh.inflated'));
    surf.vtc.med = (surf.vtc.white+surf.vtc.pial)/2;
    vtc = surf.vtc.med;

    surf.graph = fsurf2graph(vtc,surf.tri); 
    surf.curv = read_curv(fullfile(subjs_dir,'fsaverage','surf','lh.curv')); 

    pth_o = ('/Volumes/gdrive4tb/IGNITE/tonotopy/surface');
    save(fullfile(pth_o,'patch','surf_fsavg_lh.mat'))

    % 2. Create patch;  
    mri = MRIread(fullfile(pth,'probActMap','probActMap.lh.fsavg.mgz'));
    VOL = mri.vol; 
    mri = MRIread('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/destrieux_fsavg/temporalLobe_mask_lh.mgh');
    idx = find(VOL.*(mri.vol)'>=THR);

    tmp = subgraph(surf.graph,idx);
    [comp,compsiz] = conncomp(tmp); 
    [~,IDX] = max(compsiz); idx = idx(comp==IDX); 
    mask = zeros(size(VOL)); mask(idx) = 1;
    
    ijctr = fjordan(subgraph(surf.graph,idx)); % calculate Jordan centre;
    CTRD = mean(vtc(idx(ijctr),:),1);
    [~,IDX] = min(fnorm(vtc-CTRD,2));
    RAD = max(distances(surf.graph,IDX,idx))*1.1;
    
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

    save(fullfile(pth_o,'patch','patch_fsavg_lh.mat'),'ptch','roi') 

    mri.vol = zeros(size(VOL)); mri.vol(ptch.map2surf) = 1;
    MRIwrite(mri,fullfile(fullfile(pth_o,'patch','patch.lh.fsavg.mgz')));
    
    mri.vol = zeros(size(VOL)); mri.vol(ptch.map2surf(roi.map2ptch)) = 1;
    MRIwrite(mri,fullfile(fullfile(pth_o,'patch','roi.lh.fsavg.mgz')));     


end

function [G,adjmtx] = fsurf2graph(vtc,tri)

    N = size(vtc,1);

    i1=tri(:,1); 
    i2=tri(:,2);
    i3=tri(:,3);
    
    cncts =[[i1 i2];[i1 i3];[i2 i3]]; 
    dstcs = cellfun(@(x) norm(vtc(x(1),:)-vtc(x(2),:)),num2cell(cncts,2)); 
    
    adjmtx = sparse(cncts(:,1),cncts(:,2),dstcs,N,N);
    adjmtx=adjmtx+(adjmtx');
    
    nams = arrayfun(@(x) sprintf('%d',x),1:N,'UniformOutput',false);
    G = graph(adjmtx,nams); 
end

function jctr = fjordan(grph)
        
    d = distances(grph);
    dmax = max(d,[],2);    
    MIN = min(dmax);
    jctr = find(dmax==MIN);
end

function nv = fnorm(varargin)

    if nargin>=2
        v = varargin{1};
        DIM = varargin{2};
        nv = sqrt(sum(v.^2,DIM));
    elseif nargin>=1
        v = varargin{1};
        nv = norm(v);
    else
        error('Not enough input arguments')
    end
end

clc
clear
close all

subjs_dir = '/Volumes/gdrive4tb/IGNITE/resting-state/surface/recon/';
mkdir(fullfile('/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/'), 'ReCov');
pth = '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ReCov';

%% Surf lh

% Load fsaverage surfaces and create surface graph;    
surf_lh = struct;

% the surface mesh triangles (tri)
[~,tri] = read_surf(fullfile(subjs_dir,'fsaverage','surf','lh.white'));
surf_lh.tri = tri+1;
% the vertex coordinates of various surface (white, pial, inflated and the
% middle of the cortical ribbon)
surf_lh.vtc.white = read_surf(fullfile(subjs_dir,'fsaverage','surf','lh.smoothwm'));
surf_lh.vtc.pial = read_surf(fullfile(subjs_dir,'fsaverage','surf','lh.pial'));
surf_lh.vtc.infl = read_surf(fullfile(subjs_dir,'fsaverage','surf','lh.inflated'));
surf_lh.vtc.med = (surf_lh.vtc.white+surf_lh.vtc.pial)/2;
vtc = surf_lh.vtc.med;

% a graph (in the mathematical sense of the word is created using a
% subfunction fsurf2graph)
surf_lh.graph = fsurf2graph(vtc,surf_lh.tri);
surf_lh.curv = read_curv(fullfile(subjs_dir,'fsaverage','surf','lh.curv'));

save(fullfile(pth,'surf_lh.mat'),'surf_lh')

%% Surf rh

% Load fsaverage surfaces and create surface graph;    
surf_rh = struct;

% the surface mesh triangles (tri)
[~,tri] = read_surf(fullfile(subjs_dir,'fsaverage','surf','lh.white'));
surf_rh.tri = tri+1;
% the vertex coordinates of various surface (white, pial, inflated and the
% middle of the cortical ribbon)
surf_rh.vtc.white = read_surf(fullfile(subjs_dir,'fsaverage','surf','lh.smoothwm'));
surf_rh.vtc.pial = read_surf(fullfile(subjs_dir,'fsaverage','surf','lh.pial'));
surf_rh.vtc.infl = read_surf(fullfile(subjs_dir,'fsaverage','surf','lh.inflated'));
surf_rh.vtc.med = (surf_rh.vtc.white+surf_rh.vtc.pial)/2;
vtc = surf_rh.vtc.med;

% a graph (in the mathematical sense of the word is created using a
% subfunction fsurf2graph)
surf_rh.graph = fsurf2graph(vtc,surf_rh.tri);
surf_rh.curv = read_curv(fullfile(subjs_dir,'fsaverage','surf','lh.curv'));

save(fullfile(pth,'surf_rh.mat'),'surf_rh')


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



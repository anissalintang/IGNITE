clc
clear all
close all

pth_surf = '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ReHo/surf_lh.mat';
pth_mri = '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF/merge_mean/allSubj_lh_ALFF_merged_mean_noTin_smooth5.mgz';
%pth_mask = '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/destrieux_fsavg/temporalLobe_mask_lh.mgh';

% path for other masks for sanity check, HG should have small RAD, and
% OcPole should have big RAD (size)
% pth_mask = '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/colin27_fsavg/HO_HG_lh_mask_fsavg.mgz';
% pth_mask = '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/colin27_fsavg/HO_OcPole_lh_mask_fsavg.mgz';
pth_mask = '/Volumes/gdrive4tb/brainStates/AnissaSurfaceAnalysis/ALFF/cortex_mask/lh_cortex_label_surf.mgh';

% Load surf data
load(pth_surf);

vtc = surf_lh.vtc.med;

% Load MRI data
mri = MRIread(pth_mri);
VOL = mri.vol;

% Load mask data
mask_mri = MRIread(pth_mask);
mask = mask_mri.vol;

% % Ensure mask is binary
% mask = mask > 0;
% 
% % Find indices of the mask in the volume
% idx = find(mask);
% 
% % Extract subgraph
% tmp = subgraph(surf_lh.graph, idx);
% [comp,compsiz] = conncomp(tmp); 
% [~,IDX] = max(compsiz); idx = idx(comp==IDX); 
% 
% mask = zeros(size(VOL)); mask(idx) = 1;
% 
% % calculate Jordan centre
% ijctr = fjordan(subgraph(surf_lh.graph,idx));
% 
% CTRD = mean(vtc(idx(ijctr),:),1);
% [~,IDX] = min(fnorm(vtc-CTRD,2));
% 
% % calculate maximum distance to get the approximate size
% RAD = max(distances(surf_lh.graph,IDX,idx));
% 
% fprintf('The maximum finite distance from the Jordan center to all other nodes in the mask is: %.2f\n', RAD);

% Parameters
numRepetitions = 1000;  % Number of iterations
subsetSize = 10000;  % Adjust this based on what your computer can handle

% Find indices of the mask in the volume
maskIndices = find(mask);  % Valid node indices
N = length(maskIndices);  % Total number of valid vertices

maxDistances = zeros(1, numRepetitions);  % Initialize array for storing max distances

for i = 1:numRepetitions
    % Random subset of valid vertices
    subsetIdx = randperm(N, min(N, subsetSize));
    idx = maskIndices(subsetIdx);

    % Extract subgraph for the selected vertices
    tmp = subgraph(surf_lh.graph, idx);

    % Calculate distances
    distMatrix = distances(tmp);
    finiteDistMatrix = distMatrix(~isinf(distMatrix));  % Exclude infinite distances
    if isempty(finiteDistMatrix)
        maxDist = 0;  % If no finite distances, set maxDist to 0
    else
        maxDist = max(finiteDistMatrix);  % Max distance in the subgraph
    end

    maxDistances(i) = maxDist;
end

overallMaxDistance = max(maxDistances);
fprintf('The maximum of maximum distances across all subsets is: %.2f\n', overallMaxDistance);


function jctr = fjordan(grph)
        
    d = distances(grph);
    dmax = max(d,[],2);    
    MIN = min(dmax);
    jctr = find(dmax==MIN);
end
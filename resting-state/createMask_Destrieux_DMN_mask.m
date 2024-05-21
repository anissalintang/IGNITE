clc
clear

% List of annotation files
% annotation_list = {'G_front_sup', 'G_and_S_cingul-Ant', 'G_and_S_cingul-Mid-Post', ...
%     'G_cingul-Post-ventral', 'G_cingul-Post-dorsal', 'S_intrapariet_and_P_trans', ...
%     'S_parieto_occipital', 'G_precuneus', 'G_parietal_sup', 'G_pariet_inf-Angular', ...
%     'G_subcallosal', 'G_temporal_inf'};

annotation_list = {'G_cingul-Post-ventral', 'G_cingul-Post-dorsal', 'G_precuneus', ...
    'G_and_S_cingul-Ant', 'G_subcallosal', 'G_pariet_inf-Angular', 'G_parietal_sup', ...
    'G_oc-temp_med-Parahip', 'G_temporal_inf', 'G_temporal_middle'};




% Read the annotation files
[vertices_lh, label_lh, colortable_lh] = read_annotation('/Applications/freesurfer/7.3.2/subjects/fsaverage/label/lh.aparc.a2009s.annot');
[vertices_rh, label_rh, colortable_rh] = read_annotation('/Applications/freesurfer/7.3.2/subjects/fsaverage/label/rh.aparc.a2009s.annot');

% Create a binary mask
mask_lh = zeros(size(label_lh));
mask_rh = zeros(size(label_rh));

% Loop through each annotation and add it to the mask
for i = 1:length(annotation_list)
    index_lh = find(ismember(colortable_lh.struct_names, annotation_list{i}));
    index_rh = find(ismember(colortable_rh.struct_names, annotation_list{i}));
    
    mask_lh = mask_lh + double(label_lh == colortable_lh.table(index_lh, 5));
    mask_rh = mask_rh + double(label_rh == colortable_rh.table(index_rh, 5));
end

% Reshape to a [nvertices x 1 x 1] array
mask_lh_2D = reshape(mask_lh, [length(mask_lh), 1, 1]);
mask_rh_2D = reshape(mask_rh, [length(mask_rh), 1, 1]);

% Construct the MRI structure to save the mask
mri = struct();
mri.vox2ras = eye(4);
mri.xsize = 1;
mri.ysize = 1;
mri.zsize = 1;
mri.nframes = 1;

% Save the mask -lh
mri.vol = mask_lh_2D;
mri.volsize = size(mask_lh_2D);
MRIwrite(mri, '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/destrieux_fsavg/DMN_mask_lh.mgh');

% Save the mask -rh
mri.vol = mask_rh_2D;
mri.volsize = size(mask_rh_2D);
MRIwrite(mri, '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/destrieux_fsavg/DMN_mask_rh.mgh');

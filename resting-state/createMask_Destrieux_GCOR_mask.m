clc
clear

% List of annotation files
annotation_list = {'G_precentral', 'S_central', 'G_postcentral', ...
    'G_and_S_subcentral', 'G_pariet_inf-Supramar', 'G_temp_sup-Plan_polar', ...
    'S_circular_insula_inf', 'Lat_Fis-post', 'G_temp_sup-G_T_transv', ...
    'S_temporal_transverse', 'G_temp_sup-Plan_tempo', 'G_temp_sup-Lateral', ...
    'S_temporal_sup'};


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
MRIwrite(mri, '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/destrieux_fsavg/GCOR_mask_lh.mgh');

% Save the mask -rh
mri.vol = mask_rh_2D;
mri.volsize = size(mask_rh_2D);
MRIwrite(mri, '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/destrieux_fsavg/GCOR_mask_rh.mgh');

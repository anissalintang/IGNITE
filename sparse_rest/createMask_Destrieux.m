%% Create Auditory regions mask from Destrieux atlas (aparc.a2009s.annot)
% primary: G_temp_sup-G_T_transv
% secondary: S_temporal_transverse
% tertiary: G_temp_sup-Plan_tempo

%% primary: G_temp_sup-G_T_transv

% Read the annotation file
[vertices_lh, label_lh, colortable_lh] = read_annotation('/Applications/freesurfer/7.3.2/subjects/fsaverage/label/lh.aparc.a2009s.annot');
[vertices_rh, label_rh, colortable_rh] = read_annotation('/Applications/freesurfer/7.3.2/subjects/fsaverage/label/rh.aparc.a2009s.annot');

% Find the index of the label in the colortable
index_lh = find(ismember(colortable_lh.struct_names, 'G_temp_sup-G_T_transv'));
index_rh = find(ismember(colortable_rh.struct_names, 'G_temp_sup-G_T_transv'));

% Create a binary mask
mask_lh = double(label_lh == colortable_lh.table(index_lh, 5));
mask_rh = double(label_rh == colortable_rh.table(index_rh, 5));

% Now 'mask' is a vector with 1s where the label is and 0s everywhere else.
% To save it as a .mgh file, need to reshape it to a 2D array
% reshape it to a [nvertices x 1 x 1] array

mask_lh_2D = reshape(mask_lh, [length(mask_lh), 1, 1]); 
mask_rh_2D = reshape(mask_rh, [length(mask_rh), 1, 1]); 

% Construct the MRI structure to save the mask
mri = struct();
mri.vol = mask_lh_2D;
mri.vox2ras = eye(4);
mri.volsize = size(mask_lh_2D);
mri.xsize = 1;
mri.ysize = 1;
mri.zsize = 1;
mri.nframes = 1;

% Save the mask -lh
mri.vol = mask_lh_2D;
MRIwrite(mri, '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/destrieux_fsavg/AC_prim_lh.mgh');

% Save the mask -rh
mri.vol = mask_rh_2D;
MRIwrite(mri, '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/destrieux_fsavg/AC_prim_rh.mgh');


%% secondary: S_temporal_transverse

% Find the index of the label in the colortable
index_lh = find(ismember(colortable_lh.struct_names, 'S_temporal_transverse'));
index_rh = find(ismember(colortable_rh.struct_names, 'S_temporal_transverse'));

% Create a binary mask
mask_lh = double(label_lh == colortable_lh.table(index_lh, 5));
mask_rh = double(label_rh == colortable_rh.table(index_rh, 5));

% Now 'mask' is a vector with 1s where the label is and 0s everywhere else.
% To save it as a .mgh file, need to reshape it to a 2D array
% reshape it to a [nvertices x 1 x 1] array

mask_lh_2D = reshape(mask_lh, [length(mask_lh), 1, 1]); 
mask_rh_2D = reshape(mask_rh, [length(mask_rh), 1, 1]); 

% Construct the MRI structure to save the mask
mri = struct();
mri.vol = mask_lh_2D;
mri.vox2ras = eye(4);
mri.volsize = size(mask_lh_2D);
mri.xsize = 1;
mri.ysize = 1;
mri.zsize = 1;
mri.nframes = 1;

% Save the mask -lh
mri.vol = mask_lh_2D;
MRIwrite(mri, '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/destrieux_fsavg/AC_sec_lh.mgh');

% Save the mask -rh
mri.vol = mask_rh_2D;
MRIwrite(mri, '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/destrieux_fsavg/AC_sec_rh.mgh');


%% tertiary: G_temp_sup-Plan_tempo

% Find the index of the label in the colortable
index_lh = find(ismember(colortable_lh.struct_names, 'G_temp_sup-Plan_tempo'));
index_rh = find(ismember(colortable_rh.struct_names, 'G_temp_sup-Plan_tempo'));

% Create a binary mask
mask_lh = double(label_lh == colortable_lh.table(index_lh, 5));
mask_rh = double(label_rh == colortable_rh.table(index_rh, 5));

% Now 'mask' is a vector with 1s where the label is and 0s everywhere else.
% To save it as a .mgh file, need to reshape it to a 2D array
% reshape it to a [nvertices x 1 x 1] array

mask_lh_2D = reshape(mask_lh, [length(mask_lh), 1, 1]); 
mask_rh_2D = reshape(mask_rh, [length(mask_rh), 1, 1]); 

% Construct the MRI structure to save the mask
mri = struct();
mri.vol = mask_lh_2D;
mri.vox2ras = eye(4);
mri.volsize = size(mask_lh_2D);
mri.xsize = 1;
mri.ysize = 1;
mri.zsize = 1;
mri.nframes = 1;

% Save the mask -lh
mri.vol = mask_lh_2D;
MRIwrite(mri, '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/destrieux_fsavg/AC_tert_lh.mgh');

% Save the mask -rh
mri.vol = mask_rh_2D;
MRIwrite(mri, '/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/destrieux_fsavg/AC_tert_rh.mgh');

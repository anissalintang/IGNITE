#!/bin/bash

data_path="/Volumes/gdrive4tb/IGNITE"
log_path="/Volumes/gdrive4tb/IGNITE/resting-state/log"
fs_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface"

SUBJECTS_DIR="${fs_path}/recon";


subj=(IGNTFA_00065)

freeview -v \
$SUBJECTS_DIR/$subj/mri/T1.mgz \
$SUBJECTS_DIR/$subj/mri/wm.mgz \
$SUBJECTS_DIR/$subj/mri/brainmask.mgz \
$SUBJECTS_DIR/$subj/mri/aseg.mgz:colormap=lut:opacity=0.2 \
-f \
$SUBJECTS_DIR/$subj/surf/lh.white:edgecolor=blue \
$SUBJECTS_DIR/$subj/surf/lh.pial:edgecolor=red \
$SUBJECTS_DIR/$subj/surf/rh.white:edgecolor=blue \
$SUBJECTS_DIR/$subj/surf/rh.pial:edgecolor=red

exit 0
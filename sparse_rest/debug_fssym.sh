#!/bin/bash

fs_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface"
export SUBJECTS_DIR="${fs_path}/recon"

s=(IGNTBP_00072)

# # 128899
# mris_info $SUBJECTS_DIR/${s}/surf/lh.sphere.reg

# # 163842
# mris_info $SUBJECTS_DIR/fsaverage/surf/lh.sphere.reg

# # 163842
# mris_info $SUBJECTS_DIR/fsaverage_sym/surf/lh.sphere.reg



# # 129068
# mris_info $SUBJECTS_DIR/${s}/surf/rh.sphere.reg

# # 163842
# mris_info $SUBJECTS_DIR/fsaverage/surf/rh.sphere.reg

# # 163842
# mris_info $SUBJECTS_DIR/fsaverage_sym/surf/rh.sphere.reg

mri_info $SUBJECTS_DIR/${s}/mri/orig.mgz

mri_info $SUBJECTS_DIR/${s}/xhemi/mri/orig.mgz

info_orig=$(mri_info $SUBJECTS_DIR/${s}/mri/orig.mgz)
info_xhemi=$(mri_info $SUBJECTS_DIR/${s}/xhemi/mri/orig.mgz)

if [ "$info_orig" = "$info_xhemi" ]; then
    echo "The information is identical."
else
    echo "The information is not identical. Here are the differences:"
    diff <(echo "$info_orig") <(echo "$info_xhemi")
fi


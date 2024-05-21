#!/bin/bash

data_path="/Volumes/gdrive4tb/IGNITE";s=$1
preproc_path="/Volumes/gdrive4tb/IGNITE/resting-state/preprocessed"
vol_path="/Volumes/gdrive4tb/IGNITE/resting-state/volumetric"
log_path="/Volumes/gdrive4tb/IGNITE/resting-state/log"
mask_path="/Volumes/gdrive4tb/IGNITE/mask"
analysis_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis"
fs_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface"

export SUBJECTS_DIR="${fs_path}/recon"

s=(IGNTFA_00065)

######################################################################################################
######################################################################################################
######################################################################################################
# Check the projection of GCOR to the subject specific cortical surface Whole Brain UNSMOOTHED

freeview -f \
${fs_path}/recon/${s}/surf/lh.smoothwm:overlay=${analysis_path}/GCOR/wholeBrain/${s}/${s}_GCOR_lh_fs.mgz \
${fs_path}/recon/${s}/surf/rh.smoothwm:overlay=${analysis_path}/GCOR/wholeBrain/${s}/${s}_GCOR_rh_fs.mgz

# Check the projection of GCOR to the fsaverage surface Whole Brain UNSMOOTHED

freeview -f \
${fs_path}/recon/fsaverage/surf/lh.smoothwm:overlay=${analysis_path}/GCOR/wholeBrain/${s}/${s}_GCOR_lh_fsavg.mgz \
${fs_path}/recon/fsaverage/surf/rh.smoothwm:overlay=${analysis_path}/GCOR/wholeBrain/${s}/${s}_GCOR_rh_fsavg.mgz

# Check the projection of GCOR to the subject specific cortical surface Whole Brain SMOOTHED

freeview -f \
${fs_path}/recon/${s}/surf/lh.smoothwm:overlay=${analysis_path}/GCOR/smoothed/wholeBrain/${s}/${s}_GCOR_lh_sm_fs.mgz \
${fs_path}/recon/${s}/surf/rh.smoothwm:overlay=${analysis_path}/GCOR/smoothed/wholeBrain/${s}/${s}_GCOR_rh_sm_fs.mgz


# Check the projection of GCOR to the fsaverage surface Whole Brain SMOOTHED

freeview -f \
${fs_path}/recon/fsaverage/surf/lh.smoothwm:overlay=${analysis_path}/GCOR/smoothed/wholeBrain/${s}/${s}_GCOR_lh_sm_fsavg.mgz \
${fs_path}/recon/fsaverage/surf/rh.smoothwm:overlay=${analysis_path}/GCOR/smoothed/wholeBrain/${s}/${s}_GCOR_rh_sm_fsavg.mgz

# Check the projection of GCOR to the subject specific cortical surface Whole Brain GM UNSMOOTHED

freeview -f \
${fs_path}/recon/${s}/surf/lh.smoothwm:overlay=${analysis_path}/GCOR/wholeBrain_GM/${s}/${s}_GCOR_GM_lh_fs.mgz \
${fs_path}/recon/${s}/surf/rh.smoothwm:overlay=${analysis_path}/GCOR/wholeBrain_GM/${s}/${s}_GCOR_GM_rh_fs.mgz

# Check the projection of GCOR to fsaverage Whole Brain GM UNSMOOTHED

freeview -f \
${fs_path}/recon/fsaverage/surf/lh.smoothwm:overlay=${analysis_path}/GCOR/wholeBrain_GM/${s}/${s}_GCOR_GM_lh_fsavg.mgz \
${fs_path}/recon/fsaverage/surf/rh.smoothwm:overlay=${analysis_path}/GCOR/wholeBrain_GM/${s}/${s}_GCOR_GM_rh_fsavg.mgz


# Check the projection of GCOR to the subject specific cortical surface Whole Brain GM SMOOTHED

freeview -f \
${fs_path}/recon/${s}/surf/lh.smoothwm:overlay=${analysis_path}/GCOR/smoothed/wholeBrain_GM/${s}/${s}_GCOR_GM_lh_sm_fs.mgz \
${fs_path}/recon/${s}/surf/rh.smoothwm:overlay=${analysis_path}/GCOR/smoothed/wholeBrain_GM/${s}/${s}_GCOR_GM_rh_sm_fs.mgz

# Check the projection of GCOR to fsaverage Whole Brain GM SMOOTHED

freeview -f \
${fs_path}/recon/fsaverage/surf/lh.smoothwm:overlay=${analysis_path}/GCOR/smoothed/wholeBrain_GM/${s}/${s}_GCOR_GM_lh_sm_fsavg.mgz \
${fs_path}/recon/fsaverage/surf/rh.smoothwm:overlay=${analysis_path}/GCOR/smoothed/wholeBrain_GM/${s}/${s}_GCOR_GM_rh_sm_fsavg.mgz

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
# Check the projection of ALFF to the subject specific cortical surface Whole Brain UNSMOOTHED

freeview -f \
${fs_path}/recon/${s}/surf/lh.smoothwm:overlay=${analysis_path}/ALFF/wholeBrain/${s}/${s}_ALFF_lh_fs.mgz \
${fs_path}/recon/${s}/surf/rh.smoothwm:overlay=${analysis_path}/ALFF/wholeBrain/${s}/${s}_ALFF_rh_fs.mgz

# Check the projection of ALFF to the fsaverage surface Whole Brain UNSMOOTHED

freeview -f \
${fs_path}/recon/fsaverage/surf/lh.smoothwm:overlay=${analysis_path}/ALFF/wholeBrain/${s}/${s}_ALFF_lh_fsavg.mgz \
${fs_path}/recon/fsaverage/surf/rh.smoothwm:overlay=${analysis_path}/ALFF/wholeBrain/${s}/${s}_ALFF_rh_fsavg.mgz

# Check the projection of ALFF to the subject specific cortical surface Whole Brain SMOOTHED

freeview -f \
${fs_path}/recon/${s}/surf/lh.smoothwm:overlay=${analysis_path}/ALFF/smoothed/wholeBrain/${s}/${s}_ALFF_lh_sm_fs.mgz \
${fs_path}/recon/${s}/surf/rh.smoothwm:overlay=${analysis_path}/ALFF/smoothed/wholeBrain/${s}/${s}_ALFF_rh_sm_fs.mgz


# Check the projection of ALFF to the fsaverage surface Whole Brain SMOOTHED

freeview -f \
${fs_path}/recon/fsaverage/surf/lh.smoothwm:overlay=${analysis_path}/ALFF/smoothed/wholeBrain/${s}/${s}_ALFF_lh_sm_fsavg.mgz \
${fs_path}/recon/fsaverage/surf/rh.smoothwm:overlay=${analysis_path}/ALFF/smoothed/wholeBrain/${s}/${s}_ALFF_rh_sm_fsavg.mgz

# Check the projection of fALFF to the subject specific cortical surface Whole Brain UNSMOOTHED

freeview -f \
${fs_path}/recon/${s}/surf/lh.smoothwm:overlay=${analysis_path}/fALFF/wholeBrain/${s}/${s}_fALFF_lh_fs.mgz \
${fs_path}/recon/${s}/surf/rh.smoothwm:overlay=${analysis_path}/fALFF/wholeBrain/${s}/${s}_fALFF_rh_fs.mgz

# Check the projection of fALFF to fsaverage Whole Brain UNSMOOTHED

freeview -f \
${fs_path}/recon/fsaverage/surf/lh.smoothwm:overlay=${analysis_path}/fALFF/wholeBrain/${s}/${s}_fALFF_lh_fsavg.mgz \
${fs_path}/recon/fsaverage/surf/rh.smoothwm:overlay=${analysis_path}/fALFF/wholeBrain/${s}/${s}_fALFF_rh_fsavg.mgz


# Check the projection of fALFF to the subject specific cortical surface Whole Brain SMOOTHED

freeview -f \
${fs_path}/recon/${s}/surf/lh.smoothwm:overlay=${analysis_path}/fALFF/smoothed/wholeBrain/${s}/${s}_fALFF_lh_sm_fs.mgz \
${fs_path}/recon/${s}/surf/rh.smoothwm:overlay=${analysis_path}/fALFF/smoothed/wholeBrain/${s}/${s}_fALFF_rh_sm_fs.mgz

# Check the projection of fALFF to fsaverage Whole Brain SMOOTHED

freeview -f \
${fs_path}/recon/fsaverage/surf/lh.smoothwm:overlay=${analysis_path}/fALFF/smoothed/wholeBrain/${s}/${s}_fALFF_lh_sm_fsavg.mgz \
${fs_path}/recon/fsaverage/surf/rh.smoothwm:overlay=${analysis_path}/fALFF/smoothed/wholeBrain/${s}/${s}_fALFF_rh_sm_fsavg.mgz

######################################################################################################
######################################################################################################
######################################################################################################

# Check the projection of ALFF to the subject specific ROI -- HG UNSMOOTHED

freeview -f \
${fs_path}/recon/${s}/surf/lh.smoothwm:overlay=${analysis_path}/ALFF/HG/${s}/${s}_ALFF_HG_lh_fs.mgz \
${fs_path}/recon/${s}/surf/rh.smoothwm:overlay=${analysis_path}/ALFF/HG/${s}/${s}_ALFF_HG_rh_fs.mgz

# Check the projection of ALFF to the fsaverage surface specific ROI -- HG UNSMOOTHED

freeview -f \
${fs_path}/recon/fsaverage/surf/lh.smoothwm:overlay=${analysis_path}/ALFF/HG/${s}/${s}_ALFF_HG_lh_fsavg.mgz \
${fs_path}/recon/fsaverage/surf/rh.smoothwm:overlay=${analysis_path}/ALFF/HG/${s}/${s}_ALFF_HG_rh_fsavg.mgz

# Check the projection of ALFF to the subject specific ROI -- HG SMOOTHED

freeview -f \
${fs_path}/recon/${s}/surf/lh.smoothwm:overlay=${analysis_path}/ALFF/smoothed/HG/${s}/${s}_ALFF_HG_lh_sm_fs.mgz \
${fs_path}/recon/${s}/surf/rh.smoothwm:overlay=${analysis_path}/ALFF/smoothed/HG/${s}/${s}_ALFF_HG_rh_sm_fs.mgz


# Check the projection of ALFF to the fsaverage surface specific ROI -- HG SMOOTHED

freeview -f \
${fs_path}/recon/fsaverage/surf/lh.smoothwm:overlay=${analysis_path}/ALFF/smoothed/HG/${s}/${s}_ALFF_HG_lh_sm_fsavg.mgz \
${fs_path}/recon/fsaverage/surf/rh.smoothwm:overlay=${analysis_path}/ALFF/smoothed/HG/${s}/${s}_ALFF_HG_rh_sm_fsavg.mgz

# Check the projection of fALFF to the subject specific cortical surface HG UNSMOOTHED

freeview -f \
${fs_path}/recon/${s}/surf/lh.smoothwm:overlay=${analysis_path}/fALFF/HG/${s}/${s}_fALFF_HG_lh_fs.mgz \
${fs_path}/recon/${s}/surf/rh.smoothwm:overlay=${analysis_path}/fALFF/HG/${s}/${s}_fALFF_HG_rh_fs.mgz

# Check the projection of fALFF to fsaverage HG UNSMOOTHED

freeview -f \
${fs_path}/recon/fsaverage/surf/lh.smoothwm:overlay=${analysis_path}/fALFF/HG/${s}/${s}_fALFF_HG_lh_fsavg.mgz \
${fs_path}/recon/fsaverage/surf/rh.smoothwm:overlay=${analysis_path}/fALFF/HG/${s}/${s}_fALFF_HG_rh_fsavg.mgz


# Check the projection of fALFF to the subject specific cortical surface HG SMOOTHED

freeview -f \
${fs_path}/recon/${s}/surf/lh.smoothwm:overlay=${analysis_path}/fALFF/smoothed/HG/${s}/${s}_fALFF_HG_lh_sm_fs.mgz \
${fs_path}/recon/${s}/surf/rh.smoothwm:overlay=${analysis_path}/fALFF/smoothed/HG/${s}/${s}_fALFF_HG_rh_sm_fs.mgz

# Check the projection of fALFF to fsaverage HG SMOOTHED

freeview -f \
${fs_path}/recon/fsaverage/surf/lh.smoothwm:overlay=${analysis_path}/fALFF/smoothed/HG/${s}/${s}_fALFF_HG_lh_sm_fsavg.mgz \
${fs_path}/recon/fsaverage/surf/rh.smoothwm:overlay=${analysis_path}/fALFF/smoothed/HG/${s}/${s}_fALFF_HG_rh_sm_fsavg.mgz


######################################################################################################
######################################################################################################
######################################################################################################

# Check the projection of ALFF to the subject specific ROI -- PT UNSMOOTHED

freeview -f \
${fs_path}/recon/${s}/surf/lh.smoothwm:overlay=${analysis_path}/ALFF/PT/${s}/${s}_ALFF_PT_lh_fs.mgz \
${fs_path}/recon/${s}/surf/rh.smoothwm:overlay=${analysis_path}/ALFF/PT/${s}/${s}_ALFF_PT_rh_fs.mgz

# Check the projection of ALFF to the fsaverage surface specific ROI -- PT UNSMOOTHED

freeview -f \
${fs_path}/recon/fsaverage/surf/lh.smoothwm:overlay=${analysis_path}/ALFF/PT/${s}/${s}_ALFF_PT_lh_fsavg.mgz \
${fs_path}/recon/fsaverage/surf/rh.smoothwm:overlay=${analysis_path}/ALFF/PT/${s}/${s}_ALFF_PT_rh_fsavg.mgz

# Check the projection of ALFF to the subject specific ROI -- PT SMOOTHED

freeview -f \
${fs_path}/recon/${s}/surf/lh.smoothwm:overlay=${analysis_path}/ALFF/smoothed/PT/${s}/${s}_ALFF_PT_lh_sm_fs.mgz \
${fs_path}/recon/${s}/surf/rh.smoothwm:overlay=${analysis_path}/ALFF/smoothed/PT/${s}/${s}_ALFF_PT_rh_sm_fs.mgz


# Check the projection of ALFF to the fsaverage surface specific ROI -- PT SMOOTHED

freeview -f \
${fs_path}/recon/fsaverage/surf/lh.smoothwm:overlay=${analysis_path}/ALFF/smoothed/PT/${s}/${s}_ALFF_PT_lh_sm_fsavg.mgz \
${fs_path}/recon/fsaverage/surf/rh.smoothwm:overlay=${analysis_path}/ALFF/smoothed/PT/${s}/${s}_ALFF_PT_rh_sm_fsavg.mgz

# Check the projection of fALFF to the subject specific cortical surface PT UNSMOOTHED

freeview -f \
${fs_path}/recon/${s}/surf/lh.smoothwm:overlay=${analysis_path}/fALFF/PT/${s}/${s}_fALFF_PT_lh_fs.mgz \
${fs_path}/recon/${s}/surf/rh.smoothwm:overlay=${analysis_path}/fALFF/PT/${s}/${s}_fALFF_PT_rh_fs.mgz

# Check the projection of fALFF to fsaverage PT UNSMOOTHED

freeview -f \
${fs_path}/recon/fsaverage/surf/lh.smoothwm:overlay=${analysis_path}/fALFF/PT/${s}/${s}_fALFF_PT_lh_fsavg.mgz \
${fs_path}/recon/fsaverage/surf/rh.smoothwm:overlay=${analysis_path}/fALFF/PT/${s}/${s}_fALFF_PT_rh_fsavg.mgz


# Check the projection of fALFF to the subject specific cortical surface PT SMOOTHED

freeview -f \
${fs_path}/recon/${s}/surf/lh.smoothwm:overlay=${analysis_path}/fALFF/smoothed/PT/${s}/${s}_fALFF_PT_lh_sm_fs.mgz \
${fs_path}/recon/${s}/surf/rh.smoothwm:overlay=${analysis_path}/fALFF/smoothed/PT/${s}/${s}_fALFF_PT_rh_sm_fs.mgz

# Check the projection of fALFF to fsaverage PT SMOOTHED

freeview -f \
${fs_path}/recon/fsaverage/surf/lh.smoothwm:overlay=${analysis_path}/fALFF/smoothed/PT/${s}/${s}_fALFF_PT_lh_sm_fsavg.mgz \
${fs_path}/recon/fsaverage/surf/rh.smoothwm:overlay=${analysis_path}/fALFF/smoothed/PT/${s}/${s}_fALFF_PT_rh_sm_fsavg.mgz


######################################################################################################
######################################################################################################
######################################################################################################

# Check the projection of ALFF to the subject specific ROI -- V1 UNSMOOTHED

freeview -f \
${fs_path}/recon/${s}/surf/lh.smoothwm:overlay=${analysis_path}/ALFF/V1/${s}/${s}_ALFF_V1_lh_fs.mgz \
${fs_path}/recon/${s}/surf/rh.smoothwm:overlay=${analysis_path}/ALFF/V1/${s}/${s}_ALFF_V1_rh_fs.mgz

# Check the projection of ALFF to the fsaverage surface specific ROI -- V1 UNSMOOTHED

freeview -f \
${fs_path}/recon/fsaverage/surf/lh.smoothwm:overlay=${analysis_path}/ALFF/V1/${s}/${s}_ALFF_V1_lh_fsavg.mgz \
${fs_path}/recon/fsaverage/surf/rh.smoothwm:overlay=${analysis_path}/ALFF/V1/${s}/${s}_ALFF_V1_rh_fsavg.mgz

# Check the projection of ALFF to the subject specific ROI -- V1 SMOOTHED

freeview -f \
${fs_path}/recon/${s}/surf/lh.smoothwm:overlay=${analysis_path}/ALFF/smoothed/V1/${s}/${s}_ALFF_V1_lh_sm_fs.mgz \
${fs_path}/recon/${s}/surf/rh.smoothwm:overlay=${analysis_path}/ALFF/smoothed/V1/${s}/${s}_ALFF_V1_rh_sm_fs.mgz


# Check the projection of ALFF to the fsaverage surface specific ROI -- V1 SMOOTHED

freeview -f \
${fs_path}/recon/fsaverage/surf/lh.smoothwm:overlay=${analysis_path}/ALFF/smoothed/V1/${s}/${s}_ALFF_V1_lh_sm_fsavg.mgz \
${fs_path}/recon/fsaverage/surf/rh.smoothwm:overlay=${analysis_path}/ALFF/smoothed/V1/${s}/${s}_ALFF_V1_rh_sm_fsavg.mgz

# Check the projection of fALFF to the subject specific cortical surface V1 UNSMOOTHED

freeview -f \
${fs_path}/recon/${s}/surf/lh.smoothwm:overlay=${analysis_path}/fALFF/V1/${s}/${s}_fALFF_V1_lh_fs.mgz \
${fs_path}/recon/${s}/surf/rh.smoothwm:overlay=${analysis_path}/fALFF/V1/${s}/${s}_fALFF_V1_rh_fs.mgz

# Check the projection of fALFF to fsaverage V1 UNSMOOTHED

freeview -f \
${fs_path}/recon/fsaverage/surf/lh.smoothwm:overlay=${analysis_path}/fALFF/V1/${s}/${s}_fALFF_V1_lh_fsavg.mgz \
${fs_path}/recon/fsaverage/surf/rh.smoothwm:overlay=${analysis_path}/fALFF/V1/${s}/${s}_fALFF_V1_rh_fsavg.mgz


# Check the projection of fALFF to the subject specific cortical surface V1 SMOOTHED

freeview -f \
${fs_path}/recon/${s}/surf/lh.smoothwm:overlay=${analysis_path}/fALFF/smoothed/V1/${s}/${s}_fALFF_V1_lh_sm_fs.mgz \
${fs_path}/recon/${s}/surf/rh.smoothwm:overlay=${analysis_path}/fALFF/smoothed/V1/${s}/${s}_fALFF_V1_rh_sm_fs.mgz

# Check the projection of fALFF to fsaverage V1 SMOOTHED

freeview -f \
${fs_path}/recon/fsaverage/surf/lh.smoothwm:overlay=${analysis_path}/fALFF/smoothed/V1/${s}/${s}_fALFF_V1_lh_sm_fsavg.mgz \
${fs_path}/recon/fsaverage/surf/rh.smoothwm:overlay=${analysis_path}/fALFF/smoothed/V1/${s}/${s}_fALFF_V1_rh_sm_fsavg.mgz
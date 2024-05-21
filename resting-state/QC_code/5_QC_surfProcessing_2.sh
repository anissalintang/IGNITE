#!/bin/bash

data_path="/Volumes/gdrive4tb/IGNITE"
fs_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface"
log_path="/Volumes/gdrive4tb/IGNITE/resting-state/log"

export SUBJECTS_DIR="${fs_path}/recon"

s=(IGNTFA_00065)


# Check the projection of the functional timeseries to the subject specific cortical surface UNSMOOTHED

freeview -f \
${fs_path}/recon/${s}/surf/lh.smoothwm:overlay=${fs_path}/projected/nonSmoothed/filt_0.01-0.1/${s}/${s}_lh_filt01_fs.mgz \
${fs_path}/recon/${s}/surf/rh.smoothwm:overlay=${fs_path}/projected/nonSmoothed/filt_0.01-0.1/${s}/${s}_rh_filt01_fs.mgz \

# Check the projection of the functional timeseries to the fsaverage surface UNSMOOTHED

freeview -f \
${fs_path}/recon/fsaverage/surf/lh.smoothwm:overlay=${fs_path}/projected/nonSmoothed/filt_0.01-0.1/${s}/${s}_lh_filt01_fsavg.mgz \
${fs_path}/recon/fsaverage/surf/rh.smoothwm:overlay=${fs_path}/projected/nonSmoothed/filt_0.01-0.1/${s}/${s}_rh_filt01_fsavg.mgz \


# Check the projection of the functional timeseries to the subject specific cortical surface SMOOTHED

freeview -f \
${fs_path}/recon/${s}/surf/lh.smoothwm:overlay=${fs_path}/projected/Smoothed/filt_0.01-0.1/${s}/${s}_lh_filt01_smoothed_fs.mgz \
${fs_path}/recon/${s}/surf/rh.smoothwm:overlay=${fs_path}/projected/Smoothed/filt_0.01-0.1/${s}/${s}_rh_filt01_smoothed_fs.mgz \

# Check the projection of the functional timeseries to the fsaverage surface SMOOTHED

freeview -f \
${fs_path}/recon/fsaverage/surf/lh.smoothwm:overlay=${fs_path}/projected/Smoothed/filt_0.01-0.1/${s}/${s}_lh_filt01_smoothed_fsavg.mgz \
${fs_path}/recon/fsaverage/surf/rh.smoothwm:overlay=${fs_path}/projected/Smoothed/filt_0.01-0.1/${s}/${s}_rh_filt01_smoothed_fsavg.mgz \

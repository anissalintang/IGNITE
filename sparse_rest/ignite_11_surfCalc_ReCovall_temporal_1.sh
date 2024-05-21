#!/bin/bash

# Calculating ReCov in surface space (fsavg) for temporal mask

proj_path="/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/projected/nonSmoothed/filt_0.01-0.1"
fs_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface/recon"
	
hemi=(lh rh)

subj=($(ls /Volumes/gdrive4tb/IGNITE/sparse_rest/preprocessed))
# subj=(IGNTFA_00065)

mkdir -p "/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ReCovall/temporal"

for s in ${subj[@]}; do
	mkdir -p "/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ReCovall/temporal/${s}"
done
recov_path="/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ReCovall/temporal"

# ======================================================================= #
# Both hemispheres (whole-brain)
for s in ${subj[@]}; do
	matlab -batch "fsmerge('${proj_path}/${s}/${s}_lh_filt01_fsavg.mgz','${proj_path}/${s}/${s}_rh_filt01_fsavg.mgz','${recov_path}/${s}/${s}_bothHemi.mgz','x')" -nojvm
done

# Calculate ReCov
# Temporal
for s in ${subj[@]}; do
	matlab -batch "calc_recov_temporal('${recov_path}/${s}/${s}_bothHemi.mgz','${recov_path}/${s}/${s}_ReCovall_lh_temporal.mgz','${recov_path}/${s}/${s}_ReCovall_rh_temporal.mgz')" -nojvm
done

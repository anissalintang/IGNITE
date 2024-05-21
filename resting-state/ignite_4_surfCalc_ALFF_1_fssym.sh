#!/bin/bash

# Calculating ALFF in surface space (fsavg_sym)

proj_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface/projected/fssym/nonSmoothed/filt_0.01-0.1"
fs_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface/recon"
	
hemi=(lh rh)

subj=($(ls /Volumes/gdrive4tb/IGNITE/resting-state/preprocessed))
# subj=(IGTTFJ_00074)

mkdir -p "/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF_fssym"

for s in ${subj[@]}; do
	mkdir -p "/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF_fssym/${s}"
done
alff_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF_fssym"

# ======================================================================= #
# Calculate the STD from the NON-SMOOTHED image (ALFF)
for s in ${subj[@]}; do
	for h in ${hemi[@]}; do
		matlab -batch "fsmaths('${proj_path}/${s}/${s}_${h}_filt01_fsavg_onlh_fssym.mgz','Tstd','${alff_path}/${s}/${s}_${h}_fsavg_ALFF.mgz')" -nojvm
	done
done

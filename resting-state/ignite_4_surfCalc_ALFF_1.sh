#!/bin/bash

# Calculating ALFF in surface space (fsavg)

proj_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface/projected/nonSmoothed/filt_0.01-0.1"
fs_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface/recon"
	
hemi=(lh rh)

subj=($(ls /Volumes/gdrive4tb/IGNITE/resting-state/preprocessed))
# subj=(IGTTFJ_00074)

mkdir -p "/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF"

for s in ${subj[@]}; do
	mkdir -p "/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF/${s}"
done
alff_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF"

# ======================================================================= #
# Calculate the STD from the NON-SMOOTHED image (ALFF)
for s in ${subj[@]}; do
	for h in ${hemi[@]}; do
		matlab -batch "fsmaths('${proj_path}/${s}/${s}_${h}_filt01_fsavg.mgz','Tstd','${alff_path}/${s}/${s}_${h}_fsavg_ALFF.mgz')" -nojvm
	done
done

# Calculate the square of ALFF (to make it directly comparable with ReCov)
for s in ${subj[@]}; do
	for h in ${hemi[@]}; do
		matlab -batch "fsmaths('${alff_path}/${s}/${s}_${h}_fsavg_ALFF.mgz','sqr','${alff_path}/${s}/${s}_${h}_fsavg_ALFF_sqr.mgz')" -nojvm
	done
done
#!/bin/bash

proj_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface/projected/nonSmoothed/filt_0.01-0.1"
fs_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface/recon"
	
hemi=(lh rh)

subj=($(ls /Volumes/gdrive4tb/IGNITE/resting-state/preprocessed))
# subj=(IGNTFA_00065)

mkdir -p "/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR"

for s in ${subj[@]}; do
	mkdir -p "/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR/${s}"
done
GCOR_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR"
# ======================================================================= #
# Both hemispheres (whole-brain)
for s in ${subj[@]}; do
	matlab -batch "fsmerge('${proj_path}/${s}/${s}_lh_filt01_fsavg.mgz','${proj_path}/${s}/${s}_rh_filt01_fsavg.mgz','${GCOR_path}/${s}/${s}_bothHemi.mgz','x')" -nojvm
done

# Calculate the std
for s in ${subj[@]}; do
	matlab -batch "fsmaths('${GCOR_path}/${s}/${s}_bothHemi.mgz','Tstd','${GCOR_path}/${s}/${s}_std.mgz')" -nojvm
done

# Calculate unitVar_data
for s in ${subj[@]}; do
	matlab -batch "fsmaths('${GCOR_path}/${s}/${s}_bothHemi.mgz','div','${GCOR_path}/${s}/${s}_std.mgz','${GCOR_path}/${s}/${s}_bothHemi.mgz')" -nojvm

done

# Calculate GCOR for
# 1. Same hemisphere (results are two images of lh and rh, each correlated within its hemisphere)
# 2. Across hemisphere (results are two images of lh and rh, each correlated with across hemisphere; so lh is correlated to rh, and rh is to lh)
# 3. All / whole-brain GCOR (result is one image, correlation to wholeBrain)

# Same hemisphere
for s in ${subj[@]}; do
	matlab -batch "calc_gcor('${GCOR_path}/${s}/${s}_bothHemi.mgz','same','${GCOR_path}/${s}/${s}_GCOR_SAME_lh.mgz', '${GCOR_path}/${s}/${s}_GCOR_SAME_rh.mgz')" -nojvm
done

# Across hemisphere
for s in ${subj[@]}; do
	matlab -batch "calc_gcor('${GCOR_path}/${s}/${s}_bothHemi.mgz','across','${GCOR_path}/${s}/${s}_GCOR_ACROSS_lh.mgz', '${GCOR_path}/${s}/${s}_GCOR_ACROSS_rh.mgz')" -nojvm
done

# wholeBrain
for s in ${subj[@]}; do
	matlab -batch "calc_gcor('${GCOR_path}/${s}/${s}_bothHemi.mgz','all','${GCOR_path}/${s}/${s}_GCOR_wholeBrain_lh.mgz', '${GCOR_path}/${s}/${s}_GCOR_wholeBrain_rh.mgz')" -nojvm

done


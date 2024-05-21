#!/bin/bash

proj_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface/projected/fssym/nonSmoothed/filt_0.01-0.1"
fs_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface/recon"
	
hemi=(lh rh)

subj=($(ls /Volumes/gdrive4tb/IGNITE/resting-state/preprocessed))
# subj=(IGTTFJ_00074)

mkdir -p "/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR_fssym"

for s in ${subj[@]}; do
	mkdir -p "/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR_fssym/${s}"
done
GCOR_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR_fssym"
# ======================================================================= #
# Both hemispheres (whole-brain)
for s in ${subj[@]}; do
	matlab -batch "fsmerge('${proj_path}/${s}/${s}_lh_filt01_fsavg_onlh_fssym.mgz','${proj_path}/${s}/${s}_rh_filt01_fsavg_onlh_fssym.mgz','${GCOR_path}/${s}/${s}_bothHemi.mgz','x')" -nojvm
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
# 3. All / whole-brain GCOR (result is one image, correlation to wholeBrain)

# wholeBrain
for s in ${subj[@]}; do
	matlab -batch "calc_gcor('${GCOR_path}/${s}/${s}_bothHemi.mgz','all','${GCOR_path}/${s}/${s}_GCOR_wholeBrain_lh.mgz', '${GCOR_path}/${s}/${s}_GCOR_wholeBrain_rh.mgz')" -nojvm

done


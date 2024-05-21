#!/bin/bash

# Calculating ReHo in surface space (fsavg) for HG from Colin's mask

proj_path="/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/projected/nonSmoothed/filt_0.01-0.1"
fs_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface/recon"
	
hemi=(lh rh)

subj=($(ls /Volumes/gdrive4tb/IGNITE/sparse_rest/preprocessed))
# subj=(IGNTFA_00065)

mkdir -p "/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ReHo"

for s in ${subj[@]}; do
	mkdir -p "/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ReHo/${s}"
done
reho_path="/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ReHo"

# ======================================================================= #
# Both hemispheres (whole-brain)
for s in ${subj[@]}; do
	matlab -batch "fsmerge('${proj_path}/${s}/${s}_lh_filt01_fsavg.mgz','${proj_path}/${s}/${s}_rh_filt01_fsavg.mgz','${reho_path}/${s}/${s}_bothHemi.mgz','x')" -nojvm
done

# Calculate the std
for s in ${subj[@]}; do
	matlab -batch "fsmaths('${reho_path}/${s}/${s}_bothHemi.mgz','Tstd','${reho_path}/${s}/${s}_std.mgz')" -nojvm
done

# Calculate unitVar_data
for s in ${subj[@]}; do
	matlab -batch "fsmaths('${reho_path}/${s}/${s}_bothHemi.mgz','div','${reho_path}/${s}/${s}_std.mgz','${reho_path}/${s}/${s}_bothHemi.mgz')" -nojvm

done

# Calculate ReHo

# HG Colin
for s in ${subj[@]}; do
	matlab -batch "calc_reho_colinHG_condition('${reho_path}/${s}/${s}_bothHemi.mgz','${reho_path}/${s}/${s}_ReHo_lh_HG_Colin_rest.mgz','${reho_path}/${s}/${s}_ReHo_rh_HG_Colin_rest.mgz', '${reho_path}/${s}/${s}_ReHo_lh_HG_Colin_vis.mgz','${reho_path}/${s}/${s}_ReHo_rh_HG_Colin_vis.mgz')" -nojvm
done

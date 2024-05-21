#!/bin/bash

# Calculating ReHo in surface space (fsavg)

proj_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface/projected/nonSmoothed/filt_0.01-0.1"
fs_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface/recon"
	
hemi=(lh rh)

subj=($(ls /Volumes/gdrive4tb/IGNITE/resting-state/preprocessed))
# subj=(IGNTFA_00065)

mkdir -p "/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ReHo"

for s in ${subj[@]}; do
	mkdir -p "/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ReHo/${s}"
done
reho_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ReHo"

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

# Run matlab code to create surf.graph to get ReHo indices
matlab -batch "createSurf_ReHo"

# Calculate ReHo

# rad 2.5 mm
for s in ${subj[@]}; do
	matlab -batch "calc_reho('${reho_path}/${s}/${s}_bothHemi.mgz',2.5,'${reho_path}/${s}/${s}_ReHo_lh_2_5.mgz', '${reho_path}/${s}/${s}_ReHo_rh_2_5.mgz')" -nojvm
done

# rad 5 mm
for s in ${subj[@]}; do
	matlab -batch "calc_reho('${reho_path}/${s}/${s}_bothHemi.mgz',5,'${reho_path}/${s}/${s}_ReHo_lh_5.mgz', '${reho_path}/${s}/${s}_ReHo_rh_5.mgz')" -nojvm

done

# rad 10 mm
for s in ${subj[@]}; do
	matlab -batch "calc_reho('${reho_path}/${s}/${s}_bothHemi.mgz',10,'${reho_path}/${s}/${s}_ReHo_lh_10.mgz', '${reho_path}/${s}/${s}_ReHo_rh_10.mgz')" -nojvm
done

# rad 20 mm
for s in ${subj[@]}; do
	matlab -batch "calc_reho('${reho_path}/${s}/${s}_bothHemi.mgz',20,'${reho_path}/${s}/${s}_ReHo_lh_20.mgz', '${reho_path}/${s}/${s}_ReHo_rh_20.mgz')" -nojvm
done

# rad 40 mm
for s in ${subj[@]}; do
	matlab -batch "calc_reho('${reho_path}/${s}/${s}_bothHemi.mgz',40,'${reho_path}/${s}/${s}_ReHo_lh_40.mgz', '${reho_path}/${s}/${s}_ReHo_rh_40.mgz')" -nojvm
done
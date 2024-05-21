#!/bin/bash

# Calculating ReCov in surface space (fsavg)

proj_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface/projected/nonSmoothed/filt_0.01-0.1"
fs_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface/recon"
	
hemi=(lh rh)

subj=($(ls /Volumes/gdrive4tb/IGNITE/resting-state/preprocessed))
# subj=(IGNTFA_00065)

mkdir -p "/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ReCov"

for s in ${subj[@]}; do
	mkdir -p "/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ReCov/${s}"
done
recov_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ReCov"

# ======================================================================= #
# # Both hemispheres (whole-brain)
# Get in from ReHo path
reho_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ReHo"

# Run matlab code to create surf.graph to get ReCov indices
matlab -batch "createSurf_ReCov"

# Calculate ReCov

# rad 2.5 mm
for s in ${subj[@]}; do
	matlab -batch "calc_recov('${reho_path}/${s}/${s}_bothHemi.mgz',2.5,'${recov_path}/${s}/${s}_ReCov_lh_2_5.mgz', '${recov_path}/${s}/${s}_ReCov_rh_2_5.mgz')" -nojvm
done

# rad 5 mm
for s in ${subj[@]}; do
	matlab -batch "calc_recov('${reho_path}/${s}/${s}_bothHemi.mgz',5,'${recov_path}/${s}/${s}_ReCov_lh_5.mgz', '${recov_path}/${s}/${s}_ReCov_rh_5.mgz')" -nojvm

done

# rad 10 mm
for s in ${subj[@]}; do
	matlab -batch "calc_recov('${reho_path}/${s}/${s}_bothHemi.mgz',10,'${recov_path}/${s}/${s}_ReCov_lh_10.mgz', '${recov_path}/${s}/${s}_ReCov_rh_10.mgz')" -nojvm
done

# rad 20 mm
for s in ${subj[@]}; do
	matlab -batch "calc_recov('${reho_path}/${s}/${s}_bothHemi.mgz',20,'${recov_path}/${s}/${s}_ReCov_lh_20.mgz', '${recov_path}/${s}/${s}_ReCov_rh_20.mgz')" -nojvm
done

# rad 40 mm
for s in ${subj[@]}; do
	matlab -batch "calc_recov('${reho_path}/${s}/${s}_bothHemi.mgz',40,'${recov_path}/${s}/${s}_ReCov_lh_40.mgz', '${recov_path}/${s}/${s}_ReCov_rh_40.mgz')" -nojvm
done
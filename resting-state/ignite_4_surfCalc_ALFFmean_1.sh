#!/bin/bash

# Calculating ReHo in surface space (fsavg)

proj_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface/projected/nonSmoothed/filt_0.01-0.1"
fs_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface/recon"
	
hemi=(lh rh)

subj=($(ls /Volumes/gdrive4tb/IGNITE/resting-state/preprocessed))
# subj=(IGNTFA_00065)


for s in ${subj[@]}; do
	mkdir -p "/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFFmean/${s}"
done
reho_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ReHo"

ALFFmean_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFFmean"

# ======================================================================= #
# Calculate ALFFmean

# rad 2.5 mm
for s in ${subj[@]}; do
	matlab -batch "calc_ALFFmean_reho('${reho_path}/${s}/${s}_bothHemi.mgz',2.5,'${ALFFmean_path}/${s}/${s}_ALFFmean_lh_2_5.mgz', '${ALFFmean_path}/${s}/${s}_ALFFmean_rh_2_5.mgz')" -nojvm
done

# rad 5 mm
for s in ${subj[@]}; do
	matlab -batch "calc_ALFFmean_reho('${reho_path}/${s}/${s}_bothHemi.mgz',5,'${ALFFmean_path}/${s}/${s}_ALFFmean_lh_5.mgz', '${ALFFmean_path}/${s}/${s}_ALFFmean_rh_5.mgz')" -nojvm
done

# rad 10 mm
for s in ${subj[@]}; do
	matlab -batch "calc_ALFFmean_reho('${reho_path}/${s}/${s}_bothHemi.mgz',10,'${ALFFmean_path}/${s}/${s}_ALFFmean_lh_10.mgz', '${ALFFmean_path}/${s}/${s}_ALFFmean_rh_10.mgz')" -nojvm
done

# rad 20 mm
for s in ${subj[@]}; do
	matlab -batch "calc_ALFFmean_reho('${reho_path}/${s}/${s}_bothHemi.mgz',20,'${ALFFmean_path}/${s}/${s}_ALFFmean_lh_20.mgz', '${ALFFmean_path}/${s}/${s}_ALFFmean_rh_20.mgz')" -nojvm
done

# rad 40 mm
for s in ${subj[@]}; do
	matlab -batch "calc_ALFFmean_reho('${reho_path}/${s}/${s}_bothHemi.mgz',40,'${ALFFmean_path}/${s}/${s}_ALFFmean_lh_40.mgz', '${ALFFmean_path}/${s}/${s}_ALFFmean_rh_40.mgz')" -nojvm

done
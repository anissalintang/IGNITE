#!/bin/bash

# Script to get the mean Value from ALFF, ReHo for plotting

mask_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/destrieux_fsavg"
export SUBJECTS_DIR="${mask_path}"

alff_path="/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ALFFall"
reho_path="/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ReHoall/temporal"

hemi=(lh rh)

subj=($(ls /Volumes/gdrive4tb/IGNITE/sparse_rest/preprocessed))

# ======================================================================= #
# Get mean values for AUD region with temporal mask
for s in ${subj[@]}; do
	mkdir -p "/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ALFFall/meanValues/tinEffect/${s}"
	mkdir -p "/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ReHoall/temporal/meanValues/tinEffect/${s}"

	for h in ${hemi[@]}; do
			# Then calculate the mean ALFF for all subjects in temporal
			matlab -batch "fsstats('${alff_path}/${s}/${s}_${h}_ALFFall_smooth5.mgz','-l 500 -m','$SUBJECTS_DIR/temporalLobe_mask_${h}.mgh')" -nojvm > ${alff_path}/meanValues/tinEffect/${s}/${s}_${h}_ALFFall_smooth5.txt


			# Then calculate the mean ReHo for all subjects in temporal
			matlab -batch "fsstats('${reho_path}/${s}/${s}_ReHoall_${h}_temporal_smooth5.mgz','-m','$SUBJECTS_DIR/temporalLobe_mask_${h}.mgh')" -nojvm > ${reho_path}/meanValues/tinEffect/${s}/${s}_${h}_ReHoall_smooth5.txt
	done
done


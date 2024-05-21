#!/bin/bash

# Script to get the mean Value from ALFF, ReHo for plotting

mask_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/destrieux_fsavg"
export SUBJECTS_DIR="${mask_path}"

alff_path="/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ALFF"
reho_path="/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ReHo/temporal"
recov_path="/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ReCov/temporal"

hemi=(lh rh)
cond=(rest vis)

subj=($(ls /Volumes/gdrive4tb/IGNITE/sparse_rest/preprocessed))

# ======================================================================= #
# Get mean values for AUD region with temporal mask
for s in ${subj[@]}; do
	# mkdir -p "/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ALFF/meanValues/temporal/${s}"
	# mkdir -p "/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ReHo/temporal/meanValues/${s}"
	mkdir -p "/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ReCov/temporal/meanValues/${s}"

	for h in ${hemi[@]}; do
		for c in ${cond[@]};do
			# Then calculate the mean ALFF for all subjects in temporal
			# matlab -batch "fsstats('${alff_path}/${s}/${s}_${h}_ALFF_${c}_smooth5.mgz','-l 500 -m','$SUBJECTS_DIR/temporalLobe_mask_${h}.mgh')" -nojvm > ${alff_path}/meanValues/temporal/${s}/${s}_${h}_ALFF_${c}_smooth5.txt


			# # Then calculate the mean ReHo for all subjects in temporal
			# matlab -batch "fsstats('${reho_path}/${s}/${s}_ReHo_${h}_temporal_${c}_smooth5.mgz','-m','$SUBJECTS_DIR/temporalLobe_mask_${h}.mgh')" -nojvm > ${reho_path}/meanValues/${s}/${s}_${h}_ReHo_${c}_smooth5.txt

			# Then calculate the mean ReCov for all subjects in temporal
			matlab -batch "fsstats('${recov_path}/${s}/${s}_ReCov_${h}_temporal_${c}_smooth5.mgz','-m','$SUBJECTS_DIR/temporalLobe_mask_${h}.mgh')" -nojvm > ${recov_path}/meanValues/${s}/${s}_${h}_ReCov_${c}_smooth5.txt
		done
	done
done


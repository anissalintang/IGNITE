#!/bin/bash

# Script to get the mean Value from ALFF, GCOR and ReHo for plotting

fs_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface/recon"

mask_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/destrieux_fsavg"
export SUBJECTS_DIR="${mask_path}"

alff_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF"
# reho_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ReHo"
gcor_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR"

hemi=(lh rh)

subj=($(ls /Volumes/gdrive4tb/IGNITE/resting-state/preprocessed))
# subj=(IGTTFJ_00074)


# ======================================================================= #
# Get mean values from the sensory-motor mask
for s in ${subj[@]}; do
	for h in ${hemi[@]}; do
		# Then calculate the mean ALFF for all subjects in the mask
		matlab -batch "fsstats('${alff_path}/${s}/${s}_${h}_fsavg_ALFF.mgz','-l 500 -m','$SUBJECTS_DIR/sensory-motor_Yeo_${h}.mgh')" -nojvm > ${alff_path}/meanValues/${s}/${s}_ALFF_sensory_${h}_smooth5.txt


		# Then calculate the mean GCOR for all subjects in the mask
		matlab -batch "fsstats('${gcor_path}/${s}/${s}_GCOR_wholeBrain_${h}.mgz','-m','$SUBJECTS_DIR/sensory-motor_Yeo_${h}.mgh')" -nojvm > ${gcor_path}/meanValues/${s}/${s}_GCOR_sensory_${h}_smooth5.txt

	done
done

# Get mean values from the DMN mask
for s in ${subj[@]}; do
	for h in ${hemi[@]}; do
		# Then calculate the mean ALFF for all subjects in the mask
		matlab -batch "fsstats('${alff_path}/${s}/${s}_${h}_fsavg_ALFF.mgz','-l 500 -m','$SUBJECTS_DIR/DMN_mask_Yeo_${h}.mgh')" -nojvm > ${alff_path}/meanValues/${s}/${s}_ALFF_DMN_${h}_smooth5.txt


		# Then calculate the mean GCOR for all subjects in the mask
		matlab -batch "fsstats('${gcor_path}/${s}/${s}_GCOR_wholeBrain_${h}.mgz','-m','$SUBJECTS_DIR/DMN_mask_Yeo_${h}.mgh')" -nojvm > ${gcor_path}/meanValues/${s}/${s}_GCOR_DMN_${h}_smooth5.txt

	done
done

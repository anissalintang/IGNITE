#!/bin/bash

# Script to get the mean Value from ALFF from cortex mask

alff_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF"

hemi=(lh rh)

subj=($(ls /Volumes/gdrive4tb/IGNITE/resting-state/preprocessed))
# subj=(IGTTFJ_00074)

# ======================================================================= #
fs_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface/recon"
export SUBJECTS_DIR="${fs_path}"

mkdir -p "/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF/cortex_mask"

for h in ${hemi[@]}; do
	mri_label2vol \
	--label ${SUBJECTS_DIR}/fsaverage/label/${h}.cortex.label \
	--temp ${SUBJECTS_DIR}/fsaverage/mri/brain.mgz \
	--identity \
	--proj frac 0 1 0.1 \
	--o ${alff_path}/cortex_mask/${h}_cortex_label_vol.mgz \
	--subject fsaverage \
	--hemi ${h}

	mri_vol2surf \
	--mov ${alff_path}/cortex_mask/${h}_cortex_label_vol.mgz \
	--hemi ${h} \
	--srcsubject fsaverage \
	--trgsubject fsaverage \
	--interp nearest \
	--projfrac-avg 0 1 0.1 \
	--o ${alff_path}/cortex_mask/${h}_cortex_label_surf.mgh \
	--regheader fsaverage
done

# Get mean values for whole-Brain
for s in ${subj[@]}; do
	mkdir -p "/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF/meanValues_cortex/${s}"
		for h in ${hemi[@]}; do
			# Calculate the mean ALFF for all subjects/cond in whole-Brain
			matlab -batch "fsstats('${alff_path}/${s}/${s}_${h}_fsavg_ALFF_smooth5.mgz','-m','${alff_path}/cortex_mask/${h}_cortex_label_surf.mgh')" -nojvm > ${alff_path}/meanValues_cortex/${s}/${s}_ALFF_cortex_${h}_smooth5.txt
		done
done


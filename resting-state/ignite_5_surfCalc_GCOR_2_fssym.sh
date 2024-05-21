#!/bin/bash

proj_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface/projected/fssym/nonSmoothed/filt_0.01-0.1"
fs_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface/recon"
	
hemi=(lh rh)

subj=($(ls /Volumes/gdrive4tb/IGNITE/resting-state/preprocessed))
# subj=(IGNTFA_00065)

GCOR_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR_fssym"

# ======================================================================= #
# Calculate average from all subjects for each conditions and hemispheres
mkdir -p "/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR_fssym/merge_mean"

# Merge GCOR --wholeBrain hemisphere
for h in ${hemi[@]}; do
		# Initialize subjects string
		tin_subjects=""
		noTin_subjects=""

		# Generate subjects string
		for s in ${subj[@]}; do
			if [[ $s == *"TT"* ]]; then
				tin_subjects+="'${GCOR_path}/${s}/${s}_GCOR_wholeBrain_${h}.mgz',"
			elif [[ $s == *"NT"* ]]; then
				noTin_subjects+="'${GCOR_path}/${s}/${s}_GCOR_wholeBrain_${h}.mgz',"
			fi
		done

		# Remove the trailing comma
		tin_subjects=${tin_subjects%?}
		noTin_subjects=${noTin_subjects%?}

		# Merge all subjects
		if [[ ! -z $tin_subjects ]]; then
			matlab -batch "fsmerge(${tin_subjects},'${GCOR_path}/merge_mean/allSubj_${h}_GCOR_wholeBrain_merged_tin.mgz','t')" -nojvm
		fi
		if [[ ! -z $noTin_subjects ]]; then
			matlab -batch "fsmerge(${noTin_subjects},'${GCOR_path}/merge_mean/allSubj_${h}_GCOR_wholeBrain_merged_noTin.mgz','t')" -nojvm
		fi

		# Then calculate the mean out of the merged image
		matlab -batch "fsmaths('${GCOR_path}/merge_mean/allSubj_${h}_GCOR_wholeBrain_merged_tin.mgz','Tmean','${GCOR_path}/merge_mean/allSubj_${h}_GCOR_wholeBrain_merged_mean_tin.mgz')" -nojvm

		# Then calculate the mean out of the merged image
		matlab -batch "fsmaths('${GCOR_path}/merge_mean/allSubj_${h}_GCOR_wholeBrain_merged_noTin.mgz','Tmean','${GCOR_path}/merge_mean/allSubj_${h}_GCOR_wholeBrain_merged_mean_noTin.mgz')" -nojvm

		# Remove the merged image
		rm ${GCOR_path}/merge_mean/allSubj_${h}_GCOR_wholeBrain_merged_tin.mgz
		rm ${GCOR_path}/merge_mean/allSubj_${h}_GCOR_wholeBrain_merged_noTin.mgz
done


# ======================================================================= #
# SMOOTHED
fwhm=5

fs_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface"

export SUBJECTS_DIR="${fs_path}/recon"

for s in ${subj[@]}; do
	for h in ${hemi[@]}; do
			mri_surf2surf \
			--sval ${GCOR_path}/${s}/${s}_GCOR_wholeBrain_${h}.mgz \
			--tval ${GCOR_path}/${s}/${s}_GCOR_wholeBrain_${h}_smooth5.mgz \
			--srcsubject fsaverage_sym \
			--trgsubject fsaverage_sym \
			--hemi lh \
			--fwhm $fwhm \
			--label-src $SUBJECTS_DIR/fsaverage_sym/label/lh.cortex.label

	done
done


for h in ${hemi[@]}; do
		# Initialize subjects string
		tin_subjects=""
		noTin_subjects=""

		# Generate subjects string
		for s in ${subj[@]}; do
			if [[ $s == *"TT"* ]]; then
				tin_subjects+="'${GCOR_path}/${s}/${s}_GCOR_wholeBrain_${h}_smooth5.mgz',"
			elif [[ $s == *"NT"* ]]; then
				noTin_subjects+="'${GCOR_path}/${s}/${s}_GCOR_wholeBrain_${h}_smooth5.mgz',"
			fi
		done

		# Remove the trailing comma
		tin_subjects=${tin_subjects%?}
		noTin_subjects=${noTin_subjects%?}

		# Merge all subjects
		if [[ ! -z $tin_subjects ]]; then
			matlab -batch "fsmerge(${tin_subjects},'${GCOR_path}/merge_mean/allSubj_${h}_GCOR_wholeBrain_merged_tin_smooth5.mgz','t')" -nojvm
		fi
		if [[ ! -z $noTin_subjects ]]; then
			matlab -batch "fsmerge(${noTin_subjects},'${GCOR_path}/merge_mean/allSubj_${h}_GCOR_wholeBrain_merged_noTin_smooth5.mgz','t')" -nojvm
		fi

		# Then calculate the mean out of the merged image
		matlab -batch "fsmaths('${GCOR_path}/merge_mean/allSubj_${h}_GCOR_wholeBrain_merged_tin_smooth5.mgz','Tmean','${GCOR_path}/merge_mean/allSubj_${h}_GCOR_wholeBrain_merged_mean_tin_smooth5.mgz')" -nojvm

		# Then calculate the mean out of the merged image
		matlab -batch "fsmaths('${GCOR_path}/merge_mean/allSubj_${h}_GCOR_wholeBrain_merged_noTin_smooth5.mgz','Tmean','${GCOR_path}/merge_mean/allSubj_${h}_GCOR_wholeBrain_merged_mean_noTin_smooth5.mgz')" -nojvm

		# Remove the merged image
		rm ${GCOR_path}/merge_mean/allSubj_${h}_GCOR_wholeBrain_merged_tin_smooth5.mgz
		rm ${GCOR_path}/merge_mean/allSubj_${h}_GCOR_wholeBrain_merged_noTin_smooth5.mgz
done

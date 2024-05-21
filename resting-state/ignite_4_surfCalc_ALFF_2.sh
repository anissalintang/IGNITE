#!/bin/bash

# Calculating ALFF in surface space (fsavg), create merged_mean images before calculate stimEffect

proj_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface/projected/nonSmoothed/filt_0.01-0.1"
fs_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface/recon"
alff_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF"
	
hemi=(lh rh)

subj=($(ls /Volumes/gdrive4tb/IGNITE/resting-state/preprocessed))
# s=(IGTTFJ_00074)

# ======================================================================= #
# Calculate average from all subjects for each conditions and hemispheres
# mkdir -p "/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/ALFF/merge_mean"

# # Merge non-squared ALFF
# for h in ${hemi[@]}; do
# 		# Initialize subjects string
# 		tin_subjects=""
# 		noTin_subjects=""

# 		# Generate subjects string
# 		for s in ${subj[@]}; do
# 			if [[ $s == *"TT"* ]]; then
# 				tin_subjects+="'${alff_path}/${s}/${s}_${h}_fsavg_ALFF.mgz',"
# 			elif [[ $s == *"NT"* ]]; then
# 				noTin_subjects+="'${alff_path}/${s}/${s}_${h}_fsavg_ALFF.mgz',"
# 			fi
# 		done

# 		# Remove the trailing comma
# 		tin_subjects=${tin_subjects%?}
# 		noTin_subjects=${noTin_subjects%?}

# 		# Merge all subjects
# 		if [[ ! -z $tin_subjects ]]; then
# 			matlab -batch "fsmerge(${tin_subjects},'${alff_path}/merge_mean/allSubj_${h}_ALFF_merged_tin.mgz','t')" -nojvm
# 		fi
# 		if [[ ! -z $noTin_subjects ]]; then
# 			matlab -batch "fsmerge(${noTin_subjects},'${alff_path}/merge_mean/allSubj_${h}_ALFF_merged_noTin.mgz','t')" -nojvm
# 		fi

# 		# Then calculate the mean out of the merged image
# 		matlab -batch "fsmaths('${alff_path}/merge_mean/allSubj_${h}_ALFF_merged_tin.mgz','Tmean','${alff_path}/merge_mean/allSubj_${h}_ALFF_merged_mean_tin.mgz')" -nojvm

# 		# Then calculate the mean out of the merged image
# 		matlab -batch "fsmaths('${alff_path}/merge_mean/allSubj_${h}_ALFF_merged_noTin.mgz','Tmean','${alff_path}/merge_mean/allSubj_${h}_ALFF_merged_mean_noTin.mgz')" -nojvm

# 		# Remove the merged image
# 		rm ${alff_path}/merge_mean/allSubj_${h}_ALFF_merged_tin.mgz
# 		rm ${alff_path}/merge_mean/allSubj_${h}_ALFF_merged_noTin.mgz
# done


# ======================================================================= #
# SMOOTHED
fwhm=5

fs_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface"

export SUBJECTS_DIR="${fs_path}/recon"

for s in ${subj[@]}; do
	for h in ${hemi[@]}; do
			mri_surf2surf \
			--sval ${alff_path}/${s}/${s}_${h}_fsavg_ALFF.mgz \
			--tval ${alff_path}/${s}/${s}_${h}_fsavg_ALFF_smooth5.mgz \
			--srcsubject fsaverage \
			--trgsubject fsaverage \
			--hemi ${h} \
			--fwhm $fwhm \
			--label-src $SUBJECTS_DIR/fsaverage/label/${h}.cortex.label

	done
done

for h in ${hemi[@]}; do
		# Initialize subjects string
		tin_subjects=""
		noTin_subjects=""

		# Generate subjects string
		for s in ${subj[@]}; do
			if [[ $s == *"TT"* ]]; then
				tin_subjects+="'${alff_path}/${s}/${s}_${h}_fsavg_ALFF_smooth5.mgz',"
			elif [[ $s == *"NT"* ]]; then
				noTin_subjects+="'${alff_path}/${s}/${s}_${h}_fsavg_ALFF_smooth5.mgz',"
			fi
		done

		# Remove the trailing comma
		tin_subjects=${tin_subjects%?}
		noTin_subjects=${noTin_subjects%?}

		# Merge all subjects
		if [[ ! -z $tin_subjects ]]; then
			matlab -batch "fsmerge(${tin_subjects},'${alff_path}/merge_mean/allSubj_${h}_ALFF_merged_tin_smooth5.mgz','t')" -nojvm
		fi
		if [[ ! -z $noTin_subjects ]]; then
			matlab -batch "fsmerge(${noTin_subjects},'${alff_path}/merge_mean/allSubj_${h}_ALFF_merged_noTin_smooth5.mgz','t')" -nojvm
		fi

		# Then calculate the mean out of the merged image
		matlab -batch "fsmaths('${alff_path}/merge_mean/allSubj_${h}_ALFF_merged_tin_smooth5.mgz','Tmean','${alff_path}/merge_mean/allSubj_${h}_ALFF_merged_mean_tin_smooth5.mgz')" -nojvm

		# Then calculate the mean out of the merged image
		matlab -batch "fsmaths('${alff_path}/merge_mean/allSubj_${h}_ALFF_merged_noTin_smooth5.mgz','Tmean','${alff_path}/merge_mean/allSubj_${h}_ALFF_merged_mean_noTin_smooth5.mgz')" -nojvm

		# Remove the merged image
		rm ${alff_path}/merge_mean/allSubj_${h}_ALFF_merged_tin_smooth5.mgz
		rm ${alff_path}/merge_mean/allSubj_${h}_ALFF_merged_noTin_smooth5.mgz
done


# ======================================================================= #
# # Merge SQUARED ALFF
# for h in ${hemi[@]}; do
# 		# Initialize subjects string
# 		tin_subjects=""
# 		noTin_subjects=""

# 		# Generate subjects string
# 		for s in ${subj[@]}; do
# 			if [[ $s == *"TT"* ]]; then
# 				tin_subjects+="'${alff_path}/${s}/${s}_${h}_fsavg_ALFF_sqr.mgz',"
# 			elif [[ $s == *"NT"* ]]; then
# 				noTin_subjects+="'${alff_path}/${s}/${s}_${h}_fsavg_ALFF_sqr.mgz',"
# 			fi
# 		done

# 		# Remove the trailing comma
# 		tin_subjects=${tin_subjects%?}
# 		noTin_subjects=${noTin_subjects%?}

# 		# Merge all subjects
# 		if [[ ! -z $tin_subjects ]]; then
# 			matlab -batch "fsmerge(${tin_subjects},'${alff_path}/merge_mean/allSubj_${h}_ALFF_sqr_merged_tin.mgz','t')" -nojvm
# 		fi
# 		if [[ ! -z $noTin_subjects ]]; then
# 			matlab -batch "fsmerge(${noTin_subjects},'${alff_path}/merge_mean/allSubj_${h}_ALFF_sqr_merged_noTin.mgz','t')" -nojvm
# 		fi

# 		# Then calculate the mean out of the merged image
# 		matlab -batch "fsmaths('${alff_path}/merge_mean/allSubj_${h}_ALFF_sqr_merged_tin.mgz','Tmean','${alff_path}/merge_mean/allSubj_${h}_ALFF_sqr_merged_mean_tin.mgz')" -nojvm

# 		# Then calculate the mean out of the merged image
# 		matlab -batch "fsmaths('${alff_path}/merge_mean/allSubj_${h}_ALFF_sqr_merged_noTin.mgz','Tmean','${alff_path}/merge_mean/allSubj_${h}_ALFF_sqr_merged_mean_noTin.mgz')" -nojvm

# 		# Remove the merged image
# 		rm ${alff_path}/merge_mean/allSubj_${h}_ALFF_sqr_merged_tin.mgz
# 		rm ${alff_path}/merge_mean/allSubj_${h}_ALFF_sqr_merged_noTin.mgz
# done
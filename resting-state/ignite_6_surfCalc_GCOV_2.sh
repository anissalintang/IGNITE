#!/bin/bash

proj_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface/projected/nonSmoothed/filt_0.01-0.1"
fs_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface/recon"
	
hemi=(lh rh)

subj=($(ls /Volumes/gdrive4tb/IGNITE/resting-state/preprocessed))
# subj=(IGNTFA_00065)

GCOR_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR"

# ======================================================================= #
# Calculate average from all subjects for each conditions and hemispheres
mkdir -p "/Volumes/gdrive4tb/IGNITE/resting-state/surface/analysis/GCOR/merge_mean"

# Merge GCOR --SAME hemisphere
for h in ${hemi[@]}; do
		# Initialize subjects string
		tin_subjects=""
		noTin_subjects=""

		# Generate subjects string
		for s in ${subj[@]}; do
			if [[ $s == *"TT"* ]]; then
				tin_subjects+="'${GCOR_path}/${s}/${s}_GCOR_SAME_${h}.mgz',"
			elif [[ $s == *"NT"* ]]; then
				noTin_subjects+="'${GCOR_path}/${s}/${s}_GCOR_SAME_${h}.mgz',"
			fi
		done

		# Remove the trailing comma
		tin_subjects=${tin_subjects%?}
		noTin_subjects=${noTin_subjects%?}


		# Merge all subjects
		if [[ ! -z $tin_subjects ]]; then
			matlab -batch "fsmerge(${tin_subjects},'${GCOR_path}/merge_mean/allSubj_${h}_GCOR_SAME_merged_tin.mgz','t')" -nojvm
		fi
		if [[ ! -z $noTin_subjects ]]; then
			matlab -batch "fsmerge(${noTin_subjects},'${GCOR_path}/merge_mean/allSubj_${h}_GCOR_SAME_merged_noTin.mgz','t')" -nojvm
		fi

		# Then calculate the mean out of the merged image
		matlab -batch "fsmaths('${GCOR_path}/merge_mean/allSubj_${h}_GCOR_SAME_merged_tin.mgz','Tmean','${GCOR_path}/merge_mean/allSubj_${h}_GCOR_SAME_merged_mean_tin.mgz')" -nojvm

		# Then calculate the mean out of the merged image
		matlab -batch "fsmaths('${GCOR_path}/merge_mean/allSubj_${h}_GCOR_SAME_merged_noTin.mgz','Tmean','${GCOR_path}/merge_mean/allSubj_${h}_GCOR_SAME_merged_mean_noTin.mgz')" -nojvm

		# Remove the merged image
		rm ${GCOR_path}/merge_mean/allSubj_${h}_GCOR_SAME_merged_tin.mgz
		rm ${GCOR_path}/merge_mean/allSubj_${h}_GCOR_SAME_merged_noTin.mgz
done

# Merge GCOR --ACROSS hemisphere
for h in ${hemi[@]}; do
		# Initialize subjects string
		tin_subjects=""
		noTin_subjects=""

		# Generate subjects string
		for s in ${subj[@]}; do
			if [[ $s == *"TT"* ]]; then
				tin_subjects+="'${GCOR_path}/${s}/${s}_GCOR_ACROSS_${h}.mgz',"
			elif [[ $s == *"NT"* ]]; then
				noTin_subjects+="'${GCOR_path}/${s}/${s}_GCOR_ACROSS_${h}.mgz',"
			fi
		done

		# Remove the trailing comma
		tin_subjects=${tin_subjects%?}
		noTin_subjects=${noTin_subjects%?}

		# Merge all subjects
		if [[ ! -z $tin_subjects ]]; then
			matlab -batch "fsmerge(${tin_subjects},'${GCOR_path}/merge_mean/allSubj_${h}_GCOR_ACROSS_merged_tin.mgz','t')" -nojvm
		fi
		if [[ ! -z $noTin_subjects ]]; then
			matlab -batch "fsmerge(${noTin_subjects},'${GCOR_path}/merge_mean/allSubj_${h}_GCOR_ACROSS_merged_noTin.mgz','t')" -nojvm
		fi

		# Then calculate the mean out of the merged image
		matlab -batch "fsmaths('${GCOR_path}/merge_mean/allSubj_${h}_GCOR_ACROSS_merged_tin.mgz','Tmean','${GCOR_path}/merge_mean/allSubj_${h}_GCOR_ACROSS_merged_mean_tin.mgz')" -nojvm

		# Then calculate the mean out of the merged image
		matlab -batch "fsmaths('${GCOR_path}/merge_mean/allSubj_${h}_GCOR_ACROSS_merged_noTin.mgz','Tmean','${GCOR_path}/merge_mean/allSubj_${h}_GCOR_ACROSS_merged_mean_noTin.mgz')" -nojvm

		# Remove the merged image
		rm ${GCOR_path}/merge_mean/allSubj_${h}_GCOR_ACROSS_merged_tin.mgz
		rm ${GCOR_path}/merge_mean/allSubj_${h}_GCOR_ACROSS_merged_noTin.mgz
done


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

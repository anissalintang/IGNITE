#!/bin/bash

# create ALFF merged_mean images before calculate stimEffect

proj_path="/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/projected/nonSmoothed/filt_0.01-0.1"
alff_path="/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ALFFall"
	
hemi=(lh rh)

subj=($(ls /Volumes/gdrive4tb/IGNITE/sparse_rest/preprocessed))
# subj=(IGNTBP_00072 IGNTBR_00075)

# ======================================================================= #
# Calculate average from all subjects for each conditions and hemispheres
mkdir -p "/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ALFFall/merge_mean"

# Merge ALFF - NON SMOOTHED
for h in ${hemi[@]}; do
		# Initialize subjects/conditions string
		tin=""
		noTin=""

		# Generate subjects string
		for s in ${subj[@]}; do
			if [[ $s == *"TT"* ]]; then
				files=($(ls ${alff_path}/${s}))
				for f in ${files[@]}; do
						tin+="'${alff_path}/${s}/${s}_${h}_ALFFall.mgz',"
					
				done
			elif [[ $s == *"NT"* ]]; then
				files=($(ls ${alff_path}/${s}))
				for f in ${files[@]}; do
						noTin+="'${alff_path}/${s}/${s}_${h}_ALFFall.mgz',"
				done
			fi
		done

		# Remove the trailing comma
		tin=${tin%?}
		noTin=${noTin%?}

		# Merge all subjects per conditions
		if [[ ! -z $tin ]]; then
			matlab -batch "fsmerge(${tin},'${alff_path}/merge_mean/allSubj_${h}_ALFFall_merged_tin.mgz','t')" -nojvm
		fi

		if [[ ! -z $noTin ]]; then
			matlab -batch "fsmerge(${noTin},'${alff_path}/merge_mean/allSubj_${h}_ALFFall_merged_noTin.mgz','t')" -nojvm
		fi

		# Then calculate the mean out of the merged image
		matlab -batch "fsmaths('${alff_path}/merge_mean/allSubj_${h}_ALFFall_merged_tin.mgz','Tmean','${alff_path}/merge_mean/allSubj_${h}_ALFFall_merged_mean_tin.mgz')" -nojvm

		# Then calculate the mean out of the merged image
		matlab -batch "fsmaths('${alff_path}/merge_mean/allSubj_${h}_ALFFall_merged_noTin.mgz','Tmean','${alff_path}/merge_mean/allSubj_${h}_ALFFall_merged_mean_noTin.mgz')" -nojvm


		# Remove the merged image
		rm ${alff_path}/merge_mean/allSubj_${h}_ALFFall_merged_tin.mgz
		rm ${alff_path}/merge_mean/allSubj_${h}_ALFFall_merged_noTin.mgz
done


# ======================================================================= #
# SMOOTHED
fwhm=5

fs_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface"

export SUBJECTS_DIR="${fs_path}/recon"

for s in ${subj[@]}; do
	for h in ${hemi[@]}; do
			mri_surf2surf \
			--sval ${alff_path}/${s}/${s}_${h}_ALFFall.mgz \
			--tval ${alff_path}/${s}/${s}_${h}_ALFFall_smooth5.mgz \
			--srcsubject fsaverage \
			--trgsubject fsaverage \
			--hemi ${h} \
			--fwhm $fwhm \
			--label-src $SUBJECTS_DIR/fsaverage/label/${h}.cortex.label
	done
done

# Merge ALFF - SMOOTHED
for h in ${hemi[@]}; do
		# Initialize subjects/conditions string
		tin=""
		noTin=""

		# Generate subjects string
		for s in ${subj[@]}; do
			if [[ $s == *"TT"* ]]; then
				files=($(ls ${alff_path}/${s}))
				for f in ${files[@]}; do
						tin+="'${alff_path}/${s}/${s}_${h}_ALFFall_smooth5.mgz',"
					
				done
			elif [[ $s == *"NT"* ]]; then
				files=($(ls ${alff_path}/${s}))
				for f in ${files[@]}; do
						noTin+="'${alff_path}/${s}/${s}_${h}_ALFFall_smooth5.mgz',"
				done
			fi
		done

		# Remove the trailing comma
		tin=${tin%?}
		noTin=${noTin%?}

		# Merge all subjects per conditions
		if [[ ! -z $tin ]]; then
			matlab -batch "fsmerge(${tin},'${alff_path}/merge_mean/allSubj_${h}_ALFFall_merged_tin_smooth5.mgz','t')" -nojvm
		fi

		if [[ ! -z $noTin ]]; then
			matlab -batch "fsmerge(${noTin},'${alff_path}/merge_mean/allSubj_${h}_ALFFall_merged_noTin_smooth5.mgz','t')" -nojvm
		fi

		# Then calculate the mean out of the merged image
		matlab -batch "fsmaths('${alff_path}/merge_mean/allSubj_${h}_ALFFall_merged_tin_smooth5.mgz','Tmean','${alff_path}/merge_mean/allSubj_${h}_ALFFall_merged_mean_tin_smooth5.mgz')" -nojvm

		# Then calculate the mean out of the merged image
		matlab -batch "fsmaths('${alff_path}/merge_mean/allSubj_${h}_ALFFall_merged_noTin_smooth5.mgz','Tmean','${alff_path}/merge_mean/allSubj_${h}_ALFFall_merged_mean_noTin_smooth5.mgz')" -nojvm


		# Remove the merged image
		rm ${alff_path}/merge_mean/allSubj_${h}_ALFFall_merged_tin_smooth5.mgz
		rm ${alff_path}/merge_mean/allSubj_${h}_ALFFall_merged_noTin_smooth5.mgz
done

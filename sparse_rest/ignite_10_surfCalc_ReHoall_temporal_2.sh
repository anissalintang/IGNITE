#!/bin/bash

# create ReHoall merged_mean images before calculate stimEffect

proj_path="/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/projected/nonSmoothed/filt_0.01-0.1"
reho_path="/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ReHoall/temporal/"
	
hemi=(lh rh)

subj=($(ls /Volumes/gdrive4tb/IGNITE/sparse_rest/preprocessed))
# subj=(IGNTBP_00072 IGNTBR_00075)

# # ======================================================================= #
# # Calculate average from all subjects for each hemispheres
mkdir -p "/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ReHoall/temporal/merge_mean"


# ======================================================================= #
# SMOOTHED
fwhm=5

fs_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface"

export SUBJECTS_DIR="${fs_path}/recon"

for s in ${subj[@]}; do
	for h in ${hemi[@]}; do
			mri_surf2surf \
			--sval ${reho_path}/${s}/${s}_ReHoall_${h}_temporal.mgz \
			--tval ${reho_path}/${s}/${s}_ReHoall_${h}_temporal_smooth5.mgz \
			--srcsubject fsaverage \
			--trgsubject fsaverage \
			--hemi ${h} \
			--fwhm $fwhm \
			--label-src $SUBJECTS_DIR/fsaverage/label/${h}.cortex.label

	done
done

# Merge ReHoall - SMOOTHED
for h in ${hemi[@]}; do
		# Initialize subjects string
		tin=""

		noTin=""

		# Generate subjects string
		for s in ${subj[@]}; do
			if [[ $s == *"TT"* ]]; then
				files=($(ls ${reho_path}/${s}))
				for f in ${files[@]}; do
						tin+="'${reho_path}/${s}/${s}_ReHoall_${h}_temporal_smooth5.mgz',"

				done
			elif [[ $s == *"NT"* ]]; then
				files=($(ls ${reho_path}/${s}))
				for f in ${files[@]}; do
						noTin+="'${reho_path}/${s}/${s}_ReHoall_${h}_temporal_smooth5.mgz',"
				done
			fi
		done

		# Remove the trailing comma
		tin=${tin%?}

		noTin=${noTin%?}

		# Merge all subjects 
		if [[ ! -z $tin ]]; then
			matlab -batch "fsmerge(${tin},'${reho_path}/merge_mean/allSubj_${h}_ReHoall_merged_tin_smooth5.mgz','t')" -nojvm
		fi

		if [[ ! -z $noTin ]]; then
			matlab -batch "fsmerge(${noTin},'${reho_path}/merge_mean/allSubj_${h}_ReHoall_merged_noTin_smooth5.mgz','t')" -nojvm
		fi

		# Then calculate the mean out of the merged image
		matlab -batch "fsmaths('${reho_path}/merge_mean/allSubj_${h}_ReHoall_merged_tin_smooth5.mgz','Tmean','${reho_path}/merge_mean/allSubj_${h}_ReHoall_merged_mean_tin_smooth5.mgz')" -nojvm


		# Then calculate the mean out of the merged image
		matlab -batch "fsmaths('${reho_path}/merge_mean/allSubj_${h}_ReHoall_merged_noTin_smooth5.mgz','Tmean','${reho_path}/merge_mean/allSubj_${h}_ReHoall_merged_mean_noTin_smooth5.mgz')" -nojvm

		# Remove the merged image
		rm ${reho_path}/merge_mean/allSubj_${h}_ReHoall_merged_tin_smooth5.mgz
		rm ${reho_path}/merge_mean/allSubj_${h}_ReHoall_merged_noTin_smooth5.mgz
done
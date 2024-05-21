#!/bin/bash

# create ReCovall merged_mean images before calculate stimEffect

proj_path="/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/projected/nonSmoothed/filt_0.01-0.1"
recov_path="/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ReCovall/temporal/"
	
hemi=(lh rh)

subj=($(ls /Volumes/gdrive4tb/IGNITE/sparse_rest/preprocessed))
# subj=(IGNTBP_00072 IGNTBR_00075)

# # ======================================================================= #
# # Calculate average from all subjects for each hemispheres
mkdir -p "/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ReCovall/temporal/merge_mean"


# ======================================================================= #
# SMOOTHED
fwhm=5

fs_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface"

export SUBJECTS_DIR="${fs_path}/recon"

for s in ${subj[@]}; do
	for h in ${hemi[@]}; do
			mri_surf2surf \
			--sval ${recov_path}/${s}/${s}_ReCovall_${h}_temporal.mgz \
			--tval ${recov_path}/${s}/${s}_ReCovall_${h}_temporal_smooth5.mgz \
			--srcsubject fsaverage \
			--trgsubject fsaverage \
			--hemi ${h} \
			--fwhm $fwhm \
			--label-src $SUBJECTS_DIR/fsaverage/label/${h}.cortex.label

	done
done

# Merge ReCovall - SMOOTHED
for h in ${hemi[@]}; do
		# Initialize subjects string
		tin=""

		noTin=""

		# Generate subjects string
		for s in ${subj[@]}; do
			if [[ $s == *"TT"* ]]; then
				files=($(ls ${recov_path}/${s}))
				for f in ${files[@]}; do
						tin+="'${recov_path}/${s}/${s}_ReCovall_${h}_temporal_smooth5.mgz',"

				done
			elif [[ $s == *"NT"* ]]; then
				files=($(ls ${recov_path}/${s}))
				for f in ${files[@]}; do
						noTin+="'${recov_path}/${s}/${s}_ReCovall_${h}_temporal_smooth5.mgz',"
				done
			fi
		done

		# Remove the trailing comma
		tin=${tin%?}

		noTin=${noTin%?}

		# Merge all subjects 
		if [[ ! -z $tin ]]; then
			matlab -batch "fsmerge(${tin},'${recov_path}/merge_mean/allSubj_${h}_ReCovall_merged_tin_smooth5.mgz','t')" -nojvm
		fi

		if [[ ! -z $noTin ]]; then
			matlab -batch "fsmerge(${noTin},'${recov_path}/merge_mean/allSubj_${h}_ReCovall_merged_noTin_smooth5.mgz','t')" -nojvm
		fi

		# Then calculate the mean out of the merged image
		matlab -batch "fsmaths('${recov_path}/merge_mean/allSubj_${h}_ReCovall_merged_tin_smooth5.mgz','Tmean','${recov_path}/merge_mean/allSubj_${h}_ReCovall_merged_mean_tin_smooth5.mgz')" -nojvm


		# Then calculate the mean out of the merged image
		matlab -batch "fsmaths('${recov_path}/merge_mean/allSubj_${h}_ReCovall_merged_noTin_smooth5.mgz','Tmean','${recov_path}/merge_mean/allSubj_${h}_ReCovall_merged_mean_noTin_smooth5.mgz')" -nojvm

		# Remove the merged image
		rm ${recov_path}/merge_mean/allSubj_${h}_ReCovall_merged_tin_smooth5.mgz
		rm ${recov_path}/merge_mean/allSubj_${h}_ReCovall_merged_noTin_smooth5.mgz
done
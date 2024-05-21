#!/bin/bash

# create ALFF merged_mean images before calculate stimEffect

proj_path="/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/projected/nonSmoothed/filt_0.01-0.1"
alff_path="/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ALFF"
	
hemi=(lh rh)

subj=($(ls /Volumes/gdrive4tb/IGNITE/sparse_rest/preprocessed))
# subj=(IGNTBP_00072 IGNTBR_00075)

# # ======================================================================= #
# # Calculate average from all subjects for each conditions and hemispheres
mkdir -p "/Volumes/gdrive4tb/IGNITE/sparse_rest/surface/analysis/ALFF/merge_mean"

# # Merge ALFF - NON SMOOTHED
# for h in ${hemi[@]}; do
# 		# Initialize subjects/conditions string
# 		tin_rest=""
# 		tin_vis=""

# 		noTin_rest=""
# 		noTin_vis=""

# 		# Generate subjects string
# 		for s in ${subj[@]}; do
# 			if [[ $s == *"TT"* ]]; then
# 				files=($(ls ${alff_path}/${s}))
# 				for f in ${files[@]}; do
# 					if [[ $f == *"${h}_ALFF_rest.mgz" ]]; then
# 						tin_rest+="'${alff_path}/${s}/${s}_${h}_ALFF_rest.mgz',"
						
# 					elif [[ $f == *"${h}_ALFF_vis.mgz" ]]; then
# 						tin_vis+="'${alff_path}/${s}/${s}_${h}_ALFF_vis.mgz',"
						
# 					fi
# 				done
# 			elif [[ $s == *"NT"* ]]; then
# 				files=($(ls ${alff_path}/${s}))
# 				for f in ${files[@]}; do
# 					if [[ $f == *"${h}_ALFF_rest.mgz" ]]; then
# 						noTin_rest+="'${alff_path}/${s}/${s}_${h}_ALFF_rest.mgz',"
						
# 					elif [[ $f == *"${h}_ALFF_vis.mgz" ]]; then
# 						noTin_vis+="'${alff_path}/${s}/${s}_${h}_ALFF_vis.mgz',"
						
# 					fi
# 				done
# 			fi
# 		done

# 		# Remove the trailing comma
# 		tin_rest=${tin_rest%?}
# 		tin_vis=${tin_vis%?}

# 		noTin_rest=${noTin_rest%?}
# 		noTin_vis=${noTin_vis%?}

# 		# Merge all subjects per conditions
# 		if [[ ! -z $tin_rest ]]; then
# 			matlab -batch "fsmerge(${tin_rest},'${alff_path}/merge_mean/allSubj_${h}_ALFF_merged_tin_rest.mgz','t')" -nojvm
# 		fi
# 		if [[ ! -z $tin_vis ]]; then
# 			matlab -batch "fsmerge(${tin_vis},'${alff_path}/merge_mean/allSubj_${h}_ALFF_merged_tin_vis.mgz','t')" -nojvm
# 		fi

# 		if [[ ! -z $noTin_rest ]]; then
# 			matlab -batch "fsmerge(${noTin_rest},'${alff_path}/merge_mean/allSubj_${h}_ALFF_merged_noTin_rest.mgz','t')" -nojvm
# 		fi
# 		if [[ ! -z $noTin_vis ]]; then
# 			matlab -batch "fsmerge(${noTin_vis},'${alff_path}/merge_mean/allSubj_${h}_ALFF_merged_noTin_vis.mgz','t')" -nojvm
# 		fi

# 		# Then calculate the mean out of the merged image
# 		matlab -batch "fsmaths('${alff_path}/merge_mean/allSubj_${h}_ALFF_merged_tin_rest.mgz','Tmean','${alff_path}/merge_mean/allSubj_${h}_ALFF_merged_mean_tin_rest.mgz')" -nojvm

# 		# Then calculate the mean out of the merged image
# 		matlab -batch "fsmaths('${alff_path}/merge_mean/allSubj_${h}_ALFF_merged_tin_vis.mgz','Tmean','${alff_path}/merge_mean/allSubj_${h}_ALFF_merged_mean_tin_vis.mgz')" -nojvm

# 		# Then calculate the mean out of the merged image
# 		matlab -batch "fsmaths('${alff_path}/merge_mean/allSubj_${h}_ALFF_merged_noTin_rest.mgz','Tmean','${alff_path}/merge_mean/allSubj_${h}_ALFF_merged_mean_noTin_rest.mgz')" -nojvm

# 		# Then calculate the mean out of the merged image
# 		matlab -batch "fsmaths('${alff_path}/merge_mean/allSubj_${h}_ALFF_merged_noTin_vis.mgz','Tmean','${alff_path}/merge_mean/allSubj_${h}_ALFF_merged_mean_noTin_vis.mgz')" -nojvm

		# Remove the merged image
		# rm ${alff_path}/merge_mean/allSubj_${h}_ALFF_merged_tin_rest.mgz
		# rm ${alff_path}/merge_mean/allSubj_${h}_ALFF_merged_tin_vis.mgz
		# rm ${alff_path}/merge_mean/allSubj_${h}_ALFF_merged_noTin_rest.mgz
		# rm ${alff_path}/merge_mean/allSubj_${h}_ALFF_merged_noTin_vis.mgz
# done


# ======================================================================= #
# SMOOTHED
fwhm=5
cond=(rest vis)

fs_path="/Volumes/gdrive4tb/IGNITE/resting-state/surface"

export SUBJECTS_DIR="${fs_path}/recon"

for s in ${subj[@]}; do
	for h in ${hemi[@]}; do
		for c in ${cond[@]}; do
			mri_surf2surf \
			--sval ${alff_path}/${s}/${s}_${h}_ALFF_${c}.mgz \
			--tval ${alff_path}/${s}/${s}_${h}_ALFF_${c}_smooth5.mgz \
			--srcsubject fsaverage \
			--trgsubject fsaverage \
			--hemi ${h} \
			--fwhm $fwhm \
			--label-src $SUBJECTS_DIR/fsaverage/label/${h}.cortex.label

		done
	done
done

# Merge ALFF - SMOOTHED
for h in ${hemi[@]}; do
		# Initialize subjects/conditions string
		tin_rest=""
		tin_vis=""

		noTin_rest=""
		noTin_vis=""

		# Generate subjects string
		for s in ${subj[@]}; do
			if [[ $s == *"TT"* ]]; then
				files=($(ls ${alff_path}/${s}))
				for f in ${files[@]}; do
					if [[ $f == *"${h}_ALFF_rest_smooth5.mgz" ]]; then
						tin_rest+="'${alff_path}/${s}/${s}_${h}_ALFF_rest_smooth5.mgz',"
						
					elif [[ $f == *"${h}_ALFF_vis_smooth5.mgz" ]]; then
						tin_vis+="'${alff_path}/${s}/${s}_${h}_ALFF_vis_smooth5.mgz',"
						
					fi
				done
			elif [[ $s == *"NT"* ]]; then
				files=($(ls ${alff_path}/${s}))
				for f in ${files[@]}; do
					if [[ $f == *"${h}_ALFF_rest_smooth5.mgz" ]]; then
						noTin_rest+="'${alff_path}/${s}/${s}_${h}_ALFF_rest_smooth5.mgz',"
						
					elif [[ $f == *"${h}_ALFF_vis_smooth5.mgz" ]]; then
						noTin_vis+="'${alff_path}/${s}/${s}_${h}_ALFF_vis_smooth5.mgz',"
						
					fi
				done
			fi
		done

		# Remove the trailing comma
		tin_rest=${tin_rest%?}
		tin_vis=${tin_vis%?}

		noTin_rest=${noTin_rest%?}
		noTin_vis=${noTin_vis%?}

		# Merge all subjects per conditions
		if [[ ! -z $tin_rest ]]; then
			matlab -batch "fsmerge(${tin_rest},'${alff_path}/merge_mean/allSubj_${h}_ALFF_merged_tin_rest_smooth5.mgz','t')" -nojvm
		fi
		if [[ ! -z $tin_vis ]]; then
			matlab -batch "fsmerge(${tin_vis},'${alff_path}/merge_mean/allSubj_${h}_ALFF_merged_tin_vis_smooth5.mgz','t')" -nojvm
		fi

		if [[ ! -z $noTin_rest ]]; then
			matlab -batch "fsmerge(${noTin_rest},'${alff_path}/merge_mean/allSubj_${h}_ALFF_merged_noTin_rest_smooth5.mgz','t')" -nojvm
		fi
		if [[ ! -z $noTin_vis ]]; then
			matlab -batch "fsmerge(${noTin_vis},'${alff_path}/merge_mean/allSubj_${h}_ALFF_merged_noTin_vis_smooth5.mgz','t')" -nojvm
		fi

		# Then calculate the mean out of the merged image
		matlab -batch "fsmaths('${alff_path}/merge_mean/allSubj_${h}_ALFF_merged_tin_rest_smooth5.mgz','Tmean','${alff_path}/merge_mean/allSubj_${h}_ALFF_merged_mean_tin_rest_smooth5.mgz')" -nojvm

		# Then calculate the mean out of the merged image
		matlab -batch "fsmaths('${alff_path}/merge_mean/allSubj_${h}_ALFF_merged_tin_vis_smooth5.mgz','Tmean','${alff_path}/merge_mean/allSubj_${h}_ALFF_merged_mean_tin_vis_smooth5.mgz')" -nojvm

		# Then calculate the mean out of the merged image
		matlab -batch "fsmaths('${alff_path}/merge_mean/allSubj_${h}_ALFF_merged_noTin_rest_smooth5.mgz','Tmean','${alff_path}/merge_mean/allSubj_${h}_ALFF_merged_mean_noTin_rest_smooth5.mgz')" -nojvm

		# Then calculate the mean out of the merged image
		matlab -batch "fsmaths('${alff_path}/merge_mean/allSubj_${h}_ALFF_merged_noTin_vis_smooth5.mgz','Tmean','${alff_path}/merge_mean/allSubj_${h}_ALFF_merged_mean_noTin_vis_smooth5.mgz')" -nojvm

		# Remove the merged image
		rm ${alff_path}/merge_mean/allSubj_${h}_ALFF_merged_tin_rest_smooth5.mgz
		rm ${alff_path}/merge_mean/allSubj_${h}_ALFF_merged_tin_vis_smooth5.mgz
		rm ${alff_path}/merge_mean/allSubj_${h}_ALFF_merged_noTin_rest_smooth5.mgz
		rm ${alff_path}/merge_mean/allSubj_${h}_ALFF_merged_noTin_vis_smooth5.mgz
done
#!/bin/bash

data_path="/Volumes/gdrive4tb/IGNITE"

mkdir -p "/Volumes/gdrive4tb/IGNITE/tonotopy/log"
log_path="/Volumes/gdrive4tb/IGNITE/tonotopy/log"

# subj=($(ls /Volumes/gdrive4tb/IGNITE/data/nifti))
subj=(IGNTFA_00065)

###############################################################
# Preprocess only if functional data exist!
# if ls ${data_path}/data/nifti/${s}/*final_fMRI_MB2_sparse_tono*.nii* 1> /dev/null 2>&1; then
# This load the complex image data, not the imaginary nor real images
for s in ${subj[@]}; do
	dat_tono=($(ls ${data_path}/data/nifti/${s}/*final_fMRI_MB2_sparse_tono*[^_]*.nii* | head -n 1))

	echo "data = ${dat_tono[@]}"

	if [ -n "$dat_tono" ]; then

		#Make directories for the preprocessing files
		mkdir -p ${data_path}/tonotopy/preprocessed/$s
		analysis_path="/Volumes/gdrive4tb/IGNITE/tonotopy"

		cp $dat_tono ${analysis_path}/preprocessed/$s/${s}_sparse_tono_orig.nii.gz

            # QC NORDIC
            ## Before NORDIC(orig image)
            fslmaths ${analysis_path}/preprocessed/$s/${s}_sparse_tono_orig.nii.gz -Tmean ${analysis_path}/preprocessed/$s/mean_before.nii.gz
            fslmaths ${analysis_path}/preprocessed/$s/${s}_sparse_tono_orig.nii.gz -Tstd ${analysis_path}/preprocessed/$s/std_before.nii.gz
            fslmaths ${analysis_path}/preprocessed/$s/mean_before.nii.gz -div ${analysis_path}/preprocessed/$s/std_before.nii.gz ${analysis_path}/preprocessed/$s/snr_before.nii.gz
            fslstats ${analysis_path}/preprocessed/$s/snr_before.nii.gz -M >> ${analysis_path}/preprocessed/$s/snr_before.txt


            ## After NORDIC 
            fslmaths ${analysis_path}/preprocessed/$s/${s}_sparse_tono_nordic.nii.gz -Tmean ${analysis_path}/preprocessed/$s/mean_after.nii.gz
            fslmaths ${analysis_path}/preprocessed/$s/${s}_sparse_tono_nordic.nii.gz -Tstd ${analysis_path}/preprocessed/$s/std_after.nii.gz
            fslmaths ${analysis_path}/preprocessed/$s/mean_after.nii.gz -div ${analysis_path}/preprocessed/$s/std_after.nii.gz ${analysis_path}/preprocessed/$s/snr_after.nii.gz
            fslstats ${analysis_path}/preprocessed/$s/snr_after.nii.gz -M >> ${analysis_path}/preprocessed/$s/snr_after.txt

        else
        	echo "Sparse tonotopy image does not exist for ${s}"
	fi

done
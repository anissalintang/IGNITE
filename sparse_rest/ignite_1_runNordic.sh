#!/bin/bash

# The first step of pre-processing is to run NORDIC to lower the termal noise
# ref= https://www.nature.com/articles/s41467-021-25431-8
# Moeller 2021
data_path="/Volumes/gdrive4tb/IGNITE"

mkdir -p "/Volumes/gdrive4tb/IGNITE/sparse_rest/log"
log_path="/Volumes/gdrive4tb/IGNITE/sparse_rest/log"

# subj=($(ls /Volumes/gdrive4tb/IGNITE/data/nifti))
subj=(IGTTKA_00017)

###############################################################
# Preprocess only if functional data exist!
# This load the complex image data, not the imaginary nor real images
for s in ${subj[@]}; do
	# dat_rest=($(ls ${data_path}/data/nifti/${s}/*final_fMRI_MB2_sparse_rest*[^_]*.nii* | head -n 1))
    # dat_rest_j=($(ls ${data_path}/data/nifti/${s}/*final_fMRI_MB2_sparse_rest*[^_]*.json | head -n 1))
    # dat_rest_pe0=($(ls ${data_path}/data/nifti/${s}/*final_fMRI_MB2_sparse_pepolar_0_te35*[^_]*.nii* | head -n 1))
    # dat_rest_pe0_j=($(ls ${data_path}/data/nifti/${s}/*final_fMRI_MB2_sparse_pepolar_0_te35*[^_]*.json | head -n 1))
    # dat_rest_pe1=($(ls ${data_path}/data/nifti/${s}/*final_fMRI_MB2_sparse_pepolar1*[^_]*.nii* | head -n 1))
    # dat_rest_pe1_j=($(ls ${data_path}/data/nifti/${s}/*final_fMRI_MB2_sparse_pepolar1*[^_]*.json | head -n 1))

	# if [ -n "$dat_rest" ]; then

		#Make directories for the preprocessing files
		# mkdir -p ${data_path}/sparse_rest/preprocessed/$s
		analysis_path="/Volumes/gdrive4tb/IGNITE/sparse_rest"

        # # Copying all the necessary files
		# cp $dat_rest ${analysis_path}/preprocessed/$s/${s}_sparse_rest_orig.nii.gz
        # cp $dat_rest_j ${analysis_path}/preprocessed/$s/${s}_sparse_rest_orig.json

        # cp $dat_rest_pe0 ${analysis_path}/preprocessed/$s/${s}_sparse_rest_pe0.nii.gz
        # cp $dat_rest_pe0_j ${analysis_path}/preprocessed/$s/${s}_sparse_rest_pe0.json

        # cp $dat_rest_pe1 ${analysis_path}/preprocessed/$s/${s}_sparse_rest_pe1.nii.gz
        # cp $dat_rest_pe1_j ${analysis_path}/preprocessed/$s/${s}_sparse_rest_pe1.json


		##############################################################
        files=($(ls ${analysis_path}/preprocessed/$s/${s}_sparse_rest_orig.nii.gz))
		
		echo "FILES = ${files[@]}"

 		for file in ${files[@]}; do
                matlab -batch "ARG = struct; \
                ARG.DIROUT = '${analysis_path}/preprocessed/${s}/'; \
                ARG.full_dynamic_range = 1; \
                ARG.magnitude_only = 1; \
                ARG.MP = 2; \
                NIFTI_NORDIC('$file',[],'${s}_sparse_rest_nordic',ARG)" -nojvm

        done

    # else
    #     echo "Sparse rest image does not exist for ${s}"
	# fi

done